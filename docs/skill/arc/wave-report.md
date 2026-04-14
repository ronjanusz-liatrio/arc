# Wave Report: Lifecycle Closure

**Created:** 2026-04-14T00:00:00Z
**Theme:** Complete the Arc idea lifecycle by automating the shipped transition
**Target:** 1-2 weeks

## Wave Goal

Arc automates every lifecycle transition except the final one — marking an idea as shipped after the SDD pipeline completes. This wave closes that loop by delivering `/arc-ship`, which verifies cw-validate proof artifacts and transitions BACKLOG status to shipped. This completes the pipeline continuity strategic goal from VISION.md (Goal 5) and prevents the drift risk that led to spec 08's manual cleanup.

## Selected Ideas

| # | Title | Priority | Summary |
|---|-------|----------|---------|
| 1 | [/arc-ship skill](docs/BACKLOG.md#arc-ship-skill) | P1-High | Automates the final lifecycle transition — verifies proof artifacts and marks ideas as shipped |

## Dependencies and Blockers

- None identified

## Engineering Readiness

- **Temper Phase:** Not available — Temper not configured
- **Gate Status:** Not available
- **Failing Gates:** Not available
- **Delivery Risk:** Low — single idea, follows established SKILL.md patterns, well-shaped brief with all gaps resolved
- **Recommendation:** Proceed without constraints

## Temper Context

> No Temper management report available. Wave planned without phase constraints.

## Handoff Instructions

For each spec-ready idea in this wave, proceed with the SDD pipeline:

1. Run `/cw-spec` with the idea's brief as input:
   - Copy the brief sections from `docs/BACKLOG.md#arc-ship-skill`
   - Use the brief's Problem, Proposed Solution, and Success Criteria as the spec starter prompt

2. After spec generation, continue with `/cw-plan` → `/cw-dispatch`

3. After implementation, run `/cw-validate` to verify gates

### Per-Idea Handoff

| Idea | Status | Next Action |
|------|--------|-------------|
| /arc-ship skill | spec-ready | `/cw-spec` — New skill to verify cw-validate proof artifacts and transition BACKLOG status to shipped, with batch mode, ROADMAP rollup, and Spec field backfill |

## Backlog Status

| Status | Count |
|--------|-------|
| Captured | 19 |
| Shaped | 0 |
| Spec-Ready | 1 |
| Shipped | 7 |
| **Total** | **27** |
