---
role: product-leadership
artifact: BACKLOG
output_path: docs/BACKLOG.md
---

# BACKLOG Template

This template defines the BACKLOG artifact across all 7 maturity phases. The backlog is a triaged list of product ideas organized as inline markdown sections with a summary table header. Each idea progresses through the idea lifecycle (Capture, Shape, Spec-Ready) and is stored as a `## {Title}` section within the BACKLOG file. When an idea ships, it is removed from the BACKLOG and archived in the wave archive at `docs/skill/arc/waves/`.

The `/arc-capture` skill appends new idea stubs to the backlog. The `/arc-shape` skill expands captured stubs into full briefs. The `/arc-wave` skill promotes shaped ideas to spec-ready status with wave assignments.

---

## Storage Format

### Summary Table

The BACKLOG begins with a summary table providing a scannable overview of all ideas:

```markdown
| Title | Status | Priority | Wave |
|-------|--------|----------|------|
| [Idea Title](#idea-title) | captured | P2-Medium | -- |
| [Another Idea](#another-idea) | shaped | P1-High | -- |
| [Ready Idea](#ready-idea) | spec-ready | P0-Critical | Wave 1 |
```

**Columns:**

| Column | Values | Description |
|--------|--------|-------------|
| Title | Linked text | Idea title as markdown anchor link to the `## {Title}` section below |
| Status | `captured`, `shaped`, `spec-ready` | Current stage in the idea lifecycle (shipped ideas are archived to `docs/skill/arc/waves/`) |
| Priority | `P0-Critical`, `P1-High`, `P2-Medium`, `P3-Low` | Rough priority assigned at capture time |
| Wave | Wave name or `--` | ROADMAP wave assignment (set by `/arc-wave`) |

### Idea Sections

Each idea is a `## {Title}` section. The section format depends on the idea's lifecycle stage:

**Captured idea (stub):**

```markdown
## {Title}

- **Status:** captured
- **Priority:** P2-Medium
- **Captured:** 2026-04-07T14:30:00Z

{One-line summary provided at capture time.}
```

**Shaped idea (full brief):**

```markdown
## {Title}

- **Status:** shaped
- **Priority:** P1-High
- **Captured:** 2026-04-07T14:30:00Z
- **Shaped:** 2026-04-08T10:15:00Z

{One-line summary provided at capture time.}

### Problem

{1-3 sentences: who is affected, what the pain point is, and the impact of leaving it unsolved.}

### Proposed Solution

{1-2 sentences: high-level approach and the capability it unlocks.}

### Success Criteria

- {Measurable outcome with target}
- {Measurable outcome with target}
- {Measurable outcome with target}

### Constraints

- {Time, technical, team, or scope constraints}

### Assumptions

- {What must be true for this solution to work}

### Open Questions

- {Clarifications needed before proceeding to spec}
```

**Spec-ready idea (full brief with wave assignment):**

```markdown
## {Title}

- **Status:** spec-ready
- **Priority:** P0-Critical
- **Captured:** 2026-04-07T14:30:00Z
- **Shaped:** 2026-04-08T10:15:00Z
- **Wave:** Wave 1 — Core Capture Flow

{Full brief subsections same as shaped, plus wave assignment.}
```

---

## Phase Requirements

### Spike -- Not Required

**Required sections:** None.

**Content guidance:**

- Backlogs are not required during Spike — the project is still validating whether it should exist
- If ideas are captured during Spike, they can be stored informally and migrated to a BACKLOG at Foundation

**Mermaid diagrams:** None required.

---

### Proof of Concept -- Not Required

**Required sections:** None.

**Content guidance:**

- Backlogs are not required during PoC — the project is validating its core assumption
- If ideas are captured during PoC, they can be stored informally and migrated to a BACKLOG at Foundation

**Mermaid diagrams:** None required.

---

### Vertical Slice -- Not Required

**Required sections:** None.

**Content guidance:**

- Backlogs are not required during Vertical Slice — the project is building its first end-to-end slice
- If ideas emerge during Vertical Slice, they can be captured informally and migrated to a BACKLOG at Foundation

**Mermaid diagrams:** None required.

---

### Foundation -- Stub

**Required sections:**

- **Backlog Overview:** 1-2 sentences describing how the backlog is organized and what the priority categories mean
- **Priority Definitions:** Table defining the four priority levels and when to use each

```markdown
| Priority | Label | When to Use |
|----------|-------|-------------|
| P0 | Critical | Blocks current wave or causes user-visible failure |
| P1 | High | Important for current or next wave; significant user impact |
| P2 | Medium | Valuable but not urgent; can wait 1-2 waves |
| P3 | Low | Nice to have; consider if capacity allows |
```

- **Summary Table:** Table header with 5-15 initial ideas
- **Idea Sections:** One `## {Title}` section per idea, following the captured stub format at minimum

**Content guidance:**

- Initial ideas should represent a broad cross-section of product needs — features, improvements, and technical debt
- Every idea must have a title, status, priority, and one-line summary at minimum
- Use the captured stub format for ideas that have not been through `/arc-shape`
- Ideas that have already been shaped should use the full brief format
- Reference CUSTOMER.md to tag which persona each idea serves (in the Problem section when shaped)

**Mermaid diagrams:** None required.

---

### MVP -- Draft

**Required sections:**

All Foundation sections, maintained and current. Additionally:

- **IDs:** Each idea section includes a unique identifier (B001, B002, ...) for cross-referencing from ROADMAP.md and DECISIONS.md
- **Size Estimates:** Shaped ideas include a rough size estimate (S, M, L, XL) to aid wave planning
- **Acceptance Criteria:** Shaped ideas include explicit acceptance criteria (distinct from success criteria — acceptance criteria are pass/fail checks for the implementation)
- **Status Tracking:** Summary table updated with current lifecycle status for all ideas
- **Customer Persona Reference:** Each shaped idea references the primary persona it serves (from CUSTOMER.md)
- **Cut List:** Section listing ideas that were explicitly descoped or rejected, with brief rationale

**Content guidance:**

- IDs enable traceability — ROADMAP waves and DECISIONS entries can reference specific backlog items
- Size estimates do not need to be precise — they help `/arc-wave` balance wave capacity
- Acceptance criteria bridge the gap between Arc's brief and `/cw-spec`'s scenario definitions
- The cut list prevents re-surfacing of previously rejected ideas and provides decision history
- Review the full backlog periodically — stale captured ideas should either be shaped or cut

**Mermaid diagrams:** None required.

---

### Growth -- Full

**Required sections:**

All MVP sections, maintained and current. Additionally:

- **Backlog Health Metrics:** Summary statistics: total ideas, count by status, count by priority, average time from capture to spec-ready, ideas per wave
- **Feature Streams:** Grouping of related ideas into thematic streams (e.g., "Capture Flow", "Shaping Pipeline", "Integration") for easier triage
- **Technical Debt Register:** Section tracking non-feature work: refactoring, performance, documentation, and infrastructure improvements that compete for wave capacity

**Content guidance:**

- Backlog health metrics help product owners identify bottlenecks in the idea pipeline
- Feature streams emerge naturally as the backlog grows — do not force streams on a small backlog
- Technical debt competes with features for wave capacity — tracking it explicitly prevents silent accumulation
- Reference wave archive retrospectives (`docs/skill/arc/waves/`) to validate that backlog health is improving over time

**Mermaid diagrams:** None required.

---

### Maturity -- Full (Maintained)

**Required sections:**

All Growth sections, maintained and current. Additionally:

- **Backlog Retrospective:** Analysis of the backlog's effectiveness over the product lifecycle: estimation accuracy, pipeline throughput, idea quality trends, and lessons for future product planning

**Content guidance:**

- The Maturity backlog is a historical record as much as an active one
- Backlog retrospective provides data for improving the capture-to-spec-ready pipeline
- Review feature streams — some may have been fully addressed and can be archived
- Updates are infrequent but the backlog should still accurately reflect remaining work

**Mermaid diagrams:** None required.

---

## Cross-References

- **VISION.md:** Product vision that backlog ideas implement (always-required)
- **CUSTOMER.md:** Personas whose needs drive idea prioritization (always-required)
- **ROADMAP.md:** Waves that group spec-ready backlog ideas into delivery cycles (product-leadership)
- **PROJECT_CHARTER.md:** Project scope constrains what ideas belong in the backlog (temper: always-required)
- **DECISIONS.md:** Records significant backlog decisions — cuts, re-prioritizations, scope changes (temper: always-required)
- **Idea lifecycle:** `references/idea-lifecycle.md` defines the Capture, Shape, Spec-Ready, Shipped progression
- **Brief format:** `references/brief-format.md` defines the spec-ready brief structure used in shaped idea sections
- **Wave archive:** `references/wave-archive.md` defines the archive schema for shipped ideas stored at `docs/skill/arc/waves/`
