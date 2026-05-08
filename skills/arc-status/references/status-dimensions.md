# Status Dimensions

`/arc-status` performs a read-only pulse check across five summary sections: **Current Wave**, **Backlog Snapshot**, **In-Flight Specs**, **Recent Activity**, and **Lifecycle Gaps**. After the summary, it recommends a **Next-Step Suggestion** based on the findings. Each section defines what is read, how to parse it, how to render the output, and a graceful fallback when the source artifact is missing.

---

## SD-1: Current Wave

**Purpose:** Identify the active (first non-completed) wave from the roadmap and report its name, goal, status, and idea count so the user knows where delivery stands.

**Detection Logic:**

1. Read `docs/ROADMAP.md`
2. Parse the wave summary table (the first table after the `# ROADMAP` heading) — each row has columns: Wave, Goal, Status, Target, Ideas
3. Scan rows top-to-bottom; the **current wave** is the first row where the Status column is not `Completed`
4. If all rows have Status `Completed`, report "All waves completed"
5. Extract from the matched row: wave name, goal text, status value, and idea count

**Inputs:**

- `docs/ROADMAP.md` — wave summary table

**Output Format:**

```markdown
**Current Wave**

{Wave Name}: {Goal}
Status: {status} | Ideas: {count}
```

**Fallback (ROADMAP.md missing):**

```markdown
**Current Wave**

No roadmap found — run /arc-wave to plan a delivery wave.
```

**Fallback (all waves completed):**

```markdown
**Current Wave**

All waves completed — run /arc-wave to plan the next wave.
```

---

## SD-2: Backlog Snapshot

**Purpose:** Count ideas at each lifecycle status and report the distribution, giving the user a quick pipeline health view. Active statuses (captured, shaped, spec-ready) come from the backlog summary table; shipped count comes from the wave archive.

**Detection Logic:**

1. Read `docs/BACKLOG.md`
2. Locate the summary table — the first markdown table that contains columns: Title, Status, Priority, Wave
3. Parse each data row (skip header and separator rows)
4. Extract the Status column value from each row
5. Count ideas per active status: `captured`, `shaped`, `spec-ready`
6. Count shipped items from the wave archive:
   a. Glob `docs/skill/arc/waves/*.md` files
   b. In each file, count lines matching `### ` (H3 headings) — each H3 subsection represents one shipped idea
   c. Sum the H3 counts across all archive files
   d. If the `docs/skill/arc/waves/` directory is absent or contains no `.md` files, Shipped = `0`
7. Sum all four counts (Captured + Shaped + Spec-Ready + Shipped) for the total

**Inputs:**

- `docs/BACKLOG.md` — summary table rows (for captured, shaped, spec-ready counts)
- `docs/skill/arc/waves/*.md` — wave archive files (for shipped count)

**Output Format:**

```markdown
**Backlog Snapshot**

| Status | Count |
|--------|-------|
| Captured | {N} |
| Shaped | {N} |
| Spec-Ready | {N} |
| Shipped | {N} |
| **Total** | **{N}** |
```

**Fallback (BACKLOG.md missing):**

```markdown
**Backlog Snapshot**

No backlog found — run /arc-capture to start capturing ideas.
```

---

## SD-3: In-Flight Specs

**Purpose:** List all spec directories under `docs/specs/` and for each report whether a spec file, plan evidence, and validation report are present — so the user can see SDD pipeline progress at a glance.

**Detection Logic:**

1. Glob `docs/specs/NN-spec-*/` directories (where NN is a two-digit number)
2. For each spec directory, detect three artifacts:

   **a. Spec file present:**
   - Glob for `{dir}/NN-spec-*.md` (the spec document itself)
   - Status: `yes` if at least one matching file exists, `no` otherwise

   **b. Plan evidence:**
   - Check for plan files: glob `{dir}/plan-*` for any plan artifact
   - If no plan files found, check recent commits: run `git log --oneline -30` and search for commit messages containing `(T0` referencing this spec's NN prefix
   - Status: `yes` if plan files exist OR a matching commit is found, `no` otherwise

   **c. Validation report:**
   - Glob for `{dir}/NN-validation-*.md`
   - Status: `yes` if at least one matching file exists, `no` otherwise

3. Sort spec directories by NN prefix (ascending)

**Inputs:**

- `docs/specs/` directory — subdirectories matching `NN-spec-*`
- Each spec directory — contents (spec file, plan files, validation report)
- `git log --oneline -30` — recent commit messages (for plan evidence fallback)

**Output Format:**

```markdown
**In-Flight Specs**

| Spec | Spec File | Plan | Validation |
|------|-----------|------|------------|
| {NN}-spec-{name} | yes/no | yes/no | yes/no |
```

**Fallback (no specs directory or no spec subdirectories):**

```markdown
**In-Flight Specs**

No specs found — run /cw-spec to create a specification.
```

---

## SD-4: Recent Activity

**Purpose:** Show the last 10 git commits to give the user a sense of recent momentum and what has been worked on.

**Detection Logic:**

1. Run `git log --oneline -10`
2. Capture the output verbatim
3. If the repository has fewer than 10 commits, display all available commits

**Inputs:**

- Git history — last 10 commits via `git log --oneline -10`

**Output Format:**

```markdown
**Recent Activity**

```
{git log output, one commit per line}
```
```

**Fallback (no commits or not a git repo):**

```markdown
**Recent Activity**

No git history found.
```

---

## Lifecycle Gap Detection

`/arc-status` detects five lifecycle gaps — transitions between stages where an idea or spec has completed one stage but has not yet entered the next. Each gap identifies stalled work and recommends the skill to run next. The gap detection section appears in the inline summary after the four core pulse-check sections.

---

### LG-1: Captured → Shaped

**Purpose:** Identify ideas that have been captured but never entered shaping, indicating they may be sitting in the backlog without active refinement.

**Detection Logic:**

1. Read `docs/BACKLOG.md`
2. Find all idea sections (`## {Title}`) where `Status: captured`
3. For each captured idea, check whether a `Shaped:` timestamp field exists in the idea's metadata block
4. Flag any idea where `Status: captured` AND no `Shaped:` field is present

**Inputs:**

- `docs/BACKLOG.md` — idea sections with `Status:` and optional `Shaped:` fields

**Output Format:**

```markdown
| Gap | Item | Remediation |
|-----|------|-------------|
| Captured → Shaped | {Idea Title} | Run /arc-shape |
```

**Remediation Hint:** `/arc-shape`

---

### LG-2: Shaped → Spec

**Purpose:** Identify ideas that have completed shaping but do not have a corresponding spec, indicating the SDD pipeline has not started for that idea.

**Detection Logic:**

1. Read `docs/BACKLOG.md`
2. Find all idea sections (`## {Title}`) where `Status: shaped`
3. For each shaped idea, check whether a `Spec:` field exists in the idea's metadata block
4. If `Spec:` is absent → flag as gap
5. If `Spec:` is present, verify the referenced directory exists on the filesystem (e.g., `docs/specs/NN-spec-name/`)
6. If the directory does not exist → flag as gap

**Inputs:**

- `docs/BACKLOG.md` — idea sections with `Status: shaped` and optional `Spec:` field
- Filesystem — verify spec directory existence for each `Spec:` value

**Output Format:**

```markdown
| Gap | Item | Remediation |
|-----|------|-------------|
| Shaped → Spec | {Idea Title} | Run /cw-spec |
```

**Remediation Hint:** `/cw-spec`

---

### LG-3: Spec → Plan

**Purpose:** Identify spec directories that contain a spec file but show no evidence that `cw-plan` has been executed, indicating the spec has not been broken into tasks.

**Detection Logic:**

1. Glob `docs/specs/NN-spec-*/` directories
2. For each spec directory, confirm a spec file exists: glob `{dir}/NN-spec-*.md`
3. If no spec file exists, skip this directory (it is not a valid spec)
4. Check for plan evidence using two signals:
   a. **File-based:** Glob `{dir}/plan-*` and `{dir}/tasks-*` for any plan or task artifact
   b. **Commit-based:** Run `git log --oneline -30` and search for commit messages containing `(T0` that reference this spec's NN prefix or name
5. If neither signal is found → flag as gap

**Inputs:**

- `docs/specs/` directory — subdirectories matching `NN-spec-*`
- Each spec directory — presence of `plan-*` or `tasks-*` files
- `git log --oneline -30` — recent commit messages for plan execution evidence

**Output Format:**

```markdown
| Gap | Item | Remediation |
|-----|------|-------------|
| Spec → Plan | {NN}-spec-{name} | Run /cw-plan |
```

**Remediation Hint:** `/cw-plan`

---

### LG-4: Plan → Validation

**Purpose:** Identify spec directories that have plan or task execution evidence but no validation report, indicating the implementation may be complete but has not been formally validated.

**Detection Logic:**

1. Glob `docs/specs/NN-spec-*/` directories
2. For each spec directory, check for plan evidence (same signals as LG-3: `plan-*` files, `tasks-*` files, or commits referencing `(T0` for this spec)
3. If no plan evidence exists, skip this directory (LG-3 would catch it instead)
4. Check for a validation report: glob `{dir}/NN-validation-*.md`
5. If no validation report exists → flag as gap

**Inputs:**

- `docs/specs/` directory — subdirectories matching `NN-spec-*`
- Each spec directory — plan evidence files and validation report files
- `git log --oneline -30` — recent commit messages (for plan evidence fallback)

**Output Format:**

```markdown
| Gap | Item | Remediation |
|-----|------|-------------|
| Plan → Validation | {NN}-spec-{name} | Run /cw-validate |
```

**Remediation Hint:** `/cw-validate`

---

### LG-5: Validation → Shipped

**Purpose:** Identify specs that have passed validation but whose linked backlog idea has not been transitioned to `shipped`, indicating delivery is complete but the backlog has not been updated.

**Detection Logic:**

1. Glob `docs/specs/NN-spec-*/` directories
2. For each spec directory, glob `{dir}/NN-validation-*.md` for validation reports
3. If no validation report exists, skip this directory
4. Read the validation report and search for the literal string `**Overall**: PASS`
5. If the report does not contain `**Overall**: PASS`, skip (validation did not pass)
6. Identify the linked backlog idea:
   a. Search `docs/BACKLOG.md` for idea entries where the `Spec:` field matches this spec directory path
   b. If no matching idea is found, skip (no backlog linkage)
7. Check the matched idea's `Status:` field
8. If `Status:` is `spec-ready` (not `shipped`) → flag as gap

**Inputs:**

- `docs/specs/` directory — subdirectories with validation reports
- Each validation report — presence of `**Overall**: PASS`
- `docs/BACKLOG.md` — idea entries with `Spec:` field matching the spec directory and `Status:` field

**Output Format:**

```markdown
| Gap | Item | Remediation |
|-----|------|-------------|
| Validation → Shipped | {Idea Title} | Run /arc-ship |
```

**Remediation Hint:** `/arc-ship`

---

### LG-6: Orphan Spec

**Purpose:** Identify PASS-validated spec directories that have no linked backlog idea, indicating the spec bypassed the `/arc-capture → /arc-shape → /arc-wave` lifecycle and shipped (or is shipping) without lifecycle bookkeeping.

**Detection Logic:**

1. Glob `docs/specs/NN-spec-*/` directories
2. For each spec directory, glob `{dir}/*-validation-*.md` for validation reports
3. If no validation report exists, skip this directory
4. Read the validation report and search for the literal string `**Overall**: PASS`
5. If the report does not contain `**Overall**: PASS`, skip (validation did not pass)
6. Scan `docs/BACKLOG.md` idea entries for any `Spec:` field whose value (after whitespace trim and trailing-slash normalization) equals the spec directory path
7. If no matching backlog idea is found → flag the spec directory as a gap

**Inputs:**

- `docs/specs/` directory — subdirectories with validation reports
- Each validation report — presence of `**Overall**: PASS`
- `docs/BACKLOG.md` — idea entries with `Spec:` field for linkage check (trailing-slash normalized, matching the LG-3/LG-4 rule)

**Output Format:**

```markdown
| Gap | Item | Remediation |
|-----|------|-------------|
| Orphan Spec | {NN}-spec-{name} | Run /arc-capture |
```

**Remediation Hint:** `/arc-capture`

---

### No Gaps Detected

When all five gap checks complete and no gaps are found, the Lifecycle Gaps section displays a single line:

```markdown
**Lifecycle Gaps**

No lifecycle gaps detected.
```

---

### Error Handling

Detection failures for any individual gap check (e.g., unreadable file, malformed metadata, missing directory) are treated as a **skipped check with a warning**, not a hard error. The remaining gap checks continue to execute.

**Skipped check output:**

```markdown
| Gap | Item | Remediation |
|-----|------|-------------|
| {Gap Name} | (skipped — {reason}) | -- |
```

Example reasons: "BACKLOG.md unreadable", "spec directory inaccessible", "git log unavailable".

The skill does not terminate on detection failures. All gap checks that can execute will execute regardless of individual failures.

---

## Wave Linkage Detection

`/arc-status` scopes lifecycle-gap recommendations to the active delivery wave when one exists. This section documents how the active wave is resolved, how the wave-linked idea set is computed, how spec-scoped gaps (LG-3 and LG-4) inherit wave scope, and how skipped checks render in active-wave mode. The algorithm is consumed by Step 6 (gap scope tagging), Step 6's table renderer (Scope column rendering), and Step 7 (Next-Step Suggestion Precedence).

---

### WL-1: Active Wave Resolution

**Purpose:** Produce a `(wave_name, wave_status)` tuple — or `(null, null)` — that represents the single active delivery wave used by all downstream wave-linkage logic.

**Detection Logic:**

1. Read `docs/ROADMAP.md` using the same parse as SD-1 (Current Wave).
2. Locate the wave summary table — the first markdown table after the `# ROADMAP` heading with columns Wave, Goal, Status, Target, Ideas.
3. Walk the data rows top-to-bottom. The **first row whose Status column is not `Completed`** is the active wave row.
4. Extract two values from that row:
   - **Active wave name** — the verbatim string in the Wave column, with surrounding whitespace trimmed. The extracted name is preserved verbatim otherwise (em dashes, colons, and other markdown-special characters are not escaped or altered).
   - **Active wave status** — the Status column value, expected to be one of `planned` or `active`. The legacy value `Completed` is excluded by the first-non-Completed filter above.
5. If no non-Completed row exists — no ROADMAP file, empty table, or every row has Status `Completed` — the active wave name is `null` and the active wave status is `null`.

**Inputs:**

- `docs/ROADMAP.md` — wave summary table (shared with SD-1)

**Outputs:**

- `wave_name`: string or `null`
- `wave_status`: `planned`, `active`, or `null`

**Notes:**

- The resolution is authoritative: the spec does not second-guess the Status field (no stalled-wave detection, no date-based heuristics).
- Only the first non-Completed row is considered. Later non-Completed rows in the same table are ignored — the skill assumes one active wave at a time.

---

### WL-2: Wave-Linked Idea Set

**Purpose:** Compute the set of backlog idea titles whose Wave column matches the active wave name, used to tag each lifecycle gap as `wave-linked` or `backlog-only`.

**Detection Logic:**

1. If `wave_name` from WL-1 is `null`, the wave-linked set is the empty set. Skip the remaining steps.
2. Read `docs/BACKLOG.md` and locate the summary table (the first table containing columns Title, Status, Priority, Wave — shared with SD-2).
3. For each data row:
   a. Extract the `Title` column value (the idea title).
   b. Extract the `Wave` column value.
   c. Trim surrounding whitespace from both the row's Wave value and from the active `wave_name`.
   d. Compare the two trimmed strings by **exact case-sensitive string match**.
   e. If the trimmed Wave value equals the trimmed `wave_name`, add the idea's title (untrimmed, as it appears in the Title column) to the wave-linked set.
4. Rows whose Wave column is empty, missing, or does not match are not added to the set.

**Match Rules:**

- **Case-sensitive**: `Wave 4 — Foo` matches `Wave 4 — Foo` but not `wave 4 — foo` or `WAVE 4 — FOO`.
- **Whitespace-trimmed**: leading and trailing whitespace on either side is removed before comparison — `  Wave 4 — Foo  ` matches `Wave 4 — Foo`.
- **No normalization beyond trim**: internal whitespace, em dashes, hyphens, and Unicode characters must match exactly. `Wave 4 - Foo` (hyphen) does not match `Wave 4 — Foo` (em dash).
- **No partial or substring matching**: `Wave 4` does not match `Wave 4 — Foo`.

**Inputs:**

- `wave_name` from WL-1
- `docs/BACKLOG.md` summary table

**Outputs:**

- `wave_linked_ideas`: set of idea titles (possibly empty)

---

### WL-3: Gap Scope Tagging

**Purpose:** Assign each lifecycle gap detected in Step 6 a `scope` field of `wave-linked` or `backlog-only`, used by the table renderer to populate the Scope column and by Step 7 to filter which gaps drive the next-step recommendation.

**Detection Logic:**

For each detected gap, determine its subject idea and consult the wave-linked set:

1. **LG-1 (Captured → Shaped) and LG-2 (Shaped → Spec)** — the subject is the backlog idea title identified during gap detection.
   - If the subject title is in `wave_linked_ideas` → `scope = wave-linked`.
   - Otherwise → `scope = backlog-only`.
2. **LG-3 (Spec → Plan) and LG-4 (Plan → Validation)** — the subject is a spec directory (e.g., `docs/specs/07-spec-thing/`). Resolve the spec's linked backlog idea via the `Spec:` field:
   a. Scan `docs/BACKLOG.md` idea entries for a `Spec:` field whose value equals the spec directory path (e.g., `docs/specs/07-spec-thing/`).
   b. If a matching backlog idea is found and its title is in `wave_linked_ideas` → `scope = wave-linked`.
   c. If no matching backlog idea is found, or the matched idea's title is not in `wave_linked_ideas` → `scope = backlog-only`.
3. **LG-5 (Validation → Shipped)** — the subject is the backlog idea identified in LG-5's detection logic (the idea whose `Spec:` field matches the spec directory with a passing validation report).
   - If the subject's title is in `wave_linked_ideas` → `scope = wave-linked`.
   - Otherwise → `scope = backlog-only`.
4. **Skipped checks** — when a lifecycle check could not execute (see Error Handling), the resulting row has no resolvable subject. Its scope is `--` (a placeholder, not `wave-linked` or `backlog-only`).
5. **No active wave (WL-1 returned `null`)** — scope tagging is functionally unused. The scope field may be computed as `backlog-only` for all gaps but is ignored by both the table renderer (no Scope column is emitted) and Step 7 (no-wave branch of the precedence).

**Outputs:**

- Each gap is tagged with `scope ∈ { wave-linked, backlog-only, -- }`.

---

### WL-4: Scope Column Rendering

**Purpose:** Conditionally render the Scope column in the Lifecycle Gaps table.

**Rendering Rules:**

1. If `wave_name` from WL-1 is not null, render the Lifecycle Gaps table with four columns: `Gap | Item | Remediation | Scope`.
   - For a gap tagged `wave-linked`, the Scope cell is the literal string `Wave: {wave_name}` (verbatim wave name — no escaping beyond standard markdown table cell content).
   - For a gap tagged `backlog-only`, the Scope cell is the literal string `Backlog (outside wave)`.
   - For a skipped check (scope `--`), the Scope cell is the literal string `--`.
2. If `wave_name` is null, render the table in its existing three-column format: `Gap | Item | Remediation`. No Scope column is emitted and the scope field on each gap is ignored.
3. The `No lifecycle gaps detected.` message (see "No Gaps Detected" above) is unchanged regardless of wave state — no table is rendered in that case.

---

### Worked Example

Given a ROADMAP where the first non-Completed row has Wave `Wave 4 — Foo` and Status `active`, and a BACKLOG containing three ideas:

| Title | Status | Priority | Wave |
|-------|--------|----------|------|
| Idea-A | captured | P1 | `Wave 4 — Foo` |
| Idea-B | shaped | P0 | _(empty)_ |
| Idea-C | captured | P2 | `  Wave 4 — Foo  ` |

**WL-1 output:** `wave_name = "Wave 4 — Foo"`, `wave_status = "active"`.

**WL-2 output:** After trimming and case-sensitive comparison, `wave_linked_ideas = { "Idea-A", "Idea-C" }`. Idea-B is excluded (empty Wave column).

**WL-3 output (assuming each idea has a matching gap):**

- Idea-A has LG-1 (captured, unshaped) → `scope = wave-linked`.
- Idea-B has LG-2 (shaped, no spec) → `scope = backlog-only`.
- Idea-C has LG-1 (captured, unshaped) → `scope = wave-linked` (trim rule applied).

**WL-4 rendered table:**

```markdown
| Gap | Item | Remediation | Scope |
|-----|------|-------------|-------|
| Captured → Shaped | Idea-A | Run /arc-shape | Wave: Wave 4 — Foo |
| Shaped → Spec | Idea-B | Run /cw-spec | Backlog (outside wave) |
| Captured → Shaped | Idea-C | Run /arc-shape | Wave: Wave 4 — Foo |
```

**Contrast — null active wave:** If the same BACKLOG is rendered against a ROADMAP with no non-Completed rows, WL-1 returns `(null, null)`, WL-2 returns the empty set, and WL-4 renders the three-column table with no Scope column. Step 7 falls through to the no-wave precedence branch.

---

## Next-Step Suggestion Precedence

After emitting all summary sections, `/arc-status` recommends the single most relevant next skill. The recommendation uses a **first-match-wins precedence list** — evaluate conditions from Priority 1 downward and stop at the first match. The list is **wave-state-aware**: Priorities 1–8 apply when an active wave exists (the **active wave name** resolved in Step 2 is non-null), and Priorities 9–14 apply when the active wave name is null (no ROADMAP, empty table, or all rows Completed).

This section depends on the algorithm defined in [Wave Linkage Detection](#wave-linkage-detection) above — specifically WL-1 (active wave resolution), WL-2 (wave-linked idea set), and WL-3 (gap scope tagging). The precedence rows refer to "wave-linked" and "backlog-only" gaps exactly as those terms are defined by WL-3.

---

### Precedence Table

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
| 14 | No active wave AND no gaps | `/arc-wave` | "No gaps and no active wave — plan the next delivery wave?" |

---

### Evaluation Logic

1. Resolve the **active wave name** and **active wave status** from Step 2 (WL-1). Compute the **wave-linked idea set** per WL-2 and tag each lifecycle gap detected in Step 6 with a scope field of `wave-linked` or `backlog-only` per WL-3.
2. Select the applicable branch:
   - **Active-wave branch (Priorities 1–8)** — taken when the active wave name is non-null. Only gaps tagged `wave-linked` by WL-3 can satisfy Priorities 2–6. Backlog-only gaps remain visible in the Lifecycle Gaps table (with `Backlog (outside wave)` in the Scope column) but never drive the recommendation in this branch, and they are not considered by Priorities 7 and 8.
   - **No-wave branch (Priorities 9–14)** — taken when the active wave name is null. All detected gaps are eligible (the scope field is functionally unused in this branch because WL-3 tags every gap as `backlog-only` when there is no active wave). This branch preserves the pre-change gap-first recommendation behavior.
3. Walk the precedence rows of the selected branch top-to-bottom. At the first row whose condition matches, stop and use that row's recommended skill and reason template.
4. Substitute `{Name}`, `{status}`, `{Idea Title}`, `{Priority}`, and `{NN}-spec-{name}` into the reason template from the matched row. See "Wave-name interpolation" below for the `{Name}` substitution rule.
5. Select the **alternative skill** for the `AskUserQuestion` prompt using the rules in the next subsection.

**Priority 6 / Priority 13 P0/P1 filter.** Only LG-1 (Captured → Shaped) gaps whose subject idea has `Priority: P0` or `Priority: P1` in its `docs/BACKLOG.md` metadata block qualify. Ideas with `Priority: P2`, `Priority: P3`, or an unset priority do not trigger Priority 6 or Priority 13. This matches the pre-change Priority-5 filter behavior.

**Priority 1 precondition.** Priority 1 fires only when the active wave name is non-null **and** the wave-linked idea set from WL-2 is empty. An empty wave with no backlog linkage blocks all of Priorities 2–6 (no wave-linked gap subject can exist) and also blocks Priorities 7 and 8 (a clean wave with assigned ideas, not a wave with zero ideas).

**Priorities 7 and 8 gating.** Priorities 7 and 8 require the wave-linked idea set to be non-empty **and** every detected gap tagged `wave-linked` by WL-3 to be absent (i.e., no wave-linked LG-* gap matched Priorities 2–6). A wave with only backlog-only gaps satisfies this "no wave-linked gaps remain" condition.

**Wave-name interpolation.** Whenever a reason template substitutes `{Name}`, the active wave name resolved by WL-1 is passed through verbatim — no escaping transformations beyond standard JSON string encoding. Em dashes, colons, and other markdown-special characters appear in the rendered `AskUserQuestion` question exactly as they appear in `docs/ROADMAP.md`.

---

### AskUserQuestion Format

The prompt must **always** include at least 3 options: the recommended skill (labeled `(Recommended)`), exactly one alternative skill selected per the rules below, and `Done for now`. These three options are mandatory on every invocation — the prompt is never reduced to fewer than three, and `Done for now` is always the final option.

#### Alternative-Skill Selection

Select the alternative skill per the matched priority:

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
| 14 (no wave, no gaps) | `/arc-audit` |

**Never offer the recommended skill as its own alternative.** If a fall-through would yield the same skill as the recommendation (e.g., both Priority 7 and Priority 14 recommend `/arc-wave`, but their alternatives differ), use the alternative listed in the table above.

#### Prompt Shape

The `question` field must include the fully-substituted reason template from the precedence row so the user understands why this skill is being recommended.

```
AskUserQuestion({
  questions: [{
    question: "{reason template with concrete values filled in}",
    header: "Next Step",
    options: [
      { label: "Run {recommended skill} (Recommended)", description: "{one-line description of what the skill does}" },
      { label: "Run {alternative skill}", description: "{one-line description of the alternative}" },
      { label: "Done for now", description: "Exit without running any skill" }
    ]
  }]
})
```

---

### User Selection Handling

| Selection | Action |
|-----------|--------|
| Recommended skill | Invoke via `Skill({ name: "{skill-name}" })` |
| Alternative skill | Invoke via `Skill({ name: "{skill-name}" })` |
| Done for now | Exit silently — no skill invocation, no further output |

**Constraint:** No skill is ever invoked without the user explicitly selecting it from the AskUserQuestion prompt.

---

## Cross-References

- `skills/arc-audit/references/audit-dimensions.md` — Backlog health and wave alignment checks (deeper analysis than status pulse)
- `references/idea-lifecycle.md` — Idea status transitions and lifecycle phases
- `references/wave-planning.md` — Wave planning guidance and phase-based sizing
