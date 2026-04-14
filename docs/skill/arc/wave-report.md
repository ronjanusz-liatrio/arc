# Wave Report: Shaping Intelligence

**Created:** 2026-04-14T00:00:00Z
**Theme:** Make arc-shape smarter with external skill awareness
**Target:** 1-2 weeks

## Wave Goal

Arc's shaping pipeline currently analyzes ideas across four dimensions but has no awareness of the broader skill ecosystem. This wave adds skill discovery via `/skillz` to the feasibility analysis, so shaped briefs entering `/cw-spec` account for available tooling — reducing redundant work and surfacing integration opportunities that would otherwise be missed.

## Selected Ideas

| # | Title | Priority | Summary |
|---|-------|----------|---------|
| 1 | [Skill discovery via /skillz during shaping](docs/BACKLOG.md#skill-discovery-via-skillz-during-shaping) | P1-High | Enrich feasibility dimension with /skillz marketplace discovery |

## Dependencies and Blockers

- None identified

## Engineering Readiness

- **Temper Phase:** Not available — Temper not configured
- **Gate Status:** Not available
- **Failing Gates:** Not available
- **Delivery Risk:** Medium — new inter-plugin integration pattern with no existing precedent in the codebase
- **Recommendation:** Spike the /skillz query mechanism early to validate the assumption that skill discovery is programmatically accessible

## Temper Context

**Phase:** Not available
**Hard gate failures:** Not available
**Scope constraint:** No constraints applied

> No Temper management report available. Wave planned without phase constraints.

## Handoff Instructions

For each spec-ready idea in this wave, proceed with the SDD pipeline:

1. Run `/cw-spec` with the idea's brief as input:
   - Copy the brief sections from `docs/BACKLOG.md#skill-discovery-via-skillz-during-shaping`
   - Use the brief's Problem, Proposed Solution, and Success Criteria as the spec starter prompt

2. After spec generation, continue with `/cw-plan` → `/cw-dispatch`

3. After implementation, run `/cw-validate` to verify gates

### Per-Idea Handoff

| Idea | Status | Next Action |
|------|--------|-------------|
| Skill discovery via /skillz during shaping | spec-ready | `/cw-spec` — Enrich arc-shape feasibility with /skillz skill discovery |

## Backlog Status

| Status | Count |
|--------|-------|
| Captured | 20 |
| Shaped | 0 |
| Spec-Ready | 1 |
| Shipped | 8 |
| **Total** | **29** |
