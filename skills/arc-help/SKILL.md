---
name: arc-help
description: "Quick reference guide — overview of all 9 Arc skills, artifacts, workflow, and installation instructions. Invoke when you need a skill index, workflow diagram, or installation instructions — when the user says 'what can arc do', 'show me the arc skills', 'how do I install arc', or 'I'm new to arc'. Always outputs the full reference; does not accept arguments or take actions."
user-invocable: true
allowed-tools: []
requires:
  files: []
  artifacts: []
  state: ""
produces:
  files: []
  artifacts: []
  state-transition: ""
consumes: {}
triggers:
  condition: "user needs an index of Arc skills, a workflow overview, or installation instructions"
  alternates:
    - /arc-status
---

# /arc-help — Quick Reference Guide

## Context Marker

Always begin your response with: **ARC-HELP**

## Overview

Arc is a Claude Code plugin for lightweight product direction. It manages the idea lifecycle from raw thought to shipped feature, keeping product direction as plain markdown files in your repo (`VISION`, `CUSTOMER`, `ROADMAP`, `BACKLOG`) with shipped ideas archived to the wave archive (`docs/skill/arc/waves/`).

Arc is the upstream companion to [temper](https://github.com/ronjanusz-liatrio/temper) (engineering maturity) and [claude-workflow](https://github.com/ronjanusz-liatrio/claude-workflow) (spec-driven development). Arc shapes **what** gets built before temper governs **how** it gets built. Shaped ideas flow from Arc into the claude-workflow SDD pipeline (`/cw-spec` -> `/cw-plan` -> `/cw-dispatch`).

## Skills

Arc provides nine skills for managing the product idea lifecycle:

| Skill | Description | Invocation |
|-------|-------------|------------|
| `/arc-assess` | Codebase discovery and migration -- scan for scattered product-direction content and import into Arc artifacts | `/arc-assess` |
| `/arc-capture` | Fast idea entry -- record a raw idea to the backlog in under 30 seconds | `/arc-capture` |
| `/arc-shape` | Interactive refinement -- transform a captured idea into a spec-ready brief using parallel analysis | `/arc-shape` or `/arc-shape "Idea Title"` |
| `/arc-status` | Project pulse check -- summarize current wave, backlog, in-flight specs, and recent activity | `/arc-status` |
| `/arc-wave` | Delivery cycle management -- group shaped ideas into a wave and hand off to the SDD pipeline | `/arc-wave` |
| `/arc-sync` | README synchronization -- scaffold or update README.md with sections synced to product direction | `/arc-sync` |
| `/arc-ship` | Ship a validated idea -- verify proof artifacts, archive to wave file, remove from BACKLOG | `/arc-ship` or `/arc-ship "Idea Title"` |
| `/arc-audit` | Pipeline health audit -- check backlog health, wave alignment, and cross-reference integrity | `/arc-audit` |
| `/arc-help` | Quick reference guide -- this help output | `/arc-help` |

## Workflow

Recommended workflow (Arc + Temper):

```
Assess:
  /arc-assess     → Discover product content (reads Temper engineering context)
  /temper-assess  → Bootstrap engineering docs + README engineering sections

Develop ideas:
  /arc-capture    → Record new ideas
  /arc-shape      → Refine ideas (reads Temper engineering context)
  /arc-wave       → Plan delivery cycles (validates against Temper phase)

Sync documentation:
  /arc-sync       → Sync README product sections (what + why)
  /temper-sync    → Sync README engineering sections (how)

Implement:
  /cw-spec → /cw-plan → /cw-dispatch → /cw-validate

Ship:
  /arc-ship       → Archive shipped ideas to wave files (docs/skill/arc/waves/)

Check status:
  /arc-status     → Project pulse check (wave, backlog, specs, activity)

Audit health:
  /arc-audit      → Product pipeline + engineering maturity summary
  /temper-audit   → Engineering gates + product direction summary

Shared verbs: assess, sync, audit — same intent, different domain.
```

`/arc-help` is available at any point for this reference.

## Artifacts

Arc manages five product direction artifacts in your repository:

| Artifact | File Path | Purpose |
|----------|-----------|---------|
| **VISION** | `docs/VISION.md` | Product vision, strategic direction, and north star metrics |
| **CUSTOMER** | `docs/CUSTOMER.md` | Personas, jobs-to-be-done, and success metrics |
| **ROADMAP** | `docs/ROADMAP.md` | Phased delivery plan with themes and milestones |
| **BACKLOG** | `docs/BACKLOG.md` | Triaged idea list with status, priority, and brief summaries |
| **Wave Archive** | `docs/skill/arc/waves/` | Completed wave records and shipped idea details (one file per wave) |

These files live in your project repo alongside engineering docs -- no separate product tool to sync.

## Installation

### Arc

```bash
# From Git
claude plugin marketplace add https://github.com/ronjanusz-liatrio/arc.git
claude plugin install arc@arc --scope user

# From local filesystem (development)
claude plugin marketplace add /path/to/arc
claude plugin install arc@arc --scope project
```

### Temper (engineering maturity)

```bash
claude plugin marketplace add https://github.com/ronjanusz-liatrio/temper.git
claude plugin install temper@temper --scope user
```

### Claude Workflow (spec-driven development)

```bash
claude plugin marketplace add https://github.com/ronjanusz-liatrio/claude-workflow.git
claude plugin install claude-workflow@claude-workflow --scope user
```

## More Information

See [README.md](../../README.md) for full documentation, lifecycle diagrams, and plugin structure.

## Instructions

When invoked, output the full content of this guide starting from the Overview section. Do not accept arguments -- always display the complete reference.
