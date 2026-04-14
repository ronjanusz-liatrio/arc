# Shaping Dimensions

`/arc-shape` analyzes each captured idea across four dimensions using parallel subagents. Each dimension produces structured findings that feed into the shaped brief.

## Dimension 1: Problem Clarity

**Purpose:** Validate that the problem statement is specific, scoped, and grounded in observable impact.

**Key Questions:**
- Is the problem statement specific enough to act on?
- Who exactly is affected? (Name a persona from `docs/CUSTOMER.md` if available)
- What is the observable impact? (Wasted time, blocked workflow, risk, cost)
- Are we describing symptoms or root cause?
- Can someone unfamiliar with the context understand the problem?

**Inputs:**
- Captured idea stub from `docs/BACKLOG.md` (title + one-line summary)
- `docs/CUSTOMER.md` (if present) for persona context
- `docs/VISION.md` (if present) for product scope

**Output Format:**

```markdown
### Problem Clarity Assessment

**Clarity:** High | Medium | Low
**Affected persona:** {persona name or "Not identified"}
**Impact:** {observable impact statement}
**Gaps identified:**
- {gap description and recommendation}

**Suggested problem statement:**
> {1-3 sentence problem statement ready for the brief}
```

**How it feeds into the brief:** The suggested problem statement populates the **Problem** section. Gaps become follow-up questions in the interactive Q&A.

---

## Dimension 2: Customer Fit

**Purpose:** Validate that the idea aligns with defined personas and serves an identified job-to-be-done.

**Key Questions:**
- Does this idea align with a persona defined in `docs/CUSTOMER.md`?
- Which JTBD statement does this idea serve?
- Is there evidence of demand (persona pain points, existing JTBD gaps)?
- Does this idea serve the primary persona or a secondary one?
- Would solving this problem move a success metric from `docs/CUSTOMER.md`?

**Inputs:**
- Captured idea stub from `docs/BACKLOG.md`
- `docs/CUSTOMER.md` (if present) — personas, JTBD catalog, success metrics
- `docs/VISION.md` (if present) — target audience

**Output Format:**

```markdown
### Customer Fit Assessment

**Persona match:** {persona name} | "No matching persona"
**JTBD served:** {JTBD statement} | "No matching JTBD"
**Demand evidence:** {evidence description} | "No evidence available"
**Fit rating:** Strong | Moderate | Weak | No fit

**Gaps identified:**
- {gap description and recommendation}

**Recommendation:** {Proceed / Needs persona work / Defer}
```

**How it feeds into the brief:** Persona match informs the **Problem** section (who is affected). JTBD alignment validates the **Proposed Solution**. Gaps become follow-up questions.

---

## Dimension 3: Scope Boundaries

**Purpose:** Ensure constraints and non-goals are explicit before the idea enters the SDD pipeline.

**Key Questions:**
- Are constraints explicit? (Time, technical, team, scope limitations)
- What is intentionally excluded? (Non-goals)
- What are the dependencies? (Other ideas, external systems, team availability)
- What is the smallest viable scope that still delivers value?
- Does the idea's scope fit within the product's scope boundaries from `docs/VISION.md`?

**Inputs:**
- Captured idea stub from `docs/BACKLOG.md`
- `docs/VISION.md` (if present) — scope boundaries
- `docs/ROADMAP.md` (if present) — existing wave commitments and dependencies

**Output Format:**

```markdown
### Scope Assessment

**Scope size:** Small | Medium | Large | Too large (split recommended)
**Explicit constraints:**
- {constraint}

**Suggested non-goals:**
- {non-goal with rationale}

**Dependencies:**
- {dependency description}

**Minimum viable scope:**
> {1-2 sentence description of the smallest version that delivers value}

**Gaps identified:**
- {gap description and recommendation}
```

**How it feeds into the brief:** Constraints populate the **Constraints** section. Non-goals inform the `/cw-spec` non-goals. Dependencies may affect **Wave Assignment**. Gaps become follow-up questions.

---

## Dimension 4: Feasibility

**Purpose:** Assess whether the project can absorb this idea given its current maturity and engineering capacity.

**Key Questions:**
- Given the current Temper phase, can engineering absorb this work?
- What are the technical risks or unknowns?
- Are there unknowns that need spikes or research before spec?
- Does this require new patterns or infrastructure, or does it fit existing conventions?
- Are there hard gate failures that should be addressed first?

**Inputs:**
- Captured idea stub from `docs/BACKLOG.md`
- `docs/management-report.md` (if present) — Temper phase, gate results, coverage matrix
- Project CLAUDE.md (if present) — TEMPER: sections for project context
- `docs/ROADMAP.md` (if present) — current wave load
- Skill discovery results from `/skillz-find` (when skillz plugin is installed)

**Output Format:**

```markdown
### Feasibility Assessment

**Temper phase:** {phase} | "Not available"
**Hard gate failures:** {list} | "None" | "Not available"
**Technical risk:** Low | Medium | High
**Risk factors:**
- {risk description}

**Unknowns requiring spikes:**
- {unknown and suggested spike approach}

**Pattern fit:** Existing patterns | New patterns required | Infrastructure needed
**Feasibility rating:** Ready | Ready with caveats | Needs spike | Not feasible now

**Recommendation:** {Proceed / Spike first / Defer to later phase}

#### Relevant Skills
| Skill Name | Installs/wk | Security | Recommendation | Relevance |
|------------|-------------|----------|----------------|-----------|
| {name} | {count} | {status} | install / investigate / avoid | {1-2 sentence summary} |

_If `/skillz-find` returned zero results or skillz is not installed:_
> No relevant skills found on skills.sh for this problem domain.
```

**How it feeds into the brief:** Risk factors inform **Constraints** and **Assumptions**. Unknowns populate **Open Questions**. Feasibility rating may affect whether the idea proceeds to shaping or returns to Capture. Discovered skills are surfaced in the Step 3 synthesis table so the user is aware of available tooling before the brief enters `/cw-spec`.

---

## Aggregation

After all four subagents return, `/arc-shape` aggregates results:

1. **Merge gaps** from all dimensions into a deduplicated list
2. **Identify critical gaps** — any dimension rated Low/Weak/Not feasible flags the idea for additional Q&A
3. **Pre-populate brief fields** using suggested content from each dimension
4. **Present synthesis** to the user: dimension ratings (five rows), key findings, relevant skills, and recommended follow-up questions
5. **Run interactive Q&A** to fill remaining gaps using AskUserQuestion

The synthesis table includes five rows: **Problem Clarity**, **Customer Fit**, **Scope**, **Feasibility**, and **Skill Discovery**. Skill Discovery is not a fifth parallel subagent — it runs inside the Feasibility subagent and is surfaced as its own row in the synthesis for visibility. When the `/skillz` plugin is not installed, the Skill Discovery row displays "Skipped" with the skip reason.

The goal is to minimize Q&A rounds by front-loading analysis — the subagents do the research, the user makes the decisions.
