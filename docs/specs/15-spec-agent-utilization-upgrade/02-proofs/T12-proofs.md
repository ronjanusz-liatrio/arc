# T12 Proof Summary — T02.2: Populate requires/produces/consumes/triggers in 9 SKILL.md frontmatters

**Task:** T02.2 — Add the four new frontmatter fields (`requires`, `produces`, `consumes`,
`triggers`) to every `skills/arc-*/SKILL.md`, grounded in each skill's actual reads and
writes. Shape follows the contract in `references/frontmatter-fields.md` (T02.1).

**Status:** PASS

## Proof Artifacts

| File | Type | Status | What it shows |
|------|------|--------|---------------|
| `T12-01-yaml-parse.txt` | cli (YAML round-trip) | PASS | Full parsed frontmatter for every skill dumped as JSON; PyYAML 6.0.3 loaded each block without error. |
| `T12-02-field-shape.txt` | cli (contract check) | PASS | Matrix showing all 9 skills pass the 8-key ordered-frontmatter contract and all required sub-fields. |

## What Was Implemented

Added four structured frontmatter fields to every `skills/arc-*/SKILL.md` — nine files
in total. All edits were purely additive: existing fields (`name`, `description`,
`user-invocable`, `allowed-tools`) were preserved in shape and order, and the new fields
were appended after `allowed-tools`. No body content was modified and no context-marker
headers were touched (that is the scope of T01.2 / task #8).

`git diff --stat skills/` shows **189 insertions, 0 deletions** across the 9 files.

### Per-skill summary

| Skill | `requires.state` | `produces.state-transition` | `consumes.from` count |
|-------|------------------|------------------------------|-----------------------|
| `arc-capture` | `""` (empty — always valid) | `raw -> captured` | 0 (empty map) |
| `arc-shape` | `idea.status = 'captured'` | `captured -> shaped` | 1 (`/arc-capture`) |
| `arc-wave` | `shaped_count >= 1 AND wave_active = false` | `shaped -> spec-ready` | 1 (`/arc-shape`) |
| `arc-ship` | `idea.status = 'spec-ready' AND validation_status = 'PASS'` | `spec-ready -> shipped` | 2 (`/arc-wave`, `/cw-validate`) |
| `arc-status` | `""` (empty — read-only) | `""` (no transition) | 0 (empty map) |
| `arc-audit` | `""` (empty — always valid) | `""` (no transition) | 0 (empty map) |
| `arc-assess` | `""` (empty — always valid) | `raw -> captured` | 0 (empty map) |
| `arc-sync` | `""` (empty — always valid) | `""` (no transition) | 2 (`/arc-wave`, `/arc-shape`) |
| `arc-help` | `""` (empty — always valid) | `""` (no transition) | 0 (empty map) |

## Acceptance Criteria Verified

From `frontmatter-contract-layer.feature` Scenario 5 (populate frontmatter fields) and
task-level requirements:

- [x] Every `skills/arc-*/SKILL.md` has `requires`, `produces`, `consumes`, `triggers`
      fields present — **9 / 9 PASS**
- [x] Existing fields (`name`, `description`, `user-invocable`, `allowed-tools`) are
      unchanged in shape and order — **9 / 9 PASS** (diff is purely additive)
- [x] Every frontmatter round-trips through a YAML parser without error — **9 / 9 PASS**
      (see `T12-01-yaml-parse.txt`)
- [x] Sub-fields match the contract in `references/frontmatter-fields.md`:
      `requires.{files, artifacts, state}`, `produces.{files, artifacts,
      state-transition}`, `consumes.from` (or empty map), `triggers.{condition,
      alternates}` — **9 / 9 PASS** (see `T12-02-field-shape.txt`)
- [x] `arc-wave` `requires.state` equals `"shaped_count >= 1 AND wave_active = false"`
      (spec-mandated example) — **PASS**
- [x] `arc-ship` `requires.state` equals `"idea.status = 'spec-ready' AND
      validation_status = 'PASS'"` (spec-mandated example) — **PASS**
- [x] Skills with no upstream dependency (`arc-capture`, `arc-status`, `arc-audit`,
      `arc-assess`, `arc-help`) declare `consumes: {}` per the worked example in the
      contract — **PASS**
- [x] Body content and context-marker headers untouched (out of scope for this task)
      — **PASS** (diff shows no removals, only additions inside frontmatter blocks)

## Reproduction

```bash
# Install PyYAML in a venv and re-run both proofs:
python3 -m venv /tmp/arc-t12-venv
/tmp/arc-t12-venv/bin/pip install --quiet PyYAML

# Proof 1: round-trip parse
/tmp/arc-t12-venv/bin/python -c "
import re, yaml, json
skills = ['arc-capture','arc-shape','arc-wave','arc-ship','arc-status',
          'arc-audit','arc-assess','arc-sync','arc-help']
for s in skills:
    text = open(f'skills/{s}/SKILL.md').read()
    m = re.match(r'^---\n(.*?)\n---\n', text, re.DOTALL)
    fm = yaml.safe_load(m.group(1))
    assert len(fm) == 8
    print(s, 'OK')
"
```
