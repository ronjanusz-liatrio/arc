# 17-spec-claude-md-static-references

## Introduction/Overview

Arc currently injects and refreshes a live `ARC:product-context` managed section in the project `CLAUDE.md` containing dynamic counts (backlog stage counts, current wave name, persona list, vision summary). These values drift the moment any artifact changes, and the dual ownership — `/arc-wave` injects, `/arc-ship` refreshes — creates avoidable churn and write paths into a file other plugins also manage. This spec replaces the live block with a **static reference block** that links to the live source artifacts (`BACKLOG.md`, `ROADMAP.md`, `VISION.md`, `CUSTOMER.md`) with one-line usage hints, and consolidates all CLAUDE.md write authority into `/arc-sync`.

## Goals

1. Eliminate live status data (backlog counts, wave name, persona list, vision summary) from the `ARC:product-context` section in `CLAUDE.md`.
2. Replace it with a fixed-content static block of links + per-link usage hints to the live source artifacts.
3. Make `/arc-sync` the sole skill that writes the `ARC:product-context` block; remove all CLAUDE.md write paths from `/arc-wave` and `/arc-ship`.
4. Migrate legacy live blocks idempotently — running `/arc-sync` on a project with the old format replaces it with the new static format; running again is a no-op.
5. Preserve coexistence: managed-block markers, insertion priority relative to TEMPER:/Snyk, and graceful handling of missing CLAUDE.md remain intact.

## User Stories

- As a **Project Stakeholder** reading a project's CLAUDE.md, I want to see pointers to where current backlog/wave/vision live so that I can navigate to authoritative source artifacts instead of trusting cached counts.
- As a **Developer** maintaining Arc, I want a single skill (`/arc-sync`) that owns CLAUDE.md writes so that I don't have to chase stale data across `/arc-wave` and `/arc-ship` invocations.
- As an **Arc User** running `/arc-wave` or `/arc-ship`, I want the skill to focus on its core job (wave creation, idea shipping) without worrying about CLAUDE.md drift.
- As an **Arc User** with an existing project, I want my old live `ARC:product-context` block to be auto-replaced with the new static format the next time I run `/arc-sync`, with no manual edit required.

## Demoable Units of Work

### Unit 1: Define static block schema and update bootstrap-protocol

**Purpose:** Establish the canonical static block format (content + insertion algorithm + idempotency rules) so downstream skill changes have a single reference doc.

**Functional Requirements:**
- The system shall update `skills/arc-wave/references/bootstrap-protocol.md` to specify a static `ARC:product-context` block whose content does **not** include backlog counts, current wave name, persona list, phase, or vision summary.
- The static block shall contain exactly these elements between the BEGIN/END markers:
  1. A `## Product Context` H2 heading.
  2. A short intro sentence stating that live status is in the linked artifacts, not this section.
  3. A bulleted list of links — one bullet each for `docs/BACKLOG.md`, `docs/ROADMAP.md`, `docs/VISION.md`, `docs/CUSTOMER.md` — with each bullet ending in an em-dash followed by a one-line usage hint (when to consult that artifact).
- The block shall continue to use `<!--# BEGIN ARC:product-context -->` / `<!--# END ARC:product-context -->` markers for coexistence with TEMPER:/MM: namespaces.
- The bootstrap-protocol shall describe insertion priority unchanged from today (before first TEMPER: marker → before Snyk → at EOF).
- The bootstrap-protocol shall describe migration behavior: when an existing block is found between markers, replace its full content with the static template regardless of whether the prior content was live counts or already-migrated static text. Migration is therefore the same code path as routine writes.
- The bootstrap-protocol shall document idempotency: running the protocol twice produces identical file bytes between marker positions.
- The bootstrap-protocol shall name `/arc-sync` as the sole writer and explicitly note that `/arc-wave` and `/arc-ship` no longer write the block.
- The "Update Behavior" table that lists Vision/Phase/Wave/Personas/Backlog field sources shall be removed; the section becomes content-free of dynamic-source references.

**Proof Artifacts:**
- File: `skills/arc-wave/references/bootstrap-protocol.md` contains the static template literal block, the migration paragraph, and the writer-attribution sentence naming `/arc-sync` only.
- File: `skills/arc-wave/references/bootstrap-protocol.md` does **not** contain the words "Backlog count", "shipped count", or any reference to "captured, shaped, spec-ready" inside the managed-section schema description.
- Test: `grep -nE 'Backlog:|Current Wave:|Phase:|Primary Personas:|Vision:' skills/arc-wave/references/bootstrap-protocol.md` returns no matches inside the static-block template definition.

### Unit 2: Remove CLAUDE.md write paths from /arc-wave and /arc-ship

**Purpose:** Make `/arc-wave` and `/arc-ship` CLAUDE.md-agnostic for product context. They neither create nor refresh the `ARC:product-context` section.

**Functional Requirements:**
- The system shall remove Step 9 ("Inject ARC:product-context into CLAUDE.md") from `skills/arc-wave/SKILL.md` along with its sub-steps 9a–9d.
- The system shall remove Step 7 ("Refresh ARC:product-context") from `skills/arc-ship/SKILL.md`.
- Both SKILL.md files shall renumber subsequent steps consecutively.
- Both SKILL.md files shall remove the constraint "**NEVER** modify TEMPER: or MM: managed sections in CLAUDE.md" and "**NEVER** create CLAUDE.md if it doesn't exist" only if the surrounding constraints become irrelevant after Step removal — otherwise leave the read-only constraints intact for any incidental reads.
- Both SKILL.md files shall remove `CLAUDE.md` from any "Files Read/Written" list where it appeared solely for product-context purposes.
- Both SKILL.md files shall add a one-line note in their "Next Steps" or post-completion summary stating: "Run /arc-sync if the project's CLAUDE.md product-context block needs creation or refresh."
- The flowchart in `skills/arc-ship/SKILL.md` shall be updated to remove the `Refresh CLAUDE.md\nproduct-context` node and reconnect surrounding edges.
- `references/wave-planning.md` shall be updated to drop the line "An `ARC:product-context` managed section in the project CLAUDE.md" from any "creates" list and replaced with a sentence that points readers to `/arc-sync` for CLAUDE.md updates.
- `skills/arc-ship/references/ship-criteria.md` (if it references the CLAUDE.md refresh step) shall be updated to drop those references.

**Proof Artifacts:**
- Test: `grep -n 'CLAUDE.md' skills/arc-wave/SKILL.md` returns zero lines that describe writes (no "Inject", "Refresh", "Update", or "Replace" verbs paired with CLAUDE.md).
- Test: `grep -n 'CLAUDE.md' skills/arc-ship/SKILL.md` returns zero lines that describe writes.
- Test: `grep -n 'product-context' skills/arc-wave/SKILL.md skills/arc-ship/SKILL.md` returns zero matches inside skill execution steps.
- File: `skills/arc-wave/SKILL.md` step numbering is contiguous with no gaps after Step 9 removal.
- File: `skills/arc-ship/SKILL.md` step numbering is contiguous with no gaps after Step 7 removal.

### Unit 3: Implement static-block management in /arc-sync

**Purpose:** Make `/arc-sync` the sole writer of the `ARC:product-context` block, handling both greenfield injection (CLAUDE.md exists but block missing) and migration of legacy live blocks.

**Functional Requirements:**
- The system shall add a step to `skills/arc-sync/SKILL.md` that, after README sync completes, processes the project's `CLAUDE.md` per the bootstrap-protocol updates from Unit 1.
- The system shall implement the following decision logic for `/arc-sync`'s CLAUDE.md handling:
  - If `CLAUDE.md` does not exist in the project root: skip silently. Do not create the file.
  - If `CLAUDE.md` exists and contains `<!--# BEGIN ARC:product-context -->`: replace content between BEGIN/END markers with the static template (overwrites live blocks and re-applies the static template idempotently).
  - If `CLAUDE.md` exists and does not contain the markers: insert the static block at the priority-1 position (before first TEMPER: marker, then before Snyk, then EOF).
- The system shall ensure the resulting block is byte-identical regardless of whether the project had a live block, an already-migrated static block, or no block at all.
- The system shall add a brief diagnostic line to the `/arc-sync` summary output indicating the action taken: `injected`, `migrated`, `refreshed`, or `skipped (no CLAUDE.md)`.
- The system shall update `skills/arc-sync/references/readme-mapping.md` cross-references to note that `/arc-sync` also manages the ARC:product-context section in CLAUDE.md.
- The system shall not modify any TEMPER: or MM: managed sections, even if encountered adjacent to the ARC: section.

**Proof Artifacts:**
- File: `skills/arc-sync/SKILL.md` contains a step describing CLAUDE.md product-context management after the README sync step.
- Test: After running `/arc-sync` on a fresh project with a CLAUDE.md lacking the ARC: block, `grep -c '<!--# BEGIN ARC:product-context -->' CLAUDE.md` returns `1`.
- Test: After running `/arc-sync` twice in succession on the same project, `git diff` between runs shows no changes to CLAUDE.md (idempotency).
- Test: After running `/arc-sync` on a project with a legacy live block (containing `**Backlog:** N captured, ...`), the resulting block contains links to `docs/BACKLOG.md`, `docs/ROADMAP.md`, `docs/VISION.md`, `docs/CUSTOMER.md` and contains no count lines.

### Unit 4: Dogfood migration on arc repo CLAUDE.md

**Purpose:** Validate the end-to-end behavior by running the new `/arc-sync` against this repo and committing the migrated CLAUDE.md as a proof artifact.

**Functional Requirements:**
- The system shall run `/arc-sync` against `/home/ron.linux/arc/` after Units 1–3 are implemented.
- The resulting `CLAUDE.md` in this repo shall have its `ARC:product-context` block replaced with the new static format (links + hints).
- The new block shall be positioned in the same location as the prior block (no relocation on migration).
- All non-`ARC:product-context` content in this repo's `CLAUDE.md` (including the `SKILLZ:installed-skills` section, the unmanaged narrative content above, and any TEMPER: blocks if present) shall be preserved byte-for-byte outside the ARC: marker boundaries.

**Proof Artifacts:**
- File: `/home/ron.linux/arc/CLAUDE.md` contains the new static block between `<!--# BEGIN ARC:product-context -->` and `<!--# END ARC:product-context -->`.
- File: `/home/ron.linux/arc/CLAUDE.md` between the ARC markers contains no `**Backlog:**`, `**Current Wave:**`, `**Phase:**`, `**Primary Personas:**`, or `**Vision:**` lines.
- File: `/home/ron.linux/arc/CLAUDE.md` between the ARC markers contains markdown links to `docs/BACKLOG.md`, `docs/ROADMAP.md`, `docs/VISION.md`, and `docs/CUSTOMER.md`.
- Test: `git diff` for this commit shows changes confined to lines between the ARC: BEGIN/END markers in CLAUDE.md (modulo whitespace).

## Non-Goals (Out of Scope)

- Removing or modifying `TEMPER:`-namespaced managed sections in CLAUDE.md (those remain owned by Temper).
- Changing how `/arc-shape` reads CLAUDE.md for tech-stack/phase context — cross-plugin reads remain unchanged.
- Removing the `ARC:` namespace concept from Arc — the namespace and marker format stay; only the content inside one section changes.
- Auto-running `/arc-sync` from `/arc-wave` or `/arc-ship` — these skills become CLAUDE.md-agnostic and do not orchestrate sync.
- Adding new managed sections under the `ARC:` namespace (e.g., `ARC:roadmap`, `ARC:features`) inside CLAUDE.md — README still hosts those via existing `arc-sync` mappings.
- Deprecating or removing `docs/skill/arc/waves/*.md` archive files — the shipped count moves out of CLAUDE.md but the archive remains the source for `/arc-ship` and README sync.
- Backwards-compatibility shim that keeps live counts on a deprecation path — migration is one-shot on next `/arc-sync` run with no opt-out.

## Design Considerations

The static block content should read like a navigation aid: short intro sentence, four labeled links, each with a contextual hint that helps a reader (or another agent) decide when to open the file. Example:

```markdown
<!--# BEGIN ARC:product-context -->
## Product Context

For live product status, see the source artifacts. This section intentionally contains no counts, statuses, or names — those drift; the linked files are authoritative.

- [docs/BACKLOG.md](docs/BACKLOG.md) — current ideas with their lifecycle status (captured, shaped, spec-ready, shipped). Read before suggesting new ideas or proposing scope changes.
- [docs/ROADMAP.md](docs/ROADMAP.md) — active and planned waves with goals and targets. Read when deciding what to work on next or to understand the current delivery cycle.
- [docs/VISION.md](docs/VISION.md) — product vision, north-star problem, and strategic boundaries. Read when shaping new ideas or evaluating fit.
- [docs/CUSTOMER.md](docs/CUSTOMER.md) — primary personas and their jobs-to-be-done. Read when scoping a feature or assessing customer fit.
<!--# END ARC:product-context -->
```

This is illustrative; the implementation may refine wording during Unit 1, but the structural elements (intro sentence + four bullets with em-dash hints) are required by Unit 1's functional requirements.

## Repository Standards

- Conventional commits per `CLAUDE.md`: `type(scope): description`. Use `feat`, `refactor`, `docs`, or `chore` scopes appropriate to each unit.
- Follow the Arc skill context-marker convention: SKILL.md edits must preserve the leading `**ARC-{NAME}**` marker.
- All changes go through `/cw-spec` → `/cw-plan` → `/cw-dispatch` workflow per project `CLAUDE.md` Development section.
- Markdown link format: relative paths (e.g., `docs/BACKLOG.md`, not absolute or remote URLs).
- HTML marker format: `<!--# BEGIN ARC:product-context -->` and matching END — exact byte sequence per existing bootstrap-protocol.md.

## Technical Considerations

- **Idempotency** is the key correctness property. The replace-between-markers algorithm in bootstrap-protocol.md is already idempotent; Unit 1 only changes the template content, not the algorithm.
- **Detection of legacy vs new content** is unnecessary because the migration code path is "always overwrite content between markers with current static template." Both legacy live content and prior static content get replaced with the same bytes — no special-case branch needed.
- **Markdown rendering**: links use relative paths starting with `docs/`. They render in tools that resolve paths from the repo root (GitHub, VS Code, Claude Code's markdown renderer). They do not render in tools that assume absolute paths — acceptable.
- **Cross-plugin coexistence**: TEMPER: marker positions and content are not modified. Insertion priority remains "before first TEMPER: marker → before Snyk → at EOF" so ARC: appears upstream of TEMPER: where both exist.
- **Removal of "Update Behavior" table from bootstrap-protocol.md**: this table currently maps fields to data sources (`docs/VISION.md` → Vision line, etc.). After Unit 1, no field has a data source — the content is literal. The table is removed rather than emptied.
- **Step renumbering**: arc-wave currently has Steps 1–11 (Step 9 is the CLAUDE.md inject step); after removal, Steps 10–11 renumber to 9–10. arc-ship has Steps 1–8 (Step 7 is the refresh step); after removal, Step 8 renumbers to 7. All cross-references to step numbers within those SKILL.md files must be updated.

## Security Considerations

- No secrets are introduced or exposed by this change — `ARC:product-context` is markdown content in a project file.
- No new file-system writes outside of CLAUDE.md (which was already being written) — write surface area decreases (two skills lose write access).
- No external network calls.

## Success Metrics

- **Zero live data drift**: the `ARC:product-context` block in any project's CLAUDE.md no longer becomes stale because no skill writes mutable values into it.
- **Single writer**: only `/arc-sync` writes to the block — verifiable by `grep` in skill source files.
- **Migration coverage**: 100% of legacy blocks encountered by `/arc-sync` get migrated on first run; 0% require manual intervention.
- **Idempotency**: running `/arc-sync` twice produces a zero-byte diff to CLAUDE.md.

## Open Questions

No open questions at this time.
