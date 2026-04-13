# 09-spec-command-walkthrough-diagrams

## Introduction/Overview

Arc's three core skills (`/arc-capture`, `/arc-shape`, `/arc-wave`) are documented today as long textual procedures with multiple branches and interactive prompts. New users reading a SKILL.md must scroll through several hundred lines before understanding the shape of a typical session.

This feature adds a **visual walkthrough flowchart** near the top of each core SKILL.md so readers immediately grasp the most common end-to-end experience of invoking that command. Diagrams follow Arc's existing brand styling (teal / orange / navy) and are validated via mermaid-cli in a lint script, guaranteeing every committed fence actually parses.

## Goals

1. Add a mermaid **flowchart** walkthrough of the most common success path to each of the three core SKILL.md files (`arc-capture`, `arc-shape`, `arc-wave`).
2. Place each diagram immediately after the skill's `## Overview` section so it is visible before constraint/process text.
3. Apply Arc's existing brand theme (the `themeVariables` init block used in README.md) for visual consistency across all plugin docs.
4. Provide a `scripts/lint-mermaid.sh` lint artifact that runs `mmdc` against every ```mermaid fence in the repo and exits non-zero on parse failure.
5. Keep each flowchart under ~15 nodes so it remains scannable in a GitHub preview without scrolling.

## User Stories

- As a **new Arc user**, I want to see a visual walkthrough at the top of each skill's SKILL.md so I can understand the command's typical flow before reading the full procedure.
- As a **developer reviewing a SKILL.md change**, I want CI-style local feedback that my mermaid fences parse so I don't ship a broken diagram.
- As a **product owner browsing the repo on GitHub**, I want every diagram to render consistently with the Arc brand so the plugin feels polished.

## Demoable Units of Work

### Unit 1: Mermaid Lint Script and Baseline Sweep

**Purpose:** Establish the validation infrastructure first so Unit 2 can author diagrams against a passing lint. Ensures existing README/reference diagrams still parse after any theme adjustments.

**Functional Requirements:**

- The system shall provide an executable `scripts/lint-mermaid.sh` that uses `set -euo pipefail`.
- The system shall discover every ```mermaid fenced block in `**/*.md` files, excluding `node_modules/`, `.worktrees/`, and `docs/specs/` research directories.
- The system shall extract each fence to a temporary file and pass it to `npx --yes @mermaid-js/mermaid-cli mmdc --parseOnly` (or the equivalent parse-validation flag).
- The script shall report, for each file, the count of fences found and the count that passed parsing.
- The script shall exit with status `0` when every fence parses, and status `1` listing the offending file and fence index when any fence fails.
- The script shall produce clean, silent output on success — one summary line — with no instructional prose.
- The script shall not require any configuration file; all behavior is defined inline.
- Running the script against the current repo (before Unit 2 changes) shall pass, confirming existing README and reference diagrams are valid.

**Proof Artifacts:**

- CLI: `bash scripts/lint-mermaid.sh` on the pre-Unit-2 tree returns exit code `0` with a summary line like `3 files, 4 fences, all valid`.
- CLI: Introducing a deliberately broken fence in a scratch test file and re-running the script returns exit code `1` naming the broken file and fence index.
- File: `scripts/lint-mermaid.sh` exists, is executable (`chmod +x`), and passes `shellcheck`.

---

### Unit 2: Walkthrough Flowcharts in Core SKILL.md Files

**Purpose:** Give readers an immediate visual map of the most common success flow for each of the three core skills, placed early in the file with consistent Arc branding.

**Functional Requirements:**

- The system shall add one ```mermaid flowchart to `skills/arc-capture/SKILL.md`, `skills/arc-shape/SKILL.md`, and `skills/arc-wave/SKILL.md`.
- Each flowchart shall be inserted **immediately after the `## Overview` section** and introduced with a `## Walkthrough` heading.
- Each flowchart shall begin with the same `%%{init: {'theme': 'base', 'themeVariables': {...}}}%%` block currently used in `README.md`, ensuring brand colors (`#11B5A4` teal, `#E8662F` orange, `#1B2A3D` navy) render consistently.
- Each flowchart shall depict the **most common success path only** — not every branch, error state, or retry loop. Alternate paths described in the skill's Process section are intentionally omitted to keep the diagram scannable.
- Each flowchart shall contain **no more than 15 nodes** (including start/end markers) and fit within a standard GitHub markdown preview viewport without horizontal scroll at default zoom.
- The `/arc-capture` flowchart shall depict Path A (inline idea) as the canonical flow: user invokes with inline idea → Claude parses title+summary → single AskUserQuestion for confirmation + priority → append to BACKLOG → confirmation message.
- The `/arc-shape` flowchart shall depict the common shaping flow: select idea → launch 4 parallel subagents → synthesize draft brief → interactive Q&A for gaps → validate → update BACKLOG + write shape report.
- The `/arc-wave` flowchart shall depict the common wave flow: read context → scope assessment → select shaped ideas (multi-select) → gather theme + target → update ROADMAP + BACKLOG → inject ARC:product-context into CLAUDE.md → write wave report.
- Each flowchart shall use `classDef` styles that map node color to semantic role (user input, Claude action, file write, decision) consistent with the existing lifecycle diagrams.
- The `scripts/lint-mermaid.sh` from Unit 1 shall pass against all three modified SKILL.md files.
- The existing textual Process sections in each SKILL.md shall remain unchanged — the flowchart **augments**, it does not replace.

**Proof Artifacts:**

- File: `skills/arc-capture/SKILL.md` contains a `## Walkthrough` heading followed by a ```mermaid fence, located between the `## Overview` and `## Critical Constraints` sections.
- File: `skills/arc-shape/SKILL.md` contains a `## Walkthrough` heading followed by a ```mermaid fence, located between the `## Overview` and `## Critical Constraints` sections.
- File: `skills/arc-wave/SKILL.md` contains a `## Walkthrough` heading followed by a ```mermaid fence, located between the `## Overview` and `## Critical Constraints` sections.
- CLI: `bash scripts/lint-mermaid.sh` exits `0` with a summary that includes counts from the three updated SKILL.md files.
- File: Each flowchart's init block matches the theme block in `README.md` exactly (diffable as a copy-paste).
- Test: `grep -c '^## Walkthrough$' skills/arc-{capture,shape,wave}/SKILL.md` returns `1` for each file.

## Non-Goals (Out of Scope)

- Adding walkthroughs to `/arc-sync`, `/arc-audit`, `/arc-assess`, or `/arc-help` — covered only if later requested.
- Replacing existing textual Process steps with diagrams — the walkthrough is additive.
- Depicting error paths, retry loops, or every AskUserQuestion branch — common success path only.
- Rendering diagrams to committed `.png`/`.svg` files — we rely on GitHub's live mermaid rendering.
- CI integration — the lint script is a local tool; wiring into a pre-commit hook or GitHub Action is a future enhancement.
- Modifying the README.md lifecycle or pipeline diagrams.
- Introducing a Node `package.json` or committing `node_modules`; the lint script uses `npx --yes` so dependencies are fetched on demand.

## Design Considerations

- **Visual consistency:** Reuse the exact `themeVariables` init block from `README.md` (lines 40, 105, 180). Copy-paste equivalence matters — any drift should be caught by a future single-source-of-truth refactor.
- **Placement:** Top of the file (after Overview, before Constraints) so the diagram is the first thing a reader sees after the description.
- **Scannability:** Favor horizontal (`flowchart LR`) layout — matches the existing lifecycle and pipeline diagrams and reduces vertical scroll on GitHub preview.
- **Node labels:** Short imperative phrases (e.g., "Parse title + summary", "Append to BACKLOG") — no sentences.
- **Semantic colors via classDef:** user input → navy; Claude action → teal; file write → orange-ish accent. Match conventions already in `references/idea-lifecycle.md`.

## Repository Standards

- Bash: `set -euo pipefail`, shellcheck-clean (per project CLAUDE.md).
- Markdown: Match existing SKILL.md heading style and spacing (blank line before/after headings, no trailing whitespace).
- Mermaid fences: Use ```mermaid ... ``` (not ~~~). Preserve exact copy of the init block from README.
- Conventional commits: `docs(skills): add walkthrough flowchart to <skill>` and `build(lint): add mermaid-cli lint script`.

## Technical Considerations

- **mmdc invocation:** Use `npx --yes @mermaid-js/mermaid-cli` so no install step is required. The `--parseOnly` flag (or equivalent) validates syntax without rendering PNG/SVG — faster and no Chromium dependency. If `--parseOnly` is unavailable in the current CLI version, fall back to `mmdc -i <input> -o /tmp/out.svg` and discard output.
- **Fence extraction:** Use awk or a small sed pipeline to extract fences; avoid a full markdown parser dependency.
- **Exclusions:** `docs/specs/` is excluded because spec documents may intentionally contain WIP/example mermaid that is not meant to be valid until the spec is implemented.
- **Idempotency:** Re-running the lint script must not create temp files outside `$TMPDIR` and must clean them up with `trap`.
- **Platform:** Script targets macOS zsh (user's environment). Avoid GNU-specific flags (`grep -P`, `sed -i''`).

## Security Considerations

- `npx --yes` will fetch `@mermaid-js/mermaid-cli` from npm on first run — users should be aware this pulls a network dependency. Acceptable: this is a local dev tool, not runtime code. No secrets, tokens, or user data involved.
- No files outside the repo working tree are modified by the lint script.

## Success Metrics

- **Coverage:** 3/3 core SKILL.md files gain a walkthrough flowchart.
- **Validity:** Lint script exits `0` on the updated repo — `100%` of committed mermaid fences parse.
- **Readability:** Each flowchart renders in GitHub preview at default zoom within a single viewport (no horizontal scroll on a 1440-wide window).
- **Brand consistency:** The `themeVariables` init block in all three new flowcharts is byte-identical to the block in README.md.

## Open Questions

- Should the lint script be wired into a pre-commit hook in a follow-up spec? (Deferred — out of scope here.)
- If `@mermaid-js/mermaid-cli --parseOnly` is not supported in the current release, the full-render fallback pulls Chromium (~100MB) via `npx`. Acceptable tradeoff or switch to a lighter `mermaid` Node API call? (Investigate during Unit 1; defer decision to implementation.)
