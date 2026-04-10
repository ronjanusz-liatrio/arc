# README Quality Rules

`/arc-sync` enforces quality gates on every scaffolded and updated README. These rules are adapted from [readme-author](https://github.com/liatrio-labs/claude-plugins/tree/main/plugins/readme-author) conventions and tailored for Arc-managed READMEs. Both scaffold mode and update mode validate output against these gates before presenting for user approval.

This document is consumed by:
- **`/arc-sync` scaffold mode** --- validates the generated README before user approval
- **`/arc-sync` update mode** --- validates managed section changes before writing

---

## Line Count Target

| Metric | Target | Action |
|--------|--------|--------|
| Total README lines | 100--200 | Warn if outside range |
| Managed section lines (all `ARC:` sections combined) | 40--100 | Refactor if exceeding |
| Single managed section | 5--25 lines | Split or condense if outside range |
| TEMPER: managed sections (all combined) | 30--80 | Arc does not manage line count — Temper controls these |
| Non-managed sections (License, etc.) | 5--15 combined | Keep minimal |

A README under 100 lines likely lacks enough context for onboarding. A README over 200 lines should move detail into `docs/` and link from the README.

---

## Heading Hierarchy

The README must use semantic headings with no skipped levels:

| Level | Usage | Rule |
|-------|-------|------|
| `#` (h1) | Project title only | Exactly one h1 in the entire file |
| `##` (h2) | Top-level sections (Overview, Features, Roadmap, etc.) | All major sections use h2 |
| `###` (h3) | Subsections within a section | Only appear nested under an h2 |
| `####` (h4) | Rarely used | Avoid unless section depth requires it |

**Violations:** Multiple h1 headings, h3 appearing without a preceding h2, or h4 used for top-level sections.

---

## Accessibility

| Rule | Requirement |
|------|-------------|
| Image alt text | Every `![...]()` image must have non-empty alt text in the brackets |
| Descriptive links | No bare URLs --- use `[descriptive text](url)` format |
| Plain language | Target Grade 8--10 reading level for prose sections |
| Color alone | Mermaid diagrams must not rely solely on color to convey meaning --- use labels on all nodes |

---

## Progressive Disclosure

The README provides a quick-start surface. Detailed content lives in `docs/`.

| Content type | README treatment | Deep-dive location |
|--------------|-----------------|-------------------|
| Problem statement | 2--3 sentences | `docs/VISION.md` |
| Audience | Brief persona summaries (name + role + one sentence) | `docs/CUSTOMER.md` |
| Features | Bullet list with one-line descriptions | `docs/BACKLOG.md` per-idea briefs |
| Roadmap | Compact table (wave, theme, status) | `docs/ROADMAP.md` |
| Lifecycle diagram | Mermaid diagram with status counts | `docs/BACKLOG.md` for full idea list |
| Install instructions | Minimal steps to get running | Dedicated install guide if complex |
| Contributing | Link to CONTRIBUTING.md or brief inline rules | `CONTRIBUTING.md` |

Each managed section should include at least one `](docs/...)` link for traceability (supports TS-7).

---

## Conciseness Rules

### Features Section (`ARC:features`)

- Use a bullet list, not a table
- Each bullet: bold title followed by an em-dash and one-sentence description
- Include only shipped items (`Status: shipped` from BACKLOG.md)
- Do not expose priority metadata (P0/P1/P2/P3) in the public README
- Do not include idea status labels --- if it is in the features section, it shipped

```markdown
- **Fast Idea Capture** --- Record product ideas in under 30 seconds
- **Interactive Shaping** --- Refine ideas into spec-ready briefs with guided Q&A
```

### Audience Section (`ARC:audience`)

- Brief persona summaries: name, role, and one sentence of context
- Do not dump full persona profiles --- link to CUSTOMER.md for details
- Use a bullet list or short paragraph per persona

```markdown
- **Alex, Platform Engineer** --- Builds internal tooling and needs to track product direction without context-switching
- **Jordan, Product Owner** --- Manages idea lifecycle from capture through delivery
```

### Roadmap Section (`ARC:roadmap`)

- Compact table with columns: Wave, Theme, Status
- Include only active and planned waves (omit completed waves older than one cycle)
- Status values: `Active`, `Planned`, `Completed`

```markdown
| Wave | Theme | Status |
|------|-------|--------|
| Wave 3 | Pipeline Health | Active |
| Wave 4 | Cross-Plugin Integration | Planned |
```

### Overview Section (`ARC:overview`)

- 2--3 sentences covering the problem and value proposition
- First sentence states the problem; second sentence states how the project solves it
- Link to `docs/VISION.md` for the full vision document

---

## Managed Section Constraints

Content between `ARC:` markers must follow these constraints:

| Constraint | Rule |
|------------|------|
| No artifact dumps | Never paste full artifact content between markers --- summarize and link |
| Marker stability | Never move, rename, or nest `<!--# BEGIN/END ARC:... -->` markers |
| Whitespace | One blank line after the BEGIN marker, one blank line before the END marker |
| No HTML (other than markers) | Managed section content should be pure Markdown |
| Self-contained | Each managed section should be understandable without reading other sections |

---

## TEMPER Section Guidance

TEMPER-managed sections are owned by Temper. Arc scaffolds empty placeholder markers but never writes content to them.

| Section | Owner | Arc's Role |
|---------|-------|------------|
| `TEMPER:architecture` | Temper | Scaffold placeholder, validate presence |
| `TEMPER:getting-started` | Temper | Scaffold placeholder, validate presence |
| `TEMPER:testing` | Temper | Scaffold placeholder, validate presence |
| `TEMPER:contributing` | Temper | Scaffold placeholder, validate presence |

When TEMPER sections are present and populated, Arc validates reader journey coherence (TS-9) and engineering presence (TS-10) but never modifies TEMPER section content.

## Non-Managed Section Guidance

Scaffold mode generates a License placeholder. Other engineering sections (install, contributing) are managed by Temper via TEMPER: markers.

### License

- Single line stating the license type
- Link to the LICENSE file if it exists
- Do not create or modify LICENSE files

---

## Mermaid Diagram Rules

### Brand Colors

All mermaid diagrams use Liatrio brand colors via the init directive:

```
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#11B5A4', 'secondaryColor': '#E8662F', 'tertiaryColor': '#1B2A3D'}}}%%
```

### Diagram Constraints

| Constraint | Limit |
|------------|-------|
| Maximum nodes | 20 |
| Node labels | Must include status counts where applicable (e.g., `Captured(3)`) |
| Direction | Left-to-right (`LR`) for lifecycle flows, top-to-bottom (`TD`) for hierarchies |
| Edge labels | Use only when the relationship is not obvious from context |
| Subgraphs | Maximum 3 --- use sparingly |

### Status Count Labels

The lifecycle diagram shows live counts from BACKLOG.md as node labels:

```
Captured(3) --> Shaped(2) --> Spec-Ready(1) --> Shipped(4)
```

Counts must match the current BACKLOG.md tallies. A zero count is displayed as `Status(0)` --- do not omit zero-count nodes.

---

## Metadata Exposure Rules

The public README must not expose internal project management metadata:

| Metadata type | Exposure rule |
|---------------|---------------|
| Priority levels (P0--P3) | Never shown in README |
| Internal status labels (captured, shaped, spec-ready) | Never shown in features section; permitted in lifecycle diagram |
| Idea IDs or BACKLOG entry identifiers | Never shown in README |
| Wave planning details (velocity, capacity) | Never shown --- use only wave name, theme, and status |
| Review scores or health ratings | Never shown in README |
| Stale markers or review timestamps | Never shown in README |

The features section lists shipped capabilities as user-facing descriptions. The roadmap section shows wave names and themes. Internal workflow metadata stays in `docs/`.

---

## Validation Checklist

`/arc-sync` runs this checklist before presenting output for user approval:

| # | Gate | Pass criteria |
|---|------|---------------|
| 1 | Line count | README is 100--200 lines |
| 2 | Single h1 | Exactly one `#` heading |
| 3 | No skipped headings | Heading levels increment by 1 |
| 4 | Image alt text | All images have non-empty alt text |
| 5 | No bare URLs | All URLs wrapped in Markdown link syntax |
| 6 | Managed sections concise | Each `ARC:` section is 5--25 lines |
| 7 | No priority metadata | No P0/P1/P2/P3 strings in features section |
| 8 | Diagram node limit | Mermaid diagrams have 20 or fewer nodes |
| 9 | Diagram brand colors | Mermaid init block uses Liatrio colors |
| 10 | Traceability links | At least one `](docs/...)` link in managed sections |
| 11 | No artifact dumps | No managed section exceeds 25 lines |
| 12 | Progressive disclosure | Detail sections link to `docs/` files |

**Gate behavior:** Gates 1, 7, and 8 are warnings (proceed with advisory). Gates 2--6 and 9--12 are errors (must fix before writing).

---

## Cross-References

- `skills/arc-sync/references/trust-signals.md` --- Trust-signal definitions that validate structural quality post-write
- `skills/arc-sync/references/readme-mapping.md` --- Artifact-to-section mapping rules
- `references/idea-lifecycle.md` --- Status values used in lifecycle diagrams and features lists
