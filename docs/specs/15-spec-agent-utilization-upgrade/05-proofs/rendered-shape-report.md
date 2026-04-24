# Shape Report: Add rewrite mode to arc-sync injection prompt

**Shaped:** 2026-04-23T11:45:00Z
**Idea:** Add rewrite mode to arc-sync injection prompt
**Status:** captured → shaped

## Before (Captured Stub)

When arc-sync detects injection mode (existing README without ARC: markers), offer a "Rewrite" option that reads the existing README holistically, re-homes content into ARC:/TEMPER: managed sections, previews the diff, and validates trust signals — existing prose is relocated, never deleted.

## Subagent Analysis Summary

| Dimension | Rating | Key Finding |
|-----------|--------|-------------|
| Problem Clarity | High | Pain point clearly identified: users with existing READMEs face friction when adopting Arc; current arc-sync only supports fresh injection, forcing manual merging |
| Customer Fit | Strong | Directly addresses the Tech Lead persona (managing existing projects) and Developer persona (contributing to projects mid-adoption) |
| Scope | Medium | Scope is well-bounded: extends arc-sync step 3 with a conditional "Rewrite" path; no new data structures or external dependencies |
| Feasibility | Ready | Fits existing arc-sync patterns; reuses current markdown parsing and diff preview infrastructure; no new infrastructure required |
| Skill Discovery | 2 skills found | difflib (Python standard library for diff generation) and mistune (existing markdown parser in use) — both already in dependencies |

## Relevant Skills

| Skill | Author | Installs/wk | Recommendation | Relevance |
|-------|--------|-------------|----------------|-----------|
| markdown-diff | klarna/code-templates | 42 | investigate | Provides structured diff output for complex markdown changes |
| linting-markdown | prettier | 156 | install | Arc uses Prettier for markdown formatting; consistent with existing toolchain |

## After (Shaped Brief)

### Problem

Product teams adopting Arc into existing projects face friction when their README.md already has content. Arc-sync currently only supports fresh injection (appending ARC: and TEMPER: sections to empty or ARC:-ready READMEs). Teams with established README content must manually merge, risking data loss or duplication. This blocks adoption for mid-stage projects.

### Proposed Solution

Extend arc-sync to detect README content and offer a "Rewrite" mode that reads the entire README holistically, relocates existing sections into ARC:/TEMPER: managed sections (preserving all content), generates a preview diff, and validates that trust signals remain intact after the transformation. Existing prose is relocated and reorganized, never deleted.

### Success Criteria

- Arc-sync detects existing README content and offers "Rewrite" as a manual option before proceeding
- After rewrite, all original content is preserved in the output (no deletions)
- Trust signal validation passes on the rewritten README (TS-1 through TS-10 from trust-signals.md)
- Generated diff preview allows the user to review changes before committing
- Rewritten README maintains consistent markdown formatting (uses Prettier)

### Constraints

- Time: Must complete within 1 week (P1-High priority, next wave candidate)
- Technical: Cannot modify the arc-sync step 1 or step 2 logic; only extends step 3
- Team: Requires one developer with knowledge of current markdown parsing and diff infrastructure

### Assumptions

- Existing README content can be parsed as markdown sections (edge case: binary or non-markdown content is out of scope)
- Trust signals are present in target README or can be validated against an empty set
- User will review the diff preview and explicitly confirm before the rewrite is saved

### Open Questions

- Should the rewrite mode preserve exact formatting of existing sections, or normalize to Arc's markdown style?
- If a section name conflicts between existing content and ARC:/TEMPER: sections, which takes precedence?

## Gaps Resolved During Q&A

- **Scope clarity** → Confirmed that rewrite only modifies README.md, not other files; wave planning ROADMAP or BACKLOG updates are out of scope
- **Safety concerns** → Clarified that no content is deleted, only relocated; user reviews diff before confirming
- **Integration point** → Confirmed that rewrite extends step 3 of arc-sync (after metadata collection, before final output)

## Open Questions Deferred

- Batch rewrite mode (applying the same rewrite to multiple projects) deferred to a follow-up wave
- Automated metadata extraction from existing README structure deferred to spec phase exploration

---

## Acceptance Criteria

- [x] Subagent Analysis Summary table contains all five dimensions (Problem Clarity, Customer Fit, Scope, Feasibility, Skill Discovery) with ratings and key findings
- [x] After (Shaped Brief) section contains all six required subsections in order: Problem, Proposed Solution, Success Criteria, Constraints, Assumptions, Open Questions — each with non-placeholder values
- [x] Gaps Resolved During Q&A lists three entries explicitly describing what was clarified
- [x] Open Questions Deferred lists two deferred questions for later phases
- [x] Every `{SlotName}` placeholder replaced with concrete value — no literal `{...}` text remains
