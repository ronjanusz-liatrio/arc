# Arc — Claude Code Plugin

## What This Is
A Claude Code plugin providing `/arc-capture`, `/arc-shape`, and `/arc-wave` skills for
product direction and idea lifecycle management. Arc is the upstream companion to temper —
it shapes what gets built before temper governs how it gets built.
See [README.md](README.md) for the full design.

## Development
- Build this plugin using SDD: `/cw-research` → `/cw-spec` → `/cw-plan` → `/cw-dispatch`
- Follow conventional commits: `type(scope): description`
- This repo is itself a Claude Code plugin — test installation locally with:
  ```
  claude plugin marketplace add /Users/ron/dev/arc
  claude plugin install arc@arc --scope project
  ```

## Structure
- `skills/` — SKILL.md definitions for capture, shape, and wave
- `templates/` — Artifact templates for VISION, CUSTOMER, ROADMAP, BACKLOG
- `references/` — Shared reference docs (idea lifecycle, brief format, wave planning)
- `.claude-plugin/` — Plugin packaging metadata

## Skill Context Markers

Every Arc skill SKILL.md file opens with a context marker in the format `**ARC-{SKILL-NAME}**`, where SKILL-NAME is the full directory name including the `arc-` prefix, converted to uppercase. For example, the skill at `skills/arc-capture/SKILL.md` opens with `**ARC-CAPTURE**`, and `skills/arc-shape/SKILL.md` opens with `**ARC-SHAPE**`. This marker ensures that LLM responses are clearly attributed to the correct Arc skill context. Future Arc skills must follow this convention.

<!--# BEGIN ARC:product-context -->
## Product Context

- **Vision:** Lightweight product direction for spec-driven development — inspired by Linear's fast capture and clean triage, arc is the upstream companion to temper.
- **Current Wave:** No active wave
- **Primary Personas:** Product Owner, Developer, Tech Lead, Project Stakeholder, Reader, New Arc User
- **Backlog:** 20 captured, 0 shaped, 0 spec-ready, 11 shipped
<!--# END ARC:product-context -->

<!--# BEGIN SKILLZ:installed-skills -->
## Installed Skills

- **skill-creator** (project) -- Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, edit, or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy.
  Source: skills.sh/anthropics/skills
  Installed: 2026-04-22
<!--# END SKILLZ:installed-skills -->
