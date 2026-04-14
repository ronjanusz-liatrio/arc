# Questions Round 1: Shape Skill Discovery

## Q1: Discovery Mechanism
**Question:** How should the feasibility subagent discover skills?
**Answer:** Run `/skillz-find` live — the feasibility subagent spawns `/skillz-find` with a query derived from the idea's problem domain. Fresh results each time.

## Q2: Output Integration
**Question:** What should the feasibility subagent do with discovered skills?
**Answer:** Add to feasibility output — append a "Relevant Skills" subsection to the feasibility assessment with skill names, relevance, and recommendations.

## Q3: Query Derivation
**Question:** How should the query for `/skillz-find` be derived?
**Answer:** Both — combine idea-derived keywords (from title + summary) with project context for broader discovery.

## Q4: Visibility
**Question:** Should the user see skill discovery results before the brief is finalized?
**Answer:** Show in synthesis — include skill discovery results in the Step 3 synthesis table alongside the other 4 dimensions.

## Pre-existing Context from Brief
- Graceful fallback: warn and continue when `/skillz` is not installed
- No hard dependency on `/skillz` — `/arc-shape` must remain functional without it
- Discovery results enrich the existing feasibility dimension, not a separate brief section
