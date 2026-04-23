# T13 Proof Summary — T02.3: Implement scripts/parse-frontmatter.sh (Mermaid + JSON output)

**Task:** T02.3 — Create `scripts/parse-frontmatter.sh` that reads all nine
`skills/arc-*/SKILL.md` frontmatters and emits a dependency graph as either
Mermaid markdown (`--format mermaid`) or structured JSON (`--format json`).
Script must be executable, non-interactive, `exit 0` on success, `exit 1` on
parse error. Mermaid output must stay under 50 lines so it renders in GitHub
preview, use Arc's Liatrio theme (see `templates/VISION.tmpl.md`), and target
every skill that declares a sibling in `consumes.from`.

**Status:** PASS

## Proof Artifacts

| File | Type | Status | What it shows |
|------|------|--------|---------------|
| `T13-01-cli-errors.txt` | cli (flag parser + error paths) | PASS | Transcripts for every documented exit-1 path plus the warn-but-continue behaviour for missing files. |
| `T13-02-acceptance.txt` | cli (acceptance-criteria matrix) | PASS | Structured assertions against the `frontmatter-contract-layer.feature` scenarios for both formats, plus captured Mermaid + JSON output. |

## What Was Implemented

Added a new executable script at `scripts/parse-frontmatter.sh`. It:

1. Parses a single `--format` flag (`mermaid` or `json`) plus zero-or-more
   SKILL.md paths. When no paths are supplied it defaults to every
   `skills/arc-*/SKILL.md` under the repo root.
2. Extracts the first YAML frontmatter block from each file with POSIX `awk`,
   then converts it to JSON via `mikefarah/yq` v4.
3. Normalises each entry to the four contract fields (`requires`, `produces`,
   `consumes`, `triggers`), defaulting any missing field to an empty object.
4. For `--format json`, merges every entry into a single JSON document keyed by
   skill name and pretty-prints with `jq`.
5. For `--format mermaid`, emits a fenced `flowchart LR` block:
   - One node per skill (stable three-letter ids: `cap`, `shp`, `wav`, ...).
   - Sibling-to-sibling edges derived from `consumes.from[].skill`.
   - External upstreams (e.g. `/cw-validate`) collapsed into a dashed `ext`
     note so the block stays under 50 lines.
   - The Liatrio theme header from `templates/VISION.tmpl.md`.
6. Fails fast on invalid flags, unknown flags, missing `--format` value,
   missing `yq`/`jq` on `PATH`, python-yq installed instead of mikefarah/yq,
   and malformed frontmatter. Missing input files produce a non-fatal stderr
   warning and do not halt processing of valid inputs.
7. Documents `yq` install hints (macOS brew, Linux curl, Docker stage) in the
   script header per task requirement.

`shellcheck` clean. `set -euo pipefail` + `trap` cleanup for tempfiles.

### Script surface area

| Invocation | Behaviour |
|---|---|
| `scripts/parse-frontmatter.sh --format mermaid` | 21-line Mermaid block with 9 arc-* nodes + 5 sibling edges + 1 collapsed external edge |
| `scripts/parse-frontmatter.sh --format json` | Single JSON document with 9 keys; every value exposes `requires`/`produces`/`consumes`/`triggers` |
| `scripts/parse-frontmatter.sh --format mermaid skills/arc-capture/SKILL.md` | Single-node graph for the named file |
| `scripts/parse-frontmatter.sh` | exit 1 — `--format is required` |
| `scripts/parse-frontmatter.sh --format xml` | exit 1 — `invalid --format value: xml` |
| `scripts/parse-frontmatter.sh --unknown` | exit 1 — `unknown flag: --unknown` |
| `scripts/parse-frontmatter.sh --format json /tmp/no.md` | stderr warning + exit 0 when other inputs succeed; exit 1 when the only input is malformed |
| `scripts/parse-frontmatter.sh -h` | prints usage header lines |

## Acceptance Criteria Verified

From `frontmatter-contract-layer.feature` and the task scope:

- [x] `--format mermaid` exits 0 — **PASS**
- [x] Mermaid stdout contains a `flowchart` declaration — **PASS**
- [x] Mermaid rendered contains exactly 9 nodes, one per arc skill — **PASS** (9 / 9)
- [x] Every skill with a sibling `consumes.from` entry appears as an edge target — **PASS** (arc-shape, arc-ship, arc-sync, arc-wave all edge targets)
- [x] Mermaid block is 50 lines or fewer — **PASS** (21 lines)
- [x] `--format json` exits 0 — **PASS**
- [x] stdout is a single valid JSON document — **PASS** (round-trips through `jq`)
- [x] JSON has one entry per arc skill keyed by skill name — **PASS** (9 / 9)
- [x] Each JSON entry exposes `requires`, `produces`, `consumes`, `triggers` — **PASS** (9 / 9)
- [x] Script is executable (`mode 0755`) and non-interactive — **PASS**
- [x] Uses Arc's Liatrio Mermaid theme (matches `templates/VISION.tmpl.md`) — **PASS**
- [x] Script header calls out `yq` install hints — **PASS**
- [x] `shellcheck scripts/parse-frontmatter.sh` passes — **PASS**

## Out of Scope (handled by downstream tasks)

- **Artifact capture** at `docs/specs/15-spec-agent-utilization-upgrade/02-proofs/dependency-graph.md`
  and `frontmatter-parse.json` is task T02.4 (#14), which is blocked by this task.
- **`marketplace.json` listing** (#9 T01.3) is unrelated.

## Reproduction

```bash
# Install mikefarah/yq v4 (Linux arm64 example — swap arm64->amd64 for x86_64):
mkdir -p ~/.local/bin
curl -fsSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64 \
  -o ~/.local/bin/yq && chmod +x ~/.local/bin/yq
export PATH="$HOME/.local/bin:$PATH"

# Render Mermaid:
scripts/parse-frontmatter.sh --format mermaid

# Render JSON:
scripts/parse-frontmatter.sh --format json | jq 'keys'
```
