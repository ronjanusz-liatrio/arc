# Brief Validation

Readiness criteria for promoting a shaped brief to spec-ready status. A brief that passes all criteria is ready for handoff to `/cw-spec`.

## Readiness Checklist

### Problem (Required)

| # | Criterion | Pass | Fail |
|---|-----------|------|------|
| 1 | Problem identifies a specific affected persona or user group | Named persona or concrete user description | Vague "users" or "people" |
| 2 | Problem describes a concrete pain point | Observable behavior, measurable waste, or explicit blocker | Abstract category ("struggle with", "have difficulty") |
| 3 | Problem states the impact of inaction | Quantified cost, named consequence, or explicit risk | No impact mentioned |
| 4 | Problem is 1-3 sentences | Within range | Too brief (incomplete) or too long (scope creep) |

### Proposed Solution (Required)

| # | Criterion | Pass | Fail |
|---|-----------|------|------|
| 5 | Solution describes a capability, not implementation | "A skill that guides users through..." | "A Python script that parses..." |
| 6 | Solution connects to the stated problem | Clear link between pain and remedy | Solution addresses a different problem |
| 7 | Solution is 1-2 sentences | Within range | Overspecified or underspecified |

### Success Criteria (Required)

| # | Criterion | Pass | Fail |
|---|-----------|------|------|
| 8 | At least 3 success criteria listed | 3+ items | Fewer than 3 |
| 9 | Each criterion is independently verifiable | Can confirm pass/fail without other criteria | Criteria are interdependent or vague |
| 10 | Criteria are measurable or binary | "Produces a complete brief" (binary), "Completes in under 30 seconds" (measurable) | "Improves the experience" (subjective) |

### Constraints (Required)

| # | Criterion | Pass | Fail |
|---|-----------|------|------|
| 11 | At least 1 constraint documented | Explicit constraint listed | Section empty |
| 12 | Constraints are restrictions, not requirements | "Must not call external APIs" (restriction) | "Must support 3 personas" (requirement) |
| 13 | Or explicitly states "No constraints identified" | Deliberate acknowledgment | Section missing |

### Assumptions (Required)

| # | Criterion | Pass | Fail |
|---|-----------|------|------|
| 14 | At least 1 assumption documented | Explicit assumption listed | Section empty |
| 15 | Assumptions are falsifiable | "CUSTOMER.md exists with at least one persona" (falsifiable) | "Users will like this" (not falsifiable) |
| 16 | Or explicitly states "No assumptions identified" | Deliberate acknowledgment | Section missing |

### Wave Assignment (Set by /arc-wave)

| # | Criterion | Pass | Fail |
|---|-----------|------|------|
| 17 | Wave assignment is set or explicitly "Unassigned" | References a ROADMAP wave or states "Unassigned" | Field missing |

### Open Questions

| # | Criterion | Pass | Fail |
|---|-----------|------|------|
| 18 | Open questions are listed or explicitly "None" | Questions listed with context, or "None" | Section missing |
| 19 | No blocking questions remain unresolved | All blocking items marked resolved or deferred with rationale | Blocking question with no resolution plan |

## Validation Outcome

**Spec-Ready:** All 19 criteria pass. The brief can be promoted to `spec-ready` status and assigned to a wave.

**Needs Work:** One or more criteria fail. The skill should:
1. Present the failed criteria to the user
2. Guide the user through fixing each gap via AskUserQuestion
3. Re-validate after fixes

**Return to Capture:** Multiple critical failures (problem unclear, no persona fit, not feasible). The idea should revert to `captured` status per the backward transition in `references/idea-lifecycle.md`.

## Common Failure Patterns

| Pattern | Symptom | Fix |
|---------|---------|-----|
| Vague problem | "Users need better X" | Ask: Who specifically? What happens without it? What does "better" mean? |
| Solution-first | Problem section describes the solution | Rewrite: What pain exists independent of any solution? |
| Unmeasurable criteria | "Improves developer experience" | Rewrite with observable outcome: "Developers complete task in ≤3 steps" |
| Missing constraints | Empty constraints section | Ask: Are there technical, time, or scope limits? If truly none, state explicitly |
| Assumed context | Brief assumes reader knowledge | Add context: Name the tool, define the acronym, link the reference |
| Scope creep | Problem describes multiple unrelated pains | Split into separate ideas, each with one focused problem |

## Cross-References

- [shaping-dimensions.md](shaping-dimensions.md) — The four analysis dimensions that produce brief content
- `references/brief-format.md` — The structural format this checklist validates against
- `references/idea-lifecycle.md` — Lifecycle transitions triggered by validation outcome
