# T35 Proof Summary

**Task:** FIX-REVIEW-35 — Scripts portability pack (macOS bash 3.2, GNU-only flags, state.sh parser)
**Category:** A (Correctness — portability regression)
**Status:** COMPLETED
**Executed:** 2026-04-24

## Scope

Four scripts hardened to run identically on macOS (bash 3.2, BSD coreutils,
BSD awk) and Linux (bash 4+, GNU coreutils, gawk):

- `scripts/state.sh`
- `scripts/validate-backlog.sh`
- `scripts/validate-brief.sh`
- `scripts/parse-frontmatter.sh`

## Changes Applied

| # | Script                       | Fix                                                                                                 |
|---|------------------------------|-----------------------------------------------------------------------------------------------------|
| 1 | `state.sh:214-233`           | Replaced `mapfile -t` + GNU `find -printf '%T@ %p\n'` with `find -print0` + bash 3.2 read-loop + POSIX `ls -t` sort.                                                |
| 2 | `state.sh:228-246`           | Relaxed verdict parser from exact `PASS\|PENDING\|FAIL` to prefix match (`FAIL*`, `PENDING*`, `PASS*`). Suffixed verdicts ("PENDING - awaiting review", "FAIL (2 issues)") now contribute to precedence. |
| 3 | `state.sh:286-296`           | Replaced GNU `find -printf '%f\n'` with `find -print0` + `while read -d '' ... basename`.         |
| 4 | `validate-backlog.sh:113-130`| Replaced 3-arg `awk match(s, re, arr)` (gawk-only) with portable 2-arg `match()` + `substr()`.    |
| 5 | `validate-backlog.sh:133-303`| Replaced two bash-4 `declare -A` maps with parallel arrays (`TABLE_KEYS`/`TABLE_VALUES`, `SECTION_KEYS`/`SECTION_VALUES`) plus `table_lookup` / `section_lookup` helpers. All callers updated. |
| 6 | `validate-brief.sh:102-118`  | Replaced 3-arg `awk match(s, re, arr)` with 2-arg `match()` + `substr()`.                          |
| 7 | `parse-frontmatter.sh:92-99` | Replaced GNU-only `sort -z` with line-delimited `sort` (safe for newline-free SKILL.md paths).    |

## Out of Scope (owned by other tasks)

- `scripts/validate-roadmap.sh` — owned by task #36 (awk→JSON escaping fix). Untouched.
- `scripts/parse-frontmatter.sh` temp-filename collision — owned by task #38. Untouched.
- `scripts/validate-brief.sh` empty-array detection — owned by task #37. Untouched.

## Proof Artifacts

| # | File                                | Type      | Status | Summary |
|---|-------------------------------------|-----------|--------|---------|
| 1 | `T35-01-shellcheck.txt`             | cli       | PASS   | `shellcheck --severity=style` on all 4 scripts returns 0, no warnings. |
| 2 | `T35-02-state-runtime.txt`          | cli       | PASS   | `state.sh` runs in ~34ms (well under 500ms), exits 0, emits all 6 top-level keys. |
| 3 | `T35-03-prefix-parser.txt`          | test      | PASS   | Synthetic fixtures confirm "PENDING - awaiting review" → PENDING, "FAIL (2 issues)" → FAIL, PASS → PASS, and FAIL > PASS precedence with mixed files. |
| 4 | `T35-04-live-runs.txt`              | cli       | PASS   | All 4 scripts exit 0 on the live repo; output shape unchanged (20 captured, PASS validation, 2 gaps, 9 skills in JSON/mermaid). |
| 5 | `T35-05-portability-grep.txt`       | static    | PASS   | Grep confirms no live `mapfile`/`declare -A`/`find -printf`/`sort -z`/3-arg `match()` remain — all matches are in explanatory comments. Affirmative check: all live `match()` call-sites are 2-arg. |

## Acceptance Criteria

- [x] ShellCheck clean at `--severity=style` post-fix
- [x] All 4 scripts exit 0 on current repo (behavior unchanged on Linux)
- [x] `state.sh` runs in < 500ms (observed: ~34ms)
- [x] Validation-status parser prefix-matches PASS / PENDING / FAIL
- [x] FAIL > PENDING > PASS precedence preserved
- [x] No `mapfile`, `declare -A`, `find -printf`, `sort -z`, or 3-arg `awk match()` in live code
- [x] Scope respected: only the 4 listed scripts modified; no co-owned files touched

## Verification Commands

```bash
shellcheck --severity=style scripts/state.sh scripts/validate-backlog.sh scripts/validate-brief.sh scripts/parse-frontmatter.sh
time scripts/state.sh | jq .validation_status
scripts/validate-backlog.sh
scripts/parse-frontmatter.sh --format json | jq keys
scripts/parse-frontmatter.sh --format mermaid | head -5
```
