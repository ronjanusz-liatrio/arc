# Clarifying Questions — Round 1

**Date:** 2026-04-07

## Q1: Scope — Single spec or split?
**Answer:** Single spec (Recommended)
All 7 demoable units in one spec — components are tightly coupled and the plugin is pure markdown.

## Q2: BACKLOG storage format
**Answer:** Open to suggestions
User deferred to spec author's recommendation.

**Recommendation:** Inline sections with summary table header. Each idea is a `## Title` section in BACKLOG.md. Captured ideas are stubs (title, summary, priority, status). Shaped ideas expand with full brief subsections (Problem, Proposed Solution, Success Criteria, Constraints, Assumptions). Summary table at top provides scannable overview.

## Q3: arc-shape subagent pattern
**Answer:** Parallel subagents
v1 uses the full parallel subagent pattern — multi-dimensional analysis (problem clarity, customer fit, scope, feasibility).

## Q4: Temper management report integration
**Answer:** Read if present
v1 checks for docs/management-report.md and uses gate results/phase info to constrain wave scope. Graceful no-op if missing.
