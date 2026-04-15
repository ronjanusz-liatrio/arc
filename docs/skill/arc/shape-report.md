# Shape Report: Wave archive

**Shaped:** 2026-04-15T00:05:00Z
**Idea:** Wave archive
**Status:** captured → shaped

## Before (Captured Stub)

Remove finished items from BACKLOG and ROADMAP, preserve them in per-wave archive files at `docs/skill/arc/waves/NN-wave-name.md`.

## Subagent Analysis Summary

| Dimension | Rating | Key Finding |
|-----------|--------|-------------|
| Problem Clarity | Medium | Trigger and scope clear retroactively; stub itself was thin |
| Customer Fit | Strong | Directly serves PO + Tech Lead artifact-hygiene JTBD; demand evidence in spec 08 |
| Scope | Medium | Touches /arc-ship, /arc-sync, /arc-status, /arc-audit, templates, 6 SKILL.md files |
| Feasibility | Ready | Spec 13 already shipped — implementation live and validated |
| Skill Discovery | Skipped | Meta-validation exercise |

## After (Shaped Brief)

### Problem

After waves complete, `docs/BACKLOG.md` and `docs/ROADMAP.md` retain all shipped items and completed waves indefinitely. The Product Owner and Tech Lead lose signal-to-noise as historical entries inflate both files — half of BACKLOG was historical weight at 10 shipped vs 20 active, and ROADMAP mixed completed waves with active ones. Without a removal path, both artifacts grow monotonically and obscure the active pipeline during triage.

### Proposed Solution

Per-wave archive at `docs/skill/arc/waves/NN-wave-name.md`. `/arc-ship` writes archive + prunes BACKLOG/ROADMAP atomically; `/arc-sync` performs an automatic idempotent migration sweep; `/arc-status`, `/arc-audit`, and `/arc-sync` reader paths source shipped counts and feature lists from the archive; templates/references redefine BACKLOG statuses as `captured | shaped | spec-ready` and ROADMAP wave statuses as `planned | active`.

### Success Criteria

- Zero `Status: shipped` rows in BACKLOG.
- Zero `Status: Completed` waves in ROADMAP.
- One archive file per completed wave plus orphan fallback.
- `/arc-status` and `/arc-audit` shipped counts match archive subsection count.
- Re-running `/arc-sync` is idempotent.

### Constraints

- Idempotent migration; archive-first write ordering; no shell text-processing tools; orphan fallback to `00-uncategorized.md`.

### Assumptions

- Each shipped idea belongs to one wave; existing artifact-migration patterns apply; git history is authoritative for archive mutations.

### Open Questions

None.

## Gaps Resolved During Q&A

No interactive Q&A required — all gaps surfaced by the parallel analysis were already resolved by the existing spec 13 design. The shaped brief is a retroactive synthesis aligned with the shipped implementation.

## Open Questions Deferred

None.
