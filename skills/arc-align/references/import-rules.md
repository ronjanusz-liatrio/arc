# Import Rules

`/arc-align` classifies discovered content into artifact targets, generates captured stubs, cleans up original sources, and maintains an import manifest. This document defines the classification rules, stub generation logic, cleanup behavior, and manifest format.

---

## Artifact Classification

Every discovery is classified into exactly one of three artifact targets based on its content type. Classification uses the detection pattern that flagged the content, the surrounding context, and the rules below.

---

### BACKLOG — Actionable Items

**Content types:** TODOs, features, bugs, ideas, task lists, roadmap items, sprint goals, epics, user stories, milestones, numbered feature lists, kanban boards.

**Classification signals:**

| Signal | Example |
|--------|---------|
| Task list syntax | `- [ ] Add rate limiting` |
| Feature enumeration | `1. User auth 2. RBAC 3. Audit logs` |
| Actionable heading | `## Roadmap`, `## TODO`, `## Planned Features`, `## Backlog` |
| Kanban structure | `### To Do` / `### In Progress` / `### Done` |
| Sprint/milestone grouping | `## Sprint 14 Goals`, `## Milestone 2` |
| Keyword with action context | "planned", "upcoming", "next steps", "future work" near actionable items |
| User story format | "As a {persona}, I want {goal} so that {benefit}" |

**Decision rule:** If the content describes work to be done, features to be built, or items to be tracked — classify as BACKLOG.

---

### VISION — Mission and Direction

**Content types:** Mission statements, vision statements, north-star metrics, strategic direction, product principles.

**Classification signals:**

| Signal | Example |
|--------|---------|
| Mission heading | `## Our Mission`, `## Mission Statement` |
| Vision heading | `## Product Vision`, `## Vision` |
| North-star content | `## North Star`, references to guiding metrics |
| Strategic language | "We exist to...", "Our goal is...", "We believe..." in declarative product statements |

**Decision rule:** If the content describes why the product exists, where it is going, or what principles guide decisions — classify as VISION.

---

### CUSTOMER — Personas and Audience

**Content types:** Persona definitions, target audience descriptions, jobs-to-be-done, user segments, audience profiles.

**Classification signals:**

| Signal | Example |
|--------|---------|
| Persona heading | `## Personas`, `### Alex — Platform Engineer` |
| Audience heading | `## Target Audience` |
| Persona structure | Name, role, goals, pain points in a structured block |
| JTBD format | "When {situation}, I want {motivation}, so I can {outcome}" |
| Demographic/psychographic description | "Small engineering teams (2-10 developers) shipping SaaS products" |

**Decision rule:** If the content describes who uses the product, what their needs are, or how they behave — classify as CUSTOMER.

---

### Ambiguous Content

When content does not clearly map to a single target:

| Ambiguity | Resolution |
|-----------|-----------|
| Roadmap with vision framing | Classify individual items as BACKLOG; classify the framing paragraph as VISION if it stands alone |
| Feature list with persona context | Classify the features as BACKLOG; classify the persona description as CUSTOMER |
| General "about" content | If it describes what the product does and why, classify as VISION |
| Mixed file with multiple content types | Split into separate discoveries, each with its own classification |

**Inclusivity principle:** When in doubt, import rather than skip. It is better to import a marginal item as a captured BACKLOG stub (where the user can review and delete it) than to miss genuine product-direction content. The alignment report marks weak-signal imports for user review.

---

## Stub Generation

When importing a discovery into BACKLOG as a captured stub, `/arc-align` generates the following structure per idea.

### Stub Format

```markdown
## {Title}

- **Status:** captured
- **Priority:** P2-Medium
- **Captured:** {ISO 8601 timestamp}
<!-- aligned-from: {source_path}:{line_range} -->

{One-line summary}
```

### Field Derivation Rules

---

#### Title

The title is derived from the source content using the first applicable rule:

| Source Content | Derivation Rule | Example |
|---------------|-----------------|---------|
| Heading present | Use the heading text, stripped of markdown syntax (`#`, `**`, links) | `## Add dark mode` → "Add dark mode" |
| Task list item | Use the task text, stripped of checkbox syntax | `- [ ] Fix auth bug` → "Fix auth bug" |
| Numbered list item | Use the item text, stripped of number prefix | `3. Webhook support` → "Webhook support" |
| User story format | Extract the goal clause | "As a dev, I want real-time logs" → "Real-time logs" |
| No clear title | Use the first meaningful line (non-blank, non-comment), truncated to 60 characters | First line of the section |

If the derived title exceeds 80 characters, truncate at the last word boundary before 80 characters.

---

#### Summary

The one-line summary is extracted from the source content:

| Source Content | Extraction Rule |
|---------------|-----------------|
| Paragraph follows heading | Use the first sentence of the paragraph |
| Task list item with no paragraph | Use the task text itself as the summary |
| Multi-line content | Use the first non-heading, non-blank line, truncated to 120 characters |
| No extractable content | Use "Imported from {source_path}" |

---

#### Priority

All imported items default to **P2-Medium**. No automatic priority inference is performed — the user adjusts priorities after import.

---

#### Timestamp

The `Captured` timestamp uses ISO 8601 format with UTC timezone: `YYYY-MM-DDTHH:MM:SSZ`.

Example: `2026-04-08T14:30:00Z`

---

#### Aligned-From Marker

The `<!-- aligned-from: ... -->` comment records the source location for traceability:

```
<!-- aligned-from: {source_path}:{line_range} -->
```

- `source_path`: Relative path from the repository root (e.g., `README.md`, `docs/TODO.md`)
- `line_range`: Line numbers of the imported content. Single line: `5`. Range: `10-25`.

Example: `<!-- aligned-from: README.md:50-70 -->`

This marker enables:
- Manifest cross-referencing for idempotent re-runs
- Audit trail showing where each imported idea originated
- Source verification if the original content needs to be reviewed

---

### BACKLOG Summary Table

After creating stubs, update the summary table at the top of `docs/BACKLOG.md` with one row per imported idea:

```markdown
| [{Title}](#{anchor}) | captured | P2-Medium | -- |
```

The anchor is derived from the title using standard markdown anchor rules: lowercase, spaces to hyphens, non-alphanumeric characters (except hyphens) stripped.

Example: "Add Dark Mode Support" → `#add-dark-mode-support`

---

## VISION and CUSTOMER Imports

### VISION Import Format

Append discovered vision content to `docs/VISION.md` under a `## Imported Content` section:

```markdown
## Imported Content

<!-- aligned-from: {source_path}:{line_range} -->
{imported content, preserving original formatting}
```

If the `## Imported Content` section already exists, append below existing content within that section. Do not create duplicate section headings.

### CUSTOMER Import Format

Append discovered persona/audience content to `docs/CUSTOMER.md` under a `## Imported Content` section:

```markdown
## Imported Content

<!-- aligned-from: {source_path}:{line_range} -->
{imported persona content, preserving original formatting}
```

Same append-within-section rule as VISION imports.

---

## Code Comment Classification

Code comments discovered via CC-1 through CC-4 patterns are always classified as BACKLOG targets. The rules below override the general stub generation defaults for code-sourced imports.

---

### Target Artifact

All code comment discoveries map to **BACKLOG**. Code comments are actionable items regardless of marker type — they represent work to be tracked, not vision or persona content.

---

### Priority Overrides

| Marker | Priority | Rationale |
|--------|----------|-----------|
| CC-1: TODO | P2-Medium | Standard actionable reminder — normal priority |
| CC-2: FIXME | P1-High | Known defect requiring correction — elevated priority |
| CC-3: HACK | P1-High | Technical debt with a temporary workaround — elevated priority |
| CC-4: XXX | P2-Medium | Needs review but no confirmed defect — normal priority |

These overrides replace the default P2-Medium for all FIXME and HACK imports. The user can adjust priorities after import.

---

### Title Derivation

Strip the comment marker, any surrounding comment syntax, and leading/trailing whitespace from the extracted text:

1. Remove the marker (`TODO`, `FIXME`, `HACK`, `XXX`) and any following colon
2. Strip common comment prefixes: `//`, `#`, `/*`, `*`, `--`, `"""`, `'''`
3. Use the remaining text as the title, truncated to 80 characters at the last word boundary

**Examples:**

| Raw comment | Derived title |
|-------------|---------------|
| `// TODO: refactor this module to use the new auth client` | "Refactor this module to use the new auth client" |
| `# FIXME: breaks when timezone is not UTC` | "Breaks when timezone is not UTC" |
| `// HACK: setTimeout to work around modal rendering delay` | "SetTimeout to work around modal rendering delay" |
| `# XXX: review locking strategy under high concurrency` | "Review locking strategy under high concurrency" |

---

### Summary Format

The one-line summary for code comment stubs uses the following format:

```
Code comment from {file}:{line}
```

Example: `Code comment from src/auth/client.py:42`

---

### Aligned-From-Code Marker

Code comment stubs use a distinct traceability marker to distinguish them from markdown-sourced imports:

```
<!-- aligned-from-code: {file}:{line} -->
```

- `file`: Relative path from the repository root to the source file (e.g., `src/auth/client.py`)
- `line`: The exact line number of the comment marker

Example: `<!-- aligned-from-code: src/auth/client.py:42 -->`

This marker is used in addition to the standard `<!-- aligned-from: ... -->` comment on the stub. Both markers are present on code comment stubs:

```markdown
## Refactor this module to use the new auth client

- **Status:** captured
- **Priority:** P2-Medium
- **Captured:** 2026-04-08T14:30:00Z
<!-- aligned-from: src/auth/client.py:42 -->
<!-- aligned-from-code: src/auth/client.py:42 -->

Code comment from src/auth/client.py:42
```

---

### Deduplication Rule

If the same comment text (after marker stripping) appears in multiple source files — for example, copy-pasted boilerplate or a shared pattern — import exactly one stub and note the additional locations in the summary:

**Single-location stub (standard):**
```
Code comment from src/handlers/user.py:18
```

**Multi-location stub (deduplicated):**
```
Code comment from src/handlers/user.py:18 (also: src/handlers/admin.py:22, src/handlers/org.py:31)
```

The `aligned-from-code` marker on deduplicated stubs references the first occurrence. Additional locations are listed in the summary line only. The manifest records each location as a separate row, all pointing to the same imported stub title.

**Deduplication match criteria:** Two comments are considered duplicates when their derived titles (post-stripping) are identical after case normalization. Comments with the same marker but different text are not deduplicated.

---

## Source Cleanup

After all imports succeed, remove the original content to eliminate drift between Arc-managed and unmanaged content.

---

### Entire-File Deletion

Delete the source file when **all** of its content was classified as product-direction and imported. Criteria for entire-file deletion:

- The file contains only product-direction content (no non-product sections remain)
- Every section of the file has been imported or is boilerplate (empty lines, frontmatter, comments)
- Common entire-file candidates: `TODO.md`, `PERSONAS.md`, `FEATURES.md`, standalone roadmap files

**Deletion is performed only after all imports from the file succeed.** If any import from the file fails, the file is left intact.

---

### Partial-Section Removal

When a file contains both product-direction and non-product content, remove only the imported sections.

**Section boundary detection:**

| Boundary Type | Rule |
|---------------|------|
| Heading-delimited | A section starts at a `##` or `###` heading and ends at the next heading of the same or higher level, or at end of file |
| Blank-line-delimited | If no heading structure exists, a section is a block of consecutive non-blank lines separated by one or more blank lines |
| Task list block | Consecutive task list items (`- [ ]` / `- [x]`) form a single block. Remove the entire block if all items were imported. |

**Removal procedure:**

1. Identify the exact line range of the imported section
2. Remove all lines in the range
3. Collapse any resulting double-blank-line sequences to a single blank line
4. Verify the remaining file is valid markdown (headings still nested correctly)
5. If removal leaves the file with only whitespace or frontmatter, delete the file entirely

**Preservation guarantee:** Content outside the identified section boundaries is never modified. The surrounding text, headings, and structure remain intact.

---

## Manifest Format

`docs/skill/arc/align-manifest.md` tracks every import for idempotent re-runs and audit purposes.

### Table Structure

```markdown
# Align Manifest

| Source Path | Line Range | Target Artifact | Imported Title | Timestamp |
|-------------|-----------|-----------------|----------------|-----------|
| README.md | 50-70 | BACKLOG | Add dark mode support | 2026-04-08T14:30:00Z |
| TODO.md | 1-5 | BACKLOG | Fix auth bug | 2026-04-08T14:30:01Z |
| PERSONAS.md | 1-40 | CUSTOMER | (persona content) | 2026-04-08T14:30:02Z |
| ABOUT.md | 10-20 | VISION | (vision content) | 2026-04-08T14:30:03Z |
```

### Column Definitions

| Column | Description |
|--------|-------------|
| Source Path | Relative path from repository root to the original file |
| Line Range | Line numbers of the imported content (single line: `5`, range: `10-25`) |
| Target Artifact | One of `BACKLOG`, `VISION`, or `CUSTOMER` |
| Imported Title | For BACKLOG imports: the stub title. For VISION/CUSTOMER: `(vision content)` or `(persona content)` |
| Timestamp | ISO 8601 timestamp of the import |

### Update Logic

**Creating the manifest:**

If `docs/skill/arc/align-manifest.md` does not exist, create it with the table header and add rows for all imports in the current run.

**Appending to an existing manifest:**

If the manifest already exists, append new rows below the existing table entries. Do not modify or remove existing rows.

**Idempotent re-run check:**

Before importing, read the manifest and build a set of `{source_path}:{line_range}` keys. Skip any discovery whose source location matches an existing manifest entry. Mark skipped items in the alignment report with the original import timestamp.

**Edge cases:**

| Scenario | Behavior |
|----------|----------|
| Source file was renamed since last import | The new path does not match the manifest entry — the content is treated as a new discovery. The user can manually mark it as a duplicate. |
| Source file content shifted (different line range) | Different line range means different manifest key — the content is treated as new. The user reviews for duplicates in the alignment report. |
| Manifest file was deleted | All source locations are treated as new — full re-import occurs (with user confirmation via the standard import flow). |

---

## Cross-References

- `skills/arc-align/references/detection-patterns.md` — Keyword, structural, and code comment patterns (CC-1 through CC-4) used to discover content before classification
- `references/idea-lifecycle.md` — The Capture stage definition and required fields for imported stubs
- `references/brief-format.md` — The brief format that captured stubs will eventually be shaped into
- `templates/BACKLOG.tmpl.md` — Template used to bootstrap BACKLOG.md if absent before import
- `templates/VISION.tmpl.md` — Template used to bootstrap VISION.md if absent before import
- `templates/CUSTOMER.tmpl.md` — Template used to bootstrap CUSTOMER.md if absent before import
- `skills/arc-align/SKILL.md` — Steps 2c, 5, 6, and 7 reference this document for classification and import rules; Step 2c code comment scanning uses the CC-1 through CC-4 priority overrides and aligned-from-code marker format defined here
