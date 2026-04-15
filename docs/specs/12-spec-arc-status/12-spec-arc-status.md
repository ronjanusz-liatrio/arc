# 12-spec-arc-status

## Introduction/Overview

Introduce `/arc-status` — a fast, read-only pulse check that summarizes the current state of the project across Arc artifacts (`BACKLOG.md`, `ROADMAP.md`), claude-workflow pipeline state (spec directories, task boards, validation reports), and recent git momentum. The output is an inline terminal summary showing where the project is today, what's complete, what's next, and which skill to run to make progress.

## Goals

1. Aggregate project state from Arc + claude-workflow + git into a single terminal summary in under a few seconds
2. Surface the current wave's progress (shipped vs. in-flight idea counts, remaining work)
3. Detect lifecycle gaps between stages (captured→shaped, shaped→spec, spec→plan, plan→validation, validation→shipped)
4. Suggest the single most relevant next skill invocation based on the pulse findings
5. Remain strictly read-only — no file writes, no mutations to existing artifacts

## User Stories

- As a product owner returning to the project after context switching, I want to run `/arc-status` and see in one summary where the project stands so I can resume work without re-reading every artifact.
- As a tech lead planning the day's work, I want `/arc-status` to tell me which idea is ready for the next pipeline stage so I don't waste time triaging the backlog.
- As a developer mid-wave, I want `/arc-status` to flag lifecycle gaps (e.g., a shaped idea with no spec, or a validated idea not yet shipped) so nothing stalls silently.
- As a new contributor joining the repo, I want `/arc-status` to show recent momentum via git commits so I understand what the team has been working on lately.

## Demoable Units of Work

### Unit 1: Core Pulse Check — Data Aggregation and Inline Summary

**Purpose:** Create the `/arc-status` skill that reads Arc + claude-workflow + git state and emits a structured inline summary.

**Functional Requirements:**

- The system shall provide a new skill at `skills/arc-status/SKILL.md` with `user-invocable: true` and frontmatter `allowed-tools: Glob, Grep, Read, Bash, AskUserQuestion, Skill`
- The system shall begin its response with the context marker `**ARC-STATUS**`
- The system shall read `docs/BACKLOG.md` and parse the summary table to count ideas per status (captured, shaped, spec-ready, shipped)
- The system shall read `docs/ROADMAP.md` (if present) and parse the wave summary table to identify the current non-completed wave
- The system shall glob `docs/specs/NN-spec-*/` directories and detect the presence of spec file, task board (via `cw-plan` output marker or TaskList), and validation report files (`NN-validation-*.md`)
- The system shall run `git log --oneline -10` to capture recent commit momentum
- The system shall emit an inline summary with these sections: "Current Wave", "Backlog Snapshot", "In-Flight Specs", "Recent Activity"
- The system shall not write any files — output is inline only
- The system shall handle missing artifacts gracefully (no ROADMAP.md, no specs directory, etc.) with a single-line notice and continue

**Proof Artifacts:**

- File: `skills/arc-status/SKILL.md` exists with the required frontmatter, context marker, and four summary sections defined in Process
- CLI: Running `/arc-status` in this repo emits an inline summary beginning with `**ARC-STATUS**` and including all four sections, in under a few seconds, without writing any files
- File: `skills/arc-status/references/status-dimensions.md` exists with the detection logic for each summary section

### Unit 2: Lifecycle Gap Detection

**Purpose:** Extend the pulse check to detect and report gaps between lifecycle stages across Arc and claude-workflow.

**Functional Requirements:**

- The system shall detect the following stage gaps and include a "Lifecycle Gaps" section in the inline summary:
  - **Captured→Shaped**: ideas with `Status: captured` and no `Shaped:` timestamp
  - **Shaped→Spec**: ideas with `Status: shaped` and no `Spec:` field, OR `Spec:` field points to a non-existent directory
  - **Spec→Plan**: spec directories containing a spec file but no evidence of `cw-plan` execution (no task board reference or no `plan-*` files)
  - **Plan→Validation**: spec directories with planned/executed tasks but no `NN-validation-*.md` file
  - **Validation→Shipped**: validation reports containing `**Overall**: PASS` where the linked BACKLOG idea still has `Status: spec-ready` (not `shipped`)
- The system shall report each detected gap with: stage name, idea title (or spec name), and a one-line remediation hint (which skill to run next)
- The system shall display "No lifecycle gaps detected" when all stages are in sync
- The system shall treat detection failures (e.g., unreadable spec file) as a skipped check with a warning, not a hard error
- The detection logic shall be documented in `skills/arc-status/references/status-dimensions.md`

**Proof Artifacts:**

- File: `skills/arc-status/SKILL.md` contains a "Lifecycle Gaps" step with detection rules for all five gaps
- File: `skills/arc-status/references/status-dimensions.md` contains detection rules for all five gaps with pattern/predicate definitions
- CLI: Running `/arc-status` on this repo reports any lifecycle gaps that exist (at minimum, the Validation→Shipped check must execute for spec 11 once its validation PASS is produced)
- CLI: Running `/arc-status` on a repo with no gaps prints "No lifecycle gaps detected"

### Unit 3: Next-Step Suggestion

**Purpose:** After the summary is displayed, offer the user the single most relevant next skill invocation via AskUserQuestion, based on the pulse findings.

**Functional Requirements:**

- The system shall select a recommended next action using this precedence (first match wins):
  1. A Validation→Shipped gap exists → suggest `/arc-ship`
  2. A Plan→Validation gap exists → suggest `/cw-validate`
  3. A Spec→Plan gap exists → suggest `/cw-plan`
  4. A Shaped→Spec gap exists → suggest `/cw-spec`
  5. A Captured→Shaped gap exists on a P0/P1 idea → suggest `/arc-shape`
  6. No gaps and current wave in progress → suggest `/arc-wave` rollup or `/arc-audit` health check
  7. No gaps and no current wave → suggest `/arc-wave` to plan a new one
- The system shall present the recommendation via AskUserQuestion with at least 3 options: the recommended skill (labeled with "(Recommended)"), one alternative skill, and "Done for now"
- When the user selects the recommended or alternative skill, the system shall invoke it via the `Skill` tool
- When the user selects "Done for now", the system shall exit silently
- The AskUserQuestion prompt shall include the reason for the recommendation (e.g., "Spec 11 has a validation PASS but is still spec-ready — ship it?")
- The system shall not invoke any skill without user confirmation

**Proof Artifacts:**

- File: `skills/arc-status/SKILL.md` contains the Next-Step Suggestion step with the precedence list and AskUserQuestion/Skill invocation pattern
- CLI: Running `/arc-status` on this repo after gap detection presents an AskUserQuestion with a recommended option marked "(Recommended)"
- CLI: Selecting "Done for now" exits without invoking any skill

## Non-Goals (Out of Scope)

- Writing a status report file to `docs/skill/arc/` — the summary is inline only (revisit if persistent history becomes a need)
- Modifying BACKLOG or ROADMAP based on findings — `/arc-status` is strictly read-only; mutations belong to `/arc-audit`, `/arc-ship`, etc.
- Deep backlog health analysis (stale-idea detection, priority imbalance, duplicate detection) — that is `/arc-audit`'s job; `/arc-status` defers to it via suggestion, not by running it
- Cross-repo status aggregation — single-repo scope only
- Temper phase integration — not in scope for this spec
- Interactive filtering (by priority, wave, etc.) — the summary is a single canonical view

## Design Considerations

No UI components. The skill is a SKILL.md definition with an associated `references/status-dimensions.md` and inline terminal output formatted in plain markdown. Section headers use the same visual conventions as existing Arc skills (bold section labels, tables where appropriate).

## Repository Standards

- SKILL.md files follow the existing frontmatter + markdown structure in `skills/arc-*/`
- Reference docs live in `skills/arc-status/references/` and follow the format used by `skills/arc-audit/references/audit-dimensions.md`
- Conventional commits: `feat(arc-status): description` for new work, `docs(arc-status): description` for reference docs
- No code files — all artifacts are markdown

## Technical Considerations

- `/arc-status` uses `Bash` for a single `git log --oneline -10` invocation; all other reads use `Read`/`Glob`/`Grep`
- Parsing BACKLOG.md status counts reuses the same summary-table-row pattern used by `/arc-audit` — detection via `Grep` on `| status |` column
- Lifecycle gap detection for `Spec→Plan` cannot inspect the claude-workflow TaskList directly (no file-backed task board for CW tasks in this repo); instead, presence of a `plan-*` or `tasks-*` artifact in the spec directory OR a commit referencing `(T0` in the last 30 commits serves as the plan-executed signal. The precise predicate is documented in `references/status-dimensions.md`
- Validation report detection uses a glob for `NN-validation-*.md` inside each spec directory; "PASS" detection via `Grep` for the literal string `**Overall**: PASS`
- No new dependencies; no new tools need to be added to arc's `allowed-tools` — the skill defines its own frontmatter
- The skill is independent of `/skillz` and all other companion plugins — it only reads in-repo state

## Security Considerations

- Read-only operation — no file writes, no shell execution beyond `git log`
- No external network calls, no API keys, no authentication
- No credentials or secrets are read; the skill only inspects markdown and git metadata already in the working tree

## Success Metrics

- `/arc-status` emits a four-section summary in under a few seconds on this repo
- Lifecycle gap detection correctly identifies at least one known gap in this repo (or reports "no gaps" truthfully)
- When run after `/cw-validate` produces a PASS for spec 11, the Validation→Shipped gap is detected and `/arc-ship` is recommended as the next step
- No false positives on a clean repo where all lifecycle stages are in sync

## Open Questions

- No open questions at this time.
