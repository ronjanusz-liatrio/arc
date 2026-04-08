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

Scan all non-excluded files using two detection strategies in sequence. Read `skills/arc-align/references/detection-patterns.md` for the full pattern reference.

**Detection ordering rationale:** Keyword matching runs first because it uses Grep and completes quickly across the entire non-excluded file set. Structural matching runs second on files not already flagged by keyword matching, since it requires line-by-line parsing with Read and is slower. A file matched by keyword scan is not re-scanned for structural patterns.

**2a. Keyword matching (Grep-based, fast):**

Run one Grep call per keyword against all non-excluded files. Use case-insensitive matching. For each keyword, build Grep glob exclusions from the merged exclusion set (Step 1e).

**Keywords to scan (17 total):**

| # | Search Term | Typical Target |
|---|-------------|----------------|
| KW-1 | `roadmap` | BACKLOG |
| KW-2 | `backlog` | BACKLOG |
| KW-3 | `todo` | BACKLOG |
| KW-4 | `planned` | BACKLOG |
| KW-5 | `upcoming` | BACKLOG |
| KW-6 | `feature list` | BACKLOG |
| KW-7 | `future work` | BACKLOG |
| KW-8 | `next steps` | BACKLOG |
| KW-9 | `milestone` | BACKLOG |
| KW-10 | `sprint` | BACKLOG |
| KW-11 | `epic` | BACKLOG |
| KW-12 | `user story` | BACKLOG |
| KW-13 | `persona` | CUSTOMER |
| KW-14 | `target audience` | CUSTOMER |
| KW-15 | `mission` | VISION |
| KW-16 | `vision` | VISION |
| KW-17 | `north star` | VISION |

**Procedure for each keyword:**

1. Run Grep with `output_mode: "content"`, `-i: true`, and context lines (`-C: 3`) to capture surrounding content:

   ```
   Grep({
     pattern: "{keyword}",
     "-i": true,
     output_mode: "content",
     "-C": 3,
     "-n": true,
     glob: "*.md"
   })
   ```

   For multi-word keywords (`feature list`, `future work`, `next steps`, `user story`, `target audience`, `north star`), use the exact phrase as the pattern.

2. Filter results against the exclusion set -- discard any matches in excluded paths.

3. For each match, record a **keyword discovery entry**:
   - **Source file path:** The file containing the match (relative to repo root)
   - **Line range:** The matched line number plus context lines (e.g., if match is on line 15 with `-C: 3`, record lines 12-18). Expand to section boundaries (next heading or blank-line block) for more complete extraction.
   - **Matched content snippet:** The matched line plus context lines returned by Grep (truncate to 200 characters for the discovery list display)
   - **Detection method:** `keyword`
   - **Matched keyword:** The specific keyword that triggered the match (e.g., `roadmap`)

4. Deduplicate: If the same file is matched by multiple keywords, merge the entries into a single discovery per section. Use heading boundaries (`##` or `###`) to determine section scope -- if two keyword matches fall within the same heading section, combine them into one discovery covering the full section.

5. Track all files that received at least one keyword match in a `keyword_matched_files` set. These files are excluded from the structural scan in Step 2b.

**2b. Structural matching (Read-based, line-by-line):**

After keyword scanning completes, identify files to structurally scan:

1. Use Glob to list all markdown files: `Glob({ pattern: "**/*.md" })`
2. Remove files in the exclusion set (Step 1e)
3. Remove files already in the `keyword_matched_files` set (Step 2a)
4. The remaining files are the structural scan candidates

For each candidate file, Read the full file content and parse line-by-line for four structural patterns:

**ST-1: Markdown Task Lists**

Detect lines matching `- [ ]` or `- [x]` (markdown checkbox syntax).

- Scan for consecutive task list lines (lines matching `^\s*- \[([ x])\] .+`)
- Flag sections with 2 or more consecutive task list items
- Record the full block of consecutive task items as one discovery
- **Line range:** First task item line through last consecutive task item line
- **Content snippet:** All task items in the block (truncate to 200 characters)
- **Detection method:** `structural`

**ST-2: Numbered Feature Lists**

Detect sequential numbered items starting from 1.

- Scan for runs of 3+ consecutive lines matching `^\d+\.\s+.+` where the numbers increment sequentially (1, 2, 3, ...)
- Non-sequential numbering (e.g., 1, 3, 5) or fewer than 3 items are not flagged
- **Line range:** First numbered item through last in the sequential run
- **Content snippet:** All items in the run (truncate to 200 characters)
- **Detection method:** `structural`

**ST-3: Heading Patterns**

Detect level-2 headings indicating product-direction sections (case-insensitive):

- `## Roadmap`
- `## TODO`
- `## Planned Features`
- `## Backlog`

When a matching heading is found:
- **Line range:** From the heading line to the line before the next heading of the same or higher level (`##` or `#`), or end of file
- **Content snippet:** The heading plus the first 200 characters of the section body
- **Detection method:** `structural`

**ST-4: Kanban-Style Markers**

Detect level-3 headings matching (case-insensitive):

- `### To Do`
- `### In Progress`
- `### Done`

Detection requires at least 2 of these 3 headings present in the same file to confirm kanban structure.

When confirmed:
- **Line range:** From the first kanban heading through the content under the last kanban heading (to the next non-kanban heading of the same or higher level, or end of file)
- **Content snippet:** All kanban headings and the first 200 characters of their combined content
- **Detection method:** `structural`

**Structural scan output:**

Collect all structural discoveries into the same list as keyword discoveries. Each entry follows the same format: source file path, line range, content snippet, detection method, and matched pattern identifier (ST-1 through ST-4).

**2c. Classify discoveries:**

For each discovery (from both 2a and 2b), classify into one of three artifact targets. Read `skills/arc-align/references/import-rules.md` for the full classification rules.

| Target | Content Type | Classification Signals |
|--------|-------------|----------------------|
| `BACKLOG` | Actionable items: TODOs, features, bugs, ideas, task lists, roadmap items | KW-1 through KW-12, ST-1 through ST-4 |
| `VISION` | Mission/vision/north-star content | KW-15 (`mission`), KW-16 (`vision`), KW-17 (`north star`) |
| `CUSTOMER` | Persona/audience/JTBD content | KW-13 (`persona`), KW-14 (`target audience`) |

When a discovery's keyword or structural pattern does not map cleanly to a single target (e.g., a roadmap section containing a vision statement), split into separate discoveries per the ambiguity rules in `import-rules.md`.

**2d. Check manifest for prior imports:**

Read `docs/align-manifest.md` (if present). Parse the manifest table and build a set of `{source_path}:{line_range}` keys. For each discovery, check if its source location matches an existing manifest entry. If it matches:
- Remove the discovery from the import list
- Add it to the skipped-items list with the original import timestamp from the manifest

**2e. Build discovery list:**

Assemble the final discovery list with one entry per discovery:

| Field | Description |
|-------|-------------|
| Source file path | Relative path from repo root |
| Line range | Start line through end line (e.g., `20-35`) |
| Matched content snippet | First 200 characters of the matched section |
| Detection method | `keyword` or `structural` |
| Pattern identifier | The specific keyword (KW-1 through KW-17) or structural pattern (ST-1 through ST-4) that triggered the match |
| Target artifact | `BACKLOG`, `VISION`, or `CUSTOMER` (from Step 2c) |

Sort the discovery list by source file path, then by line range (ascending). This ordering groups discoveries from the same file together for easier user review in Step 3.

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
