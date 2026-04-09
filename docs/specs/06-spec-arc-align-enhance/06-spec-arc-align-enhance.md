# 06-spec-arc-align-enhance

## Introduction/Overview

Enhance `/arc-align` with five new capabilities: a cw-research subagent pre-scan for deep codebase exploration, spec-directory scanning to extract product-direction content from existing specifications, source-code comment scanning for TODO/FIXME/HACK/XXX markers, an analysis artifact that synthesizes all findings into gap analysis and recommendations before prompting the user for import confirmation, and relocation of all Arc operational artifacts (reports, manifests, analysis) from `docs/` to `docs/skill/arc/` to separate Arc's internal files from the repo's product-direction artifacts.

## Goals

1. Invoke `/cw-research` as a subagent before the main scan to produce a structured research report that informs the analysis phase
2. Scan `docs/specs/` for product-direction content embedded in existing specifications — extracting goals to VISION, user stories to BACKLOG, non-goals and open questions to BACKLOG as future ideas, and persona references to CUSTOMER
3. Scan source code files for TODO, FIXME, HACK, and XXX comment markers and import them as BACKLOG captured stubs
4. Generate `docs/skill/arc/align-analysis.md` after discovery but before the import prompt, containing structured findings, gap analysis, and recommendations based on what the codebase has and what it lacks
5. Relocate all Arc operational artifacts (reports, manifests, analysis) from `docs/` to `docs/skill/arc/`, keeping product-direction artifacts (BACKLOG, VISION, CUSTOMER, ROADMAP) at `docs/` — this separation applies across all Arc skills, not just arc-align

## User Stories

- As a product owner adopting Arc on a mature repo with existing specs, I want arc-align to extract product-direction content from those specs so I don't manually re-enter goals and user stories into Arc artifacts.
- As a developer with scattered TODO/FIXME comments in source code, I want arc-align to consolidate those into BACKLOG stubs so they enter the idea lifecycle alongside markdown-based discoveries.
- As a team lead running arc-align for the first time, I want to see an analysis of what the codebase has vs. what it lacks (e.g., "no vision statement found", "3 specs share a common theme") so I can make informed decisions about what to import and what to create manually.
- As a developer on an unfamiliar codebase, I want arc-align to leverage cw-research's deep exploration so the analysis is grounded in architecture and conventions, not just keyword matches.
- As a repo maintainer, I want Arc's internal reports and manifests stored separately from my product-direction artifacts so that `docs/` isn't cluttered with operational files that only Arc reads.

## Demoable Units of Work

### Unit 1: cw-research Subagent Integration

**Purpose:** Add an optional pre-scan step that invokes `/cw-research` as a subagent to perform deep codebase exploration, producing a research report that feeds the analysis phase.

**Functional Requirements:**

- The system shall add a new Step 0 ("Research Phase") to the arc-align process, executed before the existing Step 1 (Configure Exclusions)
- The system shall prompt the user via AskUserQuestion whether to run the research phase, with options: "Run deep scan (Recommended)" (invokes cw-research), "Quick scan only" (skip research, proceed with existing behavior), and "Use existing report" (if a prior research report exists)
- When the user selects "Run deep scan," the system shall invoke cw-research as a subagent using the Agent tool with `subagent_type: "general-purpose"`, passing a prompt that instructs it to run `/cw-research` focused on product-direction discovery — architecture, conventions, dependencies, and any product/planning content found in code, config, and documentation
- The research report shall be saved to `docs/specs/research-align/research-align.md` following cw-research's standard output format
- When the user selects "Use existing report," the system shall read the existing research report from `docs/specs/research-align/research-align.md` and use its findings in the analysis phase (Unit 4)
- The research report findings shall be passed forward as structured context to the analysis phase (Unit 4), specifically: detected project type, architecture patterns, key dependencies, and any product-direction content noted by cw-research
- The system shall update the SKILL.md `allowed-tools` frontmatter to include `Agent` (required for subagent invocation)

**Proof Artifacts:**

- CLI: Running `/arc-align` presents the research phase prompt as the first interaction
- File: `docs/specs/research-align/research-align.md` exists after selecting "Run deep scan"
- File: Research findings are referenced in `docs/skill/arc/align-analysis.md` (Unit 4 output)

### Unit 2: Spec Directory Scanning

**Purpose:** Remove `docs/specs/` from the hardcoded exclusion list and add spec-specific detection patterns that extract product-direction content from existing specifications into the appropriate Arc artifacts.

**Functional Requirements:**

- The system shall remove `docs/specs/` from the hardcoded exclusion list in Step 1a of the SKILL.md, allowing spec files to be scanned
- The system shall add the following hardcoded exclusions to replace the blanket `docs/specs/` exclusion: `docs/specs/*/proofs/` (proof artifact directories), `docs/specs/*/*.feature` (Gherkin files), and `docs/specs/*/questions-*.md` (question files) — these contain implementation artifacts, not product-direction content
- The system shall add new keyword patterns for spec content detection:
  - KW-18: `## Goals` — extract goal statements as VISION content
  - KW-19: `## User Stories` — extract user stories as BACKLOG items (one stub per story)
  - KW-20: `## Non-Goals` — extract non-goals as BACKLOG items with a `(deferred)` prefix in the title, signaling they were explicitly scoped out but may be future work
  - KW-21: `## Open Questions` — extract open questions as BACKLOG items with a `(open question)` prefix in the title
  - KW-22: `## Introduction/Overview` — extract overview content as VISION if it contains mission/direction language
- The system shall apply spec-specific classification rules in `import-rules.md`:
  - Goals sections → VISION (the goals describe what the product aims to achieve)
  - User stories → BACKLOG (each `As a...` story becomes one captured stub)
  - Non-goals → BACKLOG with `(deferred)` title prefix and P3-Low default priority
  - Open questions → BACKLOG with `(open question)` title prefix and P2-Medium default priority
  - Overview sections → VISION only if they contain declarative product-direction language (not just feature descriptions)
  - Persona references in user stories → CUSTOMER (extract the persona role when a consistent persona pattern appears across multiple stories)
- The system shall add a `<!-- aligned-from-spec: {spec_name} -->` comment (in addition to the standard `<!-- aligned-from: ... -->`) on stubs imported from specs, enabling traceability back to the originating specification
- The system shall update `detection-patterns.md` with the new KW-18 through KW-22 patterns, including examples from actual spec format

**Proof Artifacts:**

- File: `docs/BACKLOG.md` contains stubs imported from specs with `<!-- aligned-from-spec: ... -->` markers
- File: `docs/VISION.md` contains content extracted from spec goals sections
- File: `detection-patterns.md` documents KW-18 through KW-22 patterns
- File: `import-rules.md` documents spec-specific classification rules

### Unit 3: Source Code Comment Scanning

**Purpose:** Add a third detection strategy that scans source code files for TODO, FIXME, HACK, and XXX comment markers, importing them as BACKLOG captured stubs.

**Functional Requirements:**

- The system shall add a new detection phase (Step 2c in the process, after keyword and structural matching) called "Code comment scanning"
- The system shall scan source code files with extensions: `.py`, `.ts`, `.tsx`, `.js`, `.jsx`, `.go`, `.rs`, `.java`, `.kt`, `.rb`, `.sh`, `.bash`, `.zsh`, `.swift`, `.c`, `.cpp`, `.h`, `.hpp`, `.cs`
- The system shall search for the following comment markers using Grep with case-insensitive matching:
  - CC-1: `TODO` — actionable work items left in code
  - CC-2: `FIXME` — known bugs or issues requiring attention
  - CC-3: `HACK` — temporary workarounds that need proper solutions
  - CC-4: `XXX` — areas requiring attention or review
- The system shall extract the comment text following the marker (e.g., `// TODO: refactor this module` → title: "Refactor this module", summary: "Code comment from {file}:{line}")
- The system shall strip common comment prefixes (`//`, `#`, `/*`, `*`, `--`, `"""`, `'''`) from the extracted text
- The system shall classify all code comment discoveries as BACKLOG targets
- The system shall assign priorities based on marker type: FIXME → P1-High (known bugs), TODO → P2-Medium (standard), HACK → P1-High (technical debt requiring attention), XXX → P2-Medium (needs review)
- The system shall add a `<!-- aligned-from-code: {file}:{line} -->` comment on stubs imported from code comments, distinguishing them from markdown-sourced imports
- The system shall deduplicate code comment discoveries: if the same TODO text appears in multiple files (e.g., copy-pasted boilerplate), import only one stub and note the additional locations in the summary
- The system shall respect the existing exclusion set — code files inside excluded directories (node_modules, vendor, dist, build) are not scanned
- The system shall update `detection-patterns.md` with CC-1 through CC-4 pattern definitions and examples

**Proof Artifacts:**

- File: `docs/BACKLOG.md` contains stubs from code comments with `<!-- aligned-from-code: ... -->` markers
- CLI: Running `/arc-align` on a repo with TODO comments in `.py` files produces discoveries in the discovery list
- File: `detection-patterns.md` documents CC-1 through CC-4 patterns

### Unit 4: Analysis Artifact Generation

**Purpose:** After all discovery phases complete but before the import confirmation prompt, synthesize findings into a structured analysis artifact with gap analysis and recommendations.

**Functional Requirements:**

- The system shall add a new Step 2.5 ("Analysis Phase") between the current Step 2 (Discover) and Step 3 (Confirm Import) in the SKILL.md process
- The system shall generate `docs/skill/arc/align-analysis.md` containing the following sections:
  - **Discovery Summary:** Count of discoveries by source type (markdown keywords, markdown structural, spec extraction, code comments) and by target artifact (BACKLOG, VISION, CUSTOMER)
  - **Gap Analysis:** Identify what the codebase has vs. what it lacks across Arc's four artifact types:
    - VISION: Does the repo have any mission/vision/north-star content? If not, flag as a gap.
    - CUSTOMER: Does the repo have persona or audience definitions? If not, flag as a gap.
    - ROADMAP: Does the repo have phased planning content? (Note: arc-align doesn't manage ROADMAP directly, but can flag its absence)
    - BACKLOG: How many actionable items were discovered? Are they concentrated in a few files or scattered?
  - **Theme Analysis:** Group related discoveries by topic similarity (e.g., "3 specs and 5 TODOs relate to authentication") and suggest potential wave groupings
  - **Recommendations:** Ordered list of suggested next actions based on findings, such as:
    - "Create a VISION artifact — no vision/mission content was found anywhere in the codebase"
    - "These 12 TODO comments in src/auth/ suggest an authentication overhaul — consider shaping this as a single initiative"
    - "Spec 02 and spec 03 share overlapping user stories — review for deduplication after import"
  - **Research Integration:** If a cw-research report exists (from Unit 1), incorporate its findings:
    - Cross-reference research-detected architecture patterns with discovered product-direction content
    - Flag architectural areas with no corresponding product-direction coverage
    - Note any discrepancies between research findings and discovered content
- The system shall use the cw-research report (if available) to enrich the analysis — specifically, the project type, architecture patterns, and key dependencies inform the theme analysis and recommendations
- The system shall present a condensed inline summary of the analysis before the import prompt, including the top 3 recommendations and the gap analysis results
- The system shall include a Mermaid diagram in the analysis artifact showing the distribution of discoveries by source type and target artifact, using Liatrio brand colors

**Proof Artifacts:**

- File: `docs/skill/arc/align-analysis.md` exists after running `/arc-align` with all required sections populated
- CLI: Inline summary before the import prompt shows gap analysis and top recommendations
- File: Analysis references cw-research report findings when available

### Unit 5: Operational Artifact Path Restructuring

**Purpose:** Relocate all Arc-generated operational artifacts (reports, manifests, analysis) from `docs/` to `docs/skill/arc/`, separating Arc's internal files from the repo's product-direction artifacts (BACKLOG, VISION, CUSTOMER, ROADMAP).

**Functional Requirements:**

- The system shall write all Arc operational artifacts to `docs/skill/arc/` instead of `docs/`:
  - `docs/skill/arc/align-report.md` (was `docs/align-report.md`)
  - `docs/skill/arc/align-manifest.md` (was `docs/align-manifest.md`)
  - `docs/skill/arc/align-analysis.md` (was `docs/align-analysis.md` — new in this spec)
  - `docs/skill/arc/wave-report.md` (was `docs/wave-report.md`)
  - `docs/skill/arc/review-report.md` (was `docs/review-report.md`)
  - `docs/skill/arc/shape-report.md` (was `docs/shape-report.md`)
- The system shall keep product-direction artifacts at their current paths:
  - `docs/BACKLOG.md` — unchanged
  - `docs/VISION.md` — unchanged
  - `docs/CUSTOMER.md` — unchanged
  - `docs/ROADMAP.md` — unchanged
- The system shall update the hardcoded exclusion list in arc-align's Step 1a to reference the new `docs/skill/arc/` paths for Arc-managed operational files
- The system shall update all SKILL.md files across all Arc skills (`arc-align`, `arc-capture`, `arc-shape`, `arc-wave`, `arc-review`, `arc-readme`) to reference the new `docs/skill/arc/` paths wherever they read or write operational artifacts
- The system shall update all reference documents that mention operational artifact paths:
  - `skills/arc-align/references/align-report-template.md` — update output path
  - `skills/arc-align/references/import-rules.md` — update manifest path references
  - `skills/arc-review/references/review-report-template.md` — update output path
  - `skills/arc-review/references/audit-dimensions.md` — update any report path references
  - `skills/arc-wave/references/wave-report-template.md` — update output path
- The system shall update `README.md` to reflect the new path structure in the plugin structure tree and any path references
- The system shall create the `docs/skill/arc/` directory as part of artifact bootstrap (same pattern as `docs/` directory creation in the current Step 4)
- The system shall handle migration gracefully: if old-path artifacts exist (e.g., `docs/align-manifest.md` from a prior run), arc-align shall read from the old path, copy content to the new path, and inform the user that the old file can be deleted

**Proof Artifacts:**

- File: `docs/skill/arc/align-report.md` is created at the new path after an arc-align run
- File: `docs/skill/arc/align-manifest.md` is created at the new path after an arc-align run
- CLI: `docs/BACKLOG.md` remains at its current path — product artifacts are unaffected
- File: All SKILL.md files reference `docs/skill/arc/` for operational artifacts
- File: README.md plugin structure tree shows the `docs/skill/arc/` path

## Non-Goals (Out of Scope)

- **Automatic spec deduplication** — the analysis flags overlapping specs but does not merge or deduplicate them
- **ROADMAP artifact population** — the analysis flags ROADMAP gaps but arc-align does not create or populate `docs/ROADMAP.md` (that's `/arc-wave`'s responsibility)
- **Code refactoring suggestions** — code comment scanning extracts TODOs but does not suggest code changes
- **Modifying existing specs** — spec scanning is read-only; original specs are never modified or deleted (they are reference documents, not scattered content to be cleaned up)
- **Automatic wave assignment** — theme analysis suggests wave groupings but does not assign items to waves
- **Interactive research configuration** — the cw-research subagent runs with a standard prompt; custom research dimensions are not configurable

## Design Considerations

- The analysis artifact should be scannable — use tables and bullet points, not prose paragraphs
- The inline summary before the import prompt should be concise (under 20 lines) — the full analysis is in the artifact
- Code comment discoveries should be visually distinguishable in the discovery list (e.g., prefixed with a code file icon or `[code]` tag)
- Spec-sourced discoveries should similarly be tagged as `[spec]` in the discovery list to distinguish from organic markdown discoveries

## Repository Standards

- SKILL.md modifications: add new steps while preserving existing step numbering (use 0 for research, 2.5 for analysis, 2c for code comments)
- Reference doc updates: append new patterns to existing detection-patterns.md and import-rules.md rather than creating new files
- Conventional commits: `feat(arc-align): ...` for behavior changes, `docs(arc-align): ...` for reference doc updates
- New comments follow existing patterns: `<!-- aligned-from-spec: ... -->` and `<!-- aligned-from-code: ... -->` mirror `<!-- aligned-from: ... -->`

## Technical Considerations

- **Spec scanning exclusions:** Proof directories, feature files, and question files are excluded because they contain implementation artifacts, not product-direction content. Only spec markdown files (`*-spec-*.md`) and research reports are scanned.
- **Code comment deduplication:** Identical TODO text across files suggests boilerplate or copy-paste — deduplicate to prevent BACKLOG noise. Use exact text matching after stripping comment syntax and whitespace.
- **Research subagent cost:** The cw-research subagent invocation adds wall-clock time. Making it optional (with "Quick scan only" as an alternative) keeps the fast-path available for users who want lightweight alignment.
- **Analysis artifact idempotency:** `docs/skill/arc/align-analysis.md` is overwritten on every run (not appended to). It reflects the current state, not a history. The align-report.md (at `docs/skill/arc/`) continues to serve the history/audit role.
- **Source code file extensions:** The extension list covers the most common languages. Users can add additional extensions via the custom exclusion patterns (inverted — they'd need to modify detection-patterns.md for new extensions, which is documented as a limitation).
- **Step numbering:** Using 0 and 2.5 avoids renumbering all existing steps, which would invalidate cross-references in reference docs and the existing spec (03-spec-arc-align).
- **Path restructuring scope:** The `docs/skill/arc/` relocation is cross-cutting — it touches every Arc skill's SKILL.md, the hardcoded exclusion list, reference docs, and the README. Implementing it as part of this spec (rather than a separate spec) avoids a mid-flight migration where some skills write to old paths and others to new paths.
- **Migration from old paths:** Old-path artifacts from prior runs are read (for manifest continuity) then written to the new location. The old files are not deleted automatically — the user is informed and can clean up manually. This preserves the non-destructive principle.

## Security Considerations

- Code comment scanning reads source files but never modifies them — read-only access
- The cw-research subagent has its own security constraints (no credentials in reports, no external network access beyond what cw-research already permits)
- Code comments may contain sensitive context (e.g., `// TODO: rotate the API key for prod`) — the analysis artifact should redact any content matching common secret patterns (API keys, tokens, passwords) before writing to disk
- The `<!-- aligned-from-code: ... -->` markers expose source file paths and line numbers in BACKLOG.md — same visibility concern as existing `<!-- aligned-from: ... -->` markers, acceptable for internal repos

## Success Metrics

- Running `/arc-align` on a repo with 3+ existing specs extracts at least one item per spec into Arc artifacts
- Running `/arc-align` on a repo with TODO/FIXME comments in source code produces corresponding BACKLOG stubs
- The analysis artifact correctly identifies gaps (e.g., no VISION content) when those artifacts don't exist
- The cw-research integration enriches the analysis with architecture context not available from keyword/structural scanning alone
- Re-running `/arc-align` after import produces zero new imports from previously scanned specs and code comments (idempotent via manifest)
- The analysis artifact is generated in under 10 seconds (excluding cw-research subagent time)

## Open Questions

- No open questions at this time.
