# Shape Report: Skill discovery via /skillz during shaping

**Shaped:** 2026-04-14T00:00:00Z
**Idea:** Skill discovery via /skillz during shaping
**Status:** captured → shaped

## Before (Captured Stub)
Add a mandatory /skillz validation step to /arc-shape so ideas cannot be promoted to a wave without passing it.

## Subagent Analysis Summary

| Dimension | Rating | Key Finding |
|-----------|--------|-------------|
| Problem Clarity | Medium | "Passing /skillz" was ambiguous — reframed from gate to discovery during Q&A |
| Customer Fit | Weak | No persona directly owns this pain; coupling risk flagged |
| Scope | Small | Enriches existing feasibility subagent rather than adding a new workflow step |
| Feasibility | Needs spike | /skillz has no documented callable query API; new inter-plugin pattern |

## After (Shaped Brief)

### Problem

During `/arc-shape`'s feasibility analysis, there is no awareness of what skills are available in the `/skillz` marketplace. Shaped briefs may miss opportunities to leverage existing tooling or propose solutions that duplicate available capabilities. The result is that `/cw-spec` produces specs that don't account for the tooling landscape, leading to redundant work or missed integration opportunities.

### Proposed Solution

Enrich the feasibility dimension of `/arc-shape`'s parallel subagent analysis with a skill discovery step that queries `/skillz` for skills relevant to the problem being shaped, folding available tooling context into the feasibility assessment.

### Success Criteria

- The feasibility subagent queries `/skillz` for skills related to the idea's problem domain
- Discovered skills are surfaced in the feasibility assessment with their relevance to the idea
- The shaped brief's feasibility dimension reflects available tooling when `/skillz` is installed
- When `/skillz` is not installed, the user is warned and shaping proceeds normally

### Constraints

- Must not create a hard dependency on `/skillz` — `/arc-shape` must remain functional without it
- Discovery results enrich the existing feasibility dimension, not a separate brief section

### Assumptions

- `/skillz` exposes a search or query mechanism that can be invoked programmatically or via subagent
- Skill discovery results are meaningful at shaping time (before any code exists)

### Wave Assignment

Unassigned

### Open Questions

- How does the feasibility subagent invoke `/skillz` discovery? (Agent subagent with Skill tool, or direct invocation?)
- What query parameters map an idea's problem domain to relevant skills?

## Gaps Resolved During Q&A

- **Reframed from gate to discovery:** Original idea was a blocking "/skillz gate" — user clarified intent is skill discovery to inform design, not a pass/fail validation step
- **Placement:** User chose to enrich the existing feasibility dimension during `/arc-shape` (5th analysis concern within the feasibility subagent) rather than a new workflow step
- **Output integration:** User chose to fold discovery results into the feasibility dimension rather than a separate brief section
- **Fallback behavior:** User chose warn-and-continue when `/skillz` is not installed

## Open Questions Deferred

- How does the feasibility subagent invoke `/skillz` discovery? (Agent subagent with Skill tool, or direct invocation?)
- What query parameters map an idea's problem domain to relevant skills?
