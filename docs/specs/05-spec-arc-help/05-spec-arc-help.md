# 05-spec-arc-help

## Introduction/Overview

Arc-help is a new skill (`/arc-help`) that provides a comprehensive, self-contained guide to the Arc plugin. It explains what Arc is, lists all skills with descriptions and workflow order, describes the managed artifacts, provides installation instructions, and links to the full README. The content is static within the SKILL.md — no dynamic file reads required.

## Goals

1. Give users a single command (`/arc-help`) to understand what Arc does and how to use it
2. Cover all six existing skills with descriptions and recommended workflow order
3. Describe the four managed artifacts (VISION, CUSTOMER, ROADMAP, BACKLOG)
4. Include installation instructions for Arc and its companion plugins
5. Link to the full README for detailed documentation

## User Stories

- As a new Arc user, I want to run `/arc-help` so that I can quickly understand what skills are available and how they fit together
- As an existing Arc user, I want a quick reference so that I can recall the workflow order and artifact purposes without leaving the terminal
- As a user installing Arc for the first time, I want to see install instructions so that I can set up Arc and its companion plugins correctly

## Demoable Units of Work

### Unit 1: SKILL.md with Static Help Content

**Purpose:** Create the arc-help skill definition with all help content baked into the SKILL.md prompt, following the established skill conventions.

**Functional Requirements:**
- The system shall create `skills/arc-help/SKILL.md` with standard frontmatter (`name`, `description`, `user-invocable: true`, `allowed-tools`)
- The SKILL.md shall include a Context Marker section instructing the agent to begin with `**ARC-HELP**`
- The help content shall include an overview section explaining what Arc is and its relationship to temper and claude-workflow
- The help content shall include a skill table listing all seven skills (including arc-help itself) with name, one-line description, and invocation syntax
- The help content shall include a workflow section showing the recommended skill execution order (`/arc-align → /arc-capture → /arc-shape → /arc-wave → /arc-readme`, with `/arc-review` as an anytime audit)
- The help content shall include an artifacts section describing VISION, CUSTOMER, ROADMAP, and BACKLOG with their purposes and file paths
- The help content shall include an installation section with commands for Arc, temper, and claude-workflow
- The help content shall include a link to the project README for full documentation
- The skill shall accept no arguments — it always outputs the full guide
- The allowed-tools list shall be minimal (only `Read` if needed for future extensibility, or empty if purely static output)

**Proof Artifacts:**
- File: `skills/arc-help/SKILL.md` exists with valid frontmatter and all required content sections
- CLI: `/arc-help` invocation produces output beginning with `**ARC-HELP**` followed by the comprehensive guide

### Unit 2: Plugin Registration and Skill Index Update

**Purpose:** Register arc-help in the skill index and verify it appears in the plugin's skill listing.

**Functional Requirements:**
- The system shall add an arc-help row to the skill table in `skills/README.md` with description and invocation syntax
- The arc-help entry shall be positioned logically in the table (after arc-review, as a meta/utility skill)
- The workflow section in `skills/README.md` shall note `/arc-help` as available at any time (similar to `/arc-review`)
- The README.md skill table and Plugin Structure tree shall include arc-help

**Proof Artifacts:**
- File: `skills/README.md` contains an arc-help row in the skill table
- File: `README.md` lists arc-help in both the skill table and the Plugin Structure tree

## Non-Goals (Out of Scope)

- Dynamic content that reads from README.md or other files at runtime
- Argument parsing or per-skill detail views
- Interactive menus or topic selection
- Versioned help output tied to plugin.json version
- Modifying any existing skill's behavior or content

## Design Considerations

- Output should be clean, scannable markdown — tables for structured data, code blocks for commands
- Follow the same tone and formatting conventions as the existing README.md
- Keep the output concise enough to read in a terminal without excessive scrolling

## Repository Standards

- Skill frontmatter: `name`, `description`, `user-invocable`, `allowed-tools`
- Context marker pattern: `**ARC-HELP**`
- Conventional commits: `feat(arc-help): description`
- File structure: `skills/arc-help/SKILL.md`

## Technical Considerations

- Since content is static in SKILL.md, the allowed-tools list can be empty or minimal — no file reads are required at runtime
- The SKILL.md acts as both the skill definition and the content source — the agent simply outputs the prescribed content
- No references/ subdirectory needed since all content is inline

## Security Considerations

No security considerations — this skill only outputs static help text with no external data access, no user input processing, and no file modifications.

## Success Metrics

- `/arc-help` produces a complete, accurate guide covering all skills, artifacts, and install steps
- A new user can go from `/arc-help` output to a working Arc installation and first `/arc-capture` without consulting any other documentation
- Help content matches current state of skills and artifacts in the repository

## Open Questions

No open questions at this time.
