# Wave Report: Core Capture Flow

**Created:** 2026-04-23T14:30:00Z
**Theme:** Streamline the initial idea capture experience to reduce friction and improve triage velocity
**Target:** 2 weeks

## Wave Goal

This wave focuses on streamlining Arc's capture workflow to reduce the time from "rough idea" to "ready for shaping". By addressing manual triage bottlenecks and improving the capture-to-shape transition, we enable product teams to maintain a healthy backlog without administrative overhead. This directly supports the vision of lightweight product direction for spec-driven development.

## Selected Ideas

| # | Title | Priority | Summary |
|---|-------|----------|---------|
| 1 | [Add rewrite mode to arc-sync injection prompt](#add-rewrite-mode-to-arc-sync-injection-prompt) | P1-High | Enable arc-sync to rewrite existing READMEs holistically when injection markers are not yet present |
| 2 | [Remove time estimates from arc-wave](#remove-time-estimates-from-arc-wave) | P1-High | Eliminate effort estimation from wave planning to reduce planning overhead |
| 3 | [Fix stale arc-align path references](#fix-stale-arc-align-path-references) | P2-Medium | Correct stale documentation references that still point to the pre-rename `arc-align/` paths |

## Dependencies and Blockers

- Arc-sync rewrite mode depends on stabilization of the Arc-assess skill (completed in prior wave)
- Documentation reference fixes are independent and can be applied anytime
- None identified between the three selected ideas

## Engineering Readiness

- **Temper Phase:** Not available
- **Gate Status:** Not available
- **Failing Gates:** Not available
- **Delivery Risk:** Low
- **Recommendation:** Not available — Temper not configured

## Temper Context

**Phase:** Not available
**Hard gate failures:** Not available
**Scope constraint:** No constraints applied

## Handoff Instructions

For each spec-ready idea in this wave, proceed with the SDD pipeline:

1. Run `/cw-spec` with the idea's brief as input:
   - Copy the brief sections from `docs/BACKLOG.md#{IdeaAnchor}`
   - Use the brief's Problem, Proposed Solution, and Success Criteria as the spec starter prompt

2. After spec generation, continue with `/cw-plan` → `/cw-dispatch`

3. After implementation, run `/temper-audit` to evaluate gate status

### Per-Idea Handoff

| Idea | Status | Next Action |
|------|--------|-------------|
| Add rewrite mode to arc-sync injection prompt | spec-ready | `/cw-spec` — Enable READMEs to be rewritten holistically when ARC: markers are not yet present |
| Remove time estimates from arc-wave | spec-ready | `/cw-spec` — Strip time/effort estimates from wave workflow to simplify planning |
| Fix stale arc-align path references | spec-ready | `/cw-spec` — Correct documentation references pointing to pre-rename paths |

## Backlog Status

| Status | Count |
|--------|-------|
| Captured | 20 |
| Shaped | 0 |
| Spec-Ready | 3 |
| Shipped | 11 |
| **Total** | **34** |

---

## Acceptance Criteria

- [x] The rendered wave report contains a `**Target:**` line that states the captured timeframe verbatim (`2 weeks`)
- [x] Every `{SlotName}` placeholder from this template is replaced with a concrete value
- [x] All six top-level sections present in order: Wave Goal, Selected Ideas, Dependencies and Blockers, Engineering Readiness, Temper Context, Handoff Instructions, and Backlog Status
- [x] Backlog Status table shows counts for all four lifecycle stages plus a bolded Total row
- [x] Per-Idea Handoff table contains one row per idea selected, each with a non-empty `/cw-spec` next action summary
