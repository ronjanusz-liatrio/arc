---
name: arc-audit
description: "Pipeline health audit — check backlog health, wave alignment, and cross-reference integrity across all product artifacts"
user-invocable: true
allowed-tools: Glob, Grep, Read, Write, Edit, AskUserQuestion
---

# /arc-audit — Pipeline Health Audit

## Context Marker

Always begin your response with: **ARC-REVIEW**

## Overview

You audit the health of product artifacts across two dimensions: **backlog health** (quality and completeness of ideas in BACKLOG.md) and **wave alignment** (consistency between BACKLOG, ROADMAP, VISION, and CUSTOMER). After analysis, you generate a diagnostic report and offer interactive fixes for identified issues.

## Critical Constraints

- **NEVER** modify VISION.md or CUSTOMER.md content — only report on their state
- **NEVER** apply fixes without user confirmation via AskUserQuestion
- **NEVER** delete content from BACKLOG.md — only add markers
- **ALWAYS** begin your response with `**ARC-REVIEW**`
- **ALWAYS** generate `docs/skill/arc/review-report.md` after analysis

## Process

### Step 1: Read Context

Read the following files (graceful no-op if absent, except BACKLOG.md):

1. `docs/BACKLOG.md` — **Required.** If absent, inform the user:
   > No backlog found. Run `/arc-capture` first to create ideas.
   Exit gracefully.
2. `docs/ROADMAP.md` — Wave structure and idea assignments
3. `docs/VISION.md` — Product direction
4. `docs/CUSTOMER.md` — Personas and JTBD
5. `docs/management-report.md` — Temper feedback loop

Ask the user if they want to adjust the staleness threshold:

```
AskUserQuestion({
  questions: [{
    question: "Stale idea threshold is currently 14 days. Would you like to adjust it?",
    header: "Threshold",
    options: [
      { label: "Keep 14 days", description: "Default — flag captured ideas older than 14 days" },
      { label: "7 days", description: "More aggressive — flag ideas after one week" },
      { label: "30 days", description: "More lenient — flag ideas after one month" },
      { label: "Custom", description: "Enter a custom number of days" }
    ],
    multiSelect: false
  }]
})
```

If the user selects "Custom," prompt for the value.

### Step 2: Backlog Health Audit

Execute all five backlog health checks per `skills/arc-audit/references/audit-dimensions.md`.

Read the reference file for exact detection logic, thresholds, and output formats.

#### BH-1: Stale Ideas

- Find all ideas with `Status: captured` and no `Shaped:` timestamp
- Parse the `Captured:` ISO 8601 date and compare against the current date
- Flag if the age exceeds the configured staleness threshold

Report in the format defined in audit-dimensions.md (BH-1 section).

#### BH-2: Priority Imbalance

- Count non-shipped ideas at each priority level: P0-Critical, P1-High, P2-Medium, P3-Low
- Flag if any single level holds >50% of non-shipped ideas
- Flag if zero ideas exist at P2-Medium or P3-Low

Report in the format defined in audit-dimensions.md (BH-2 section).

#### BH-3: Status Distribution

- Count all ideas by status: `captured`, `shaped`, `spec-ready`, `shipped`
- Detect bottleneck conditions:
  - Capture stall: 5+ captured with 0 shaped
  - Shape stall: 3+ shaped with 0 spec-ready

Report in the format defined in audit-dimensions.md (BH-3 section).

#### BH-4: Missing Brief Fields

- Find all ideas with `Status: shaped`
- For each, verify the presence of all 7 required subsections:
  1. `### Problem`
  2. `### Proposed Solution`
  3. `### Success Criteria`
  4. `### Constraints`
  5. `### Assumptions`
  6. `### Wave Assignment`
  7. `### Open Questions`
- Flag any idea missing one or more sections

Report in the format defined in audit-dimensions.md (BH-4 section).

#### BH-5: Invalid Status Values

- Read all `Status:` fields in BACKLOG.md idea entries
- Allowed values: `captured`, `shaped`, `spec-ready`, `shipped`
- Flag any idea with a value outside this set

Report in the format defined in audit-dimensions.md (BH-5 section).

### Step 3: Wave Alignment Audit

Execute all seven wave alignment checks per `skills/arc-audit/references/audit-dimensions.md`.

**If `docs/ROADMAP.md` is absent:** Skip WA-1, WA-2, and WA-3 (report as info: "No ROADMAP.md found — wave alignment checks skipped").

#### WA-1: Broken ROADMAP References

- Parse all anchor references in ROADMAP.md (links of the form `[Title](#anchor)` or `[Title](docs/BACKLOG.md#anchor)`)
- For each reference, verify a matching `## {Title}` section exists in BACKLOG.md
- Normalize titles to anchor format: lowercase, spaces to hyphens, punctuation stripped
- Flag any reference where the anchor target is missing

Report in the format defined in audit-dimensions.md (WA-1 section).

#### WA-2: Status Mismatch

- Extract all idea references from ROADMAP.md wave sections
- For each referenced idea, look up its `Status:` in BACKLOG.md
- Flag ideas with status `captured` or `shaped` (not yet `spec-ready` or `shipped`)

Report in the format defined in audit-dimensions.md (WA-2 section).

#### WA-3: Orphaned Spec-Ready Ideas

- Find all ideas with `Status: spec-ready` in BACKLOG.md
- For each, search ROADMAP.md for a reference to its anchor
- Flag any spec-ready idea with no matching ROADMAP reference

Report in the format defined in audit-dimensions.md (WA-3 section).

#### WA-4: VISION Alignment

- Check whether `docs/VISION.md` exists
- If it exists, check for stub indicators:
  - File has fewer than 200 non-whitespace characters
  - File contains `<!-- auto-created` but no `##` section headings
- Report as info if VISION.md exists with content; warning if missing or stub-only

Report in the format defined in audit-dimensions.md (WA-4 section).

#### WA-5: CUSTOMER Alignment

- Check whether `docs/CUSTOMER.md` exists and contains at least one `## {Persona Name}` section heading
- Scan shaped ideas in BACKLOG.md for persona references (lines containing "persona:" or referencing names from CUSTOMER.md)
- Flag any persona reference that does not match a `##` heading in CUSTOMER.md
- If CUSTOMER.md is absent or has no personas, report warning

Report in the format defined in audit-dimensions.md (WA-5 section).

#### WA-6: Cross-Reference Integrity

- Parse all rows in the BACKLOG summary table: extract the title link text from each row
- Parse all `## {Title}` section headings in BACKLOG.md
- Compare the two sets:
  - Orphaned rows: titles in the summary table with no matching `## {Title}` section
  - Orphaned sections: `## {Title}` sections with no matching summary table row
- Flag any mismatch

Report in the format defined in audit-dimensions.md (WA-6 section).

#### WA-7: README Trust-Signal Audit

Evaluate the structural trust signals defined in `skills/arc-sync/references/trust-signals.md` against the project's README.md `ARC:` managed sections.

**Skip conditions:**
- If `README.md` does not exist at the project root: report as info ("No README.md found") and skip
- If `README.md` exists but contains no `<!--# BEGIN ARC:... -->` markers: report as info ("No ARC: sections in README — run `/arc-sync` to scaffold") and skip

**Detection logic:**
- Read `skills/arc-sync/references/trust-signals.md` for the canonical signal definitions and evaluability rules
- Evaluate each of the 8 trust signals (TS-1 through TS-8) per the detection steps in trust-signals.md
- A signal is evaluable only when its source artifact exists AND the corresponding `ARC:` managed section exists in README.md
- For each evaluable signal, cross-reference README.md content against the source artifact (VISION.md, CUSTOMER.md, BACKLOG.md, ROADMAP.md) to determine pass/fail
- TS-8 (No Placeholders) only fails when the source artifact has substantive content (>200 non-whitespace chars) — placeholder text is permitted when the artifact is absent or a stub

**Report format:**
- Output a trust-signal scorecard: `N of M signals passing` (where M is the count of evaluable signals)
- For each signal, report PASS, FAIL, or N/A with a detail string explaining the result
- Use the scorecard format defined in trust-signals.md

**Severity:**
- `info` — 75% or more of evaluable signals pass
- `warning` — fewer than 75% of evaluable signals pass

**Recommended action:** "Run `/arc-sync` to fix failing signals" with a list of which signals failed.

Report in the format defined in audit-dimensions.md (WA-7 section).

### Step 4: Calculate Health Rating

Apply the thresholds from audit-dimensions.md to determine the overall rating:

| Rating | Criteria |
|--------|----------|
| **Healthy** | Zero critical findings AND fewer than 3 warnings |
| **Needs Attention** | Zero critical findings AND 3+ warnings, OR exactly 1 critical finding |
| **Critical** | 2 or more critical findings |

**Critical findings** (always count toward rating):
- BH-5: Invalid status values (any count)
- WA-1: Broken ROADMAP references (any count)
- WA-6: Cross-reference integrity failures (any count)

**Warning findings** (count toward warning total):
- BH-1: Stale ideas (1+ stale idea)
- BH-2: Priority imbalance (triggered)
- BH-3: Status distribution bottleneck (triggered)
- BH-4: Missing brief fields (1+ idea affected)
- WA-2: Status mismatch (1+ idea)
- WA-3: Orphaned spec-ready ideas (1+ idea)
- WA-4: VISION stub or missing
- WA-5: CUSTOMER undefined personas (1+ reference)
- WA-7: README trust signals (<75% of evaluable signals passing)

**Info findings** do not affect the health rating.

### Step 5: Generate Report

Read `skills/arc-audit/references/review-report-template.md` for the full report format.

Create `docs/skill/arc/review-report.md` with:

- Timestamp and staleness threshold
- Overall health rating with criteria explanation
- Backlog health findings table (all 5 checks)
- Wave alignment findings table (all 7 checks)
- Status distribution summary with pipeline health assessment
- Recommended actions grouped by severity (critical, warnings, info)
- Fixes applied section (initially empty, populated if user applies fixes)
- Cross-references to audit-dimensions.md, idea-lifecycle.md, and brief-format.md

### Step 6: Present Findings

Show the findings summary inline and offer interactive fixes via AskUserQuestion with multi-select:

```
AskUserQuestion({
  questions: [{
    question: "Review complete. Which fixes would you like to apply?",
    header: "Fixes",
    options: [
      { label: "Mark stale ideas as reviewed", description: "Add <!-- stale: reviewed {date} --> to {N} stale captured ideas" },
      { label: "Reconcile summary table", description: "Update BACKLOG summary table to match section headings ({N} mismatches)" },
      { label: "Add missing brief markers", description: "Insert <!-- TODO: fill {field} --> in {N} ideas with incomplete briefs" },
      { label: "Remove broken ROADMAP refs", description: "Delete {N} wave references to non-existent BACKLOG ideas" },
      { label: "No fixes", description: "Skip all fixes — I'll handle them manually" }
    ],
    multiSelect: true
  }]
})
```

Only include fix options for issues that were actually detected. If no fixable issues were found, skip this step and proceed to Step 8.

### Step 7: Apply Fixes

For each fix the user selected, apply the change to the appropriate file:

**Mark stale ideas as reviewed:**
- For each stale idea in BACKLOG.md, insert `<!-- stale: reviewed {YYYY-MM-DD} -->` on the line below the idea's `- **Status:** captured` field

**Reconcile summary table:**
- Add missing rows for orphaned sections (sections with no summary table row)
- Remove rows for orphaned entries (summary table rows with no matching section), with per-row confirmation via AskUserQuestion

**Add missing brief markers:**
- For each shaped idea missing brief sections, insert `<!-- TODO: fill {section} -->` as a placeholder under the idea's section in BACKLOG.md

**Remove broken ROADMAP references:**
- For each broken wave reference in ROADMAP.md, confirm removal with the user:

```
AskUserQuestion({
  questions: [{
    question: "Remove broken reference to '{anchor}' from Wave {N} in ROADMAP.md?",
    header: "Confirm",
    options: [
      { label: "Remove", description: "Delete the reference line from the wave" },
      { label: "Keep", description: "Leave the broken reference in place" }
    ],
    multiSelect: false
  }]
})
```

After applying fixes, update the "Fixes Applied" section of `docs/skill/arc/review-report.md` with a checklist of what was changed.

### Step 8: Offer Next Steps

**Conditionally include "Update README" option:**

If WA-7 detected trust-signal failures (fewer than 100% of evaluable signals passing), include the "Update README" option in the next-steps list. If WA-7 was skipped or all signals passed, omit it.

```
AskUserQuestion({
  questions: [{
    question: "What would you like to do next?",
    header: "Next",
    options: [
      { label: "Run review again", description: "Re-audit after fixes to verify health improvement" },
      { label: "Update README", description: "Run /arc-sync to fix stale or incomplete ARC: sections" },
      { label: "Capture new ideas", description: "Run /arc-capture to add ideas to the backlog" },
      { label: "Plan a wave", description: "Run /arc-wave to organize spec-ready ideas into a delivery cycle" },
      { label: "Done", description: "Finish the review session" }
    ],
    multiSelect: false
  }]
})
```

> **Note:** The "Update README" option above is only included when WA-7 reported one or more failing trust signals. If WA-7 was skipped (no README or no ARC: sections) or all evaluable signals passed, omit that option from the list.

**Handle selection:**
- **Run review again:** Loop back to Step 1 (re-read all files, re-run all checks)
- **Update README:** Inform the user to run `/arc-sync` to fix the failing trust signals identified by WA-7, listing which signals failed
- **Capture new ideas:** Inform the user to run `/arc-capture`
- **Plan a wave:** Inform the user to run `/arc-wave`
- **Done:** Summarize the review session (health rating, fixes applied, remaining issues) and exit

## References

- `skills/arc-audit/references/audit-dimensions.md` — Health check definitions, detection logic, thresholds, severity levels, and configurable parameters
- `skills/arc-audit/references/review-report-template.md` — Report format and section layout for `docs/skill/arc/review-report.md`
- `skills/arc-sync/references/trust-signals.md` — Structural trust-signal definitions used by WA-7 (TS-1 through TS-8)
- `references/idea-lifecycle.md` — Idea status transitions, timestamp fields, and lifecycle phases
- `references/brief-format.md` — The seven required brief sections used by BH-4
