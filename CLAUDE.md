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

## Skill Orchestration

See [`references/skill-orchestration.md`](references/skill-orchestration.md) for the state vector, validity matrix, ordering invariants, and dispatcher precedence that govern when each skill is appropriate to invoke.

## Skill Context Markers

Every Arc skill SKILL.md file opens with a context marker in the format `**ARC-{SKILL-NAME}**`, where SKILL-NAME is the full directory name including the `arc-` prefix, converted to uppercase. For example, the skill at `skills/arc-capture/SKILL.md` opens with `**ARC-CAPTURE**`, and `skills/arc-shape/SKILL.md` opens with `**ARC-SHAPE**`. This marker ensures that LLM responses are clearly attributed to the correct Arc skill context. Future Arc skills must follow this convention.

<!--# BEGIN ARC:product-context -->
## Product Context

For live product status, see the source artifacts. This section intentionally contains no counts, statuses, or names — those drift; the linked files are authoritative.

- [docs/BACKLOG.md](docs/BACKLOG.md) — current ideas with their lifecycle status (captured, shaped, spec-ready, shipped). Read before suggesting new ideas or proposing scope changes.
- [docs/ROADMAP.md](docs/ROADMAP.md) — active and planned waves with goals and targets. Read when deciding what to work on next or to understand the current delivery cycle.
- [docs/VISION.md](docs/VISION.md) — product vision, north-star problem, and strategic boundaries. Read when shaping new ideas or evaluating fit.
- [docs/CUSTOMER.md](docs/CUSTOMER.md) — primary personas and their jobs-to-be-done. Read when scoping a feature or assessing customer fit.
<!--# END ARC:product-context -->

<!--# BEGIN SKILLZ:installed-skills -->
## Installed Skills

- **skill-creator** (project) -- Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, edit, or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy.
  Source: skills.sh/anthropics/skills
  Installed: 2026-04-22
<!--# END SKILLZ:installed-skills -->
