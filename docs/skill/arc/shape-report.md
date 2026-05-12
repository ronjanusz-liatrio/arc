# Shape Report: Classify shipped-spec user stories as merge candidates in arc-assess

**Shaped:** 2026-05-08T18:30:00Z
**Idea:** Classify shipped-spec user stories as merge candidates in arc-assess
**Status:** captured → shaped

## Before (Captured Stub)

Enhance `/arc-assess` classification rules to detect when a KW-19 user story originates from a spec with `status: shipped` (via BACKLOG summary table or spec metadata). Instead of creating a new captured stub, flag the story as a merge candidate for the corresponding shipped skill entry's `### User Stories` subsection — automating what spec 08 did manually.

## Subagent Analysis Summary

| Dimension | Rating | Key Finding |
|-----------|--------|-------------|
| Problem Clarity | High | Tech Lead safe-rerun JTBD; 9 duplicate stubs re-created on 2026-04-13 |
| Customer Fit | Strong | Reinforces spec-08 single-representation invariant |
| Scope | Medium | Original framing predates spec 13; re-anchored on wave archive |
| Feasibility | Ready | Spec-08 prior-art Gherkin available; existing KW-19 branching pattern fits |
| Skill Discovery | Skipped | Not relevant for in-skill prose edit |

## Relevant Skills

> Skill discovery was skipped — not relevant for in-skill prose edit.

## After (Shaped Brief)

### Problem

When `/arc-assess` re-scans a repo whose specs have already shipped, KW-19 (`## User Stories`) matches in shipped spec files re-classify those stories as new captured BACKLOG stubs. The 2026-04-13 re-run produced 9 duplicate captured stubs from shipped specs (08, 09, 01-align-ignore-dirs); only manual user intervention prevented re-duplication. This violates the spec-08 single-representation invariant and breaks the Tech Lead's safe-rerun JTBD — running `/arc-assess` twice should be idempotent. The original captured framing referenced BACKLOG `status: shipped`, but spec 13 (wave-archive) moved shipped state out of BACKLOG into `docs/skill/arc/waves/*.md`, so detection must re-anchor on the wave archive.

### Proposed Solution

Add a "merge-candidate" sub-branch to the KW-19 classification rule in `skills/arc-assess/SKILL.md` and `references/import-rules.md`. Build a shipped-spec index from `docs/skill/arc/waves/*.md` using both signals (`### {Title}` subsection match OR `**Spec:** {path}` field match, OR'd). When KW-19 fires on a source inside a shipped spec dir, emit a `merge-candidate` row in `align-report.md` (source path + line range, target wave archive, target skill heading, provenance) instead of creating a captured stub. Multi-match cases list all candidates and require user confirmation. Persona extraction continues to run for shipped-spec stories. No auto-rewrite, no manifest entry.

### Success Criteria

- Re-running `/arc-assess` on the current repo produces zero duplicate captured stubs for user stories that originate in specs already in the wave archive.
- The 9 user stories duplicated on 2026-04-13 classify as `merge-candidate` rows on a fresh re-run.
- Multi-spec matches surface all candidates and require user confirmation.
- Persona extraction still produces CUSTOMER.md updates for shipped-spec stories.
- Detection is idempotent across repeat runs.
- Existing KW-1..KW-18 and KW-20..KW-22 classification behavior unchanged.

### Constraints

- Must not auto-rewrite wave archive `### User Stories` blocks.
- Wave archive is the single source of truth for shipped state.
- Do not modify already-completed spec-08 manual merges.
- All edits target prose in `skills/arc-assess/SKILL.md` and references.
- Must remain compatible with `align-manifest.md` schema (no merge-candidate manifest rows).

### Assumptions

- Shipped-spec index built from a bounded set of wave archive files (currently 5).
- Spec 08's prior-art Gherkin provides reusable scenarios for `/cw-spec`.
- KW-19 branching pattern in `import-rules.md` accommodates the new "shipped-spec" branch.
- A future skill or manual workflow performs the actual merge edit — out of scope here.

### Open Questions

- None

## Gaps Resolved During Q&A

- Shipped detection signal → both signals OR'd (`### {Title}` subsection title and `**Spec:**` field value).
- Multi-match disambiguation → list all candidates in align-report; user picks during interactive confirmation.
- Output format → report-only annotation; no manifest row; no auto-rewrite.
- Persona extraction behavior → continue running for shipped-spec stories; only suppress the captured-stub creation.

## Open Questions Deferred

- None
