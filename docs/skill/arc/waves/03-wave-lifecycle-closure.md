# Wave 3: Wave Lifecycle Closure

- **Theme:** Wave Lifecycle Closure
- **Goal:** Remove finished items from BACKLOG and ROADMAP, preserving them in per-wave archive files at `docs/skill/arc/waves/NN-wave-name.md`.
- **Target:** 1-2 weeks
- **Completed:** 2026-04-15T00:15:00Z

## Shipped Ideas

### Wave archive

- **Status:** shipped
- **Priority:** P1-High
- **Captured:** 2026-04-15T00:00:00Z
- **Shaped:** 2026-04-15T00:05:00Z
- **Shipped:** 2026-04-15T00:15:00Z
- **Wave:** Wave 3 — Wave Lifecycle Closure
- **Spec:** docs/specs/13-spec-wave-archive

Remove finished items from BACKLOG and ROADMAP, preserve them in per-wave archive files at `docs/skill/arc/waves/NN-wave-name.md`.

#### Problem

After waves complete, `docs/BACKLOG.md` and `docs/ROADMAP.md` retain all shipped items and completed waves indefinitely. The Product Owner and Tech Lead lose signal-to-noise as historical entries inflate both files — half of BACKLOG was historical weight at 10 shipped vs 20 active, and ROADMAP mixed completed waves with active ones. Without a removal path, both artifacts grow monotonically and obscure the active pipeline during triage.

#### Proposed Solution

Introduce a per-wave archive at `docs/skill/arc/waves/NN-wave-name.md` and re-wire the lifecycle so shipped items leave BACKLOG and completed waves leave ROADMAP atomically:

1. `/arc-ship` writes the shipped idea's full detail to the wave archive, then removes the idea row + section from BACKLOG; when all wave ideas are archived, prunes the wave from ROADMAP and stamps `**Completed:** {timestamp}` in the archive metadata.
2. `/arc-sync` performs an automatic, idempotent migration sweep on every run to handle legacy shipped items and completed waves.
3. `/arc-status`, `/arc-audit`, and `/arc-sync` (reader side) source shipped counts and feature lists from `docs/skill/arc/waves/*.md` instead of BACKLOG.
4. Templates and references are updated to reflect the new state machine: BACKLOG statuses are `captured | shaped | spec-ready` only; ROADMAP wave statuses are `planned | active` only.

#### Success Criteria

- Zero rows with `Status: shipped` in `docs/BACKLOG.md` after migration.
- Zero waves with `Status: Completed` in `docs/ROADMAP.md` after migration.
- `docs/skill/arc/waves/` contains one archive file per completed wave plus an orphan fallback.
- `/arc-status` and `/arc-audit` shipped counts equal the archive subsection count exactly.
- Re-running `/arc-sync` after migration produces zero writes (idempotent).

#### Constraints

- Migration must be idempotent — re-running `/arc-sync` with no new candidates writes nothing.
- Write ordering in `/arc-ship`: archive append first, then BACKLOG removal, then ROADMAP pruning if wave-complete.
- No shell text-processing tools (`sed`, `awk`, `grep`); use Edit/Write only.
- Orphaned shipped items (no matching wave) route to `docs/skill/arc/waves/00-uncategorized.md` with a warning.

#### Assumptions

- Each shipped idea belongs to exactly one wave; orphans are rare and fall back deterministically.
- Existing artifact-migration patterns and managed-section conventions apply unchanged.
- Git history is the authoritative record of archive mutations — no in-file versioning needed.

#### Open Questions

None.
