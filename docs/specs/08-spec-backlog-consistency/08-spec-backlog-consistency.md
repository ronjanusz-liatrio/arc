# 08-spec-backlog-consistency

## Introduction/Overview

The `/arc-assess` import created duplicate representations in `docs/BACKLOG.md`: 28 captured user stories describe capabilities already shipped in the 7 skill entries. Additionally, `docs/VISION.md` contains redundant aligned-from blocks and `README.md` has a stale lifecycle count and an incorrect pipeline diagram label. This spec addresses all consistency issues identified in the pre-spec review.

## Goals

1. Eliminate duplicate representation — every shipped capability appears once, not twice
2. Enrich shipped skill entries with user-story context from the captured stubs they subsume
3. Retroactively assign all 7 shipped skills to "Wave 0: Bootstrap"
4. Deduplicate VISION.md by removing redundant aligned-from blocks
5. Fix README.md lifecycle count and pipeline diagram label

## User Stories

- As a product owner reading the backlog, I want each capability represented once so the captured/shipped counts reflect reality
- As a developer reviewing VISION.md, I want a clean document without repeated content blocks
- As a reader of the README, I want the lifecycle diagram counts and pipeline labels to be accurate

## Demoable Units of Work

### Unit 1: Merge Captured User Stories into Shipped Skill Entries

**Purpose:** Consolidate 28 captured user stories into the 7 shipped skill entries they belong to, then remove the captured stubs. This is the core cleanup.

**Functional Requirements:**

- The system shall append user-story text from each captured stub as a `### User Stories` subsection under the corresponding shipped skill entry
- The system shall preserve `<!-- aligned-from -->` comments from the captured stubs when merging (provenance retention)
- The system shall remove the 28 captured stub sections (`## {Title}`) from BACKLOG.md after merging
- The system shall remove the corresponding 28 rows from the BACKLOG summary table
- The system shall update each shipped skill entry's wave field from `--` to `Wave 0: Bootstrap`
- The system shall update the summary table rows for all 7 shipped items to show `Wave 0: Bootstrap`
- The system shall NOT modify any captured items that are NOT duplicates of shipped capabilities (deferred items, "Add rewrite mode", etc.)

**Captured-to-Skill Mapping:**

| Captured Item | Target Shipped Skill |
|---|---|
| Quick idea capture | /arc-capture skill |
| Interactive idea refinement | /arc-shape skill |
| Organize ideas into delivery waves | /arc-wave skill |
| Product direction as markdown in repo | /arc-wave skill |
| Idea pipeline respects Temper constraints | /arc-wave skill |
| Audit backlog health | /arc-audit skill |
| Cross-reference integrity between artifacts | /arc-audit skill |
| Error-path scenario documentation | /arc-audit skill |
| Interactive audit fix application | /arc-audit skill |
| Consolidate scattered product direction | /arc-assess skill |
| Migrate TODO items from READMEs | /arc-assess skill |
| Idempotent re-run safety | /arc-assess skill |
| README features reflect shipped items | /arc-sync skill |
| README shows current wave and roadmap | /arc-sync skill |
| Warn on stale README sections | /arc-audit skill |
| Scaffold README from VISION docs | /arc-sync skill |
| Structural trust validation for README | /arc-sync skill |
| Quick reference for all Arc skills | /arc-help skill |
| Recall workflow order from terminal | /arc-help skill |
| Install instructions for Arc setup | /arc-help skill |
| Extract product direction from existing specs | /arc-assess skill |
| Consolidate code TODOs into BACKLOG | /arc-assess skill |
| Gap analysis before import | /arc-assess skill |
| Deep exploration via cw-research | /arc-assess skill |
| Separate Arc reports from product artifacts | /arc-assess skill |
| Record idea in one prompt mid-workflow | /arc-capture skill |
| Confirm and prioritize in single interaction | /arc-capture skill |
| Free-text idea description then confirm | /arc-capture skill |

**Proof Artifacts:**

- File: `docs/BACKLOG.md` summary table contains exactly 7 shipped rows and no rows for the 28 merged items
- File: `docs/BACKLOG.md` shipped skill sections each contain a `### User Stories` subsection with merged content
- File: `docs/BACKLOG.md` all shipped rows show `Wave 0: Bootstrap` in the Wave column
- CLI: `grep -c '| captured |' docs/BACKLOG.md` returns count equal to (original captured count minus 28)
- CLI: `grep -c '| shipped |' docs/BACKLOG.md` returns 7

### Unit 2: Deduplicate VISION.md

**Purpose:** Remove redundant `<!-- aligned-from -->` blocks from VISION.md that repeat content already present in the clean summary sections.

**Functional Requirements:**

- The system shall retain the clean summary sections: Vision Summary, Problem Statement, Value Proposition (lines 1-16)
- The system shall remove the `## Imported Content` heading and all `<!-- aligned-from -->` blocks that duplicate content from the summary sections
- The system shall retain any `<!-- aligned-from -->` blocks that contain content NOT already in the summary (e.g., strategic goals, quality goals, discovery goals, readme goals, help goals, assessment goals, capture goals that are structured differently)
- The system shall preserve heading hierarchy and readability

**Proof Artifacts:**

- File: `docs/VISION.md` contains no `## Imported Content` heading
- File: `docs/VISION.md` retains Vision Summary, Problem Statement, and Value Proposition sections
- File: `docs/VISION.md` retains strategic goals and other non-redundant content with their aligned-from provenance

### Unit 3: Fix README.md Inconsistencies

**Purpose:** Correct the pipeline diagram label and update the lifecycle count to match the post-cleanup BACKLOG state.

**Functional Requirements:**

- The system shall change the pipeline diagram edge label from `"shaped brief"` to `"spec-ready brief"` on the `AW -->|...|CS` line in README.md
- The system shall update the `ARC:lifecycle-diagram` Mermaid state labels to reflect the post-cleanup counts:
  - `Captured({N})` where N = remaining captured items after merge
  - `Shipped(7)` (unchanged)
  - `Shaped(0)` and `Spec-Ready(0)` (unchanged)

**Proof Artifacts:**

- File: `README.md` contains `"spec-ready brief"` and does NOT contain `"shaped brief"`
- File: `README.md` lifecycle diagram `Captured` count matches `grep -c '| captured |' docs/BACKLOG.md`

## Non-Goals (Out of Scope)

- Triaging priorities on the remaining captured items (all stay at their current P2/P3)
- Creating ROADMAP.md or populating the `ARC:roadmap` section
- Modifying CUSTOMER.md
- Running `/arc-sync` to refresh other README sections (can be done separately)
- Resolving the VISION/README "Linear inspiration" messaging difference (editorial choice)

## Design Considerations

No specific design requirements identified. All changes are markdown content edits.

## Repository Standards

- Conventional commits: `docs(arc): description`
- BACKLOG entry format: `## {Title}` with inline metadata fields
- Summary table format: `| [Title](#anchor) | status | priority | wave |`
- Aligned-from comments: `<!-- aligned-from: path:lines -->` retained for provenance

## Technical Considerations

- BACKLOG.md summary table anchors must remain valid after removing rows — verify all `[Title](#anchor)` links point to existing `## {Title}` sections
- When merging user stories into shipped entries, append after the one-line description and before any closing content
- The lifecycle diagram count must be computed AFTER the merge, not before
- Keep aligned-from comments from merged stubs so provenance chain is preserved

## Security Considerations

No security concerns — all changes are documentation edits to tracked markdown files.

## Success Metrics

- BACKLOG summary table row count = (pre-cleanup count) - 28
- Zero captured items that describe already-shipped capabilities
- VISION.md line count reduced by removing duplicate content
- README lifecycle diagram counts match actual BACKLOG state
- All internal markdown anchor links resolve correctly

## Open Questions

No open questions at this time.
