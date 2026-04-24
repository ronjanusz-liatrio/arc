# Trigger Eval Harness

This directory contains the Arc trigger-eval suite: one JSON file per Arc skill,
each containing 20 annotated queries used to measure how accurately the skill
description causes Claude to select that skill.

---

## Purpose

Arc ships 9 skills. Autonomous agents select skills by matching a user's prompt
against each skill's `description` field. Undertriggering (Claude skips a skill
it should invoke) and mis-triggering (Claude invokes a sibling skill) are the
primary failure modes.

This eval set:

- Provides a stable regression baseline so that description rewrites can be
  measured objectively.
- Surfaces near-miss collisions between sibling skills (e.g., `arc-status` vs.
  `arc-audit`) before they reach production.
- Is the primary evidence for the ≥ 95% aggregate accuracy target defined in
  `docs/specs/15-spec-agent-utilization-upgrade/15-spec-agent-utilization-upgrade.md`.

---

## File Inventory

| File | Skill |
|------|-------|
| `arc-assess.json` | `/arc-assess` |
| `arc-audit.json` | `/arc-audit` |
| `arc-capture.json` | `/arc-capture` |
| `arc-help.json` | `/arc-help` |
| `arc-shape.json` | `/arc-shape` |
| `arc-ship.json` | `/arc-ship` |
| `arc-status.json` | `/arc-status` |
| `arc-sync.json` | `/arc-sync` |
| `arc-wave.json` | `/arc-wave` |

---

## JSON Shape

Each file is a single JSON object:

```json
{
  "skill": "<skill-name>",
  "queries": [
    {
      "query": "<natural-language prompt>",
      "expected_trigger": true,
      "rationale": "<why this prompt should (or should not) trigger the skill>"
    }
  ]
}
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `skill` | string | The Arc skill name (e.g., `"arc-capture"`). Matches the file's base name. |
| `queries` | array | Exactly 20 query objects. |
| `queries[].query` | string | The natural-language prompt fed to the model. |
| `queries[].expected_trigger` | boolean | `true` if this skill should be selected; `false` if Claude should route elsewhere or stay idle. |
| `queries[].rationale` | string | Human-readable annotation explaining the expected outcome. Near-miss entries name the sibling skill they route to. |

### 20-Query Split

Every file contains exactly **10 should-trigger** (`expected_trigger: true`) and
**10 should-NOT-trigger** (`expected_trigger: false`) queries.

Verify with:

```bash
cat tests/trigger-evals/arc-shape.json \
  | jq '[.queries[].expected_trigger] | group_by(.) | map({key: .[0], count: length})'
# Expected: [{"key": false, "count": 10}, {"key": true, "count": 10}]
```

### Query Composition Guidelines

**Should-trigger queries (10 per skill):**

- At least 3 use **informal or adjacent phrasing** rather than the exact skill
  verb (e.g., "jot this down" for `arc-capture`, "flesh out" for `arc-shape`).
- The remaining queries use explicit or near-explicit trigger language.

**Should-NOT-trigger queries (10 per skill):**

- At least 3 are **sibling near-misses** — queries that share keywords with the
  target skill but should route to a different Arc skill. The `rationale` field
  identifies the correct destination (e.g., "Routes to arc-audit").
- The remaining queries are out-of-domain prompts that should not trigger any
  Arc skill.

---

## Running the Eval

The eval runner lives in Anthropic's `skills` repository:
`skills/skill-creator/scripts/run_loop.py`.

The lowest-commitment path is to clone the repository locally and invoke the
script directly — no installation or plugin setup required.

### Step 1 — Clone the skills repository

```bash
git clone https://github.com/anthropics/skills.git /tmp/anthropics-skills
```

### Step 2 — Invoke run_loop.py against a single Arc skill

From the root of this repository:

```bash
python3 /tmp/anthropics-skills/skills/skill-creator/scripts/run_loop.py \
  --skill-path skills/arc-capture/SKILL.md \
  --eval-file tests/trigger-evals/arc-capture.json \
  --output tests/trigger-evals/arc-capture-baseline.json
```

Replace `arc-capture` with any of the 9 skill names to run a different skill.

#### Expected command-line arguments

| Argument | Description |
|----------|-------------|
| `--skill-path` | Path to the SKILL.md file being evaluated. |
| `--eval-file` | Path to the 20-query JSON eval file for that skill. |
| `--output` | Destination path for the per-query result JSON (baseline file). |

> Note: Argument names may vary across `run_loop.py` versions. Run
> `python3 /tmp/anthropics-skills/skills/skill-creator/scripts/run_loop.py --help`
> to confirm the exact flags for the version you cloned.

### Step 3 — Run all 9 skills

```bash
for skill in arc-assess arc-audit arc-capture arc-help arc-shape arc-ship arc-status arc-sync arc-wave; do
  python3 /tmp/anthropics-skills/skills/skill-creator/scripts/run_loop.py \
    --skill-path "skills/${skill}/SKILL.md" \
    --eval-file "tests/trigger-evals/${skill}.json" \
    --output "tests/trigger-evals/${skill}-baseline.json"
done
```

---

## Interpreting Results

`run_loop.py` prints a per-query pass/fail table and an aggregate accuracy
number. Example output:

```
arc-capture — eval results
==========================
 1  PASS  expected=true   got=true   "I have a quick idea — add keyboard shortcuts"
 2  PASS  expected=true   got=true   "Customer asked for SSO"
 3  PASS  expected=true   got=true   "We found a bug in the auth flow"
...
20  PASS  expected=false  got=false  "Summarize yesterday's standup notes into meeting minutes"

Accuracy: 20/20 (100.0%)
```

A result is a **PASS** when the model's trigger decision matches
`expected_trigger`. A result is a **FAIL** when they differ.

The aggregate accuracy for a single skill is `(passes / 20) * 100`.

---

## Accuracy Target

| Scope | Target |
|-------|--------|
| Per-skill | No individual skill floor is enforced; monitor for outliers. |
| Aggregate (9 skills × 20 queries = 180 total) | **≥ 95%** (171 / 180 correct) |

Results below 95% indicate that one or more skill descriptions need further
refinement using the `skill-creator` iterative-optimization loop.

---

## Baseline Result Files

After running the eval for the first time (task T06.3), a baseline file is
committed alongside each eval JSON:

```
tests/trigger-evals/
  arc-capture.json            ← eval queries (this spec)
  arc-capture-baseline.json   ← per-query results from the first run
  ...
```

The baseline files serve as regression anchors. Future description changes should
be compared against these files to confirm they do not decrease accuracy.

The aggregate summary (per-skill scores + overall accuracy) is captured in:

```
docs/specs/15-spec-agent-utilization-upgrade/06-proofs/eval-baseline-summary.md
```

---

## Related Files

- `docs/specs/15-spec-agent-utilization-upgrade/trigger-eval-harness.feature` — BDD scenarios this harness satisfies.
- `docs/specs/15-spec-agent-utilization-upgrade/research-agent-utilization.md` §2 — Anthropic's 20-query eval methodology and near-miss design rationale.
- `skills/skill-creator/SKILL.md` (in `anthropics/skills`) — the upstream skill-creator guide that defines the eval format.
