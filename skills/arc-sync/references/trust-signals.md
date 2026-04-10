# Trust Signals

Arc-managed README sections are validated against 8 structural trust signals. Each signal is a Grep/Read-detectable proxy for product direction credibility — it proves the content is real, current, and traceable to source artifacts, without evaluating prose quality.

This document is the canonical single source of truth for trust-signal definitions. It is consumed by:
- **WA-7** (`/arc-audit`) — audit mode, evaluates signals and reports a scorecard
- **`/arc-sync`** — post-update validation, confirms no regressions after writing

---

## Evaluability Rules

A signal is **evaluable** only when its source artifact exists and the corresponding `ARC:` managed section exists in README.md. Non-evaluable signals are excluded from the scorecard denominator.

| Condition | Result |
|-----------|--------|
| Source artifact exists AND `ARC:` section exists | Evaluable — run detection |
| Source artifact missing | Not evaluable — exclude from scorecard |
| `ARC:` section missing | Not evaluable — exclude from scorecard |
| Source artifact is a stub (<200 non-whitespace chars) | Evaluable for TS-1 through TS-7 (may fail); TS-8 passes (placeholder permitted) |

**Scorecard formula:** `N passing / M evaluable` (where M <= 8)

**Severity assignment:**
- `info` — 75% or more of evaluable signals pass
- `warning` — fewer than 75% of evaluable signals pass

---

## Signal Definitions

---

### TS-1: Overview

**Trust statement:** "This project solves a real problem."

**Source artifact:** `docs/VISION.md`

**Managed section:** `<!--# BEGIN ARC:overview -->`

**Detectable proxy:** The `ARC:overview` section has 2+ non-blank content lines AND at least one sentence from the VISION.md Problem Statement is present (not placeholder text).

**Detection steps:**

1. Read `README.md` and extract content between `<!--# BEGIN ARC:overview -->` and `<!--# END ARC:overview -->`
2. Count non-blank lines in the extracted content — require >= 2
3. Read `docs/VISION.md` and extract the Problem Statement section (content under `## Problem Statement` or `## Problem`)
4. Normalize whitespace in both the VISION.md problem statement and the ARC:overview content
5. Check whether any sentence (period-delimited segment of 10+ characters) from the problem statement appears as a substring in ARC:overview content (case-insensitive)

**Pass criteria:** Both conditions met — 2+ non-blank lines AND at least one problem statement sentence matched.

**Fail criteria:** Fewer than 2 non-blank lines, OR no problem statement sentence found in ARC:overview.

---

### TS-2: Audience

**Trust statement:** "They built this for someone specific."

**Source artifact:** `docs/CUSTOMER.md`

**Managed section:** `<!--# BEGIN ARC:audience -->`

**Detectable proxy:** The `ARC:audience` section contains at least one persona name that matches a `##` heading in CUSTOMER.md.

**Detection steps:**

1. Read `docs/CUSTOMER.md` and extract all `## {Persona Name}` headings — collect persona names
2. Read `README.md` and extract content between `<!--# BEGIN ARC:audience -->` and `<!--# END ARC:audience -->`
3. For each persona name from CUSTOMER.md, search for it in the ARC:audience content
4. Matching is case-insensitive with normalized whitespace (collapse multiple spaces/tabs to single space, trim)

**Pass criteria:** At least one persona name from CUSTOMER.md appears in ARC:audience content.

**Fail criteria:** No persona name matches found.

---

### TS-3: Features

**Trust statement:** "This project ships real things."

**Source artifact:** `docs/BACKLOG.md`

**Managed section:** `<!--# BEGIN ARC:features -->`

**Detectable proxy:** The `ARC:features` section contains a bullet list where 1+ item titles match a `Status: shipped` idea in BACKLOG.md.

**Detection steps:**

1. Read `docs/BACKLOG.md` and find all idea entries with `Status: shipped`
2. Extract each shipped idea's title from its `## {Title}` heading
3. Read `README.md` and extract content between `<!--# BEGIN ARC:features -->` and `<!--# END ARC:features -->`
4. For each shipped idea title, search for it in the ARC:features content
5. Matching is case-insensitive substring search (the README bullet text must contain the BACKLOG title as a substring)

**Pass criteria:** At least one shipped idea title from BACKLOG.md appears in ARC:features content.

**Fail criteria:** Zero shipped idea titles found in ARC:features.

---

### TS-4: Roadmap

**Trust statement:** "There's a delivery plan, not just ideas."

**Source artifact:** `docs/ROADMAP.md`

**Managed section:** `<!--# BEGIN ARC:roadmap -->`

**Detectable proxy:** The `ARC:roadmap` section contains a table or list with at least one wave name matching a wave section in ROADMAP.md.

**Detection steps:**

1. Read `docs/ROADMAP.md` and extract all wave section headings (`## {Wave Name}` or `### {Wave Name}`)
2. Collect wave names from the headings
3. Read `README.md` and extract content between `<!--# BEGIN ARC:roadmap -->` and `<!--# END ARC:roadmap -->`
4. For each wave name from ROADMAP.md, search for it in the ARC:roadmap content
5. Matching is case-insensitive substring search

**Pass criteria:** At least one wave name from ROADMAP.md appears in ARC:roadmap content.

**Fail criteria:** Zero wave names found in ARC:roadmap.

---

### TS-5: Lifecycle Diagram

**Trust statement:** "The pipeline is active, not decorative."

**Source artifact:** `docs/BACKLOG.md` (status counts derived from idea statuses)

**Managed section:** `<!--# BEGIN ARC:lifecycle-diagram -->`

**Detectable proxy:** The `ARC:lifecycle-diagram` section contains a mermaid code fence AND at least one status count node label is non-zero.

**Detection steps:**

1. Read `README.md` and extract content between `<!--# BEGIN ARC:lifecycle-diagram -->` and `<!--# END ARC:lifecycle-diagram -->`
2. Verify a mermaid code fence exists (``` ```mermaid ``` block)
3. Within the mermaid block, search for node labels with status counts using pattern: `[\w-]+\(\d+\)` (e.g., `Captured(3)`, `Spec-Ready(2)`, `Shipped(7)`)
4. Extract the numeric values from each matched node label
5. Check whether at least one extracted count is greater than zero

**Pass criteria:** Mermaid fence exists AND at least one status count node label has a value > 0.

**Fail criteria:** No mermaid fence found, OR all status count node labels are zero, OR no status count node labels found.

---

### TS-6: Currency

**Trust statement:** "This data reflects the current state."

**Source artifact:** `docs/BACKLOG.md`

**Managed section:** `<!--# BEGIN ARC:features -->`

**Detectable proxy:** The shipped idea count in ARC:features matches the shipped count in BACKLOG.md (no drift).

**Detection steps:**

1. Read `docs/BACKLOG.md` and count all idea entries with `Status: shipped` — this is `backlog_shipped_count`
2. Read `README.md` and extract content between `<!--# BEGIN ARC:features -->` and `<!--# END ARC:features -->`
3. Count bullet list items (`- ` prefixed lines with non-empty content after the prefix) in the ARC:features section — this is `readme_features_count`
4. Compare the two counts

**Pass criteria:** `readme_features_count == backlog_shipped_count`

**Fail criteria:** Counts differ. Report: `"{readme_features_count} in README vs {backlog_shipped_count} in BACKLOG"`

---

### TS-7: Traceability

**Trust statement:** "This data comes from real artifacts."

**Source artifact:** Any `docs/` file

**Managed section:** Any `ARC:` managed section

**Detectable proxy:** At least one `ARC:` managed section contains a `](docs/` link that resolves to an existing file.

**Detection steps:**

1. Read `README.md` and extract all content within `ARC:` managed sections (between any `<!--# BEGIN ARC:... -->` and `<!--# END ARC:... -->` pair)
2. Search for Markdown links containing `docs/` in the path: pattern `\]\(docs/[^)]+\)`
3. For each matched link, extract the relative file path
4. Check whether the referenced file exists on disk (relative to project root)

**Pass criteria:** At least one `](docs/...)` link found in any ARC: section AND the referenced file exists.

**Fail criteria:** No `](docs/...)` links found in any ARC: section, OR all such links point to non-existent files.

---

### TS-8: No Placeholders

**Trust statement:** "This isn't scaffolding they forgot to fill in."

**Source artifact:** Per-section (VISION.md for overview, CUSTOMER.md for audience, BACKLOG.md for features, ROADMAP.md for roadmap)

**Managed section:** All `ARC:` managed sections

**Detectable proxy:** No `ARC:` managed section contains placeholder text ("TBD", "TODO", "Coming soon", "Not yet defined") when the corresponding source artifact has substantive content (>200 non-whitespace characters).

**Detection steps:**

1. Define placeholder patterns (case-insensitive): `TBD`, `TODO`, `Coming soon`, `Not yet defined`
2. Define the section-to-artifact mapping:

   | ARC Section | Source Artifact |
   |-------------|----------------|
   | `ARC:overview` | `docs/VISION.md` |
   | `ARC:audience` | `docs/CUSTOMER.md` |
   | `ARC:features` | `docs/BACKLOG.md` |
   | `ARC:roadmap` | `docs/ROADMAP.md` |
   | `ARC:lifecycle-diagram` | `docs/BACKLOG.md` |

3. For each `ARC:` managed section in README.md:
   a. Extract the section content
   b. Search for any placeholder pattern in the content
   c. If a placeholder is found, check the corresponding source artifact:
      - Read the source artifact file
      - Count non-whitespace characters
      - If count > 200: the artifact has substantive content — placeholder is a **failure**
      - If count <= 200 or file does not exist: placeholder is **permitted** (pass)

**Pass criteria:** No ARC: section contains placeholder text where the source artifact has substantive content.

**Fail criteria:** At least one ARC: section contains placeholder text AND the corresponding source artifact has >200 non-whitespace characters. Report which section and which placeholder was found.

---

## Section-to-Artifact Mapping

This mapping defines which source artifact each ARC: managed section derives from. Both WA-7 and `/arc-sync` use this mapping to determine evaluability and to cross-reference content.

| ARC Section | Source Artifact | Signals |
|-------------|----------------|---------|
| `ARC:overview` | `docs/VISION.md` | TS-1, TS-8 |
| `ARC:audience` | `docs/CUSTOMER.md` | TS-2, TS-8 |
| `ARC:features` | `docs/BACKLOG.md` | TS-3, TS-6, TS-8 |
| `ARC:roadmap` | `docs/ROADMAP.md` | TS-4, TS-8 |
| `ARC:lifecycle-diagram` | `docs/BACKLOG.md` | TS-5, TS-8 |
| *(any ARC: section)* | *(any docs/ file)* | TS-7 |

---

## Scorecard Output Format

Both consumers produce a scorecard using this format:

```markdown
**Trust-Signal Scorecard**

| Signal | Name | Status | Detail |
|--------|------|--------|--------|
| TS-1 | Overview | PASS / FAIL / N/A | {detail or reason} |
| TS-2 | Audience | PASS / FAIL / N/A | {detail or reason} |
| TS-3 | Features | PASS / FAIL / N/A | {detail or reason} |
| TS-4 | Roadmap | PASS / FAIL / N/A | {detail or reason} |
| TS-5 | Lifecycle Diagram | PASS / FAIL / N/A | {detail or reason} |
| TS-6 | Currency | PASS / FAIL / N/A | {detail or reason} |
| TS-7 | Traceability | PASS / FAIL / N/A | {detail or reason} |
| TS-8 | No Placeholders | PASS / FAIL / N/A | {detail or reason} |

**Result:** {N} of {M} evaluable signals passing
**Severity:** info | warning
```

- `PASS` — signal detection criteria met
- `FAIL` — signal detection criteria not met (detail explains why)
- `N/A` — signal not evaluable (source artifact or ARC: section missing)

---

## Cross-References

- `skills/arc-audit/references/audit-dimensions.md` — WA-7 uses these signal definitions for the README trust-signal audit
- `skills/arc-audit/references/review-report-template.md` — Report format includes the trust-signal scorecard
- `skills/arc-audit/SKILL.md` — Step 3 (Wave Alignment Audit) includes WA-7
- `references/idea-lifecycle.md` — Status values referenced by TS-3, TS-5, TS-6
- `references/brief-format.md` — Brief fields referenced by source artifact structure
