---
role: always-required
artifact: CUSTOMER
output_path: docs/CUSTOMER.md
---

# CUSTOMER Template

This template defines the CUSTOMER artifact across all 7 maturity phases. The customer document captures persona definitions, jobs-to-be-done (JTBD) statements, and success metrics for the product's target users. It ensures that every idea shaped in the BACKLOG and every wave planned in the ROADMAP is grounded in real customer needs.

The `/arc-shape` skill reads CUSTOMER.md during the "customer fit" analysis dimension to validate whether a captured idea aligns with defined personas and serves an identified JTBD.

---

## Phase Requirements

### Spike -- Notes

**Required sections:**

- **Initial Audience Notes:** 2-4 sentences describing who might use this product and why. Informal observations — detailed persona work comes later.

**Content guidance:**

- Keep it conversational — "We think developers at mid-size companies would use this because..."
- Name specific roles or job titles, not abstract categories
- It is acceptable to be uncertain — "we believe" and "we suspect" are valid
- This section seeds the persona work in later phases

**Mermaid diagrams:** None required.

---

### Proof of Concept -- Draft

**Required sections:**

- **Primary Persona:** A named persona with role, context, and 2-3 key characteristics that define their relationship to the product
- **Needs and Pain Points:** 3-5 bullet points describing what the primary persona struggles with today and what they need from this product
- **Jobs-To-Be-Done:** At least 1 JTBD statement in the format: "When [situation], I want to [motivation], so I can [expected outcome]"

**Content guidance:**

- The primary persona should be the single most important user — the person whose satisfaction determines product success
- Needs should be expressed from the persona's perspective, not the builder's
- JTBD statements should describe the outcome the persona wants, not the feature they use
- Reference VISION.md to ensure the persona aligns with the stated target audience

**Example JTBD:**

```
When I have a raw product idea while reviewing a pull request,
I want to capture it in under 30 seconds without leaving the terminal,
so I can return to my review without losing the thought.
```

**Mermaid diagrams:** None required.

---

### Vertical Slice -- Draft (Validated)

**Required sections:**

- **Primary Persona:** Refined from PoC with validation notes (e.g., "confirmed via user interviews" or "validated by team discussion")
- **Secondary Personas:** 1-2 additional personas who interact with the product in different capacities (e.g., a tech lead vs. a product owner vs. a developer)
- **Needs and Pain Points:** Expanded to cover all defined personas
- **Jobs-To-Be-Done:** At least 2 JTBD statements covering different personas or usage contexts
- **Interaction Model:** How each persona interacts with the product — frequency, primary touchpoints, and expected workflow

**Content guidance:**

- Secondary personas help identify edge cases and prioritization conflicts
- Interaction model should describe the persona's natural workflow, not the product's feature set
- Validate personas against real usage if possible — even informal feedback counts
- JTBD statements should be distinct, not variations of the same job

**Mermaid diagrams:** None required.

---

### Foundation -- Full

**Required sections:**

- **All Personas:** Finalized primary and secondary personas with complete profiles: name, role, context, characteristics, goals, frustrations
- **Needs and Pain Points:** Comprehensive list organized by persona
- **Jobs-To-Be-Done Catalog:** At least 3 JTBD statements per primary persona, at least 1 per secondary persona. Each statement follows the standard format.
- **Success Metrics:** Measurable indicators of customer satisfaction or adoption, with targets (e.g., "Primary persona completes idea capture in under 30 seconds")
- **Persona-to-Artifact Map:** Table mapping each persona to the product artifacts and skills they interact with most

**Content guidance:**

- The Foundation customer document is the approved persona contract — changes require a DECISIONS.md entry
- Success metrics should be observable and tied to persona goals, not vanity metrics
- The persona-to-artifact map helps skills like `/arc-shape` quickly identify which persona an idea serves
- Cross-reference VISION.md success criteria to ensure alignment

**Mermaid diagrams:**

- **Persona interaction map** (flowchart): Shows how each persona interacts with product skills and artifacts. Apply Liatrio brand colors via `%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#11B5A4', 'primaryTextColor': '#FFFFFF', 'primaryBorderColor': '#0D8F82', 'secondaryColor': '#E8662F', 'secondaryTextColor': '#FFFFFF', 'secondaryBorderColor': '#C7502A', 'tertiaryColor': '#1B2A3D', 'tertiaryTextColor': '#FFFFFF', 'lineColor': '#1B2A3D', 'fontFamily': 'Inter, sans-serif'}}}%%`

**Liatrio branding:** Applicable to mermaid diagrams in generated output. Use the theme configuration above for flowchart or other diagram types.

---

### MVP -- Full (Maintained)

**Required sections:**

All Foundation sections, maintained and current. Additionally:

- **Adoption Status:** Summary of which personas are actively using the product, with qualitative or quantitative evidence

**Content guidance:**

- Review personas against actual usage — are the right people using the product?
- Update JTBD statements if real usage revealed jobs that were not anticipated
- If a persona is not adopting, document why and whether the persona definition needs revision
- Reference BACKLOG.md for ideas that address unmet persona needs

**Mermaid diagrams:** Same as Foundation, updated to reflect actual adoption.

---

### Growth -- Full (Maintained)

**Required sections:**

All MVP sections, maintained and current. Additionally:

- **Segmentation:** How the customer base has segmented beyond initial personas — new usage patterns, new persona candidates, or sub-segments within existing personas
- **Expansion Opportunities:** Identified opportunities to serve adjacent personas or new JTBD based on adoption data

**Content guidance:**

- Segmentation may reveal that the primary persona has distinct sub-groups with different needs
- Expansion opportunities feed into BACKLOG.md as new captured ideas
- Update the persona-to-artifact map as new skills or artifacts are added
- Growth phase personas should be validated by usage data, not assumptions

**Mermaid diagrams:** Same as Foundation, updated to reflect current state.

---

### Maturity -- Full (Maintained)

**Required sections:**

All Growth sections, maintained and current. Additionally:

- **Customer Retrospective:** How well the product served its defined personas. Which JTBD were fully addressed, which remain open, and what was learned about customer understanding.

**Content guidance:**

- The Maturity customer document is a historical record as much as an active one
- Customer retrospective informs future product planning and persona work
- Consider whether new personas have emerged that warrant a product refresh
- Updates are infrequent but should reflect current user reality

**Mermaid diagrams:** Same as Foundation, updated to reflect final state.

---

## Cross-References

- **VISION.md:** Product vision and target audience (always-required)
- **ROADMAP.md:** Delivery waves that address persona needs (product-leadership)
- **BACKLOG.md:** Individual ideas linked to persona JTBD (product-leadership)
- **PROJECT_CHARTER.md:** Project stakeholders overlap with but are distinct from customer personas (temper: always-required)
- **DECISIONS.md:** Records persona changes and customer strategy decisions (temper: always-required)
- **Brief format:** `references/brief-format.md` defines the spec-ready brief structure that references customer fit
