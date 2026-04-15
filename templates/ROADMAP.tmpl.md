---
role: product-leadership
artifact: ROADMAP
output_path: docs/ROADMAP.md
---

# ROADMAP Template

This template defines the ROADMAP artifact across all 7 maturity phases. The roadmap organizes spec-ready ideas from the BACKLOG into themed delivery waves with goals, target timeframes, dependencies, and status tracking. It translates the product VISION into a phased execution plan.

The `/arc-wave` skill reads this template when creating a new wave. It appends wave definitions to an existing ROADMAP or creates the initial document from the phase-appropriate section of this template.

---

## Phase Requirements

### Spike -- Not Required

**Required sections:** None.

**Content guidance:**

- Roadmaps are not required during Spike — the project is still validating whether it should exist
- If a ROADMAP is created during Spike, it will be minimal and likely rewritten at Vertical Slice

**Mermaid diagrams:** None required.

---

### Proof of Concept -- Not Required

**Required sections:** None.

**Content guidance:**

- Roadmaps are not required during PoC — the project is validating its core assumption
- If a ROADMAP is created during PoC, it will be minimal and likely rewritten at Vertical Slice

**Mermaid diagrams:** None required.

---

### Vertical Slice -- Stub

**Required sections:**

- **Roadmap Overview:** 1-2 sentences describing the product's delivery approach and how waves are organized
- **Current Wave:** The active delivery cycle with: wave name, goal (1 sentence), 3-5 selected ideas (linked to BACKLOG sections), target timeframe, and status (planned | active)
- **Next Wave Preview:** Brief description of the next planned wave — theme, tentative ideas, and open questions

**Content guidance:**

- The Vertical Slice roadmap is a sketch — expect it to evolve significantly at Foundation
- Current wave should include only spec-ready ideas from BACKLOG.md
- Target timeframes can be approximate ("Q2 2026" or "next 2-3 weeks")
- Link to BACKLOG.md sections using markdown anchors (e.g., `[Idea Title](docs/BACKLOG.md#idea-title)`)

**Mermaid diagrams:**

- **Wave dependency graph** (flowchart): Shows the current wave's ideas and any dependencies between them. Apply Liatrio brand colors via `%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#11B5A4', 'primaryTextColor': '#FFFFFF', 'primaryBorderColor': '#0D8F82', 'secondaryColor': '#E8662F', 'secondaryTextColor': '#FFFFFF', 'secondaryBorderColor': '#C7502A', 'tertiaryColor': '#1B2A3D', 'tertiaryTextColor': '#FFFFFF', 'lineColor': '#1B2A3D', 'fontFamily': 'Inter, sans-serif'}}}%%`

**Liatrio branding:** Applicable to mermaid diagrams in generated output. Use the theme configuration above for flowchart or other diagram types.

---

### Foundation -- Draft

**Required sections:**

- **Roadmap Overview:** Refined from Vertical Slice with delivery philosophy and wave cadence
- **Wave Summary Table:** Table listing all planned waves with columns: Wave Name, Goal, Status, Target Timeframe, Idea Count

**For each wave (at least 3 planned):**

- **Wave Name and Theme:** Descriptive name and one-sentence theme
- **Wave Goal:** What this wave delivers and why it matters, with cross-reference to VISION.md
- **Selected Ideas:** List of spec-ready ideas from BACKLOG.md with title, priority, and link
- **Target Timeframe:** Specific timeframe (month or quarter)
- **Dependencies:** Prerequisites from other waves, external systems, or team availability
- **Status:** One of: planned | active (completed waves are archived to `docs/skill/arc/waves/` and removed from ROADMAP)

Additionally:

- **Milestone Tracker:** Key milestones across all waves with target dates or phase alignment

**Content guidance:**

- At least 3 waves should be planned — the current wave, the next wave, and one future wave
- Each wave should have a coherent theme (e.g., "Core Capture Flow", "Shaping Pipeline", "Wave Management")
- Dependencies between waves should be explicit — do not assume sequential execution
- Milestone tracker provides a high-level view for stakeholders who do not need wave-level detail
- Reference CUSTOMER.md to ensure waves address real persona needs

**Mermaid diagrams:**

- **Wave dependency graph** (flowchart): Shows all planned waves and dependencies between them. Apply Liatrio brand colors.
- **Milestone timeline** (gantt): Shows key milestones plotted against waves and target timeframes. Apply Liatrio brand colors via `%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#11B5A4', 'primaryTextColor': '#FFFFFF', 'primaryBorderColor': '#0D8F82', 'secondaryColor': '#E8662F', 'secondaryTextColor': '#FFFFFF', 'secondaryBorderColor': '#C7502A', 'tertiaryColor': '#1B2A3D', 'tertiaryTextColor': '#FFFFFF', 'lineColor': '#1B2A3D', 'fontFamily': 'Inter, sans-serif'}}}%%`

**Liatrio branding:** Applicable to all mermaid diagrams. Use the theme configuration specified above.

---

### MVP -- Full

**Required sections:**

All Foundation sections, maintained and current. Additionally:

- **PO and Architect Rationale:** For each wave, a brief note from the product owner and/or architect explaining why these ideas were grouped and prioritized in this order
- **Completed Wave Retrospectives:** Completed waves are archived to `docs/skill/arc/waves/NN-wave-name.md` and removed from ROADMAP. Retrospectives for completed waves should be recorded in or referenced from the wave archive file. See `references/wave-archive.md` for the archive schema.
- **Risk and Contingency:** Identified risks to the roadmap (team availability, technical unknowns, dependency delays) with contingency plans

**Content guidance:**

- PO rationale helps future contributors understand the reasoning behind wave composition
- Retrospectives live in the wave archive (`docs/skill/arc/waves/`) — "we deferred X because Y" is more valuable than "everything went as planned"
- Risk and contingency plans should be specific and actionable
- Update the wave dependency graph and milestone timeline to reflect actual progress

**Mermaid diagrams:** Same as Foundation, updated to reflect actual progress.

---

### Growth -- Full (Maintained)

**Required sections:**

All MVP sections, maintained and current. Additionally:

- **Scaling Considerations:** How the roadmap approach adapts as the product grows — more concurrent waves, longer planning horizons, cross-team coordination
- **Long-Term Vision Alignment:** How current and planned waves connect to the long-term product vision from VISION.md

**Content guidance:**

- Scaling considerations help teams anticipate roadmap process changes as complexity increases
- Long-term alignment prevents wave planning from drifting away from the product vision
- Review completed wave retrospectives in the wave archive for patterns — are estimates consistently off? Are dependencies causing delays?
- The decision log in DECISIONS.md should capture significant roadmap changes

**Mermaid diagrams:** Same as Foundation, updated to reflect current state.

---

### Maturity -- Full (Maintained)

**Required sections:**

All Growth sections, maintained and current. Additionally:

- **Roadmap Retrospective:** How well the roadmap served the product over its lifecycle. What delivery patterns worked, what did not, and what was learned about product planning.
- **Estimation Retrospective:** Analysis of how accurate wave estimates were over time, with lessons for future planning

**Content guidance:**

- The Maturity roadmap is a historical document as much as an active one
- Roadmap retrospective informs organizational planning processes
- Estimation retrospective provides data for improving future wave sizing
- Updates are infrequent but should reflect current organizational reality

**Mermaid diagrams:** Same as Foundation, updated to reflect final state.

---

## Cross-References

- **VISION.md:** Product vision that the roadmap implements (always-required)
- **CUSTOMER.md:** Personas whose needs drive wave composition (always-required)
- **BACKLOG.md:** Individual ideas selected into waves (product-leadership)
- **PROJECT_CHARTER.md:** Project milestones and timeline (temper: always-required)
- **DECISIONS.md:** Records roadmap changes and wave planning decisions (temper: always-required)
- **Wave planning:** `references/wave-planning.md` defines wave organization principles and Temper phase compatibility
- **Wave archive:** `references/wave-archive.md` defines the archive schema for completed waves stored at `docs/skill/arc/waves/`
- **Management report:** `docs/management-report.md` (when present) provides Temper phase and gate results that constrain wave scope
