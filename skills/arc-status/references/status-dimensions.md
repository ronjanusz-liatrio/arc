# Status Dimensions

`/arc-status` performs a read-only pulse check across four summary sections: **Current Wave**, **Backlog Snapshot**, **In-Flight Specs**, and **Recent Activity**. Each section defines what is read, how to parse it, how to render the output, and a graceful fallback when the source artifact is missing.

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

**Purpose:** Count ideas at each lifecycle status in the backlog summary table and report the distribution, giving the user a quick pipeline health view.

**Detection Logic:**

1. Read `docs/BACKLOG.md`
2. Locate the summary table — the first markdown table that contains columns: Title, Status, Priority, Wave
3. Parse each data row (skip header and separator rows)
4. Extract the Status column value from each row
5. Count ideas per status: `captured`, `shaped`, `spec-ready`, `shipped`
6. Sum all counts for the total

**Inputs:**

- `docs/BACKLOG.md` — summary table rows

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

## Cross-References

- `skills/arc-audit/references/audit-dimensions.md` — Backlog health and wave alignment checks (deeper analysis than status pulse)
- `references/idea-lifecycle.md` — Idea status transitions and lifecycle phases
- `references/wave-planning.md` — Wave planning guidance and phase-based sizing
