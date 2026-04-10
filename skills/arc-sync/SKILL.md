---
name: arc-sync
description: "README lifecycle management — scaffold or update README.md with Arc-managed sections synced to product direction artifacts"
user-invocable: true
allowed-tools: Glob, Grep, Read, Write, Edit, AskUserQuestion
---

# /arc-sync — README Lifecycle Management

## Context Marker

Always begin your response with: **ARC-README**

## Overview

You keep `README.md` in sync with Arc product-direction artifacts (VISION.md, CUSTOMER.md, BACKLOG.md, ROADMAP.md). The skill operates in two modes:

- **Scaffold mode** — generates a full README from scratch for projects that don't have one, establishing `ARC:` managed section markers for future updates
- **Update mode** — selectively refreshes `ARC:` managed sections in an existing README, syncing features, roadmap, audience, and diagrams with current artifact state

Managed sections use the marker format `<!--# BEGIN ARC:{section-name} -->` / `<!--# END ARC:{section-name} -->`. Content outside managed sections is never touched.

## Critical Constraints

- **NEVER** modify content outside `ARC:` managed sections in an existing README
- **NEVER** modify `TEMPER:` or `MM:` managed sections
- **NEVER** expose internal priority metadata (P0/P1/P2/P3) in the README
- **NEVER** write to README.md without user approval via AskUserQuestion
- **NEVER** run without a substantive VISION.md (>200 non-whitespace characters)
- **ALWAYS** begin your response with `**ARC-README**`
- **ALWAYS** run trust-signal validation against the output before presenting for approval
- **ALWAYS** guarantee all evaluable trust signals pass on scaffold output
- **ALWAYS** use "Not yet defined" placeholders only when the source artifact is absent

## Process

### Step 1: Read Context

Read the following files (graceful no-op if absent, except VISION.md):

1. `docs/VISION.md` — **Required.** Extract Vision Summary, Problem Statement, and value proposition.
2. `docs/CUSTOMER.md` — Persona names and roles for the audience section.
3. `docs/BACKLOG.md` — Shipped items for features, status counts for the lifecycle diagram.
4. `docs/ROADMAP.md` — Wave names, themes, and status for the roadmap section.

Read `skills/arc-sync/references/trust-signals.md` for the trust-signal framework definitions.
Read `skills/arc-sync/references/readme-mapping.md` for the artifact-to-section mapping rules.
Read `skills/arc-sync/references/readme-quality-rules.md` for quality gates.

**VISION.md gate check:**

Count non-whitespace characters in `docs/VISION.md`:
- If the file does not exist, warn and exit: "Run `/arc-capture` or create VISION.md first."
- If the file has fewer than 200 non-whitespace characters, warn and exit: "VISION.md has insufficient content ({count} non-whitespace characters, minimum 200). Add a Problem Statement and Vision Summary before running `/arc-sync`."

### Step 2: Detect Mode

Determine the operating mode based on README.md state:

| Condition | Mode |
|-----------|------|
| No `README.md` at project root | **Scaffold** — proceed to Step 3 |
| `README.md` exists with `<!--# BEGIN ARC:` markers | **Update** — proceed to Step 7 |
| `README.md` exists without `ARC:` markers | **Injection** — offer to inject managed sections |

**If scaffold mode:** Proceed to Step 3.

**If update mode:** Proceed to Step 7.

**If injection mode:** Ask the user whether they want to inject `ARC:` managed sections into their existing README:

```
AskUserQuestion({
  questions: [{
    question: "Your README.md exists but has no ARC: managed sections. Would you like to inject them?",
    header: "README Mode",
    options: [
      { label: "Inject sections", description: "Add ARC: managed sections to your existing README — existing content is preserved" },
      { label: "Cancel", description: "Leave README.md unchanged" }
    ],
    multiSelect: false
  }]
})
```

If the user selects "Cancel," exit gracefully. If "Inject sections," proceed to Step 2a.

### Step 2a: Inject Markers into Existing README

When the user approves marker injection, determine where to place each `ARC:` managed section block in the existing README.md. The goal is to add managed sections without disrupting existing content.

#### Insertion Priority

For each `ARC:` section to be injected, find the insertion point using this priority order:

1. **After the last existing `ARC:` section end marker** — If any `<!--# END ARC:... -->` markers already exist (e.g., from a partial injection), insert the new section after the last one with one blank line separator.
2. **Before Contributing or License sections** — If a `## Contributing` or `## License` heading exists, insert before the first of these with one blank line separator.
3. **At EOF** — Append to the end of the file with one blank line separator.

#### Section Ordering

When injecting all sections at once, maintain this order relative to each other:

1. `ARC:overview`
2. `ARC:audience`
3. `ARC:features`
4. `ARC:roadmap`
5. `ARC:lifecycle-diagram`

#### Injection Procedure

1. Read the existing `README.md` and identify the insertion point using the priority order above.
2. For each `ARC:` section to be injected:
   a. Generate the section content using the same extraction rules as scaffold mode (Steps 3a-3f).
   b. Wrap the content in `<!--# BEGIN ARC:{section-name} -->` / `<!--# END ARC:{section-name} -->` markers.
3. Confirm the injection plan via AskUserQuestion before writing:

```
AskUserQuestion({
  questions: [{
    question: "The following ARC: managed sections will be injected into your README.md:\n\n{list of sections with insertion positions}\n\nExisting content will not be modified. Proceed?",
    header: "Confirm Marker Injection",
    options: [
      { label: "Inject", description: "Add the listed ARC: managed sections" },
      { label: "Cancel", description: "Leave README.md unchanged" }
    ],
    multiSelect: false
  }]
})
```

4. If "Inject," write the markers using the Edit tool, inserting at the determined position.
5. If "Cancel," exit gracefully.

#### Post-Injection Validation

After injection, verify:
- No `ARC:` section is nested inside another `ARC:`, `TEMPER:`, or `MM:` section.
- All marker pairs are properly matched (every BEGIN has a corresponding END).
- Content outside the injected markers is identical to the original file.

After successful injection, proceed to Step 4 (Trust-Signal Validation) to validate the injected content.

### Step 3: Scaffold README

Generate a complete README.md with managed and non-managed sections. Follow the structure below exactly.

Read `skills/arc-sync/references/readme-mapping.md` for the artifact-to-section extraction rules. Apply the quality gates from `skills/arc-sync/references/readme-quality-rules.md` throughout.

#### 3a. Title and Description

Extract from `docs/VISION.md`:
- **Title:** Use the project name from the VISION.md `# {Project Name}` heading, or the first sentence of the Vision Summary section.
- **One-line description:** Use the first sentence of the Vision Summary.

Output format:
```markdown
# {Project Name}

{One-line description from Vision Summary}
```

#### 3b. ARC:overview Section

Extract from `docs/VISION.md`:
- Read the Problem Statement section (content under `## Problem Statement` or `## Problem`)
- Read the Value Proposition section (content under `## Value Proposition` or `## Value Prop`)
- Combine into a concise overview (2-5 sentences)

Include a traceability link to satisfy TS-7.

Output format:
```markdown
## Overview

<!--# BEGIN ARC:overview -->

{Problem statement and value proposition — 2-5 sentences derived from VISION.md}

See [VISION.md](docs/VISION.md) for full product direction.

<!--# END ARC:overview -->
```

**Constraint:** Content must include at least one sentence from the VISION.md Problem Statement verbatim (case-insensitive match) to satisfy TS-1.

#### 3c. ARC:audience Section

Extract from `docs/CUSTOMER.md` (if present):
- Read all `## {Persona Name}` headings and their role/description
- List each persona with their role

If `docs/CUSTOMER.md` is absent:
- Use placeholder text: "Not yet defined — create [CUSTOMER.md](docs/CUSTOMER.md) to define target personas."

Output format (with CUSTOMER.md):
```markdown
## Who This Is For

<!--# BEGIN ARC:audience -->

{Persona list derived from CUSTOMER.md — one line per persona with name and role}

See [CUSTOMER.md](docs/CUSTOMER.md) for detailed personas.

<!--# END ARC:audience -->
```

Output format (without CUSTOMER.md):
```markdown
## Who This Is For

<!--# BEGIN ARC:audience -->

Not yet defined — create [CUSTOMER.md](docs/CUSTOMER.md) to define target personas.

<!--# END ARC:audience -->
```

**Constraint:** When CUSTOMER.md exists, at least one persona name from a `##` heading must appear in the section content to satisfy TS-2.

#### 3d. ARC:features Section

Extract from `docs/BACKLOG.md` (if present):
- Find all idea entries with `Status: shipped`
- Extract each shipped idea's `## {Title}` heading
- List as bullet points (title only — no priority metadata)

If `docs/BACKLOG.md` is absent or has no shipped items:
- Use: "No features shipped yet."

Output format (with shipped items):
```markdown
## Features

<!--# BEGIN ARC:features -->

{Bullet list of shipped idea titles from BACKLOG.md}

<!--# END ARC:features -->
```

Output format (no shipped items):
```markdown
## Features

<!--# BEGIN ARC:features -->

No features shipped yet.

<!--# END ARC:features -->
```

**Constraint:** When shipped items exist, each bullet must contain the shipped idea title as a substring (case-insensitive) to satisfy TS-3 and TS-6.

#### 3e. ARC:roadmap Section

Extract from `docs/ROADMAP.md` (if present):
- Read all wave section headings (`## {Wave Name}` or `### {Wave Name}`)
- Extract wave name, theme, and status (active/planned/completed)
- Present as a table

If `docs/ROADMAP.md` is absent:
- Use placeholder text: "Not yet defined — create [ROADMAP.md](docs/ROADMAP.md) to plan delivery waves."

Output format (with ROADMAP.md):
```markdown
## Roadmap

<!--# BEGIN ARC:roadmap -->

| Wave | Theme | Status |
|------|-------|--------|
| {Wave Name} | {Theme} | {Status} |

See [ROADMAP.md](docs/ROADMAP.md) for the full delivery plan.

<!--# END ARC:roadmap -->
```

Output format (without ROADMAP.md):
```markdown
## Roadmap

<!--# BEGIN ARC:roadmap -->

Not yet defined — create [ROADMAP.md](docs/ROADMAP.md) to plan delivery waves.

<!--# END ARC:roadmap -->
```

**Constraint:** When ROADMAP.md exists, at least one wave name from a `##` or `###` heading must appear in the section to satisfy TS-4.

#### 3f. ARC:lifecycle-diagram Section

Generate a mermaid state diagram showing the idea lifecycle with live status counts from `docs/BACKLOG.md`.

**Status counting:**
1. Read `docs/BACKLOG.md` and count ideas by status:
   - `captured` — ideas with `Status: captured`
   - `shaped` — ideas with `Status: shaped`
   - `spec-ready` — ideas with `Status: spec-ready`
   - `shipped` — ideas with `Status: shipped`
2. If `docs/BACKLOG.md` is absent, use 0 for all counts.

**Mermaid diagram format:**

Use Liatrio brand colors and the same theme initialization as `references/idea-lifecycle.md`:

```markdown
## Idea Lifecycle

<!--# BEGIN ARC:lifecycle-diagram -->

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#11B5A4', 'primaryTextColor': '#FFFFFF', 'primaryBorderColor': '#0D8F82', 'secondaryColor': '#E8662F', 'secondaryTextColor': '#FFFFFF', 'secondaryBorderColor': '#C7502A', 'tertiaryColor': '#1B2A3D', 'tertiaryTextColor': '#FFFFFF', 'lineColor': '#1B2A3D', 'fontFamily': 'Inter, sans-serif'}}}%%
stateDiagram-v2
    direction LR

    state "Captured({captured_count})" as captured
    state "Shaped({shaped_count})" as shaped
    state "Spec-Ready({spec_ready_count})" as specready
    state "Shipped({shipped_count})" as shipped

    [*] --> captured
    captured --> shaped
    shaped --> specready
    specready --> shipped

    classDef capture fill:#1B2A3D,stroke:#0F1D2B,color:#FFFFFF
    classDef shape fill:#E8662F,stroke:#C7502A,color:#FFFFFF
    classDef ready fill:#11B5A4,stroke:#0D8F82,color:#FFFFFF
    classDef shipped fill:#0D8F82,stroke:#0A6B63,color:#FFFFFF

    class captured capture
    class shaped shape
    class specready ready
    class shipped shipped
```

<!--# END ARC:lifecycle-diagram -->
```

Replace `{captured_count}`, `{shaped_count}`, `{spec_ready_count}`, and `{shipped_count}` with actual counts from BACKLOG.md.

**Constraint:** At least one status count must be non-zero to satisfy TS-5. If BACKLOG.md is absent (all counts zero), the diagram is still generated but TS-5 will be marked N/A.

#### 3g. Non-Managed Sections

Generate static placeholder sections for the user to fill in. These are NOT managed by Arc and will not be modified by update mode.

```markdown
## Getting Started

> Replace this section with installation and setup instructions for your project.

## Contributing

> Replace this section with contribution guidelines for your project.

## License

> Replace this section with your project's license information.
```

### Step 4: Trust-Signal Validation

Run TS-1 through TS-8 against the scaffolded README content (in memory, before writing to disk). Follow the detection steps defined in `skills/arc-sync/references/trust-signals.md`.

**Validation procedure:**

For each trust signal, determine evaluability first:

| Signal | Evaluable When |
|--------|---------------|
| TS-1: Overview | `docs/VISION.md` exists AND `ARC:overview` section exists |
| TS-2: Audience | `docs/CUSTOMER.md` exists AND `ARC:audience` section exists |
| TS-3: Features | `docs/BACKLOG.md` exists with shipped items AND `ARC:features` section exists |
| TS-4: Roadmap | `docs/ROADMAP.md` exists AND `ARC:roadmap` section exists |
| TS-5: Lifecycle Diagram | `docs/BACKLOG.md` exists AND `ARC:lifecycle-diagram` section exists |
| TS-6: Currency | `docs/BACKLOG.md` exists with shipped items AND `ARC:features` section exists |
| TS-7: Traceability | Any `docs/` file exists AND any `ARC:` section exists |
| TS-8: No Placeholders | Any `ARC:` section exists (per-section check against source artifact) |

For each evaluable signal, run the detection steps from `trust-signals.md` and record PASS or FAIL with detail.

For non-evaluable signals, record N/A.

**Build the scorecard:**

```markdown
**Trust-Signal Scorecard**

| Signal | Name | Status | Detail |
|--------|------|--------|--------|
| TS-1 | Overview | PASS / FAIL / N/A | {detail} |
| TS-2 | Audience | PASS / FAIL / N/A | {detail} |
| TS-3 | Features | PASS / FAIL / N/A | {detail} |
| TS-4 | Roadmap | PASS / FAIL / N/A | {detail} |
| TS-5 | Lifecycle Diagram | PASS / FAIL / N/A | {detail} |
| TS-6 | Currency | PASS / FAIL / N/A | {detail} |
| TS-7 | Traceability | PASS / FAIL / N/A | {detail} |
| TS-8 | No Placeholders | PASS / FAIL / N/A | {detail} |

**Result:** {N} of {M} evaluable signals passing
**Severity:** info | warning
```

**Scaffold guarantee:** All evaluable signals MUST pass on scaffold output. If any evaluable signal fails, fix the scaffolded content before proceeding. Do not present a failing scaffold to the user.

### Step 5: Present for Approval

Present the scaffolded README and trust-signal scorecard to the user for review.

```
AskUserQuestion({
  questions: [{
    question: "Here is the scaffolded README.md. Review the content and trust-signal scorecard below, then approve or request changes.\n\n{scaffolded_readme_content}\n\n{trust_signal_scorecard}",
    header: "README Scaffold",
    options: [
      { label: "Approve", description: "Write the scaffolded README to disk" },
      { label: "Request changes", description: "Describe what you'd like modified" }
    ],
    multiSelect: false
  }]
})
```

**If "Approve":** Proceed to Step 6.

**If "Request changes":** Ask the user what to change, apply modifications, re-run trust-signal validation (Step 4), and re-present (Step 5). Repeat until approved or the user cancels.

### Step 6: Write to Disk

Write the approved README.md to the project root:

1. Write the scaffolded content to `README.md` using the Write tool.
2. Confirm the write by reading back the file and verifying the `ARC:` markers are present.
3. Report a summary:

```
README.md scaffolded successfully.

Managed sections: {count} ARC: sections created
Total lines: {line_count}
Trust signals: {N}/{M} evaluable passing

Run /arc-sync again after shipping features or planning waves to update managed sections.
```

### Step 7: Capture Before-State

This step begins the **update mode** flow (entered from Step 2 when README.md contains `ARC:` markers).

1. Read `README.md` and identify all `<!--# BEGIN ARC:{section-name} -->` / `<!--# END ARC:{section-name} -->` marker pairs.
2. For each marker pair, extract and store the current content between markers as the **before-state**.
3. Record:
   - Which `ARC:` sections exist (e.g., `overview`, `audience`, `features`, `roadmap`, `lifecycle-diagram`)
   - Line count of each managed section
   - Total README line count
4. Verify no nesting conflicts: no `ARC:` section is nested inside another `ARC:`, `TEMPER:`, or `MM:` section.

**If nesting conflict detected:** Warn the user and exit: "Nesting conflict detected — {section} is inside {parent}. Fix the marker structure manually before running `/arc-sync`."

### Step 8: Rebuild Managed Sections

For each `ARC:` managed section found in Step 7, regenerate its content using the extraction rules from `skills/arc-sync/references/readme-mapping.md`. Apply the quality gates from `skills/arc-sync/references/readme-quality-rules.md` throughout.

**For each section, rebuild content as follows:**

#### 8a. ARC:overview

Re-extract from `docs/VISION.md`:

1. Extract content under `## Problem Statement` (or `## Problem`) — first paragraph
2. Extract content under `## Value Proposition` (or `## Value Prop`) — second paragraph
3. If `## Value Proposition` is absent, use `## Vision Summary` as the sole paragraph
4. Include traceability link: `See [VISION.md](docs/VISION.md) for full product direction.`

**Constraint:** Content must include at least one sentence from the VISION.md Problem Statement verbatim (case-insensitive match) to satisfy TS-1.

#### 8b. ARC:audience

Re-extract from `docs/CUSTOMER.md`:

1. If `docs/CUSTOMER.md` exists:
   - Collect all `## {Persona Name}` headings and their role/description
   - For each persona, extract the first JTBD statement or first sentence
   - Format as persona summaries with traceability link
2. If `docs/CUSTOMER.md` is absent:
   - Use: `Not yet defined — create [CUSTOMER.md](docs/CUSTOMER.md) to define target personas.`

**Constraint:** When CUSTOMER.md exists, at least one persona name from a `##` heading must appear in the section content to satisfy TS-2.

#### 8c. ARC:features

Rebuild from `docs/BACKLOG.md`:

1. Find all idea entries with `Status: shipped` (pattern: `**Status:** shipped` or `Status: shipped`, case-insensitive)
2. Extract each shipped idea's `## {Title}` heading and one-line summary
3. Format as bullet list: `- **{Title}** — {one-line summary}`
4. Include traceability link: `See [BACKLOG.md](docs/BACKLOG.md) for the full product backlog.`
5. If no shipped items exist: `No features shipped yet.`

**Constraint:** Each bullet must contain the shipped idea title as bold text (satisfies TS-3 and TS-6). The bullet count must match the shipped idea count in BACKLOG.md.

#### 8d. ARC:roadmap

Rebuild from `docs/ROADMAP.md`:

1. If `docs/ROADMAP.md` exists:
   - Collect all wave section headings (`## {Wave Name}` or `### {Wave Name}`)
   - Extract wave name, status (active/planned/completed), and goal
   - Sort: active first, then planned, then completed
   - Format as table with traceability link
2. If `docs/ROADMAP.md` is absent:
   - Use: `Not yet defined — create [ROADMAP.md](docs/ROADMAP.md) to plan delivery waves.`

**Constraint:** When ROADMAP.md exists, at least one wave name from a heading must appear in the section to satisfy TS-4.

#### 8e. ARC:lifecycle-diagram

Regenerate the mermaid state diagram from `docs/BACKLOG.md`:

1. Count ideas by status: `captured`, `shaped`, `spec-ready`, `shipped`
2. If BACKLOG.md is absent, use 0 for all counts
3. Regenerate the mermaid diagram using the same format as Step 3f (Liatrio brand colors, `stateDiagram-v2`, `direction LR`, count-labeled nodes)
4. Include traceability link: `See [BACKLOG.md](docs/BACKLOG.md) for individual idea details.`

**Constraint:** At least one status count must be non-zero to satisfy TS-5.

**Rules for all sections:**

- Follow extraction rules from `skills/arc-sync/references/readme-mapping.md` exactly
- Replace content between markers only — never move marker positions
- Never modify content outside `ARC:` managed sections
- Never modify `TEMPER:` or `MM:` managed sections
- Do not expose priority metadata (P0/P1/P2/P3)

### Step 9: Scan docs/ for ARC: Diagram Markers

Scan files in `docs/` for additional `ARC:` managed diagram markers that live outside README.md:

1. Use Glob to find all `.md` files in `docs/`
2. Use Grep to search for `<!--# BEGIN ARC:` in those files
3. For each file containing `ARC:` markers:
   - Extract the marker pair and section name
   - If the section is a known diagram type (e.g., `ARC:wave-pipeline-diagram`), regenerate it with current data
   - Apply the same marker replacement protocol: replace between markers, never move positions

**Known diagram types:**

| Marker | Source | Content |
|--------|--------|---------|
| `ARC:wave-pipeline-diagram` | `docs/ROADMAP.md`, `docs/BACKLOG.md` | Pipeline diagram showing current wave ideas and their statuses |
| `ARC:lifecycle-diagram` | `docs/BACKLOG.md` | Same lifecycle diagram as README — status counts from BACKLOG |

4. Record which docs/ files were updated for the summary report.

**If no docs/ files contain ARC: markers:** Skip this step silently.

### Step 10: Trust-Signal Validation

Run TS-1 through TS-8 against the **updated** README content (in memory, before writing to disk). Follow the detection steps defined in `skills/arc-sync/references/trust-signals.md`.

**Validation procedure:**

Use the same evaluability rules and detection steps as Step 4 (scaffold mode), but with two additional checks:

1. **Regression detection:** Compare each signal's status against the before-state captured in Step 7:
   - If a signal was passing before the update and is now failing, flag it as a **regression**
   - Include the specific cause of the regression in the scorecard detail

2. **Newly evaluable signals:** If a signal was N/A before (source artifact was missing) and is now evaluable (artifact was created since last run):
   - Report it as **newly evaluable** in the scorecard
   - Note whether it passes or fails

**Build the scorecard** using the same format as Step 4, with regression and newly-evaluable annotations:

```markdown
**Trust-Signal Scorecard (Update)**

| Signal | Name | Before | After | Detail |
|--------|------|--------|-------|--------|
| TS-1 | Overview | PASS | PASS | Verbatim match confirmed |
| TS-2 | Audience | N/A | PASS | Newly evaluable — CUSTOMER.md created |
| TS-3 | Features | PASS | PASS | 3 shipped items matched |
| TS-4 | Roadmap | PASS | FAIL | REGRESSION — wave "Core Pipeline" removed from ROADMAP.md |
| ... | ... | ... | ... | ... |

**Result:** {N} of {M} evaluable signals passing
**Regressions:** {count} (signals that were passing and are now failing)
**Newly evaluable:** {count}
**Severity:** info | warning
```

**If any regressions exist:** Warn the user explicitly in the diff summary (Step 11). Do not block the update — the user decides whether to proceed.

### Step 11: Build Diff Summary

Compute and present the changes between the before-state (Step 7) and the rebuilt content (Step 8):

For each managed section:

1. Compare before-state content with rebuilt content
2. Classify the section as:
   - **Updated** — content changed
   - **Unchanged** — content is identical (no artifact drift)
   - **New** — section marker exists but had placeholder content that is now replaced with real data

Build the summary:

```markdown
**Update Summary**

| Section | Status | Lines Before | Lines After | Delta |
|---------|--------|-------------|-------------|-------|
| ARC:overview | Unchanged | 8 | 8 | 0 |
| ARC:audience | Updated | 4 | 12 | +8 |
| ARC:features | Updated | 6 | 10 | +4 |
| ARC:roadmap | Unchanged | 14 | 14 | 0 |
| ARC:lifecycle-diagram | Updated | 22 | 22 | 0 |

**Sections updated:** {count}
**Diagrams updated:** {count} (README) + {count} (docs/)
**Total line count delta:** {delta} ({before_total} → {after_total})
```

If regressions were detected in Step 10, append a warning:

```markdown
**⚠ Trust-Signal Regressions:**

- TS-4 (Roadmap): Was PASS, now FAIL — {cause}
```

### Step 12: Present for Approval

Present the diff summary and trust-signal scorecard to the user for review.

```
AskUserQuestion({
  questions: [{
    question: "Here is the update summary for README.md. Review the changes and trust-signal scorecard below, then approve or request changes.\n\n{diff_summary}\n\n{trust_signal_scorecard}",
    header: "README Update",
    options: [
      { label: "Approve", description: "Write the updated managed sections to disk" },
      { label: "Request changes", description: "Describe what you'd like modified" },
      { label: "Cancel", description: "Discard all changes — leave README.md unchanged" }
    ],
    multiSelect: false
  }]
})
```

**If "Approve":** Proceed to Step 13.

**If "Request changes":** Ask the user what to change, apply modifications, re-run trust-signal validation (Step 10), rebuild diff summary (Step 11), and re-present (Step 12). Repeat until approved or the user cancels.

**If "Cancel":** Exit gracefully: "No changes written. README.md is unchanged."

### Step 13: Write Updates and Report

Write the updated managed sections to disk and report results.

**13a. Write README.md**

For each managed section that changed:

1. Use the Edit tool to replace content between the `<!--# BEGIN ARC:{section} -->` and `<!--# END ARC:{section} -->` markers
2. Replace only the content between markers — never modify the markers themselves or content outside them

**13b. Write docs/ diagram updates**

For each docs/ file updated in Step 9:

1. Use the Edit tool to replace content between the diagram markers
2. Verify the write by reading back the file

**13c. Confirm writes**

Read back `README.md` and verify:
- All `ARC:` marker pairs are still present and properly matched
- No nesting conflicts were introduced
- Content outside `ARC:` markers is unchanged from the original file

**13d. Report summary**

```
README.md updated successfully.

Sections updated: {count} of {total} ARC: sections
Diagrams updated: {readme_diagram_count} (README) + {docs_diagram_count} (docs/)
Line count delta: {delta} ({before_total} → {after_total})
Trust signals: {N}/{M} evaluable passing
Regressions: {count}

Run /arc-sync again after shipping features or planning waves to keep managed sections current.
```

## References

- [`skills/arc-sync/references/trust-signals.md`](references/trust-signals.md) — Trust-signal definitions (TS-1 through TS-8) used for post-scaffold and post-update validation
- [`skills/arc-sync/references/readme-mapping.md`](references/readme-mapping.md) — Artifact-to-section extraction rules for all ARC: managed sections
- [`skills/arc-sync/references/readme-quality-rules.md`](references/readme-quality-rules.md) — Quality gates for line count, heading hierarchy, accessibility, and conciseness
- [`skills/arc-wave/references/bootstrap-protocol.md`](../arc-wave/references/bootstrap-protocol.md) — Marker format and coexistence rules for ARC: namespace in project files
- [`references/idea-lifecycle.md`](../../references/idea-lifecycle.md) — Idea lifecycle stages and status values referenced by ARC:features and ARC:lifecycle-diagram
