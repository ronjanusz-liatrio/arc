---
name: arc-status
description: "Project pulse check — read-only snapshot of project health across five dimensions: current wave, backlog distribution, in-flight specs, git momentum, and lifecycle gaps. Invoke anytime you want a quick overview without making changes — when the user says 'what's the status', 'where are we', 'give me a project summary', or 'what should we work on next'. Emits a next-step recommendation. Lightweight alternative to /arc-audit, which writes a diagnostic report and offers interactive fixes."
user-invocable: true
allowed-tools: Glob, Grep, Read, Bash, AskUserQuestion, Skill
requires:
  files:
    - docs/BACKLOG.md
  artifacts:
    - BACKLOG
  state: ""
produces:
  files: []
  artifacts: []
  state-transition: ""
consumes: {}
triggers:
  condition: "any time a quick read-only project snapshot is needed"
  alternates:
    - /arc-audit
---

# /arc-status — Project Pulse Check

## Context Marker

Always begin your response with: **ARC-STATUS**

## Overview

You perform a fast, read-only pulse check across Arc artifacts and git history, then emit a single inline summary showing where the project stands. The output covers five dimensions: the current delivery wave, backlog status distribution (with shipped count derived from the wave archive at `docs/skill/arc/waves/`), in-flight spec pipeline progress, recent git momentum, and lifecycle gap detection. After the summary, you recommend a next-step skill based on the findings. No files are written — the summary is inline only.

## Critical Constraints

- **NEVER** write, create, or modify any files — this skill is strictly read-only
- **NEVER** abort on a missing optional artifact — emit the section's fallback notice and continue to the next section
- **ALWAYS** begin your response with `**ARC-STATUS**`
- **ALWAYS** emit all five summary sections in order, even when individual sections fall back to a notice
- **ALWAYS** present a next-step suggestion via AskUserQuestion after the summary sections
- **ALWAYS** handle parse errors gracefully — report what could not be parsed and continue
- **ALWAYS** treat lifecycle gap detection failures as skipped checks with warnings — never abort on a detection error
- **NEVER** invoke a skill without user confirmation via AskUserQuestion

## Process

### Step 1: Read Context

Read the following files. Only `docs/BACKLOG.md` is required — all others are optional.

1. `docs/BACKLOG.md` — **Required.** If absent, inform the user:
   > No backlog found — run `/arc-capture` to start capturing ideas.
   Exit gracefully. Do not proceed to subsequent steps.
2. `docs/ROADMAP.md` — Optional. Used by Step 2 (Current Wave). If absent, Step 2 emits its fallback notice.
3. `docs/skill/arc/waves/*.md` — Optional. Used by Step 3 (Backlog Snapshot) to derive the Shipped count from the wave archive. If the directory is absent or contains no files, Step 3 reports Shipped as `0`.

### Step 2: Current Wave

Identify the active delivery wave from the roadmap and expose its identity and status to downstream steps.

1. If `docs/ROADMAP.md` was not found in Step 1, set **active wave name** = null and **active wave status** = null, emit the fallback, and move to Step 3:
   ```
   **Current Wave**

   No roadmap found — run /arc-wave to plan a delivery wave.
   ```
2. Parse the wave summary table in `docs/ROADMAP.md` — the first markdown table after the `# ROADMAP` heading. Each row has columns: Wave, Goal, Status, Target, Ideas.
3. Scan rows top-to-bottom. The **current wave** is the first row where the Status column is not `Completed`.
4. If all rows have Status `Completed` (or the table is empty), set **active wave name** = null and **active wave status** = null, emit:
   ```
   **Current Wave**

   All waves completed — run /arc-wave to plan the next wave.
   ```
5. Otherwise extract the following values from the matched row and retain them for downstream steps:
   - **active wave name** — the verbatim string in the Wave column (pass through em dashes, colons, and other characters without transformation beyond trimming surrounding whitespace).
   - **active wave status** — the verbatim string in the Status column; under the template-enforced vocabulary this is one of `planned` or `active` (the `Completed` value is excluded by the row filter in step 3).
   - **goal text**, **target**, and **idea count** — used for the rendered summary below.

   Then emit the current wave summary (format unchanged):
   ```
   **Current Wave**

   {Wave Name}: {Goal}
   Status: {status} | Ideas: {count}
   ```

6. The **active wave name** and **active wave status** values resolved in steps 1, 4, or 5 are consumed by Step 6 (wave-linked gap scoping) and Step 7 (precedence evaluation). When either value is null, downstream steps follow their no-wave branches. The rendered output format of this step is not affected by downstream consumption.

See `skills/arc-status/references/status-dimensions.md` (SD-1) for the full detection logic and parsing details.

### Step 3: Backlog Snapshot

Count ideas at each lifecycle status. Active statuses come from the backlog summary table; the Shipped count comes from the wave archive.

1. Locate the summary table in `docs/BACKLOG.md` — the first markdown table containing columns: Title, Status, Priority, Wave.
2. Parse each data row (skip the header and separator rows).
3. Extract the Status column value from each row and count ideas per active status: `captured`, `shaped`, `spec-ready`.
4. Count shipped items from the wave archive: count `### {Title}` subsections (H3 headings) across all `docs/skill/arc/waves/*.md` files. If the `docs/skill/arc/waves/` directory is absent or contains no files, the Shipped count is `0`.
5. Sum all four counts (Captured + Shaped + Spec-Ready + Shipped) for the total.
6. Emit the snapshot:
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

#### Step 6.0: Compute Wave-Linked Idea Set (Preamble)

Before running the five gap checks, compute the **wave-linked idea set** so each detected gap can later be tagged with a scope label. This preamble runs once per invocation.

1. If the **active wave name** from Step 2 is null, the wave-linked idea set is the **empty set**. Skip steps 2–5 of this preamble. (Downstream gap scope tagging will treat every gap as `backlog-only`, and the Scope column will be omitted per the no-wave branch — see the renderer rules referenced from `status-dimensions.md` (WL-4).)
2. Otherwise, re-read (or reuse the already-parsed) `docs/BACKLOG.md` summary table — the first markdown table whose columns include `Title`, `Status`, `Priority`, and `Wave` (same table as Step 3).
3. For each data row of that table (skipping header and separator rows):
   a. Extract the `Title` column value.
   b. Extract the `Wave` column value.
   c. Trim surrounding whitespace from **both** the row's `Wave` value and the **active wave name** from Step 2.
   d. Compare the two trimmed strings by **exact case-sensitive string match** — no lowercasing, no Unicode normalization, no substring or prefix matching. `Wave 4 — Foo` matches `  Wave 4 — Foo  ` but does not match `wave 4 — foo`, `WAVE 4 — FOO`, or `Wave 4 - Foo` (hyphen vs. em dash).
   e. If the trimmed `Wave` value equals the trimmed active wave name, add the idea's **Title** (as it appears in the Title column, untrimmed) to the **wave-linked idea set**.
4. Rows whose `Wave` column is empty, missing, or does not match are excluded.
5. Retain the resulting wave-linked idea set for use by the gap-tagging logic in T01.3 and the renderer in T01.4. The five gap checks (LG-1 through LG-5) below continue to execute unchanged — the wave-linked set does not suppress any detection; it only provides the membership lookup used after detection.

This preamble also defines the **spec-to-idea linkage** used by the spec-scoped gaps LG-3 and LG-4: for a gap whose subject is a spec directory (e.g., `docs/specs/NN-spec-name/`), look up the `docs/BACKLOG.md` idea entry whose `Spec:` field equals that spec directory path; if such an idea is found and its title is in the wave-linked idea set, the gap is considered wave-linked; otherwise backlog-only. The lookup is performed at tag time (see T01.3), not in this preamble.

See `skills/arc-status/references/status-dimensions.md` (WL-2 Wave-Linked Idea Set, and WL-3 Gap Scope Tagging for the spec-to-idea linkage) for the authoritative algorithm, edge cases, and worked example.

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

#### LG-6: Orphan Spec

1. Glob `docs/specs/NN-spec-*/` directories.
2. For each spec directory, glob `{dir}/*-validation-*.md` for validation reports. If none exist, skip.
3. Read each validation report and search for the literal string `**Overall**: PASS`. If no validation report contains that string, skip.
4. Scan `docs/BACKLOG.md` idea entries for any `Spec:` field whose value, after whitespace trim and trailing-slash normalization, equals the spec directory path (e.g., `docs/specs/NN-spec-name`).
5. If a matching idea is found, skip — this spec is already linked to a backlog entry and is handled by LG-3, LG-4, or LG-5 as appropriate.
6. If no matching idea is found, flag the spec directory as an LG-6 gap.

#### Step 6.6: Tag Each Gap with Scope (Postamble)

After all five gap checks (LG-1 through LG-5) have run, but **before** the Lifecycle Gaps table is emitted, tag each detected gap (and each skipped-check row) with a `scope` field. The scope field is consumed by the table renderer (Scope column — see `references/status-dimensions.md` WL-4) and by Step 7 (to filter which gaps drive the next-step recommendation — see the "Wave scope and backlog-only gaps" note in Step 7).

For each gap produced by the LG-* detections above, resolve its **subject idea title**, then look it up in the **wave-linked idea set** computed in Step 6.0. Assign `scope` as follows:

1. **LG-1 (Captured → Shaped)** — subject = the backlog idea title flagged in LG-1 step 4. If the title is in the wave-linked idea set, `scope = wave-linked`; otherwise `scope = backlog-only`.
2. **LG-2 (Shaped → Spec)** — subject = the backlog idea title flagged in LG-2 steps 4 or 6. If the title is in the wave-linked idea set, `scope = wave-linked`; otherwise `scope = backlog-only`.
3. **LG-3 (Spec → Plan)** — subject = the spec directory (e.g., `docs/specs/NN-spec-name/`). Resolve the spec's linked backlog idea via the `Spec:` field:
   a. Scan `docs/BACKLOG.md` idea entries for a `Spec:` field whose value equals this spec directory path (exact match after whitespace trim; trailing slash variants are treated as equivalent — strip the trailing slash before comparison).
   b. If a matching backlog idea is found **and** its title is in the wave-linked idea set, `scope = wave-linked`.
   c. If no matching backlog idea is found, **or** the matched idea's title is not in the wave-linked idea set, `scope = backlog-only`.
4. **LG-4 (Plan → Validation)** — subject = the spec directory. Apply the same spec-to-idea resolution as LG-3 (steps 3a–3c above). `scope = wave-linked` only when the resolved backlog idea's title is in the wave-linked idea set; otherwise `scope = backlog-only`.
5. **LG-5 (Validation → Shipped)** — subject = the backlog idea title resolved in LG-5 step 4 (the idea whose `Spec:` field matches the spec directory with a passing validation report). If the title is in the wave-linked idea set, `scope = wave-linked`; otherwise `scope = backlog-only`.
6. **LG-6 (Orphan Spec)** — subject = the spec directory. By construction no linked backlog idea exists, so `scope = backlog-only` always.
7. **Skipped checks** — when a gap check was skipped (LG-1 through LG-5 detection threw an unrecoverable error, was unable to execute, or encountered malformed metadata), the resulting row has no resolvable subject. Tag `scope = --` (a placeholder, never `wave-linked` or `backlog-only`). Rendering and precedence both ignore `--` scopes.
8. **No active wave** — when the **active wave name** from Step 2 is null, the wave-linked idea set from Step 6.0 is empty. Every detected gap therefore evaluates to `scope = backlog-only` by the rules above. In this branch the scope field is functionally unused — the table renderer (T01.4) omits the Scope column, and Step 7's no-wave precedence (Priorities 9–14) ignores the scope field entirely.

Retain the `scope` value on every gap (and on every skipped-check row) for consumption by the Lifecycle Gaps table renderer and by Step 7. The five LG detection sections above are not modified by this postamble — tagging is a pure post-detection labelling pass with no side effects on which gaps were detected.

See `skills/arc-status/references/status-dimensions.md` (WL-3 Gap Scope Tagging) for the authoritative algorithm, spec-to-idea lookup rules, and worked example.

#### Emit Lifecycle Gaps

After running all five gap checks (and the Step 6.6 postamble), emit the results. The table shape is **conditional on the active wave name resolved in Step 2**: when the active wave name is non-null, the table adds a `Scope` column; when the active wave name is null, the table renders in its existing three-column format unchanged.

- If **no gaps found**, emit the following regardless of wave state (no table is rendered):
  ```
  **Lifecycle Gaps**

  No lifecycle gaps detected.
  ```

- If **gaps found AND the active wave name from Step 2 is null** (no active wave — no ROADMAP, empty table, or all rows Completed), emit the three-column table:
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
  In this no-wave branch, the `scope` field tagged in Step 6.6 is ignored — no Scope column header, no Scope cells. A skipped-check row renders as `| {Gap Name} | (skipped — {reason}) | -- |` (three columns, unchanged from pre-change behavior).

- If **gaps found AND the active wave name from Step 2 is non-null** (an active wave exists), emit the four-column table — the existing `Gap | Item | Remediation` columns **plus** a fourth `Scope` column:
  ```
  **Lifecycle Gaps**

  | Gap | Item | Remediation | Scope |
  |-----|------|-------------|-------|
  | Captured → Shaped | {Idea Title} | Run /arc-shape | {Scope Cell} |
  | Shaped → Spec | {Idea Title} | Run /cw-spec | {Scope Cell} |
  | Spec → Plan | {NN}-spec-{name} | Run /cw-plan | {Scope Cell} |
  | Plan → Validation | {NN}-spec-{name} | Run /cw-validate | {Scope Cell} |
  | Validation → Shipped | {Idea Title} | Run /arc-ship | {Scope Cell} |
  ```
  The `{Scope Cell}` value is derived from the `scope` field that Step 6.6 tagged onto each row:
  - For a gap tagged `scope = wave-linked`: the Scope cell is the literal string `Wave: {wave_name}` where `{wave_name}` is the **verbatim active wave name** from Step 2 — no escaping, no trimming, no case folding. Special characters (em dashes, colons, etc.) pass through unchanged (e.g., `Wave: Wave 4 — Foo`).
  - For a gap tagged `scope = backlog-only`: the Scope cell is the literal string `Backlog (outside wave)`.
  - For a skipped-check row (scope `--`): the Scope cell is the literal string `--`. The full skipped row renders as `| {Gap Name} | (skipped — {reason}) | -- | -- |` (four columns — the Remediation cell retains its existing `--` placeholder and the Scope cell is also `--`).

- The `No lifecycle gaps detected.` message is **not** augmented with a Scope column or any wave indicator in either branch — it is rendered byte-for-byte unchanged.

See `skills/arc-status/references/status-dimensions.md` (Lifecycle Gap Detection for the detection predicates and error handling rules, and WL-4 Scope Column Rendering for the authoritative rendering rules and a worked example).

### Step 7: Next-Step Suggestion

After emitting all summary sections, recommend the single most relevant next skill based on the pulse findings. The recommendation uses a **first-match-wins precedence list** — evaluate from Priority 1 downward and stop at the first matching condition. The list is **wave-state-aware**: Priorities 1–8 apply when an active wave exists (the **active wave name** resolved in Step 2 is non-null), and Priorities 9–14 apply when the active wave name is null (no ROADMAP, empty table, or all rows Completed).

#### Precedence List

| Priority | Condition | Recommended Skill | Reason Template |
|----------|-----------|-------------------|-----------------|
| 1 | Active wave exists AND wave-linked idea set is empty | `/arc-wave` | "Wave {Name} is {status} but has no ideas assigned — assign backlog ideas?" |
| 2 | Wave-linked LG-5 (Validation → Shipped) gap exists | `/arc-ship` | "{Idea Title} (in Wave {Name}) has a validation PASS but is still spec-ready — ship it?" |
| 3 | Wave-linked LG-4 (Plan → Validation) gap exists | `/cw-validate` | "{NN}-spec-{name} (in Wave {Name}) has plan evidence but no validation report — validate it?" |
| 4 | Wave-linked LG-3 (Spec → Plan) gap exists | `/cw-plan` | "{NN}-spec-{name} (in Wave {Name}) has a spec but no plan — plan it?" |
| 5 | Wave-linked LG-2 (Shaped → Spec) gap exists | `/cw-spec` | "{Idea Title} (in Wave {Name}) is shaped but has no spec — write a spec?" |
| 6 | Wave-linked LG-1 (Captured → Shaped) gap on a P0 or P1 idea | `/arc-shape` | "{Idea Title} (in Wave {Name}) is captured at {Priority} but unshaped — shape it?" |
| 7 | Active wave status is `planned` AND no wave-linked gaps remain | `/arc-wave` | "Wave {Name} is planned with no open gaps on assigned ideas — activate it?" |
| 8 | Active wave status is `active` AND no wave-linked gaps remain | `/arc-audit` | "Wave {Name} is active and wave-linked work is clean — audit wave health?" |
| 9 | No active wave AND an LG-5 (Validation → Shipped) gap exists | `/arc-ship` | "{Idea Title} has a validation PASS but is still spec-ready — ship it?" |
| 10 | No active wave AND an LG-4 (Plan → Validation) gap exists | `/cw-validate` | "{NN}-spec-{name} has plan evidence but no validation report — validate it?" |
| 11 | No active wave AND an LG-3 (Spec → Plan) gap exists | `/cw-plan` | "{NN}-spec-{name} has a spec but no plan — plan it?" |
| 12 | No active wave AND an LG-2 (Shaped → Spec) gap exists | `/cw-spec` | "{Idea Title} is shaped but has no spec — write a spec?" |
| 13 | No active wave AND an LG-1 (Captured → Shaped) gap on a P0 or P1 idea | `/arc-shape` | "{Idea Title} is captured at {Priority} but unshaped — shape it?" |
| 14 | No active wave AND an LG-6 (Orphan Spec) gap exists | `/arc-capture` | "{NN}-spec-{name} has a PASS validation report but no BACKLOG idea — capture it?" |
| 15 | No active wave AND no gaps | `/arc-wave` | "No gaps and no active wave — plan the next delivery wave?" |

**Priority 6 / Priority 13 P0/P1 filter.** Only LG-1 (Captured → Shaped) gaps on ideas whose `Priority:` field in the idea's metadata block in `docs/BACKLOG.md` is `P0` or `P1` qualify. Ideas with `Priority: P2`, `P3`, or an unset priority do not trigger Priority 6 or Priority 13 — this matches the pre-change Priority-5 filter behavior.

**Wave scope and backlog-only gaps.** Gaps tagged `backlog-only` in Step 6 (see `references/status-dimensions.md` WL-3) **never satisfy Priorities 2–6** and are **not considered by Priorities 7 and 8**. When an active wave exists, backlog-only gaps remain visible in the Lifecycle Gaps table (with `Backlog (outside wave)` in the Scope column) but do not drive the recommendation. Backlog-only gaps can only match Priorities 9–13, which are reachable only when the active wave name resolved in Step 2 is null.

**Wave-name interpolation.** Whenever a reason template substitutes `{Name}`, the active wave name resolved in Step 2 is passed through verbatim — no escaping transformations beyond standard JSON string encoding. Em dashes, colons, and other markdown-special characters appear in the `AskUserQuestion` question exactly as they appear in `docs/ROADMAP.md`.

See `skills/arc-status/references/status-dimensions.md` (Next-Step Suggestion Precedence) for the full precedence logic.

#### Present Recommendation

Use `AskUserQuestion` to present the recommendation. The prompt must **always** include at least 3 options: the recommended skill (labeled `(Recommended)`), exactly one alternative skill selected per the rules below, and `Done for now`. These three options are mandatory on every invocation — the prompt is never reduced to fewer than three, and `Done for now` is always the final option.

Select the **alternative skill** per the matched priority:

| Matched Priority | Alternative Skill Selection Rule |
|------------------|-----------------------------------|
| 1 (empty wave) | `/arc-audit` |
| 2 (wave-linked LG-5) | Next-lower-priority wave-linked gap skill that also matched among Priorities 3–6 (in order: `/cw-validate`, `/cw-plan`, `/cw-spec`, `/arc-shape`). If none matched, `/arc-audit`. |
| 3 (wave-linked LG-4) | Next-lower-priority wave-linked gap skill that also matched among Priorities 4–6 (in order: `/cw-plan`, `/cw-spec`, `/arc-shape`). If none matched, `/arc-audit`. |
| 4 (wave-linked LG-3) | Next-lower-priority wave-linked gap skill that also matched among Priorities 5–6 (in order: `/cw-spec`, `/arc-shape`). If none matched, `/arc-audit`. |
| 5 (wave-linked LG-2) | The wave-linked P0/P1 LG-1 skill (`/arc-shape`) if Priority 6 also matched. Otherwise `/arc-audit`. |
| 6 (wave-linked LG-1 P0/P1) | `/arc-audit` (no lower-priority wave-linked gap exists). |
| 7 (planned clean wave → `/arc-wave`) | `/arc-audit` |
| 8 (active clean wave → `/arc-audit`) | `/arc-wave` |
| 9 (no-wave LG-5) | Next-lower-priority no-wave gap skill that also matched among Priorities 10–13 (in order: `/cw-validate`, `/cw-plan`, `/cw-spec`, `/arc-shape`). If none matched, `/arc-audit`. |
| 10 (no-wave LG-4) | Next-lower-priority no-wave gap skill that also matched among Priorities 11–13 (in order: `/cw-plan`, `/cw-spec`, `/arc-shape`). If none matched, `/arc-audit`. |
| 11 (no-wave LG-3) | Next-lower-priority no-wave gap skill that also matched among Priorities 12–13 (in order: `/cw-spec`, `/arc-shape`). If none matched, `/arc-audit`. |
| 12 (no-wave LG-2) | The no-wave P0/P1 LG-1 skill (`/arc-shape`) if Priority 13 also matched. Otherwise `/arc-audit`. |
| 13 (no-wave LG-1 P0/P1) | `/arc-audit` (no lower-priority no-wave gap exists). |
| 14 (no-wave LG-6) | `/arc-audit` (no lower-priority no-wave gap exists). |
| 15 (no wave, no gaps) | `/arc-audit` |

**Never offer the recommended skill as its own alternative.** If the fall-through rule would yield the same skill as the recommendation (e.g., both Priority 7 and Priority 14 recommend `/arc-wave`, but their alternatives differ), use the alternative listed in the table above.

**Prompt format:**

```
AskUserQuestion({
  questions: [{
    question: "{reason from precedence table}",
    header: "Next Step",
    options: [
      { label: "Run {recommended skill} (Recommended)", description: "{one-line description of what the skill does}" },
      { label: "Run {alternative skill}", description: "{one-line description of the alternative}" },
      { label: "Done for now", description: "Exit without running any skill" }
    ]
  }]
})
```

#### Handle User Selection

- **If the user selects the recommended or alternative skill:** invoke it via the `Skill` tool. Do not invoke any skill without the user explicitly selecting it.
  ```
  Skill({ name: "{selected-skill-name}" })
  ```
- **If the user selects "Done for now":** exit silently. Do not invoke any skill. Do not emit further output.

#### Critical Constraints for Step 7

- **NEVER** invoke a skill automatically — always present `AskUserQuestion` first and wait for user selection
- **NEVER** skip the AskUserQuestion prompt — even when only one gap type is detected
- **ALWAYS** include "Done for now" as the last option
- **ALWAYS** include the reason for the recommendation in the question text

## References

- `skills/arc-status/references/status-dimensions.md` — Detection logic, parsing rules, output formats, and fallback behavior for all summary sections including lifecycle gap detection and next-step suggestion precedence
- `references/wave-archive.md` — Wave archive schema and shipped-count derivation rules
