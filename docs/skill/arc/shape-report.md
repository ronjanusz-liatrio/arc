# Shape Report: /arc-ship skill

**Shaped:** 2026-04-14T00:00:00Z
**Idea:** /arc-ship skill
**Status:** captured → shaped

## Before (Captured Stub)
New skill to mark in-progress ideas as `shipped` in docs/BACKLOG.md after verifying corresponding claude-workflow proof artifacts (cw-validate report, coverage matrix, completed task board entries) — automates the lifecycle transition that closes the loop from `/cw-validate` back to Arc.

## Subagent Analysis Summary

| Dimension | Rating | Key Finding |
|-----------|--------|-------------|
| Problem Clarity | High | Root cause correctly identified — only unautomated lifecycle transition in Arc; manual updates create drift risk |
| Customer Fit | Strong | Directly serves Product Owner persona; demand proven by specs 08 and 09 cleaning up manual-ship consequences |
| Scope | Medium | Core is simple (BACKLOG status update) but proof-verification heuristics and batch mode add coupling to cw artifact conventions |
| Feasibility | Ready with caveats | Follows existing SKILL.md patterns; two unknowns resolved during Q&A (spec-to-backlog mapping, sufficient proof definition) |

## After (Shaped Brief)

### Problem

When the SDD pipeline completes for an Arc-managed idea, the Product Owner must manually update `docs/BACKLOG.md` status to `shipped`. There is no verification that cw-validate proof artifacts exist and no enforcement of the lifecycle entry criteria defined in `references/idea-lifecycle.md`. This creates drift risk — shipped items sit in stale status indefinitely, and downstream skills (`/arc-audit`, `/arc-sync`) report incorrect state.

### Proposed Solution

An `/arc-ship` skill that verifies a cw-validate report with `**Overall**: PASS` exists for a completed idea, then transitions its BACKLOG status to `shipped` — with optional batch mode for shipping wave items together, ROADMAP wave status rollup, and interactive backfill of the `Spec` field on legacy shipped items.

### Success Criteria

- `/arc-ship` updates BACKLOG summary table row and detail section status to `shipped` in a single operation
- Verification requires a cw-validate report file containing `**Overall**: PASS` before allowing the transition
- Shipped entries include `- **Spec:**` reference path and `- **Shipped:**` ISO 8601 timestamp per lifecycle spec
- Batch mode allows selecting and shipping multiple ideas from the same wave in one invocation
- When all items in a ROADMAP wave reach `shipped`, the wave status is updated to complete (requires ROADMAP.md to exist)
- `/arc-wave` is updated to populate a `- **Spec:**` field on BACKLOG entries during wave assignment
- Offers interactive backfill of the `Spec` field on existing shipped items (Wave 0) on first run

### Constraints

- Must not modify proof artifacts — read-only verification only
- Requires a `- **Spec:**` field on BACKLOG entries for proof lookup; falls back to asking user for spec path when field is missing
- Must follow existing SKILL.md pattern and AskUserQuestion conventions
- ROADMAP wave status update only applies when `docs/ROADMAP.md` exists

### Assumptions

- cw-validate reports follow the pattern `docs/specs/NN-spec-name/NN-validation-*.md` with a parseable `**Overall**: PASS` indicator
- BACKLOG entries targeted for shipping have a `- **Spec:**` field populated by `/arc-wave`
- `docs/ROADMAP.md` may not exist; ROADMAP updates are best-effort, not blocking

### Wave Assignment

Unassigned

### Open Questions

- None

## Gaps Resolved During Q&A

- **Spec-to-backlog mapping:** User chose to add a `- **Spec:** path` field to BACKLOG entries, populated by `/arc-wave` during wave assignment. Included in this spec's scope.
- **Sufficient proof definition:** User chose to require a cw-validate report file containing `**Overall**: PASS` — stronger verification than just proof file presence.
- **Batch vs. single:** User chose optional batch mode — default to single idea but support multi-select for shipping a wave's worth of items at once.
- **Side effects:** User chose BACKLOG + ROADMAP wave status — update wave completion status when all wave items are shipped.
- **Spec scope:** User chose to include the arc-wave change (adding Spec field) in the same spec as /arc-ship.
- **Legacy items:** User chose interactive backfill — offer to populate the Spec field on existing Wave 0 shipped items on first run.

## Open Questions Deferred

- None
