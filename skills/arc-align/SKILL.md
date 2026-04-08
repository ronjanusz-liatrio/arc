---
name: arc-align
description: "Codebase discovery and migration — consolidate scattered product-direction content into Arc-managed artifacts"
user-invocable: true
allowed-tools: Glob, Grep, Read, Write, Edit, AskUserQuestion
---

# /arc-align — Codebase Discovery and Migration

## Context Marker

Always begin your response with: **ARC-ALIGN**

## Overview

You scan a project for product-direction content scattered outside Arc's managed artifacts -- roadmap entries, backlog items, TODO lists, feature plans, vision statements, and persona descriptions -- then automatically import them into `docs/BACKLOG.md`, `docs/VISION.md`, and `docs/CUSTOMER.md`. The goal is to consolidate all product-direction content under Arc's governance so that `/arc-shape`, `/arc-wave`, and `/arc-review` operate on a complete picture.

## Critical Constraints

- **NEVER** import content without user confirmation via AskUserQuestion
- **NEVER** delete source files or sections before a successful import
- **NEVER** scan or import files that contain secrets (`.env`, `credentials.json`, `*.key`)
- **NEVER** modify existing Arc-managed artifact content -- only append imported stubs
- **ALWAYS** begin your response with `**ARC-ALIGN**`
- **ALWAYS** generate `docs/align-report.md` after every run
- **ALWAYS** update `docs/align-manifest.md` after every import
- **ALWAYS** skip source locations already recorded in the manifest (idempotent re-runs)
- **ALWAYS** be inclusive at import time -- when in doubt, import as a captured stub rather than skip

## Process

### Step 1: Configure Exclusions

Apply hardcoded exclusion defaults, scan for large directories, then let the user refine.

**1a. Hardcoded exclusions (always applied, not user-deselectable):**

These paths are silently excluded from scanning. They never appear in the user-facing multi-select because they must always be excluded:

| Category | Paths |
|----------|-------|
| Directories | `.git/`, `node_modules/`, `vendor/`, `dist/`, `build/`, `docs/specs/` |
| Arc-managed files | `docs/BACKLOG.md`, `docs/ROADMAP.md`, `docs/VISION.md`, `docs/CUSTOMER.md`, `docs/wave-report.md`, `docs/review-report.md`, `docs/shape-report.md`, `docs/align-manifest.md` |
| Secret-bearing files | `.env`, `credentials.json`, `*.key` |

**1b. Directory pre-scan:**

Run a quick Glob scan to identify top-level and second-level directories with unusually large file counts (>100 files). These directories are likely dependency or generated-content folders that would slow the scan.

For each candidate directory, use `Glob({ pattern: "{dir}/**/*" })` and count the returned files. If the count exceeds 100, add the directory to the recommended-exclusion list with the file count.

Only scan directories not already in the hardcoded exclusion list.

**1c. Present exclusion confirmation:**

Present the recommended directory exclusions (from 1b) to the user for review. Hardcoded exclusions from 1a are NOT included in this list -- they are always applied silently.

```
AskUserQuestion({
  questions: [{
    question: "These directories will be excluded from scanning. Deselect any you want scanned, or add custom patterns.",
    header: "Exclusions",
    options: [
      { label: "{large_dir_1}/", description: "{N} files detected — recommended for exclusion" },
      { label: "{large_dir_2}/", description: "{N} files detected — recommended for exclusion" },
      { label: "Add custom patterns", description: "Provide additional glob patterns to exclude" }
    ],
    multiSelect: true
  }]
})
```

If no large directories are found, skip the multi-select and instead ask only:

```
AskUserQuestion({
  questions: [{
    question: "No large directories detected. Would you like to add custom exclusion patterns?",
    header: "Exclusions",
    options: [
      { label: "No, continue", description: "Proceed with default exclusions only" },
      { label: "Add custom patterns", description: "Provide additional glob patterns to exclude" }
    ],
    multiSelect: false
  }]
})
```

**1d. Custom pattern prompt (if selected):**

If the user selects "Add custom patterns," prompt for the patterns:

```
AskUserQuestion({
  questions: [{
    question: "Enter glob patterns to exclude (one per line, e.g., 'test/', '*.generated.md'):",
    header: "Custom Exclusions",
    options: [
      { label: "Provide patterns", description: "Type your exclusion patterns in the text field" }
    ],
    multiSelect: false
  }]
})
```

**1e. Merge exclusion set:**

Build the final exclusion set by combining:
1. All hardcoded exclusions from 1a (always included)
2. Large directories the user left selected in 1c
3. Any custom patterns from 1d

Directories the user deselected in 1c are removed from the exclusion set and will be scanned.

Use this merged exclusion set for all subsequent scanning in Steps 2-8.

### Step 2: Discover Product-Direction Content

Scan all non-excluded files using two detection strategies. Read `skills/arc-align/references/detection-patterns.md` for the full pattern reference.

**2a. Keyword matching:**

Search files for terms indicating product-direction content: `roadmap`, `backlog`, `todo`, `planned`, `upcoming`, `feature list`, `future work`, `next steps`, `milestone`, `sprint`, `epic`, `user story`, `persona`, `target audience`, `mission`, `vision`, `north star`.

Run keyword scan first -- it uses Grep and is fast.

**2b. Structural matching:**

Search remaining files for structural indicators:
- Markdown task lists (`- [ ]`)
- Numbered feature lists (sequential `1. Feature...` blocks)
- Heading patterns (`## Roadmap`, `## TODO`, `## Planned Features`, `## Backlog`)
- Kanban-style markers (`### To Do`, `### In Progress`, `### Done`)

Structural scan requires line-by-line parsing with Read. Run after keyword scan to minimize file reads.

**2c. Classify discoveries:**

For each match, classify into one of three artifact targets per `skills/arc-align/references/import-rules.md`:

| Target | Content Type |
|--------|-------------|
| `BACKLOG` | Actionable items: TODOs, features, bugs, ideas, task lists, roadmap items |
| `VISION` | Mission/vision/north-star content |
| `CUSTOMER` | Persona/audience/JTBD content |

**2d. Check manifest for prior imports:**

Read `docs/align-manifest.md` (if present). Skip any source locations already recorded as imported. Mark skipped items for the report.

**2e. Build discovery list:**

For each match, record:
- Source file path
- Line range
- Matched content snippet
- Detection method (keyword or structural)
- Target artifact (BACKLOG, VISION, or CUSTOMER)

### Step 3: Confirm Import

Present the discovery list to the user for review before importing.

```
AskUserQuestion({
  questions: [{
    question: "Found {N} items to import. Review the list and confirm.",
    header: "Import",
    options: [
      { label: "Import all", description: "Import all {N} discovered items into Arc artifacts" },
      { label: "Review individually", description: "Confirm each item one by one" },
      { label: "Skip", description: "Skip import — generate report only" }
    ],
    multiSelect: false
  }]
})
```

If the user selects "Review individually," present each discovery with accept/reject options.

### Step 4: Bootstrap Artifacts

Before importing, ensure target artifacts exist.

**4a. BACKLOG.md:**

If `docs/BACKLOG.md` does not exist and there are BACKLOG-targeted discoveries:
- Read `templates/BACKLOG.tmpl.md` for the Foundation phase format
- Create `docs/BACKLOG.md` following the same bootstrap logic as `/arc-capture`

**4b. VISION.md:**

If `docs/VISION.md` does not exist and there are VISION-targeted discoveries:
- Read `templates/VISION.tmpl.md`
- Create `docs/VISION.md` from the template

**4c. CUSTOMER.md:**

If `docs/CUSTOMER.md` does not exist and there are CUSTOMER-targeted discoveries:
- Read `templates/CUSTOMER.tmpl.md`
- Create `docs/CUSTOMER.md` from the template

### Step 5: Import Discoveries

Import confirmed items into the appropriate Arc artifacts. Read `skills/arc-align/references/import-rules.md` for detailed rules.

**5a. BACKLOG imports:**

For each BACKLOG-targeted discovery, create a captured stub:

```markdown
## {Title}

- **Status:** captured
- **Priority:** P2-Medium
- **Captured:** {ISO 8601 timestamp}
<!-- aligned-from: {source_path}:{line_range} -->

{One-line summary extracted or synthesized from surrounding context}
```

- Title: derived from source heading, task list text, or first meaningful line
- Priority: default to `P2-Medium`
- Status: `captured`
- Update the BACKLOG summary table with a new row per imported idea

**5b. VISION imports:**

Append discovered content to `docs/VISION.md` under a `## Imported Content` section with source attribution:

```markdown
## Imported Content

<!-- aligned-from: {source_path}:{line_range} -->
{imported content}
```

**5c. CUSTOMER imports:**

Append discovered persona/audience content to `docs/CUSTOMER.md` under a `## Imported Content` section with source attribution:

```markdown
## Imported Content

<!-- aligned-from: {source_path}:{line_range} -->
{imported persona content}
```

### Step 6: Clean Up Sources

After all imports succeed, remove the original content to eliminate drift.

**6a. Full-file deletion:**

If the entire file is product-direction content, delete the file.

**6b. Partial-section removal:**

If only a section of a file is product-direction content, remove that section from the file, preserving surrounding content. Use section boundaries (markdown headings, blank-line separators) to identify extraction ranges.

### Step 7: Update Manifest

Update `docs/align-manifest.md` with a row per import:

```markdown
# Align Manifest

| Source Path | Line Range | Target Artifact | Imported Title | Timestamp |
|-------------|-----------|-----------------|----------------|-----------|
| {source_path} | {line_range} | {target} | {title} | {ISO 8601} |
```

If the manifest does not exist, create it with the table header. If it exists, append new rows.

### Step 8: Generate Report

Create `docs/align-report.md` with the following sections:

- **Run metadata:** Timestamp, exclusion patterns applied, total files scanned, total discoveries
- **Imported items by artifact:** Grouped by target (BACKLOG, VISION, CUSTOMER), showing source path, imported title, and detection method
- **Skipped items:** Items found in the manifest from prior runs (already imported), with source path and original import date
- **Unmatched exclusions:** Files/directories that were excluded from scanning
- **Remaining unmanaged content:** Content detected but below confidence thresholds or ambiguous, with source path and snippet for manual review

### Step 9: Present Summary

Show the run summary inline as a markdown table:

```markdown
| Metric | Count |
|--------|-------|
| Files scanned | {N} |
| Items imported | {N} |
| Items skipped (manifest) | {N} |
| Items left behind | {N} |
| Files deleted | {N} |
| Sections trimmed | {N} |
```

Highlight key outcomes: new imports per artifact, skipped items, and remaining unmanaged content.

### Step 10: Offer Next Steps

```
AskUserQuestion({
  questions: [{
    question: "Alignment complete. What would you like to do next?",
    header: "Next",
    options: [
      { label: "Run again", description: "Re-scan after manual changes to find remaining content" },
      { label: "Review health", description: "Run /arc-review to audit the consolidated backlog" },
      { label: "Shape ideas", description: "Run /arc-shape to refine imported captured stubs" },
      { label: "Done", description: "Finish the alignment session" }
    ],
    multiSelect: false
  }]
})
```

**Handle selection:**
- **Run again:** Loop back to Step 1 (full re-scan with manifest deduplication)
- **Review health:** Inform the user to run `/arc-review`
- **Shape ideas:** Inform the user to run `/arc-shape`
- **Done:** Summarize total items imported, files cleaned, and exit

## References

- `skills/arc-align/references/detection-patterns.md` -- All keyword and structural detection patterns with examples
- `skills/arc-align/references/import-rules.md` -- Artifact classification rules, stub generation logic, and cleanup behavior
- `references/idea-lifecycle.md` -- Capture stage definition, entry/exit criteria
- `references/brief-format.md` -- Brief format for shaped ideas
- `templates/BACKLOG.tmpl.md` -- Template for creating BACKLOG.md if absent
- `templates/VISION.tmpl.md` -- Template for creating VISION.md if absent
- `templates/CUSTOMER.tmpl.md` -- Template for creating CUSTOMER.md if absent
