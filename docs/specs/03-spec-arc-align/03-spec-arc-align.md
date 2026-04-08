# 03-spec-arc-align

## Introduction/Overview

`/arc-align` is a codebase discovery and migration skill that scans a project for product-direction content scattered outside Arc's managed artifacts — roadmap entries, backlog items, TODO lists, feature plans, vision statements, and persona descriptions — then automatically imports them into `docs/BACKLOG.md`, `docs/VISION.md`, and `docs/CUSTOMER.md`. The goal is to consolidate all product-direction content under Arc's governance so that `/arc-shape`, `/arc-wave`, and `/arc-review` operate on a complete picture.

## Goals

1. Discover all product-direction content in a codebase that is not already managed by Arc
2. Automatically import discovered items as captured stubs into the appropriate Arc artifact (BACKLOG, VISION, CUSTOMER)
3. Delete original sources after successful import to eliminate drift between Arc-managed and unmanaged content
4. Maintain a manifest that tracks source→artifact mappings for idempotent re-runs
5. Produce a verbose summary report showing what was imported, what was skipped, and what was left behind

## User Stories

- As a product owner adopting Arc on an existing project, I want to consolidate scattered roadmap and backlog content into Arc's managed artifacts so that `/arc-review` audits the full picture.
- As a developer who has been tracking TODOs in README files, I want those items migrated into `docs/BACKLOG.md` as captured stubs so they enter the idea lifecycle.
- As a team lead, I want confidence that running `/arc-align` twice doesn't create duplicate entries so that the migration is safe to re-run after adding new content.

## Demoable Units of Work

### Unit 1: Codebase Discovery Engine

**Purpose:** Scan the codebase for product-direction content that is not managed by Arc, applying smart exclusions and presenting a confirmation step for path filtering.

**Functional Requirements:**

- The system shall apply hardcoded exclusion defaults: `.git/`, `node_modules/`, `vendor/`, `dist/`, `build/`, `docs/specs/`, and all Arc-managed files (`docs/BACKLOG.md`, `docs/ROADMAP.md`, `docs/VISION.md`, `docs/CUSTOMER.md`, `docs/wave-report.md`, `docs/review-report.md`, `docs/shape-report.md`, `docs/align-manifest.md`)
- The system shall run a quick directory scan to identify folders with unusually large file counts (>100 files) and recommend them for exclusion
- The system shall present all recommended exclusions (defaults + large directories) to the user via AskUserQuestion with multi-select, plus an option to add custom exclude patterns
- The system shall search remaining files for product-direction content using two detection strategies:
  - **Keyword matching:** Files or sections containing terms: `roadmap`, `backlog`, `todo`, `planned`, `upcoming`, `feature list`, `future work`, `next steps`, `milestone`, `sprint`, `epic`, `user story`, `persona`, `target audience`, `mission`, `vision`, `north star`
  - **Structural matching:** Markdown task lists (`- [ ]`), numbered feature lists (sequential `1. Feature...` blocks), heading patterns (`## Roadmap`, `## TODO`, `## Planned Features`, `## Backlog`), and kanban-style markers (`### To Do`, `### In Progress`, `### Done`)
- The system shall classify each discovery into one of three artifact targets: `BACKLOG` (actionable items — TODOs, features, bugs, ideas), `VISION` (mission/vision/north-star content), or `CUSTOMER` (persona/audience/JTBD content)
- The system shall read `docs/align-manifest.md` (if present) and skip any source locations that were already imported in a prior run
- The system shall produce a structured discovery list: for each match, record the source file path, line range, matched content snippet, detection method (keyword or structural), and target artifact

**Proof Artifacts:**

- Test: Running `/arc-align` on a repo with scattered TODOs, a README roadmap section, and a `PERSONAS.md` file produces a discovery list with correct artifact classifications
- File: `docs/align-manifest.md` is created or updated with source→artifact mappings after import

### Unit 2: Automatic Import and Artifact Population

**Purpose:** Import all discovered items into the appropriate Arc artifacts as captured stubs, create missing artifacts from templates, and delete original sources.

**Functional Requirements:**

- The system shall ensure `docs/BACKLOG.md` exists before importing (create from `templates/BACKLOG.tmpl.md` if absent, following the same bootstrap logic as `/arc-capture`)
- The system shall ensure `docs/VISION.md` exists before importing VISION-classified content (create from `templates/VISION.tmpl.md` if absent)
- The system shall ensure `docs/CUSTOMER.md` exists before importing CUSTOMER-classified content (create from `templates/CUSTOMER.tmpl.md` if absent)
- For BACKLOG-targeted discoveries, the system shall create one captured stub per discovered item with:
  - Title derived from the source heading, task list text, or first meaningful line
  - One-line summary extracted or synthesized from the surrounding context
  - Priority defaulting to `P2-Medium`
  - Status set to `captured`
  - Captured timestamp set to current ISO 8601 time
  - A `<!-- aligned-from: {source_path}:{line_range} -->` comment for traceability
- For VISION-targeted discoveries, the system shall append the discovered content to `docs/VISION.md` under a `## Imported Content` section with source attribution
- For CUSTOMER-targeted discoveries, the system shall append discovered persona or audience content to `docs/CUSTOMER.md` under a `## Imported Content` section with source attribution
- The system shall be inclusive at import time — when in doubt about whether content is product-direction, import it as a captured stub rather than skip it
- After all imports succeed, the system shall delete the original content:
  - If the entire file is product-direction content: delete the file
  - If only a section of a file is product-direction content: remove that section from the file, preserving surrounding content
- The system shall update `docs/align-manifest.md` with a row per import: source path, line range, target artifact, imported title, and timestamp
- The system shall update the BACKLOG summary table with new rows for all imported ideas

**Proof Artifacts:**

- File: `docs/BACKLOG.md` contains imported captured stubs with `<!-- aligned-from: ... -->` markers
- File: `docs/align-manifest.md` contains source→artifact mapping rows for all imports
- CLI: Original source files/sections are deleted after import (verified by grep for original content)

### Unit 3: Alignment Report

**Purpose:** Generate a verbose summary report showing what was imported, what was skipped, and what remains unmanaged.

**Functional Requirements:**

- The system shall generate `docs/align-report.md` after every run with the following sections:
  - **Run metadata:** Timestamp, exclusion patterns applied, total files scanned, total discoveries
  - **Imported items by artifact:** Grouped by target (BACKLOG, VISION, CUSTOMER), showing source path, imported title, and detection method
  - **Skipped items:** Items found in the manifest from prior runs (already imported), with source path and original import date
  - **Unmatched exclusions:** Files/directories that were excluded from scanning, so the user knows what wasn't checked
  - **Remaining unmanaged content:** Any product-direction-like content that was detected but fell below confidence thresholds or was ambiguous, with source path and snippet so the user can manually review
- The system shall present the report summary inline to the user after the run completes, highlighting:
  - Count of items imported per artifact
  - Count of items skipped (already in manifest)
  - Count of items left behind (below threshold)
  - Any files that were deleted vs. sections that were trimmed
- The system shall offer next steps after presenting the report

**Proof Artifacts:**

- File: `docs/align-report.md` exists and contains all required sections after a run
- CLI: Inline summary shows correct counts matching the report file

### Unit 4: SKILL.md and Plugin Integration

**Purpose:** Create the `/arc-align` skill definition following Arc's established patterns, update plugin metadata, and integrate into the README and skills directory.

**Functional Requirements:**

- The system shall create `skills/arc-align/SKILL.md` with the standard Arc SKILL.md frontmatter (`name`, `description`, `user-invocable: true`, `allowed-tools`) and the full process protocol
- The system shall create `skills/arc-align/references/detection-patterns.md` documenting all keyword and structural patterns with examples
- The system shall create `skills/arc-align/references/import-rules.md` documenting the artifact classification rules, stub generation logic, and cleanup behavior
- The system shall update `.claude-plugin/plugin.json` to include `arc-align` in the skills list and bump the patch version
- The system shall update `README.md` to add `/arc-align` to the skills table, pipeline diagram, and relationship section
- The system shall update `skills/README.md` (if present) to include `/arc-align`

**Proof Artifacts:**

- File: `skills/arc-align/SKILL.md` exists with valid frontmatter and complete process protocol
- File: `skills/arc-align/references/detection-patterns.md` documents all scan patterns
- File: `skills/arc-align/references/import-rules.md` documents classification and import logic
- File: `.claude-plugin/plugin.json` includes `arc-align` and has an incremented version
- File: `README.md` references `/arc-align` in the skills table and pipeline diagram

## Non-Goals (Out of Scope)

- **Shaping imported items** — `/arc-align` only captures stubs; refining happens via `/arc-shape`
- **Wave assignment** — imported items are unassigned; `/arc-wave` handles wave planning
- **External issue tracker import** — this skill scans local files only, not GitHub Issues, Linear, Jira, etc.
- **Merge conflict resolution** — if BACKLOG.md has concurrent edits, the user resolves conflicts manually
- **Automatic priority inference** — all imported items default to P2-Medium; the user adjusts priorities after import
- **Scanning binary files** — only text/markdown files are scanned

## Design Considerations

- The AskUserQuestion flow for exclusion patterns should be a single multi-select with smart defaults pre-checked, plus an "Add custom patterns" option — minimize friction before the scan starts
- The inline summary should be structured as a markdown table for scannability
- The alignment report should use the same Liatrio brand colors in any Mermaid diagrams (consistent with other Arc reports)

## Repository Standards

- SKILL.md frontmatter format: match `arc-capture/SKILL.md` exactly (name, description, user-invocable, allowed-tools)
- Process steps: numbered steps with AskUserQuestion for user interactions, following arc-review's pattern
- Reference docs: stored in `skills/arc-align/references/` following arc-shape and arc-wave conventions
- Conventional commits: `feat(arc-align): ...` for new files, `docs(arc-align): ...` for documentation
- Marker comments: `<!-- aligned-from: ... -->` follows the pattern of `<!-- stale: reviewed ... -->` in arc-review

## Technical Considerations

- **Detection ordering:** Keyword matches are fast (Grep tool); structural matches require line-by-line parsing (Read tool). Run keyword scan first, then structural scan on non-excluded files, to minimize file reads.
- **Section extraction:** When a file contains both product-direction and non-product-direction content, the skill must identify section boundaries (markdown headings, blank-line separators) to extract only the relevant portion.
- **Large repositories:** The exclusion pre-scan (directory file counts) prevents the skill from grinding through `node_modules`-scale directories. The exclusion confirmation step is the primary safeguard.
- **Manifest format:** `docs/align-manifest.md` uses a markdown table with columns: Source Path, Line Range, Target Artifact, Imported Title, Timestamp. This keeps it human-readable and diffable.
- **Allowed tools:** `Glob, Grep, Read, Write, Edit, AskUserQuestion` — matches the pattern of arc-review (no Agent needed since scanning is sequential, not parallel-dimension analysis)

## Security Considerations

- The skill reads and deletes files within the working directory only — no external network access
- The skill should not scan or import files that contain secrets (`.env`, `credentials.json`, `*.key`). Add these to the hardcoded exclusion list.
- The `<!-- aligned-from: ... -->` markers expose source file paths in BACKLOG.md — this is acceptable for internal repos but should be noted in the reference docs

## Success Metrics

- Running `/arc-align` on a repo with 5+ scattered product-direction files results in all items consolidated into Arc artifacts
- Re-running `/arc-align` after a successful run produces zero new imports (idempotent)
- Original source content is fully removed after import (no drift between managed and unmanaged)
- The alignment report accurately reflects what was imported, skipped, and left behind
- The skill integrates cleanly into the Arc plugin with no broken cross-references

## Open Questions

- No open questions at this time.
