# Clarifying Questions — 13-spec-wave-archive

**Round:** 1
**Captured:** 2026-04-15

## Q1: History Artifact Location

Where should shipped ideas and completed waves be preserved?

**Answer:** Keep `docs/skill/arc/wave-report.md` for the active wave, add per-wave archive files under `docs/skill/arc/waves/`.

## Q2: Migration of Existing Data

The current BACKLOG has 10 shipped items and ROADMAP has 3 completed waves. How should existing content be handled?

**Answer:** `/arc-sync` handles migration. An automatic sweep detects shipped items in BACKLOG and completed waves in ROADMAP, then migrates them to the archive.

## Q3: Read Path for Downstream Skills

After shipping, where do downstream skills (arc-sync, arc-status, arc-audit) read shipped-item data from?

**Answer:** Wave archive is the sole source of truth. The `shipped` status value is removed entirely from BACKLOG.

## Q4: Archive Trigger

When should a completed wave be removed from ROADMAP.md and archived?

**Answer:** On `/arc-ship` when the final spec-ready idea in the wave is shipped. `arc-ship` archives the wave section and removes it from ROADMAP.

## Q5: Archive File Naming

What naming pattern for archived wave files in `docs/skill/arc/waves/`?

**Answer:** `NN-wave-name.md` — zero-padded wave number + slug, matching ROADMAP wave number (e.g., `00-bootstrap.md`, `01-lifecycle-closure.md`).

## Q6: Migration UX

How should `/arc-sync` handle the one-time migration?

**Answer:** Automatic sweep on detect. When arc-sync detects shipped items in BACKLOG or completed waves in ROADMAP, it migrates them automatically and reports what was moved.
