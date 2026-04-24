# T38 Proof Summary

**Task:** FIX-REVIEW-38 — parse-frontmatter.sh temp filename collision and path injection
**Category:** B (Security — path-handling, low-severity but actionable)
**Status:** COMPLETED
**Executed:** 2026-04-24

## Issue

`scripts/parse-frontmatter.sh:142` (pre-fix line number) derived a temp filename using:

```bash
fm_file="$WORK_DIR/$(basename "$(dirname "$file")").yaml"
```

Two input files sharing the same parent directory name (e.g., `foo/arc-capture/SKILL.md`
and `bar/arc-capture/SKILL.md`) both mapped to `$WORK_DIR/arc-capture.yaml`, causing the
second write to silently overwrite the first. Additionally, special characters in `$file`
could flow uncontrolled into the temp path.

## Fix Applied

Replaced the collision-prone derivation with a SHA-256 hash of the full input path,
taking the first 12 hex characters as a unique, safe suffix:

```bash
fm_file="$WORK_DIR/fm-$(printf '%s' "$file" | sha256sum | cut -c1-12).yaml"
```

- **Unique**: SHA-256 of the full path is unique per distinct path.
- **Safe**: `sha256sum` output is strictly `[0-9a-f]`, no shell-special characters.
- **No injection risk**: `$file` is passed to `printf '%s'` on stdin — never interpolated
  into the filename itself.

## Proof Artifacts

| # | File | Type | Status | Summary |
|---|------|------|--------|---------|
| 1 | `T38-01-shellcheck.txt` | cli | PASS | `shellcheck --severity=style` returns exit 0, no warnings. |
| 2 | `T38-02-collision-test.txt` | test | PASS | Two inputs sharing parent dir name "arc-capture" both produce output — no silent overwrite. |
| 3 | `T38-03-live-run.txt` | cli | PASS | Live repo: all 9 arc-* skills parsed correctly, exit 0. |

## Acceptance Criteria

- [x] ShellCheck clean at `--severity=style` post-fix
- [x] Two inputs with same parent-dir name both appear in output (no collision)
- [x] Special characters in path cannot influence temp filename
- [x] Live repo behavior unchanged (all 9 skills emitted)
- [x] Only `scripts/parse-frontmatter.sh` modified

## Verification Commands

```bash
# ShellCheck
shellcheck --severity=style scripts/parse-frontmatter.sh

# Collision test (requires test fixtures)
bash scripts/parse-frontmatter.sh --format json \
  /tmp/collision-test/foo/arc-capture/SKILL.md \
  /tmp/collision-test/bar/arc-capture/SKILL.md | jq keys

# Live run
bash scripts/parse-frontmatter.sh --format json | jq keys
```
