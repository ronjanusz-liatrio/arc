# Audit Dimensions

`/arc-review` performs health checks across two dimension groups: **Backlog Health** and **Wave Alignment**. Each dimension defines what is checked, how to detect issues, severity levels, configurable parameters, and the output format for reporting.

---

## Backlog Health Checks

These checks audit the quality, completeness, and distribution of ideas in `docs/BACKLOG.md`.

---

### BH-1: Stale Ideas

**Purpose:** Identify captured ideas that have not progressed to shaping within the expected window, indicating they may be abandoned, deprioritized, or forgotten.

**Detection Logic:**
- Find all ideas with `Status: captured` in BACKLOG.md
- Confirm each idea has no `Shaped:` timestamp in its entry
- Compare the `Captured:` date against the current date
- Flag if the difference exceeds the configured staleness threshold

**Default Threshold:** 14 days (configurable)

**Configurable Parameter:** The staleness threshold can be adjusted interactively via AskUserQuestion at the start of a review session. Example prompt: "Stale idea threshold is currently 14 days. Enter a different value to override, or press Enter to keep the default."

**Severity:** `warning`

**Inputs:**
- All idea entries in `docs/BACKLOG.md` with `Status: captured`
- `Captured:` timestamp field per idea entry

**Output Format:**

```markdown
**BH-1 Stale Ideas**

Threshold: {N} days
Stale ideas found: {count}

| Idea | Captured Date | Days Stale |
|------|--------------|------------|
| {Title} | {YYYY-MM-DD} | {N} |

Recommended Action: Mark as reviewed (`<!-- stale: reviewed {date} -->`) or reshape.
```

**Interactive Fix:** Offer to insert `<!-- stale: reviewed {date} -->` on the line below the idea's `Status:` field in BACKLOG.md for each confirmed stale idea.

---

### BH-2: Priority Imbalance

**Purpose:** Detect skewed priority distributions that suggest triage has not been applied or that all ideas are treated as urgent.

**Detection Logic:**
- Count non-shipped ideas at each priority level: P0-Critical, P1-High, P2-Medium, P3-Low
- Flag if any single priority level holds more than 50% of all non-shipped ideas
- Flag if zero ideas exist at P2-Medium or P3-Low (suggests all remaining work is deemed urgent)

**Thresholds:**
- Imbalance trigger: >50% of non-shipped ideas at one level
- Missing tier trigger: zero ideas at P2-Medium OR zero ideas at P3-Low

**Severity:** `warning`

**Inputs:**
- All idea entries in `docs/BACKLOG.md` with `Status` not equal to `shipped`
- `Priority:` field per idea entry (expected values: P0-Critical, P1-High, P2-Medium, P3-Low)

**Output Format:**

```markdown
**BH-2 Priority Imbalance**

Non-shipped idea priority distribution:
- P0-Critical: {N} ({pct}%)
- P1-High: {N} ({pct}%)
- P2-Medium: {N} ({pct}%)
- P3-Low: {N} ({pct}%)

{If imbalance detected:}
Warning: {pct}% of ideas are at P{X} — distribution may need rebalancing.

{If missing tier detected:}
Warning: No ideas at P{X} — consider whether lower-priority work is being tracked.
```

**Interactive Fix:** No automated fix; report recommendations for manual triage.

---

### BH-3: Status Distribution

**Purpose:** Provide a pipeline health snapshot by counting ideas at each lifecycle stage and detecting bottlenecks.

**Detection Logic:**
- Count all ideas at each status: `captured`, `shaped`, `spec-ready`, `shipped`
- Detect bottleneck conditions:
  - Many shaped ideas (≥3) with zero spec-ready → stalled at brief stage
  - Many captured ideas (≥5) with zero shaped → stalled at capture stage
- Report distribution as info; elevate to warning if a bottleneck is detected

**Bottleneck Thresholds:**
- Capture→Shape bottleneck: ≥5 captured with 0 shaped
- Shape→Spec-Ready bottleneck: ≥3 shaped with 0 spec-ready

**Severity:** `info` (distribution report), `warning` (if bottleneck detected)

**Inputs:**
- All idea entries in `docs/BACKLOG.md`
- `Status:` field per idea entry

**Output Format:**

```markdown
**BH-3 Status Distribution**

| Status | Count |
|--------|-------|
| Captured (in discovery) | {N} |
| Shaped (brief complete) | {N} |
| Spec-Ready (ready for SDD) | {N} |
| Shipped (implemented) | {N} |
| **Total** | {N} |

{If bottleneck detected:}
Warning: {description of bottleneck, e.g., "5 captured ideas with 0 shaped — pipeline stalled at capture stage."}
```

**Interactive Fix:** No automated fix; bottleneck warnings trigger a recommended next step (e.g., run `/arc-shape` to progress ideas).

---

### BH-4: Missing Brief Fields

**Purpose:** Ensure all shaped ideas have complete briefs. Incomplete briefs block SDD pipeline entry.

**Detection Logic:**
- Find all ideas with `Status: shaped` in BACKLOG.md
- For each shaped idea, verify the presence of all 7 required brief sections:
  1. Problem
  2. Proposed Solution
  3. Success Criteria
  4. Constraints
  5. Assumptions
  6. Wave Assignment
  7. Open Questions
- Flag any idea missing one or more sections

**Severity:** `warning`

**Inputs:**
- All idea entries in `docs/BACKLOG.md` with `Status: shaped`
- Presence of `### Problem`, `### Proposed Solution`, `### Success Criteria`, `### Constraints`, `### Assumptions`, `### Wave Assignment`, `### Open Questions` subsections within each shaped idea's `##` section

**Output Format:**

```markdown
**BH-4 Missing Brief Fields**

Ideas with incomplete briefs: {count}

| Idea | Missing Sections |
|------|-----------------|
| {Title} | {Section1}, {Section2} |

Recommended Action: Add `<!-- TODO: fill {section} -->` placeholders to each missing section.
```

**Interactive Fix:** Offer to insert `<!-- TODO: fill {section} -->` as a placeholder for each missing section within the idea's entry in BACKLOG.md.

---

### BH-5: Invalid Status Values

**Purpose:** Catch data integrity errors where idea status fields contain values outside the allowed set, which would cause other checks to silently misclassify ideas.

**Detection Logic:**
- Read all `Status:` fields in BACKLOG.md idea entries
- Allowed values: `captured`, `shaped`, `spec-ready`, `shipped`
- Flag any idea where the status value is not in this set

**Allowed Status Values:** `captured`, `shaped`, `spec-ready`, `shipped`

**Severity:** `critical`

**Inputs:**
- All idea entries in `docs/BACKLOG.md`
- `Status:` field per idea entry

**Output Format:**

```markdown
**BH-5 Invalid Status Values**

Ideas with invalid status: {count}

| Idea | Found Status | Expected One Of |
|------|-------------|-----------------|
| {Title} | {invalid-value} | captured, shaped, spec-ready, shipped |

Recommended Action: Correct status values immediately — other health checks cannot produce reliable results until status values are valid.
```

**Interactive Fix:** No automated fix; correction requires author judgment. Prompt user to update each affected idea manually.

---

## Wave Alignment Checks

These checks audit consistency between `docs/BACKLOG.md`, `docs/ROADMAP.md`, `docs/VISION.md`, and `docs/CUSTOMER.md`.

---

### WA-1: Broken ROADMAP References

**Purpose:** Detect ROADMAP wave entries that reference BACKLOG ideas by anchor where the anchor no longer exists — a common result of idea renaming or deletion.

**Detection Logic:**
- Parse all anchor references in ROADMAP.md (Markdown links of the form `[Title](#anchor)` or `[Title](docs/BACKLOG.md#anchor)`)
- For each referenced anchor, verify a matching `## {Title}` section exists in BACKLOG.md (normalizing title to anchor format: lowercase, spaces to hyphens, punctuation stripped)
- Flag any reference where the anchor target is not found

**Severity:** `critical`

**Inputs:**
- `docs/ROADMAP.md` — all wave plan sections and their idea references
- `docs/BACKLOG.md` — all `## {Title}` section headings

**Output Format:**

```markdown
**WA-1 Broken ROADMAP References**

Broken references found: {count}

| Wave | Referenced Anchor | Status |
|------|-------------------|--------|
| {Wave Name} | {#anchor} | Missing in BACKLOG |

Recommended Action: Remove broken references or add the missing idea back to BACKLOG.
```

**Interactive Fix:** Offer to remove each broken wave reference line from ROADMAP.md with user confirmation per reference.

---

### WA-2: Status Mismatch

**Purpose:** Ensure that ideas included in ROADMAP waves have reached the required readiness level (`spec-ready` or `shipped`). Including unready ideas in a wave signals premature commitment.

**Detection Logic:**
- Extract all idea references from ROADMAP.md wave sections
- For each referenced idea, look up its `Status:` in BACKLOG.md
- Flag ideas whose status is `captured` or `shaped` (not yet `spec-ready` or `shipped`)

**Severity:** `warning`

**Inputs:**
- `docs/ROADMAP.md` — wave section idea references
- `docs/BACKLOG.md` — `Status:` field for each referenced idea

**Output Format:**

```markdown
**WA-2 Status Mismatch**

Wave-assigned ideas that are not spec-ready or shipped: {count}

| Wave | Idea | Current Status | Required |
|------|------|---------------|----------|
| {Wave Name} | {Title} | {status} | spec-ready or shipped |

Recommended Action: Either advance the idea to spec-ready before the wave begins, or remove it from the wave plan.
```

**Interactive Fix:** No automated fix; resolution requires product decision. Report flags the issue for author action.

---

### WA-3: Orphaned Spec-Ready Ideas

**Purpose:** Identify ideas that are ready for SDD pipeline entry (`spec-ready`) but have not been assigned to any ROADMAP wave, representing unplanned work.

**Detection Logic:**
- Find all ideas with `Status: spec-ready` in BACKLOG.md
- For each spec-ready idea, search ROADMAP.md for a reference to its anchor
- Flag any spec-ready idea with no matching ROADMAP reference

**Severity:** `warning`

**Inputs:**
- `docs/BACKLOG.md` — all ideas with `Status: spec-ready`
- `docs/ROADMAP.md` — all idea anchor references across all wave sections

**Output Format:**

```markdown
**WA-3 Orphaned Spec-Ready Ideas**

Spec-ready ideas not assigned to any wave: {count}

| Idea | Status | Assigned Wave |
|------|--------|--------------|
| {Title} | spec-ready | Unassigned |

Recommended Action: Assign each orphaned idea to a ROADMAP wave, or verify the ROADMAP is up to date.
```

**Interactive Fix:** No automated fix; wave assignment requires author judgment.

---

### WA-4: VISION Alignment

**Purpose:** Confirm that a product vision document exists and contains substantive content. A missing or stub VISION.md means shaping and wave planning proceed without strategic direction.

**Detection Logic:**
- Check whether `docs/VISION.md` exists
- If it exists, check for stub indicators: file size <200 characters, or contains only the auto-created note line `<!-- auto-created by arc-capture -->` with no other content blocks
- Report as info if VISION.md exists with content; warning if missing or stub-only

**Stub Detection Heuristics:**
- File is absent → warning
- File contains fewer than 200 non-whitespace characters → warning (likely stub)
- File contains `<!-- auto-created` but no `##` section headings → warning (auto-stub, not filled in)

**Severity:** `info` (exists with content), `warning` (missing or stub)

**Inputs:**
- `docs/VISION.md` — presence and content

**Output Format:**

```markdown
**WA-4 VISION Alignment**

VISION.md status: Present with content | Missing | Stub only

{If warning:}
Warning: {reason, e.g., "VISION.md is absent — shaping and wave planning lack strategic context."}

Recommended Action: {Create VISION.md using arc-capture | Expand stub with product direction}
```

**Interactive Fix:** No automated fix; VISION.md content requires human authorship. Suggest running `/arc-capture` to scaffold.

---

### WA-5: CUSTOMER Alignment

**Purpose:** Verify that at least one named persona is defined in CUSTOMER.md and that shaped ideas do not reference undefined personas, preventing orphaned persona citations.

**Detection Logic:**
- Check whether `docs/CUSTOMER.md` exists and contains at least one `## {Persona Name}` section heading
- Scan all shaped ideas in BACKLOG.md for persona references (lines containing "persona:" or referencing names found in CUSTOMER.md)
- Flag any persona reference in a shaped idea that does not match a `##` section heading in CUSTOMER.md
- If CUSTOMER.md is absent or has no personas, report warning

**Severity:** `warning` (missing personas or undefined persona references)

**Inputs:**
- `docs/CUSTOMER.md` — `## {Persona Name}` section headings
- `docs/BACKLOG.md` — shaped idea entries that contain persona references

**Output Format:**

```markdown
**WA-5 CUSTOMER Alignment**

Named personas defined: {count} ({list of names})
Shaped ideas with undefined persona references: {count}

{If issues found:}
| Idea | Referenced Persona | Found in CUSTOMER.md |
|------|-------------------|----------------------|
| {Title} | {persona name} | No |

Recommended Action: Define missing personas in CUSTOMER.md or update idea references to match defined personas.
```

**Interactive Fix:** No automated fix; persona definitions and references require author judgment.

---

### WA-6: Cross-Reference Integrity

**Purpose:** Ensure the BACKLOG summary table (at the top of BACKLOG.md) matches the `## {Title}` idea sections below it. Orphaned summary rows (rows with no matching section) or orphaned sections (sections with no matching row) indicate stale metadata.

**Detection Logic:**
- Parse all rows in the BACKLOG summary table: extract the title link text from each row
- Parse all `## {Title}` section headings in the body of BACKLOG.md
- Compare the two sets:
  - Orphaned rows: titles in the summary table with no matching `## {Title}` section
  - Orphaned sections: `## {Title}` sections with no matching summary table row
- Flag any mismatch

**Severity:** `critical`

**Inputs:**
- `docs/BACKLOG.md` — summary table rows (link text) and `## {Title}` section headings

**Output Format:**

```markdown
**WA-6 Cross-Reference Integrity**

Summary table rows: {N}
Idea sections: {N}

Orphaned summary rows (no matching section): {count}
| Title | Issue |
|-------|-------|
| {Title} | Row exists, section missing |

Orphaned sections (no matching summary row): {count}
| Title | Issue |
|-------|-------|
| {Title} | Section exists, row missing |

Recommended Action: Reconcile summary table and idea sections — add missing entries or remove stale ones.
```

**Interactive Fix:** Offer to update the BACKLOG summary table: add missing rows for orphaned sections, and remove rows that have no corresponding section. Confirm with user before each change.

---

## Health Rating Thresholds

After all checks complete, `/arc-review` computes an overall health rating by counting critical and warning findings:

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
- BH-1: Stale ideas (≥1 stale idea)
- BH-2: Priority imbalance (triggered)
- BH-3: Status distribution bottleneck (triggered)
- BH-4: Missing brief fields (≥1 idea affected)
- WA-2: Status mismatch (≥1 idea)
- WA-3: Orphaned spec-ready ideas (≥1 idea)
- WA-4: VISION stub or missing
- WA-5: CUSTOMER undefined personas (≥1 reference)

**Info findings** do not affect the health rating — they are reported for visibility only.

---

## Configurable Parameters

The following thresholds can be adjusted interactively at the start of a review session via AskUserQuestion:

| Parameter | Default | Check | Description |
|-----------|---------|-------|-------------|
| `staleness_threshold_days` | 14 | BH-1 | Days before a captured idea is considered stale |
| `capture_bottleneck_min` | 5 | BH-3 | Minimum captured ideas with 0 shaped to trigger bottleneck warning |
| `shape_bottleneck_min` | 3 | BH-3 | Minimum shaped ideas with 0 spec-ready to trigger bottleneck warning |
| `priority_imbalance_pct` | 50 | BH-2 | Percentage threshold for single-level priority imbalance |

All other thresholds (critical/warning counts for health rating, allowed status values) are fixed and not user-configurable.

---

## Cross-References

- `references/review-report-template.md` — Report format and section layout produced by `/arc-review`
- `references/idea-lifecycle.md` — Idea status transitions, timestamp fields, and lifecycle phases
- `references/brief-format.md` — The seven required brief sections used by BH-4
