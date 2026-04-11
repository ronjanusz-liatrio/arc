# 07-spec-capture-speedup

## Introduction/Overview

The `/arc-capture` skill currently requires 3-4 sequential interactive prompts to record a single idea (title, summary, priority, then a "what next?" menu). This spec reduces the interaction to 1-2 prompts by consolidating input gathering, combining confirmation with priority selection, and removing the post-capture "next steps" menu so control returns immediately to the calling workflow.

## Goals

1. Reduce inline capture (idea provided in invocation) to exactly 1 interactive prompt
2. Reduce full interactive capture (no idea provided) to exactly 2 interactive prompts
3. Collect priority as part of the confirmation prompt — no separate priority step
4. Eliminate the post-capture "next steps" menu entirely
5. Preserve all existing backlog data fields (title, summary, priority, status, timestamp)

## User Stories

- As a user running `/arc-capture` mid-workflow, I want the idea recorded in one prompt so I can return to what I was doing without losing context.
- As a user providing an idea inline, I want to confirm what was parsed and set priority in a single interaction.
- As a user running `/arc-capture` without an inline idea, I want to describe my idea once in free text and then confirm + prioritize.

## Demoable Units of Work

### Unit 1: Consolidated Capture Flow

**Purpose:** Replace the 3-step input gathering (title → summary → priority) and post-capture menu with a streamlined 1-2 prompt flow.

**Functional Requirements:**

- The system shall accept an inline idea from the invocation args and parse it into a title and one-line summary using the AI's judgment.
- When an inline idea is provided, the system shall present a single AskUserQuestion with two questions:
  1. A confirmation question showing the parsed title and summary, with options "Looks good" and "Adjust" (plus the built-in "Other" for free-text correction).
  2. A priority question with options P0-Critical, P1-High, P2-Medium, P3-Low.
- When no inline idea is provided, the system shall first present a single free-text AskUserQuestion asking the user to describe their idea in a sentence or two.
- After receiving the free-text description, the system shall parse it into title and summary and present the same confirmation + priority prompt as the inline flow.
- If the user selects "Adjust" or provides free-text via "Other", the system shall re-parse and re-present confirmation + priority (max 1 retry, then capture as-is).
- The system shall enrich captured ideas with relevant context from the current conversation when available (e.g., if capture is invoked during a shaping session, note what was being discussed).
- The system shall not write to `docs/BACKLOG.md` until both confirmation and priority are collected — no default priority.
- After writing to the backlog, the system shall print a single confirmation line: `Captured "{Title}" (priority: {Priority}) to docs/BACKLOG.md.`
- The system shall NOT present any "next steps" menu after confirmation — control returns immediately.

**Proof Artifacts:**

- File: `skills/arc-capture/SKILL.md` contains single-AskUserQuestion confirmation+priority flow
- File: `skills/arc-capture/SKILL.md` does not contain Step 5 "Offer Next Steps" or "What would you like to do next?"
- CLI: `/arc-capture add dark mode support` triggers exactly 1 AskUserQuestion interaction before writing to backlog

### Unit 2: Backlog Write Logic Preserved

**Purpose:** Ensure the backlog append logic (summary table row + idea section) is unchanged and all data fields remain intact.

**Functional Requirements:**

- The system shall continue to create `docs/BACKLOG.md` from the template if it does not exist (Step 2 unchanged).
- The system shall continue to add a summary table row with format `| [{Title}](#{anchor}) | captured | {Priority} | -- |`.
- The system shall continue to append an idea section with Status, Priority, Captured timestamp, and one-line summary.
- The system shall use ISO 8601 timestamps for the Captured field.
- The anchor link format shall remain: title lowercase, hyphens for spaces, stripped special characters.

**Proof Artifacts:**

- File: `skills/arc-capture/SKILL.md` contains summary table row format with `| [{Title}](#{anchor}) | captured | {Priority} | -- |`
- File: `skills/arc-capture/SKILL.md` contains idea section format with Status, Priority, Captured, and summary fields

## Non-Goals (Out of Scope)

- Changing the backlog data format or adding new fields
- Modifying `/arc-shape`, `/arc-wave`, or any other skill
- Adding batch capture (multiple ideas at once)
- Changing priority levels or their definitions
- Modifying the BACKLOG template

## Design Considerations

No specific design requirements identified. The AskUserQuestion UI is the only interaction surface.

## Repository Standards

- Skill files use YAML frontmatter with `name`, `description`, `user-invocable`, `allowed-tools`
- AskUserQuestion calls follow Claude Code conventions (max 4 questions, 2-4 options each, headers ≤12 chars)
- Conventional commits: `feat(arc-capture): description`

## Technical Considerations

- The skill file is pure markdown — no code execution. Changes are to the SKILL.md prompt instructions only.
- AskUserQuestion supports multi-question prompts (up to 4 questions per call), enabling confirmation + priority in one interaction.
- The "Other" option is automatically available on all AskUserQuestion prompts, providing the free-text input path.
- Context enrichment relies on the AI reading the current conversation — no new tool calls needed.

## Security Considerations

No security implications — this is a prompt-only change to a local skill file.

## Success Metrics

- Inline capture: 1 interactive prompt (down from 4)
- Full capture: 2 interactive prompts (down from 4)
- Zero post-capture menu interactions
- All existing backlog fields preserved

## Open Questions

No open questions at this time.
