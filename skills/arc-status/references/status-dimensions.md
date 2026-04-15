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

## Cross-References

- `skills/arc-audit/references/audit-dimensions.md` — Backlog health and wave alignment checks (deeper analysis than status pulse)
- `references/idea-lifecycle.md` — Idea status transitions and lifecycle phases
- `references/wave-planning.md` — Wave planning guidance and phase-based sizing
