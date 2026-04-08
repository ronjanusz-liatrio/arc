---
role: always-required
artifact: VISION
output_path: docs/VISION.md
---

# VISION Template

This template defines the VISION artifact across all 7 maturity phases. The vision document captures the product's strategic direction, target audience, value proposition, and north star metrics. It serves as the anchor for all product decisions — every idea in the BACKLOG and every wave in the ROADMAP should trace back to a vision statement.

The skill reads this template, identifies the section matching the project's current phase, and generates a VISION document populated with project-specific context.

---

## Phase Requirements

### Spike -- Stub

**Required sections:**

- **Vision Summary:** One paragraph (3-5 sentences) describing what the product is and why it exists. This is the minimal "what and why" anchor for all product decisions.

**Content guidance:**

- Keep it brief — the Spike is exploratory, not a commitment
- Center on the problem space and who is affected, not the solution architecture
- This section is carried forward and refined in all subsequent phases

**Mermaid diagrams:** None required.

---

### Proof of Concept -- Draft

**Required sections:**

- **Vision Summary:** Refined from Spike if the understanding evolved
- **Problem Statement:** 2-3 sentences describing the specific problem the product addresses, who experiences it, and the impact of leaving it unsolved
- **Target Audience:** Brief description of the primary users or beneficiaries (1-2 sentences — detailed personas belong in CUSTOMER.md)
- **Value Proposition:** One sentence articulating the unique value the product provides to its target audience

**Content guidance:**

- The problem statement should be falsifiable — a reader should be able to argue whether the problem is real
- Target audience should be specific enough to exclude people who are not the audience
- Value proposition should complete the sentence: "Unlike [alternative], our product [differentiator]"
- Reference CUSTOMER.md for detailed persona work

**Mermaid diagrams:** None required.

---

### Vertical Slice -- Draft (Stable)

**Required sections:**

- **Vision Summary:** Refined from PoC
- **Problem Statement:** Refined from PoC
- **Target Audience:** Refined from PoC
- **Value Proposition:** Refined from PoC
- **Scope Boundaries:** Explicit list of what the product will and will not do, organized as "In Scope" and "Out of Scope" bullet lists

**Content guidance:**

- Scope boundaries prevent vision creep — be specific about what is intentionally excluded
- Out of scope items should include rationale (e.g., "Multi-repo support — single repo is sufficient for target audience")
- This is the last phase where major vision pivots are expected — Foundation locks the vision

**Mermaid diagrams:** None required.

---

### Foundation -- Full

**Required sections:**

- **Vision Summary:** Finalized
- **Problem Statement:** Finalized
- **Target Audience:** Finalized with cross-reference to CUSTOMER.md personas
- **Value Proposition:** Finalized
- **Scope Boundaries:** Approved scope with clear boundaries (changes require DECISIONS.md entry)
- **Success Criteria:** At least 3 measurable outcomes with targets and measurement methods that define whether the vision is being achieved
- **Strategic Alignment:** How this product fits into the broader organizational strategy, ecosystem, or product portfolio

**Content guidance:**

- The Foundation vision is the approved product contract — changes require stakeholder sign-off and a DECISIONS.md entry
- Success criteria should be measurable and time-bound (e.g., "80% of captured ideas reach spec-ready within 2 waves")
- Strategic alignment connects the product vision to organizational goals
- Reference ROADMAP.md for how the vision translates to delivery waves

**Mermaid diagrams:**

- **Vision-to-strategy diagram** (flowchart): Shows how the product vision connects to organizational strategy, target audience, and delivery roadmap. Apply Liatrio brand colors via `%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#11B5A4', 'primaryTextColor': '#FFFFFF', 'primaryBorderColor': '#0D8F82', 'secondaryColor': '#E8662F', 'secondaryTextColor': '#FFFFFF', 'secondaryBorderColor': '#C7502A', 'tertiaryColor': '#1B2A3D', 'tertiaryTextColor': '#FFFFFF', 'lineColor': '#1B2A3D', 'fontFamily': 'Inter, sans-serif'}}}%%`

**Liatrio branding:** Applicable to mermaid diagrams in generated output. Use the theme configuration above for flowchart or other diagram types.

---

### MVP -- Full (Maintained)

**Required sections:**

All Foundation sections, maintained and current. Additionally:

- **Current State Summary:** What has been delivered against the original vision, with references to completed waves in ROADMAP.md

**Content guidance:**

- Review and update success criteria based on actual progress and feedback
- Current state summary provides a snapshot for stakeholders — keep it factual and concise
- If the vision shifted since Foundation, ensure DECISIONS.md records why
- Reference BACKLOG.md for ideas still in pipeline

**Mermaid diagrams:** Same as Foundation, updated to reflect actual progress.

---

### Growth -- Full (Maintained)

**Required sections:**

All MVP sections, maintained and current. Additionally:

- **Evolution Trajectory:** How the product vision has evolved since inception, with rationale for each significant shift and a forward-looking statement of where the product is headed

**Content guidance:**

- Evolution trajectory provides history for new team members and stakeholders
- Update target audience as the user base grows or segments emerge
- Review scope boundaries — some exclusions may now be warranted for inclusion
- Reference CUSTOMER.md for updated persona and adoption data

**Mermaid diagrams:** Same as Foundation, updated to reflect current state.

---

### Maturity -- Full (Maintained)

**Required sections:**

All Growth sections, maintained and current. Additionally:

- **Vision Retrospective:** How well the product achieved its original vision. What was delivered, what was descoped, and what was learned about product direction.

**Content guidance:**

- The Maturity vision is a historical document as much as an active one
- Vision retrospective informs future product planning and organizational strategy
- Updates are infrequent but should reflect current organizational reality
- Consider whether the product needs a vision refresh or has reached its steady state

**Mermaid diagrams:** Same as Foundation, updated to reflect final state.

---

## Cross-References

- **CUSTOMER.md:** Detailed personas and JTBD statements (always-required)
- **ROADMAP.md:** Translates vision into phased delivery waves (product-leadership)
- **BACKLOG.md:** Individual ideas that implement the vision (product-leadership)
- **PROJECT_CHARTER.md:** Project scope, stakeholders, and constraints (temper: always-required)
- **DECISIONS.md:** Records vision changes and product direction decisions (temper: always-required)
- **Idea lifecycle:** `references/idea-lifecycle.md` defines idea progression from Capture to Shipped
