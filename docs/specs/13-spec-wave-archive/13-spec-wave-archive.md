# 13-spec-wave-archive

## Introduction/Overview

Arc currently accumulates shipped ideas in `docs/BACKLOG.md` and completed waves in `docs/ROADMAP.md` forever — BACKLOG grows monotonically, and ROADMAP mixes active waves with historical ones. This spec introduces a **wave archive** at `docs/skill/arc/waves/NN-wave-name.md`, moves `/arc-ship` and `/arc-sync` to write/migrate into it, and re-points all downstream readers (status, audit, sync) at the archive as the sole source of truth for shipped work. After this change, BACKLOG carries only `captured | shaped | spec-ready` ideas and ROADMAP lists only active/planned waves — shipped history lives in its own per-wave files.

## Goals

1. Eliminate `shipped` as a BACKLOG status value — shipped ideas are moved to the archive and removed from BACKLOG entirely.
2. Eliminate `Completed` waves from ROADMAP.md — completed waves are archived and removed from the roadmap when their last idea ships.
3. Provide a durable per-wave archive at `docs/skill/arc/waves/NN-wave-name.md` capturing the wave definition + full detail of every idea it delivered.
4. Migrate the 10 existing shipped ideas and 3 existing completed waves into the new archive format via `/arc-sync` on first run after upgrade.
5. Re-point `/arc-status`, `/arc-audit`, and `/arc-sync` readers at the archive so the `shipped` count, README `ARC:features` list, and lifecycle diagram all derive from `docs/skill/arc/waves/`.

## User Stories

- As a Product Owner, I want BACKLOG.md to show only active work (captured, shaped, spec-ready) so the file stays scannable as the product matures.
- As a Product Owner, I want ROADMAP.md to show only active and planned waves so I can see what is in-flight without scrolling past finished work.
- As a Reader of the project, I want a chronological archive of what each wave delivered so I can understand the product's evolution without digging through git history.
- As a Developer running `/arc-ship`, I want the shipped idea to disappear from the BACKLOG and reappear in the wave archive automatically — no separate cleanup step.
- As a New Arc User upgrading an existing project, I want `/arc-sync` to migrate my legacy shipped items and completed waves into the new archive on its first run, with a report of what moved.

## Demoable Units of Work

### Unit 1: Wave archive schema + `/arc-sync` migration

**Purpose:** Define the `docs/skill/arc/waves/NN-wave-name.md` artifact, and migrate existing shipped items from BACKLOG.md and completed waves from ROADMAP.md into that format.

**Functional Requirements:**

- The system shall define a wave archive file format at `docs/skill/arc/waves/NN-wave-name.md` where `NN` is the zero-padded wave number and `wave-name` is a kebab-case slug derived from the wave name.
- The archive file shall contain: wave heading (`# Wave NN: {Name}`), metadata block (Theme, Goal, Target, Completed timestamp), a `## Shipped Ideas` section with one `### {Idea Title}` subsection per shipped idea, and an ordered list of idea detail blocks preserving the full brief fields (Problem, Proposed Solution, Success Criteria, Constraints, Assumptions, Open Questions) along with ship metadata (Priority, Captured, Shaped, Shipped, Spec).
- `/arc-sync` shall detect migration candidates on every run by scanning `docs/BACKLOG.md` for rows with `Status: shipped` and `docs/ROADMAP.md` for waves with `Status: Completed`.
- When migration candidates are detected, `/arc-sync` shall perform an **automatic migration sweep**: for each completed wave in ROADMAP, it creates or updates `docs/skill/arc/waves/NN-{slug}.md` with the wave definition and the full detail of every idea listed in that wave's Selected Ideas table.
- For each migrated shipped idea, `/arc-sync` shall remove the corresponding row from the BACKLOG summary table and delete the `## {Title}` detail section from BACKLOG.md.
- For each migrated completed wave, `/arc-sync` shall remove the wave's row from the ROADMAP summary table and delete the `## Wave NN: {Name}` section from ROADMAP.md.
- `/arc-sync` shall report the migration outcome inline: `Migrated N shipped ideas and M completed waves to docs/skill/arc/waves/.`
- Migration shall be idempotent — a second `/arc-sync` run with no new candidates produces no writes.
- Orphaned shipped items (shipped status in BACKLOG but belonging to no ROADMAP wave or a missing wave) shall be migrated to a fallback file `docs/skill/arc/waves/00-uncategorized.md` and reported separately.

**Proof Artifacts:**

- File: `docs/skill/arc/waves/00-bootstrap.md` exists and contains all 7 Wave 0 ideas with full detail sections after migration demonstrates the archive format and sweep correctness.
- File: `docs/skill/arc/waves/01-lifecycle-closure.md` exists and contains the `/arc-ship skill` idea demonstrates single-idea wave archival.
- CLI: `grep -c 'Status: shipped' docs/BACKLOG.md` returns `0` after migration demonstrates shipped items were removed from BACKLOG.
- CLI: `grep -c 'Status: Completed' docs/ROADMAP.md` returns `0` after migration demonstrates completed waves were removed from ROADMAP.
- Test: Running `/arc-sync` a second time with no new candidates writes no files and reports `0 migrations` demonstrates idempotency.

### Unit 2: `/arc-ship` writes to wave archive

**Purpose:** Rewrite the `/arc-ship` flow so shipped ideas are appended to the wave archive and removed from BACKLOG in a single atomic operation. When the final spec-ready idea in a wave is shipped, the wave itself is archived and removed from ROADMAP.

**Functional Requirements:**

- `/arc-ship` shall, after verifying the `**Overall**: PASS` in the cw-validate report, compute the wave archive path `docs/skill/arc/waves/NN-{slug}.md` from the idea's `- **Wave:**` field.
- If the archive file does not exist, `/arc-ship` shall create it with the wave heading and metadata block (Theme, Goal, Target) copied from the ROADMAP wave section.
- `/arc-ship` shall append the idea's full detail — all brief fields plus the new `- **Shipped:** {ISO 8601}` and `- **Spec:** {path}` fields — as a `### {Title}` subsection under `## Shipped Ideas` in the archive file.
- `/arc-ship` shall remove the idea's row from the BACKLOG summary table and delete the idea's `## {Title}` section from BACKLOG.md in the same run.
- After shipping, `/arc-ship` shall check whether all ideas originally in the wave (as recorded in the ROADMAP Selected Ideas table) have been archived. If yes, the wave is "complete": `/arc-ship` shall remove the wave's row from the ROADMAP summary table, delete the `## Wave NN: {Name}` section from ROADMAP.md, and record the completion timestamp as `**Completed:** {ISO 8601}` in the archive file's metadata block.
- Batch mode (shipping multiple ideas in one `/arc-ship` run) shall evaluate wave completion only after processing all selected ideas, so a single batch can complete a wave in one pass.
- Per-idea and batch failure handling unchanged from existing spec — `/arc-ship` records failures and continues the batch on cw-validate failure, never leaving BACKLOG/ROADMAP/archive in a partial state.
- The `ARC:product-context` refresh in `CLAUDE.md` shall derive the `Shipped` count from the archive (sum of `### {Title}` subsections across `docs/skill/arc/waves/*.md`) rather than counting `Status: shipped` rows in BACKLOG.
- If the wave section in ROADMAP is missing (e.g., the wave was previously archived but a stray shipped item remained), `/arc-ship` shall append the idea to `docs/skill/arc/waves/00-uncategorized.md` with a warning and skip ROADMAP cleanup for that idea.

**Proof Artifacts:**

- Test: Shipping the single spec-ready idea in a fresh wave via `/arc-ship` creates `docs/skill/arc/waves/03-{slug}.md`, removes the idea from BACKLOG, and removes the wave section + summary row from ROADMAP demonstrates end-to-end flow.
- CLI: After shipping, `grep -q '{Idea Title}' docs/BACKLOG.md` returns non-zero (not found) demonstrates removal from BACKLOG.
- CLI: After shipping the final idea in a wave, `grep -q '## Wave NN' docs/ROADMAP.md` returns non-zero demonstrates wave removal from ROADMAP.
- File: The archived wave file contains a `**Completed:** {timestamp}` line in its metadata block demonstrates completion timestamping.
- Test: Batch-shipping two ideas that together complete a wave produces one ROADMAP deletion, two BACKLOG deletions, and one archive file with both ideas demonstrates batch wave-completion logic.

### Unit 3: Downstream readers re-point to wave archive

**Purpose:** Update `/arc-status`, `/arc-audit`, and the reader side of `/arc-sync` so that all `shipped`-count, features-list, and lifecycle-diagram derivations read from `docs/skill/arc/waves/*.md` instead of BACKLOG.md.

**Functional Requirements:**

- `/arc-status` Step 3 (Backlog Snapshot) shall derive the `Shipped` count by counting `### {Title}` subsections across all `docs/skill/arc/waves/*.md` files, not by parsing `Status: shipped` in the BACKLOG summary table.
- `/arc-status` Step 3 output shall still present four buckets (Captured, Shaped, Spec-Ready, Shipped) with the Shipped value coming from the archive; if the archive directory is absent the Shipped count shall be `0`.
- `/arc-audit` status distribution checks (BH-3) shall count shipped ideas from `docs/skill/arc/waves/*.md` instead of BACKLOG.
- `/arc-audit` WA-6 (Cross-Reference Integrity) shall exclude shipped-state reasoning — the check applies only to captured/shaped/spec-ready rows.
- `/arc-sync` `ARC:features` section (Step 8c / Step 3d) shall list shipped ideas from `docs/skill/arc/waves/*.md` — one bullet per `### {Title}` subsection across all archive files, ordered by wave number ascending.
- `/arc-sync` `ARC:lifecycle-diagram` section (Step 8e / Step 3f) shall source the `Shipped` count from the wave archive.
- `/arc-sync` trust-signal TS-3 (Features) and TS-6 (Currency) evaluability shall be redefined: evaluable when at least one `docs/skill/arc/waves/*.md` file exists with at least one `### {Title}` subsection.
- The `ARC:product-context` block in CLAUDE.md shall be re-sourced: the `**Backlog:** ... shipped` segment reads from the archive, not BACKLOG.

**Proof Artifacts:**

- CLI: `/arc-status` output's Backlog Snapshot `Shipped` row matches `grep -c '^### ' docs/skill/arc/waves/*.md | awk -F: '{sum+=$2} END {print sum}'` demonstrates counter re-pointed.
- File: README.md `ARC:features` bullet list matches the set of `### {Title}` subsections across all wave archive files demonstrates sync reader rewire.
- Test: `/arc-audit` BH-3 report shows the same shipped count as `/arc-status` after archive changes demonstrates consistent counter source.
- File: `CLAUDE.md` `ARC:product-context` `Backlog:` line's shipped number equals the archive count demonstrates CLAUDE.md refresh re-source.

### Unit 4: Templates, references, and lifecycle documentation

**Purpose:** Update the Arc templates and reference documents so the new data model is documented consistently — no stale references to "shipped items in BACKLOG" or "Completed waves in ROADMAP".

**Functional Requirements:**

- `templates/BACKLOG.tmpl.md` shall redefine the Status column values to `captured | shaped | spec-ready` only. All examples showing a `shipped` idea shall be removed or re-pointed at the archive.
- `templates/ROADMAP.tmpl.md` shall redefine wave Status values to `planned | active` only. References to `Completed Wave Retrospectives` at MVP/Growth/Maturity phases shall be relocated to the wave archive, not ROADMAP.
- `references/idea-lifecycle.md` shall update the Shipped stage description: the idea is removed from BACKLOG and its detail lives in `docs/skill/arc/waves/NN-wave-name.md`. The mermaid diagram still shows Shipped as terminal but the data-fields note shall clarify the archive location.
- `skills/arc-sync/references/trust-signals.md` shall update TS-3 and TS-6 detection logic to read from the wave archive.
- A new reference document `references/wave-archive.md` shall document the archive schema, location, and lifecycle (created by `/arc-sync` or `/arc-ship`, read by `/arc-status`, `/arc-audit`, and `/arc-sync`).
- `skills/arc-ship/SKILL.md`, `skills/arc-wave/SKILL.md`, `skills/arc-sync/SKILL.md`, `skills/arc-status/SKILL.md`, `skills/arc-audit/SKILL.md`, and `skills/arc-help/SKILL.md` shall be updated so their Overview, Process steps, and cross-reference lists mention the wave archive correctly.

**Proof Artifacts:**

- File: `templates/BACKLOG.tmpl.md` contains no `shipped` value in its Status column definition demonstrates template update.
- File: `templates/ROADMAP.tmpl.md` contains no `completed` wave status demonstrates roadmap template cleanup.
- File: `references/wave-archive.md` exists and documents the schema demonstrates new reference created.
- CLI: `grep -l 'Status: shipped' skills/*/SKILL.md` returns no matches demonstrates all skill docs updated.
- Test: `/arc-help` output references the new archive and no longer describes BACKLOG as the shipped-item home demonstrates help text refreshed.

## Non-Goals (Out of Scope)

- No changes to `/arc-capture`, `/arc-shape`, or `/arc-assess` — these skills operate on pre-shipped ideas and are untouched.
- No UI or visualization of the archive beyond the existing mermaid lifecycle diagram in README.
- No cross-project archive aggregation — each project owns its own `docs/skill/arc/waves/`.
- No automated backfill of the `- **Spec:**` field for legacy shipped ideas that lack one; that remains the existing `/arc-ship` backfill flow (Step 1b) invoked manually before migration if needed.
- No undo/re-open of shipped ideas — once archived, re-opening is a manual edit; the skill does not provide a reverse transition.
- No versioning or diff tracking across archive updates — git history is authoritative for archive mutation history.
- No deletion of `docs/skill/arc/wave-report.md` — it remains in use as the "current wave" working artifact produced by `/arc-wave`.

## Design Considerations

- The archive file format is human-readable markdown, scannable top-to-bottom per wave.
- File naming uses the zero-padded wave number to ensure consistent lexicographic ordering in the `docs/skill/arc/waves/` directory listing.
- The `## Shipped Ideas` heading is fixed to provide a stable anchor for readers.
- No additional mermaid diagrams are required in the archive files themselves — `/arc-sync` continues to maintain the lifecycle diagram in README as the visual summary.

## Repository Standards

- Conventional commits: `feat(wave-archive)`, `refactor(arc-ship)`, `docs(arc)`.
- All SKILL.md updates preserve the existing Critical Constraints / Process / References structure.
- Mermaid diagrams in any modified skill walkthroughs continue using Liatrio brand colors per existing convention.
- Shell operations within skill processes shall continue to avoid `cat`, `head`, `tail`, `find`, `ls`, `grep`, `rg`, `sed`, `awk` — per global Claude Code tool usage rules.
- Follow SDD: `/cw-plan` → `/cw-dispatch` with sub-tasks after spec approval.

## Technical Considerations

- Migration must be idempotent: running `/arc-sync` repeatedly after migration must not duplicate, delete, or alter archived content.
- `/arc-ship` wave-completion detection requires reading the ROADMAP Selected Ideas table for the wave before the idea is removed; when the wave section is already absent (partial-migration state), the idea falls back to `docs/skill/arc/waves/00-uncategorized.md`.
- Slug derivation for archive filenames: lowercase the wave name, replace spaces with `-`, strip non-alphanumeric-hyphen characters, collapse double hyphens. Example: `Wave 2: Shaping Intelligence` → `02-shaping-intelligence.md`.
- The `NN` prefix is sourced from the wave's ROADMAP position (`Wave NN: Name`). If a wave is unnumbered (legacy), use the lowest unused two-digit prefix.
- Batch `/arc-ship` must order writes deterministically: archive appends first (so the archive is always ahead of or equal to the BACKLOG state), then BACKLOG removals, then ROADMAP pruning if wave-complete.
- Existing shipped items in BACKLOG that reference a missing or renamed wave must be detected during migration and routed to `00-uncategorized.md` with a visible warning in the `/arc-sync` report.
- All file writes use the Edit/Write tools per global tool-usage rules; never shell `sed`/`awk`.

## Security Considerations

- No credentials, tokens, or external API keys involved.
- File writes are scoped to `docs/BACKLOG.md`, `docs/ROADMAP.md`, `docs/skill/arc/waves/*.md`, `CLAUDE.md` managed sections, `templates/*.md`, `references/*.md`, and `skills/*/SKILL.md`. All locations are already write-targets for Arc skills.
- Validation report contents are read-only — the archive captures a path reference, not a copy.

## Success Metrics

- After migration: 0 rows with `Status: shipped` in `docs/BACKLOG.md` (target: 0; current: 10).
- After migration: 0 waves with `Status: Completed` in `docs/ROADMAP.md` (target: 0; current: 3).
- After migration: `docs/skill/arc/waves/` contains one file per completed wave with correct idea counts (target: 3 files, total 9 ideas across Wave 0/1/2).
- After migration: `/arc-status` and `/arc-audit` shipped counts match the archive subsection count (target: exact match).
- No regressions in existing trust signals that were passing before migration (target: ≥ current pass count).

## Open Questions

- No open questions at this time.
