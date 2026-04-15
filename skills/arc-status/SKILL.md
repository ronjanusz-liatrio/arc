---
name: arc-status
description: "Project pulse check — summarize current wave, backlog, in-flight specs, and recent activity in one inline view"
user-invocable: true
allowed-tools: Glob, Grep, Read, Bash, AskUserQuestion, Skill
---

# /arc-status — Project Pulse Check

## Context Marker

Always begin your response with: **ARC-STATUS**

## Overview

You perform a fast, read-only pulse check across Arc artifacts and git history, then emit a single inline summary showing where the project stands. The output covers five dimensions: the current delivery wave, backlog status distribution, in-flight spec pipeline progress, recent git momentum, and lifecycle gap detection. No files are written — the summary is inline only.

## Critical Constraints

- **NEVER** write, create, or modify any files — this skill is strictly read-only
- **NEVER** abort on a missing optional artifact — emit the section's fallback notice and continue to the next section
- **ALWAYS** begin your response with `**ARC-STATUS**`
- **ALWAYS** emit all five summary sections in order, even when individual sections fall back to a notice
- **ALWAYS** handle parse errors gracefully — report what could not be parsed and continue
- **ALWAYS** treat lifecycle gap detection failures as skipped checks with warnings — never abort on a detection error

## Process

### Step 1: Read Context

Read the following files. Only `docs/BACKLOG.md` is required — all others are optional.

1. `docs/BACKLOG.md` — **Required.** If absent, inform the user:
   > No backlog found — run `/arc-capture` to start capturing ideas.
   Exit gracefully. Do not proceed to subsequent steps.
2. `docs/ROADMAP.md` — Optional. Used by Step 2 (Current Wave). If absent, Step 2 emits its fallback notice.

### Step 2: Current Wave

Identify the active delivery wave from the roadmap.

1. If `docs/ROADMAP.md` was not found in Step 1, emit the fallback and move to Step 3:
   ```
   **Current Wave**

   No roadmap found — run /arc-wave to plan a delivery wave.
   ```
2. Parse the wave summary table in `docs/ROADMAP.md` — the first markdown table after the `# ROADMAP` heading. Each row has columns: Wave, Goal, Status, Target, Ideas.
3. Scan rows top-to-bottom. The **current wave** is the first row where the Status column is not `Completed`.
4. If all rows have Status `Completed`, emit:
   ```
   **Current Wave**

   All waves completed — run /arc-wave to plan the next wave.
   ```
5. Otherwise emit the current wave summary:
   ```
   **Current Wave**

   {Wave Name}: {Goal}
   Status: {status} | Ideas: {count}
   ```

See `skills/arc-status/references/status-dimensions.md` (SD-1) for the full detection logic and parsing details.

### Step 3: Backlog Snapshot

Count ideas at each lifecycle status from the backlog summary table.

1. Locate the summary table in `docs/BACKLOG.md` — the first markdown table containing columns: Title, Status, Priority, Wave.
2. Parse each data row (skip the header and separator rows).
3. Extract the Status column value from each row and count ideas per status: `captured`, `shaped`, `spec-ready`, `shipped`.
4. Sum all counts for the total.
5. Emit the snapshot:
   ```
   **Backlog Snapshot**

   | Status | Count |
   |--------|-------|
   | Captured | {N} |
   | Shaped | {N} |
   | Spec-Ready | {N} |
   | Shipped | {N} |
   | **Total** | **{N}** |
   ```

See `skills/arc-status/references/status-dimensions.md` (SD-2) for the full detection logic.

### Step 4: In-Flight Specs

List all spec directories and report pipeline artifact presence for each.

1. Glob `docs/specs/NN-spec-*/` directories (where NN is a two-digit number).
2. If no spec directories are found, emit the fallback and move to Step 5:
   ```
   **In-Flight Specs**

   No specs found — run /cw-spec to create a specification.
   ```
3. For each spec directory (sorted by NN prefix ascending), detect three artifacts:

   **a. Spec file:** Glob for `{dir}/NN-spec-*.md`. Report `yes` if at least one match exists, `no` otherwise.

   **b. Plan evidence:** Glob for `{dir}/plan-*` files. If none found, check recent commits: run `git log --oneline -30` and search for commit messages containing `(T0` referencing this spec's NN prefix. Report `yes` if plan files exist or a matching commit is found, `no` otherwise.

   **c. Validation report:** Glob for `{dir}/NN-validation-*.md`. Report `yes` if at least one match exists, `no` otherwise.

4. Emit the specs table:
   ```
   **In-Flight Specs**

   | Spec | Spec File | Plan | Validation |
   |------|-----------|------|------------|
   | {NN}-spec-{name} | yes/no | yes/no | yes/no |
   ```

See `skills/arc-status/references/status-dimensions.md` (SD-3) for the full detection logic.

### Step 5: Recent Activity

Show the last 10 git commits as a momentum indicator.

1. Run `git log --oneline -10`.
2. If the command succeeds, emit the output:
   ```
   **Recent Activity**

   ```
   {git log output, one commit per line}
   ```
   ```
3. If the repository has no commits or is not a git repo, emit:
   ```
   **Recent Activity**

   No git history found.
   ```

See `skills/arc-status/references/status-dimensions.md` (SD-4) for the full detection logic.

### Step 6: Lifecycle Gaps

Detect stalled transitions in the idea lifecycle pipeline. Read `skills/arc-status/references/status-dimensions.md` (Lifecycle Gap Detection section) for the full detection predicates, output formats, and error handling rules for all five gap types.

For each gap type below, run the detection logic. If a detection check fails (unreadable file, malformed metadata, missing directory), treat it as a **skipped check with a warning** — do not abort. Continue to the next gap check.

#### LG-1: Captured → Shaped

1. Read `docs/BACKLOG.md`.
2. Find all idea sections (`## {Title}`) where `Status: captured`.
3. For each captured idea, check whether a `Shaped:` timestamp field exists in the idea's metadata block.
4. Flag any idea where `Status: captured` AND no `Shaped:` field is present.

#### LG-2: Shaped → Spec

1. Read `docs/BACKLOG.md`.
2. Find all idea sections (`## {Title}`) where `Status: shaped`.
3. For each shaped idea, check whether a `Spec:` field exists in the idea's metadata block.
4. If `Spec:` is absent, flag as gap.
5. If `Spec:` is present, verify the referenced directory exists on the filesystem (e.g., `docs/specs/NN-spec-name/`).
6. If the directory does not exist, flag as gap.

#### LG-3: Spec → Plan

1. Glob `docs/specs/NN-spec-*/` directories.
2. For each spec directory, confirm a spec file exists: glob `{dir}/NN-spec-*.md`. If no spec file exists, skip this directory.
3. Check for plan evidence using two signals:
   a. **File-based:** Glob `{dir}/plan-*` and `{dir}/tasks-*` for any plan or task artifact.
   b. **Commit-based:** Run `git log --oneline -30` and search for commit messages containing `(T0` referencing this spec's NN prefix or name.
4. If neither signal is found, flag as gap.

#### LG-4: Plan → Validation

1. Glob `docs/specs/NN-spec-*/` directories.
2. For each spec directory, check for plan evidence (same signals as LG-3: `plan-*` files, `tasks-*` files, or commits referencing `(T0` for this spec).
3. If no plan evidence exists, skip this directory (LG-3 catches it instead).
4. Check for a validation report: glob `{dir}/NN-validation-*.md`.
5. If no validation report exists, flag as gap.

#### LG-5: Validation → Shipped

1. Glob `docs/specs/NN-spec-*/` directories.
2. For each spec directory, glob `{dir}/NN-validation-*.md` for validation reports. If none exist, skip.
3. Read the validation report and search for the literal string `**Overall**: PASS`. If not found, skip.
4. Search `docs/BACKLOG.md` for idea entries where the `Spec:` field matches this spec directory path.
5. If no matching idea is found, skip.
6. Check the matched idea's `Status:` field. If `Status:` is `spec-ready` (not `shipped`), flag as gap.

#### Emit Lifecycle Gaps

After running all five gap checks, emit the results:

- If **gaps found**, emit a table:
  ```
  **Lifecycle Gaps**

  | Gap | Item | Remediation |
  |-----|------|-------------|
  | Captured → Shaped | {Idea Title} | Run /arc-shape |
  | Shaped → Spec | {Idea Title} | Run /cw-spec |
  | Spec → Plan | {NN}-spec-{name} | Run /cw-plan |
  | Plan → Validation | {NN}-spec-{name} | Run /cw-validate |
  | Validation → Shipped | {Idea Title} | Run /arc-ship |
  ```

- If **no gaps found**, emit:
  ```
  **Lifecycle Gaps**

  No lifecycle gaps detected.
  ```

- If a **detection check was skipped**, include it in the table as:
  ```
  | {Gap Name} | (skipped — {reason}) | -- |
  ```

See `skills/arc-status/references/status-dimensions.md` (Lifecycle Gap Detection) for the full detection predicates and error handling rules.

## References

- `skills/arc-status/references/status-dimensions.md` — Detection logic, parsing rules, output formats, and fallback behavior for all five summary sections including lifecycle gap detection
