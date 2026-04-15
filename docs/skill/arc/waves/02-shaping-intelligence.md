# Wave 2: Shaping Intelligence

- **Theme:** Make arc-shape smarter with external skill awareness
- **Goal:** Enrich `/arc-shape`'s feasibility analysis with `/skillz` skill discovery so shaped briefs account for available tooling before entering `/cw-spec`
- **Target:** 1-2 weeks
- **Completed:** 2026-04-15T00:00:00Z

## Shipped Ideas

### Skill discovery via /skillz during shaping

- **Status:** shipped
- **Priority:** P1-High
- **Captured:** 2026-04-14T00:00:00Z
- **Shaped:** 2026-04-14T00:00:00Z
- **Shipped:** 2026-04-15T00:00:00Z
- **Wave:** Wave 2: Shaping Intelligence
- **Spec:** docs/specs/11-spec-shape-skill-discovery/

Before entering /cw-spec, query /skillz for available skills relevant to the problem being shaped, so the design can account for existing tooling.

#### Problem

During `/arc-shape`'s feasibility analysis, there is no awareness of what skills are available in the `/skillz` marketplace. Shaped briefs may miss opportunities to leverage existing tooling or propose solutions that duplicate available capabilities. The result is that `/cw-spec` produces specs that don't account for the tooling landscape, leading to redundant work or missed integration opportunities.

#### Proposed Solution

Enrich the feasibility dimension of `/arc-shape`'s parallel subagent analysis with a skill discovery step that queries `/skillz` for skills relevant to the problem being shaped, folding available tooling context into the feasibility assessment.

#### Success Criteria

- The feasibility subagent queries `/skillz` for skills related to the idea's problem domain
- Discovered skills are surfaced in the feasibility assessment with their relevance to the idea
- The shaped brief's feasibility dimension reflects available tooling when `/skillz` is installed
- When `/skillz` is not installed, the user is warned and shaping proceeds normally

#### Constraints

- Must not create a hard dependency on `/skillz` — `/arc-shape` must remain functional without it
- Discovery results enrich the existing feasibility dimension, not a separate brief section

#### Assumptions

- `/skillz` exposes a search or query mechanism that can be invoked programmatically or via subagent
- Skill discovery results are meaningful at shaping time (before any code exists)

#### Open Questions

- How does the feasibility subagent invoke `/skillz` discovery? (Agent subagent with Skill tool, or direct invocation?)
- What query parameters map an idea's problem domain to relevant skills?
