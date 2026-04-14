# 11-spec-shape-skill-discovery

## Introduction/Overview

Enrich `/arc-shape`'s feasibility analysis with live skill discovery from the `/skillz-find` marketplace search. When shaping an idea, the feasibility subagent will invoke `/skillz-find` with a query derived from the idea's problem domain and project context, then surface discovered skills in the synthesis table so the user can account for available tooling before the brief enters `/cw-spec`.

## Goals

1. Add a skill discovery step to the feasibility subagent that runs `/skillz-find` live during `/arc-shape`'s parallel analysis
2. Derive a search query automatically from the idea's title, summary, and project context (tech stack, CLAUDE.md)
3. Append a "Relevant Skills" subsection to the feasibility assessment output with skill names, relevance rationale, and install recommendations
4. Surface skill discovery results in the Step 3 synthesis table as a visible dimension alongside problem clarity, customer fit, scope, and feasibility
5. Degrade gracefully when `/skillz` is not installed — warn the user and continue shaping without skill discovery

## User Stories

- As a product owner shaping an idea, I want to know if relevant skills already exist in the skills.sh marketplace so that the shaped brief accounts for available tooling and avoids proposing redundant solutions.
- As a developer reviewing a shaped brief, I want to see which marketplace skills were considered during shaping so that I can install them before starting implementation.
- As a user without the skillz plugin installed, I want `/arc-shape` to warn me that skill discovery was skipped and continue shaping normally so that my workflow is not blocked.

## Demoable Units of Work

### Unit 1: Feasibility Subagent Skill Discovery

**Purpose:** Modify the feasibility subagent prompt in `skills/arc-shape/SKILL.md` to invoke `/skillz-find` and include discovered skills in the feasibility assessment output.

**Functional Requirements:**

- The system shall add a skill discovery section to the feasibility subagent prompt in `skills/arc-shape/SKILL.md` Step 2
- The feasibility subagent shall derive a search query by extracting 2-4 keyword phrases from the idea's title and one-line summary, then combining them with project context signals (tech stack from `package.json`/`pyproject.toml`/etc., CLAUDE.md references)
- The feasibility subagent shall spawn a sub-Agent that invokes `/skillz-find` with the derived query
- The feasibility subagent shall parse the `/skillz-find` scan report output and extract: skill names, weekly install counts, security status, and per-skill recommendations (install/investigate/avoid)
- The feasibility subagent shall append a `#### Relevant Skills` subsection to its output with a table of discovered skills and a 1-2 sentence summary of how each relates to the idea being shaped
- If `/skillz-find` returns zero results, the subsection shall state "No relevant skills found on skills.sh for this problem domain"

**Proof Artifacts:**

- File: `skills/arc-shape/SKILL.md` contains updated feasibility subagent prompt with `/skillz-find` invocation
- File: `skills/arc-shape/references/shaping-dimensions.md` contains updated Dimension 4 output format with `#### Relevant Skills` subsection

### Unit 2: Graceful Fallback When Skillz Is Not Installed

**Purpose:** Ensure `/arc-shape` remains fully functional when the skillz plugin is not installed by detecting its absence and warning the user.

**Functional Requirements:**

- The feasibility subagent shall attempt to invoke `/skillz-find` via a sub-Agent and detect failure (skill not found, tool not available, or timeout)
- When `/skillz-find` is not available, the feasibility subagent shall include a notice in its output: "Skill discovery skipped — `/skillz` plugin not installed. Install with: `claude plugin install skillz@skillz`"
- The fallback shall not add latency to the shaping process — the feasibility subagent shall proceed with its standard analysis (Temper phase, technical risk, pattern fit) without waiting for a skill discovery timeout
- The feasibility assessment output format shall be identical with or without skill discovery, except for the presence or absence of the `#### Relevant Skills` subsection
- No changes to `arc-shape`'s `allowed-tools` frontmatter are required — skill discovery runs inside a sub-Agent which has its own tool permissions

**Proof Artifacts:**

- File: `skills/arc-shape/SKILL.md` contains fallback logic in the feasibility subagent prompt
- CLI: Running `/arc-shape` without skillz installed produces a feasibility assessment with the "Skill discovery skipped" notice and no errors

### Unit 3: Synthesis Table Integration

**Purpose:** Surface skill discovery results in `/arc-shape`'s Step 3 synthesis so the user sees available tooling context before the brief is finalized.

**Functional Requirements:**

- The Step 3 synthesis in `skills/arc-shape/SKILL.md` shall include a "Skill Discovery" row in the dimension ratings table with columns: Dimension, Rating, Key Finding
- The rating for the Skill Discovery row shall be one of: "Skills found" (1+ relevant skills discovered), "No skills" (search returned zero results), or "Skipped" (skillz not installed)
- The key finding shall summarize the top 1-2 most relevant skills by name and recommendation, or state the skip reason
- The synthesis shall include a `### Relevant Skills` section below the dimension ratings table listing each discovered skill with: name, author, install count, recommendation (install/investigate/avoid), and relevance to the idea
- When skill discovery was skipped or returned no results, the `### Relevant Skills` section shall display the appropriate message and not show an empty table

**Proof Artifacts:**

- File: `skills/arc-shape/SKILL.md` contains updated Step 3 synthesis with Skill Discovery row and Relevant Skills section
- File: `skills/arc-shape/references/shaping-dimensions.md` contains updated Aggregation section referencing the new dimension

## Non-Goals (Out of Scope)

- Automatic installation of discovered skills — `/skillz-install` handles that separately
- Modifying the shaped brief's Constraints or Assumptions sections based on discovered skills — results are informational in the feasibility output only
- Caching or persisting skill discovery results across shaping sessions — each invocation runs a fresh search
- Adding skill discovery as a 5th parallel subagent — it runs inside the existing feasibility subagent to avoid adding a new dimension
- Modifying `/skillz-find` itself — this spec only changes `/arc-shape`'s consumption of it

## Design Considerations

No specific design requirements identified. The changes are to SKILL.md prompt text and reference documentation, not to UI components.

## Repository Standards

- SKILL.md files follow the existing frontmatter + markdown structure in `skills/arc-shape/`
- Reference docs follow the existing format in `skills/arc-shape/references/`
- Conventional commits: `feat(arc-shape): description`
- All changes are markdown — no code files to lint or test

## Technical Considerations

- `/skillz-find` requires `WebFetch` and `Bash` (for `gh api`) tools, which are available inside Agent subagents but not in `/arc-shape`'s own `allowed-tools`. The feasibility subagent already runs as an Agent, so tool access is inherited from the Agent context, not from arc-shape's frontmatter.
- The `/skillz-find` skill produces a scan report at `docs/skill/skillz/scan-report.md`. The feasibility subagent can either parse the report file or consume the Agent's text output directly. Consuming Agent output is preferred to avoid a file-system side effect during shaping.
- Query derivation combines idea-specific keywords with project context. The feasibility subagent already reads project context files (CLAUDE.md, ROADMAP.md, management-report.md), so adding tech stack detection (package.json, pyproject.toml) is additive, not a new pattern.
- `/skillz-find` searches skills.sh via WebFetch and GitHub via `gh api`. Network failures should be handled gracefully — treat them the same as "skillz not installed" (warn and continue).

## Security Considerations

- No API keys or tokens are introduced. `/skillz-find` uses the user's existing `gh` authentication.
- Skill discovery results are informational only — no automatic installation or CLAUDE.md modification occurs.
- The scan report produced by `/skillz-find` includes security audit data from skills.sh (Gen Agent Trust Hub, Socket, Snyk status). This data is displayed but not acted upon by `/arc-shape`.

## Success Metrics

- `/arc-shape` feasibility output includes a `#### Relevant Skills` subsection when skillz is installed
- The Step 3 synthesis table includes a "Skill Discovery" row with appropriate rating
- When skillz is not installed, `/arc-shape` completes normally with a "skipped" notice
- No increase in `/arc-shape`'s `allowed-tools` frontmatter — skill discovery runs entirely within the Agent subagent

## Open Questions

- No open questions at this time.
