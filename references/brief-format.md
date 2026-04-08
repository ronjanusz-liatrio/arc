# Spec-Ready Brief Format

The spec-ready brief is Arc's primary output — the artifact produced by `/arc-shape` and consumed by `/cw-spec`. This document defines the exact structure, field descriptions, and examples.

## Brief Template

```markdown
## {Idea Title}

### Problem
{1-3 sentences: who is affected, what pain they experience, and the impact}

### Proposed Solution
{1-2 sentences: high-level approach and the capability it unlocks}

### Success Criteria
- {Measurable outcome with target}
- {Measurable outcome with target}
- {Measurable outcome with target}

### Constraints
- {Constraint: time, technical, team, or scope limitation}

### Assumptions
- {What must be true for this solution to work}

### Wave Assignment
{ROADMAP wave reference, or "Unassigned" if not yet planned}

### Open Questions
- {Clarification needed before /cw-spec, or "None"}
```

## Field Descriptions

### Problem

Define the problem clearly enough that someone unfamiliar with the context understands who suffers, what the pain is, and why it matters.

**Requirements:**
- 1-3 sentences
- Must identify the affected user or persona (reference `docs/CUSTOMER.md` personas when available)
- Must describe the specific pain point, not a generic category
- Must state the impact (wasted time, blocked workflow, risk, etc.)

**Example:**
> Product owners using the temper + claude-workflow pipeline have no structured way to capture and refine ideas before they enter `/cw-spec`. Ideas arrive as ad-hoc prompts without consistent problem framing, leading to specs that miss customer context and lack clear success criteria.

### Proposed Solution

Describe what will be built at a high level — enough to understand the approach without prescribing implementation details.

**Requirements:**
- 1-2 sentences
- Must describe the capability, not the implementation
- Must connect to the problem (how does this solve the pain?)

**Example:**
> An `/arc-shape` skill that guides users through interactive problem framing, customer fit analysis, and scope definition, producing a structured brief that feeds directly into `/cw-spec`.

### Success Criteria

Define how we know this works. Each criterion should be independently verifiable.

**Requirements:**
- Minimum 3 criteria
- Each must be measurable or binary (pass/fail)
- Prefer observable outcomes over internal metrics

**Example:**
> - `/arc-shape` produces a complete brief with all required fields populated
> - Shaped briefs are accepted by `/cw-spec` without manual reformatting
> - Parallel subagent analysis covers all four shaping dimensions (problem, customer, scope, feasibility)

### Constraints

Identify limitations that bound the solution. These are not requirements — they are restrictions.

**Requirements:**
- At least 1 constraint (if none exist, state "No constraints identified")
- Categories: time, technical, team, scope, compliance

**Example:**
> - Must follow Temper's SKILL.md format conventions
> - No external API calls — all operations are local file reads and writes
> - Brief format must remain stable for `/cw-spec` compatibility

### Assumptions

State what must be true for this solution to work. If an assumption is invalidated, the brief may need reshaping.

**Requirements:**
- At least 1 assumption (if none, state "No assumptions identified")
- Each should be falsifiable

**Example:**
> - Users have `docs/CUSTOMER.md` with at least one persona defined
> - The Temper plugin is installed and has been run at least once (for phase context)

### Wave Assignment

Reference the ROADMAP wave this idea is assigned to, or "Unassigned" if not yet planned.

**Requirements:**
- Must match a wave name in `docs/ROADMAP.md` if assigned
- Set by `/arc-wave` during wave planning, not during shaping

**Example:**
> Wave 1: Plugin Foundation

### Open Questions

List any unresolved questions that should be addressed before or during `/cw-spec`. If shaping resolved all questions, state "None".

**Requirements:**
- Each question should be specific and actionable
- Questions that block implementation should be flagged as such

**Example:**
> - Should `/arc-shape` create `docs/CUSTOMER.md` from template if it doesn't exist? (blocks customer fit analysis)
> - What is the maximum number of ideas to display in the selection list?

## Validation Checklist

A brief is ready for `/cw-spec` when:

- [ ] Problem identifies who, what pain, and impact
- [ ] Proposed solution describes capability (not implementation)
- [ ] At least 3 success criteria, each measurable or binary
- [ ] At least 1 constraint documented (or explicitly "none")
- [ ] At least 1 assumption documented (or explicitly "none")
- [ ] Wave assignment is set (by `/arc-wave`) or explicitly "Unassigned"
- [ ] Open questions are listed or explicitly "None"
- [ ] Status in BACKLOG is `shaped` or `spec-ready`

## Cross-References

- [idea-lifecycle.md](idea-lifecycle.md) — The Shape stage produces this brief; Spec-Ready stage locks it
- [wave-planning.md](wave-planning.md) — Wave Assignment field is set during wave planning
