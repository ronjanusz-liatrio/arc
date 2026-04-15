# Wave 1: Lifecycle Closure

- **Theme:** Complete the Arc idea lifecycle by automating the shipped transition
- **Goal:** Close the automation loop from `/cw-validate` back to Arc by shipping `/arc-ship` — the only unautomated lifecycle transition
- **Target:** 1-2 weeks
- **Completed:** 2026-04-15T00:00:00Z

## Shipped Ideas

### /arc-ship skill

- **Status:** shipped
- **Priority:** P1-High
- **Captured:** 2026-04-13T00:00:00Z
- **Shaped:** 2026-04-14T00:00:00Z
- **Shipped:** 2026-04-14T00:00:00Z
- **Wave:** Wave 1: Lifecycle Closure
- **Spec:** docs/specs/10-spec-arc-ship/

Automates the final lifecycle transition from SDD pipeline completion back to Arc — verifies proof artifacts and marks ideas as shipped.

#### Problem

When the SDD pipeline completes for an Arc-managed idea, the Product Owner must manually update `docs/BACKLOG.md` status to `shipped`. There is no verification that cw-validate proof artifacts exist and no enforcement of the lifecycle entry criteria defined in `references/idea-lifecycle.md`. This creates drift risk — shipped items sit in stale status indefinitely, and downstream skills (`/arc-audit`, `/arc-sync`) report incorrect state.

#### Proposed Solution

An `/arc-ship` skill that verifies a cw-validate report with `**Overall**: PASS` exists for a completed idea, then transitions its BACKLOG status to `shipped` — with optional batch mode for shipping wave items together, ROADMAP wave status rollup, and interactive backfill of the `Spec` field on legacy shipped items.

#### Success Criteria

- `/arc-ship` updates BACKLOG summary table row and detail section status to `shipped` in a single operation
- Verification requires a cw-validate report file containing `**Overall**: PASS` before allowing the transition
- Shipped entries include `- **Spec:**` reference path and `- **Shipped:**` ISO 8601 timestamp per lifecycle spec
- Batch mode allows selecting and shipping multiple ideas from the same wave in one invocation
- When all items in a ROADMAP wave reach `shipped`, the wave status is updated to complete (requires ROADMAP.md to exist)
- `/arc-wave` is updated to populate a `- **Spec:**` field on BACKLOG entries during wave assignment
- Offers interactive backfill of the `Spec` field on existing shipped items (Wave 0) on first run

#### Constraints

- Must not modify proof artifacts — read-only verification only
- Requires a `- **Spec:**` field on BACKLOG entries for proof lookup; falls back to asking user for spec path when field is missing
- Must follow existing SKILL.md pattern and AskUserQuestion conventions
- ROADMAP wave status update only applies when `docs/ROADMAP.md` exists

#### Assumptions

- cw-validate reports follow the pattern `docs/specs/NN-spec-name/NN-validation-*.md` with a parseable `**Overall**: PASS` indicator
- BACKLOG entries targeted for shipping have a `- **Spec:**` field populated by `/arc-wave`
- `docs/ROADMAP.md` may not exist; ROADMAP updates are best-effort, not blocking

#### Open Questions

- None
