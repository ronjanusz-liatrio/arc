# Frontmatter Field Contract

This document defines the shape of the four structured frontmatter fields added to every
`skills/arc-*/SKILL.md` in Arc v0.18+. These fields let a dispatcher build a dependency
graph and resolve preconditions without parsing any SKILL.md body text.

## Why These Fields Exist

Arc's SKILL.md frontmatter previously carried only `name`, `description`, `user-invocable`,
and `allowed-tools`. Those fields serve Claude Code's plugin loader; they say nothing about
*when* a skill should run, *what* it needs first, or *what* it leaves behind. An autonomous
dispatcher reading only frontmatter cannot determine ordering, detect conflicts, or chain
skills — it must parse prose.

The four fields below fill that gap. They are required for all Arc skills and optional (but
encouraged) for skills in other plugins that integrate with Arc.

---

## Field Reference

### `requires`

**What it declares:** Resources and state that must be present *before* the skill can run.

| Sub-field | Type | Description |
|-----------|------|-------------|
| `files` | list of path strings | Specific file paths the skill reads. Globs accepted. |
| `artifacts` | list of arc artifact names | High-level artifact names (`BACKLOG`, `ROADMAP`, `CUSTOMER`, `VISION`, `wave-report`). |
| `state` | string (predicate expression) | Boolean predicate over the state vector. Uses `AND`, `OR`, `>=`, `=`, `!=` operators. |

**`state` predicate vocabulary:**

| Symbol | Type | Description |
|--------|------|-------------|
| `idea.status` | enum string | Status of the idea being operated on: `captured`, `shaped`, `spec-ready`, `shipped`. |
| `shaped_count` | integer | Number of ideas with status `shaped` in BACKLOG. |
| `spec_ready_count` | integer | Number of ideas with status `spec-ready` in BACKLOG. |
| `wave_active` | boolean | `true` if ROADMAP contains a wave with status `Active`. |
| `validation_status` | enum string | Result of the most recent `/cw-validate` run: `PASS`, `PENDING`, `FAIL`, `N/A`. |

**Example — arc-wave:**

```yaml
requires:
  files:
    - docs/BACKLOG.md
    - docs/VISION.md
  artifacts:
    - BACKLOG
    - VISION
  state: "shaped_count >= 1 AND wave_active = false"
```

**Example — arc-ship:**

```yaml
requires:
  files:
    - docs/BACKLOG.md
    - docs/ROADMAP.md
  artifacts:
    - BACKLOG
    - ROADMAP
  state: "idea.status = 'spec-ready' AND validation_status = 'PASS'"
```

---

### `produces`

**What it declares:** Resources and state that the skill creates or modifies on a successful
run.

| Sub-field | Type | Description |
|-----------|------|-------------|
| `files` | list of path strings | Files written or mutated by this skill. |
| `artifacts` | list of arc artifact names | Arc-level artifact names updated. |
| `state-transition` | string | Human-readable status change expressed as `A -> B`. |

The `state-transition` value is informational — it names the lifecycle transition rather
than encoding a formal expression. Use `->` as the separator. Multiple transitions are
space-separated (e.g., `"captured -> shaped"`).

**Example — arc-shape:**

```yaml
produces:
  files:
    - docs/BACKLOG.md
  artifacts:
    - BACKLOG
  state-transition: "captured -> shaped"
```

**Example — arc-wave:**

```yaml
produces:
  files:
    - docs/ROADMAP.md
    - docs/BACKLOG.md
    - docs/skill/arc/wave-report.md
    - CLAUDE.md
  artifacts:
    - ROADMAP
    - BACKLOG
    - wave-report
  state-transition: "shaped -> spec-ready"
```

---

### `consumes`

**What it declares:** Artifacts produced by specific *sibling skills* that this skill
depends on as inputs. Use `consumes` instead of — or in addition to — `requires.artifacts`
when provenance matters: you need to name not just what the artifact is, but which skill
created it.

| Sub-field | Type | Description |
|-----------|------|-------------|
| `from` | list of `{skill, artifact}` objects | Each entry names the upstream skill and the artifact it produces. |

**`from` object fields:**

| Field | Type | Description |
|-------|------|-------------|
| `skill` | string | Skill name as invoked (e.g., `/arc-shape`). Use the slash-prefixed form. |
| `artifact` | string | Arc artifact name or logical output name (e.g., `shaped-brief`, `wave-report`). |

**Example — arc-wave (consumes shaped briefs from arc-shape):**

```yaml
consumes:
  from:
    - { skill: /arc-shape, artifact: shaped-brief }
```

**Example — arc-ship (consumes the wave report and validation result):**

```yaml
consumes:
  from:
    - { skill: /arc-wave, artifact: wave-report }
    - { skill: /cw-validate, artifact: validation-report }
```

Skills that are always valid (e.g., `/arc-capture`, `/arc-status`) and do not require
upstream skill output may omit `consumes` entirely or declare it as an empty map.

---

### `triggers`

**What it declares:** The *precondition* under which this skill is the recommended next
action, and a list of alternative skills that handle related but distinct intents.

| Sub-field | Type | Description |
|-----------|------|-------------|
| `condition` | string | Human-readable condition or state description that makes this skill the right choice. |
| `alternates` | list of skill name strings | Sibling skills to consider instead when the condition is partially met or ambiguous. |

The `condition` value is a short phrase — not a formal predicate. Write it to help a
dispatcher choose between siblings. It answers the question "when would I prefer this
skill over its alternates?"

**Example — arc-status:**

```yaml
triggers:
  condition: "any time a quick read-only project snapshot is needed"
  alternates:
    - /arc-audit
```

**Example — arc-audit:**

```yaml
triggers:
  condition: "pipeline problems detected or pre-milestone health check needed"
  alternates:
    - /arc-status
```

**Example — arc-wave:**

```yaml
triggers:
  condition: "shaped_count >= 1 AND wave_active = false"
  alternates:
    - /arc-shape
    - /arc-audit
```

---

## Worked Examples

### Example 1: arc-capture (always valid, no upstream dependencies)

This skill has no state prerequisites and does not depend on any other arc skill's output.
It is always valid and consumes nothing.

```yaml
---
name: arc-capture
description: "..."
user-invocable: true
allowed-tools: Glob, Grep, Read, Write, Edit, AskUserQuestion
requires:
  files: []
  artifacts:
    - BACKLOG
  state: ""
produces:
  files:
    - docs/BACKLOG.md
  artifacts:
    - BACKLOG
  state-transition: "raw -> captured"
consumes: {}
triggers:
  condition: "any time a raw idea, feature request, bug report, or user feedback needs recording"
  alternates:
    - /arc-shape
---
```

The `state: ""` (empty string) indicates no state predicate — the skill is valid
regardless of current project state. `consumes: {}` indicates no upstream skill output
is required.

---

### Example 2: arc-wave (state-gated, consumes from arc-shape)

This skill requires shaped ideas to exist and no wave to be active. It consumes the
shaped brief produced by `/arc-shape`.

```yaml
---
name: arc-wave
description: "..."
user-invocable: true
allowed-tools: Glob, Grep, Read, Write, Edit, AskUserQuestion
requires:
  files:
    - docs/BACKLOG.md
    - docs/VISION.md
  artifacts:
    - BACKLOG
    - VISION
  state: "shaped_count >= 1 AND wave_active = false"
produces:
  files:
    - docs/ROADMAP.md
    - docs/BACKLOG.md
    - docs/skill/arc/wave-report.md
    - CLAUDE.md
  artifacts:
    - ROADMAP
    - BACKLOG
    - wave-report
  state-transition: "shaped -> spec-ready"
consumes:
  from:
    - { skill: /arc-shape, artifact: shaped-brief }
triggers:
  condition: "shaped_count >= 1 AND wave_active = false"
  alternates:
    - /arc-shape
    - /arc-audit
---
```

---

### Example 3: arc-ship (double-gated — status + validation)

This skill requires the idea to be `spec-ready` AND the validation report to show `PASS`.
Both conditions must hold simultaneously.

```yaml
---
name: arc-ship
description: "..."
user-invocable: true
allowed-tools: Glob, Grep, Read, Write, Edit, AskUserQuestion
requires:
  files:
    - docs/BACKLOG.md
    - docs/ROADMAP.md
  artifacts:
    - BACKLOG
    - ROADMAP
  state: "idea.status = 'spec-ready' AND validation_status = 'PASS'"
produces:
  files:
    - docs/BACKLOG.md
    - docs/ROADMAP.md
    - docs/skill/arc/waves/{wave-slug}.md
  artifacts:
    - BACKLOG
    - ROADMAP
    - wave-archive
  state-transition: "spec-ready -> shipped"
consumes:
  from:
    - { skill: /arc-wave, artifact: wave-report }
    - { skill: /cw-validate, artifact: validation-report }
triggers:
  condition: "idea.status = 'spec-ready' AND validation_status = 'PASS'"
  alternates:
    - /arc-audit
---
```

---

## Interaction with Existing Fields

The four new fields are **additive only**. They are inserted after `allowed-tools` and
before the first `#` heading. The pre-existing fields (`name`, `description`,
`user-invocable`, `allowed-tools`) remain unchanged in shape, order, and semantics.
Claude Code's plugin loader reads only the pre-existing fields and ignores the new ones.

```
name:           ← unchanged
description:    ← unchanged
user-invocable: ← unchanged
allowed-tools:  ← unchanged
requires:       ← new
produces:       ← new
consumes:       ← new
triggers:       ← new
```

---

## Cross-References

- [idea-lifecycle.md](idea-lifecycle.md) — defines the status values referenced in `requires.state` and `produces.state-transition`
- [skill-orchestration.md](skill-orchestration.md) — defines the full state vector and skill validity matrix derived from these fields
- [references/README.md](README.md) — index of all reference documents
