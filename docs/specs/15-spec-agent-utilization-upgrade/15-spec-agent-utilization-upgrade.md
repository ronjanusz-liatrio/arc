# 15-spec-agent-utilization-upgrade

## Introduction/Overview

Arc is a 9-skill Claude Code plugin that provides lightweight product-direction management. It works well for human-in-the-loop authoring but under-serves autonomous agents: descriptions undertrigger, sibling skills collide on verbs, artifacts lack machine-readable contracts, and no orchestration layer tells a dispatcher which skill to invoke next. This spec upgrades Arc into an autonomous-agent-ready substrate by rewriting skill descriptions to Anthropic's "pushy" standard, adding structured frontmatter (`requires`/`produces`/`consumes`/`triggers`), publishing an orchestration contract, introducing JSON schemas + validation scripts + a state predicate, adding templates for skill outputs, and seeding a 20-query trigger-eval harness.

**Research context:** `docs/specs/15-spec-agent-utilization-upgrade/research-agent-utilization.md`

## Goals

1. **Eliminate undertriggering** — every Arc skill has a "pushy" description with explicit triggers, prerequisites, and sibling disambiguation, targeting ≥ 95% correct skill selection across a 180-query eval (9 skills × 20 queries).
2. **Make skill chaining machine-readable** — all 9 skills declare `requires`/`produces`/`consumes`/`triggers` frontmatter; a parser can produce a full dependency graph without reading any SKILL.md body.
3. **Publish the orchestration contract** — `references/skill-orchestration.md` defines the state vector, skill-validity matrix, ordering invariants I1–I5, and the canonical dispatcher precedence list (Coordinator: `/arc-status`).
4. **Enable agent self-validation** — ship 4 JSON Schemas (backlog-entry, brief, wave, roadmap-row), 3 `validate-*.sh` scripts, and `scripts/state.sh` so agents can check artifacts and emit a state vector without re-globbing.
5. **Standardize skill outputs** — 3 output templates (`wave-report`, `audit-report`, `shape-report`) replace inline-generated reports.
6. **Fix surface inconsistencies** — 3 context markers corrected; `marketplace.json` lists all 9 skills; `plugin.json` gains a `skills` array.

## User Stories

- **As an autonomous agent dispatcher,** I want to read all Arc SKILL.md frontmatters and build a dependency graph so I can chain skills without parsing prose.
- **As a human agent-operator,** I want descriptions that make the right skill obvious for ambiguous prompts ("what's happening with the project?") so I don't have to read arc-help every time.
- **As a local Claude Code agent,** I want a `state.sh` I can invoke to know where the project sits (captured / shaped / spec-ready / shipped gaps) so I can suggest the right next skill.
- **As a new Arc user,** I want a single orchestration contract that tells me which skills are valid to invoke from my current state.
- **As a skill author extending Arc,** I want JSON schemas for BACKLOG, brief, wave, and roadmap artifacts so my validator can confirm I produced well-formed data.
- **As a scheduled routine that runs arc-status weekly,** I want validator scripts that exit 0/1/2 so I can alert on `1` and auto-recover on `2`.

## Demoable Units of Work

### Unit 1: Description Rewrite Pack

**Purpose:** Eliminate undertriggering and sibling-verb collisions by rewriting all 9 skill descriptions to Anthropic's "pushy" standard, fixing 3 divergent context markers, and correcting `marketplace.json` to list all 9 skills.

**Functional Requirements:**
- The system shall rewrite the `description:` field in each of the 9 files `skills/arc-*/SKILL.md` so that the new description (a) states what the skill does in a concise opening clause, (b) enumerates 2-4 trigger scenarios with "user says X" phrasings, (c) declares prerequisites where applicable, (d) explicitly disambiguates against any sibling skill that would otherwise share verbs.
- The system shall update `.claude-plugin/marketplace.json` so that the plugin description or accompanying field lists all 9 skills (currently lists 7; missing `/arc-ship` and `/arc-help`).
- The system shall correct 3 context-marker headers to match the `ARC-{SKILL-NAME}` convention:
  - `skills/arc-sync/SKILL.md` — change `**ARC-README**` to `**ARC-SYNC**`
  - `skills/arc-audit/SKILL.md` — change `**ARC-REVIEW**` to `**ARC-AUDIT**`
  - `skills/arc-assess/SKILL.md` — change `**ARC-ALIGN**` to `**ARC-ASSESS**`
- The system shall document the context-marker convention in `CLAUDE.md` so future skills follow it.
- The system shall leave all step-level procedural content in each SKILL.md unchanged (body edits only for marker corrections).

**Proof Artifacts:**
- File: `docs/specs/15-spec-agent-utilization-upgrade/01-proofs/description-before-after.md` contains a 9-row table showing old vs. new description per skill.
- File: `docs/specs/15-spec-agent-utilization-upgrade/01-proofs/marker-fixes.diff` shows the three context-marker edits.
- File: `docs/specs/15-spec-agent-utilization-upgrade/01-proofs/marketplace-update.diff` shows the manifest edit listing all 9 skills.
- CLI: `grep -E "^\\*\\*ARC-" skills/arc-*/SKILL.md` returns one ARC-{SKILL-NAME} marker per skill, all matching their containing directory.

### Unit 2: Frontmatter Contract Layer

**Purpose:** Add structured `requires` / `produces` / `consumes` / `triggers` fields to all 9 SKILL.md frontmatters so a dispatcher can build a dependency graph without parsing prose.

**Functional Requirements:**
- The system shall add four new optional-for-external, required-for-arc frontmatter fields to every `skills/arc-*/SKILL.md`: `requires`, `produces`, `consumes`, `triggers`.
- The system shall define the shape of each field in a new `references/frontmatter-fields.md` document (values, expected types, examples). `requires` carries `files`, `artifacts`, `state`; `produces` carries `files`, `artifacts`, `state-transition`; `consumes` carries `from` (list of `{skill, artifact}` pairs); `triggers` carries `condition` and `alternates`.
- The system shall populate the four fields correctly for every arc skill, grounded in the skill's actual reads/writes (e.g., `arc-wave` `requires.state = "shaped_count >= 1 AND wave_active = false"`; `arc-ship` `requires.state = "idea.status = 'spec-ready' AND validation_status = 'PASS'"`).
- The system shall ship `scripts/parse-frontmatter.sh` that reads all 9 frontmatters and emits a dependency graph as Mermaid markdown (for visual audit) and as JSON (for tooling).
- The system shall preserve backward compatibility: existing frontmatter fields (`name`, `description`, `user-invocable`, `allowed-tools`) remain unchanged in shape and order.

**Proof Artifacts:**
- File: `docs/specs/15-spec-agent-utilization-upgrade/02-proofs/dependency-graph.md` contains the Mermaid graph rendered from all 9 frontmatters.
- File: `docs/specs/15-spec-agent-utilization-upgrade/02-proofs/frontmatter-parse.json` is the JSON output of `scripts/parse-frontmatter.sh`.
- CLI: `scripts/parse-frontmatter.sh --format mermaid skills/arc-*/SKILL.md` returns a valid Mermaid graph with 9 nodes and non-empty edges for each skill that consumes from a sibling.
- Test: each of the 9 frontmatters round-trips through a YAML parser without error.

### Unit 3: Orchestration Contract

**Purpose:** Publish `references/skill-orchestration.md` as the canonical descriptive reference for autonomous dispatchers.

**Functional Requirements:**
- The system shall create `references/skill-orchestration.md` containing: (a) the state-vector definition (`idea_status`, `shaped_count`, `spec_ready_count`, `wave_active`, `validation_status`); (b) a skill-validity matrix listing each of the 9 skills with its `valid when` condition; (c) ordering invariants I1–I5 (backlog consistency, wave closure, roadmap closure, temporal monotonicity, brief atomicity); (d) the dispatcher precedence list naming `/arc-status` as the coordinator and reproducing its Step 7 ordering.
- The document shall be **descriptive guidance, not enforcement**. Agents and humans may consult it; validators may warn but do not refuse to run when invariants are violated.
- The system shall cross-link `references/skill-orchestration.md` from `CLAUDE.md`, `README.md`, and `references/README.md`.
- The system shall include at least one worked example mapping a state vector to a recommended next skill.

**Proof Artifacts:**
- File: `references/skill-orchestration.md` exists and contains sections `## State Vector`, `## Skill Validity Matrix`, `## Ordering Invariants`, `## Dispatcher Precedence`, `## Worked Example`.
- File: `docs/specs/15-spec-agent-utilization-upgrade/03-proofs/state-example.md` shows a state vector → recommended skill mapping table with at least 3 rows covering distinct states.
- CLI: `grep -l skill-orchestration.md CLAUDE.md README.md references/README.md` returns all three paths.

### Unit 4: Schemas + Validators + State Predicate

**Purpose:** Ship machine-readable contracts for artifacts and a state predicate so agents can self-validate.

**Functional Requirements:**
- The system shall create four JSON Schema (Draft-07) files under a new `schemas/` directory: `backlog-entry.schema.json`, `brief.schema.json`, `wave.schema.json`, `roadmap-row.schema.json`. Shapes are as specified in the research report §5.3.
- The system shall create three validator shell scripts: `scripts/validate-backlog.sh`, `scripts/validate-brief.sh`, `scripts/validate-roadmap.sh`. Each reads the corresponding artifact, applies the relevant schema, and enforces structural invariants (table-vs-section consistency, ROADMAP↔BACKLOG cross-references, etc.).
- The system shall create `scripts/state.sh` that emits the current state vector as JSON to stdout.
- All scripts shall use exit codes: `0` pass, `1` fail, `2` recoverable. All scripts shall be non-interactive, chainable, and depend only on `jq` + `awk`/`grep` + a JSON Schema CLI (to be chosen from `ajv-cli` or `check-jsonschema`; either is acceptable, named in the spec-time design doc).
- The system shall ship sample pass/fail test fixtures under `schemas/tests/` so the validators' behavior can be regression-tested in CI later.

**Proof Artifacts:**
- File: `schemas/*.schema.json` — four valid JSON Schema files.
- File: `scripts/validate-backlog.sh`, `scripts/validate-brief.sh`, `scripts/validate-roadmap.sh`, `scripts/state.sh` — all executable.
- CLI: `scripts/validate-backlog.sh docs/BACKLOG.md` returns exit 0.
- CLI: `scripts/validate-backlog.sh schemas/tests/backlog-missing-brief.md` returns exit 1 with a diagnostic mentioning the missing `brief` field.
- CLI: `scripts/state.sh | jq .idea_status_counts` returns a non-null object with keys `captured`, `shaped`, `spec_ready`, `shipped`.
- File: `docs/specs/15-spec-agent-utilization-upgrade/04-proofs/validate-pass.txt` and `04-proofs/validate-fail.txt` show the two CLI transcripts.

### Unit 5: Output Templates

**Purpose:** Standardize skill-generated reports with three shared templates.

**Functional Requirements:**
- The system shall create `templates/wave-report.tmpl.md`, `templates/audit-report.tmpl.md`, `templates/shape-report.tmpl.md`. Each matches the inline-generated report shape already produced by `arc-wave` Step 10, `arc-audit`, and `arc-shape` Step 7 respectively.
- Each template shall use consistent `{Slot}` placeholder syntax matching the existing 4 arc templates.
- Each template shall end with an "Acceptance Criteria" bullet list (3-5 items) that an agent can self-check against.
- The system shall update the three corresponding SKILL.md files to reference the new templates in place of inline generation (zero behavior change — same output, sourced from template).

**Proof Artifacts:**
- File: `templates/wave-report.tmpl.md`, `templates/audit-report.tmpl.md`, `templates/shape-report.tmpl.md` exist with consistent placeholder syntax.
- File: `docs/specs/15-spec-agent-utilization-upgrade/05-proofs/rendered-wave-report.md` shows a filled-in example from the template.
- File: `docs/specs/15-spec-agent-utilization-upgrade/05-proofs/rendered-audit-report.md` and `05-proofs/rendered-shape-report.md` — same for the other two.
- CLI: `grep -l wave-report.tmpl.md skills/arc-wave/SKILL.md` returns a match.

### Unit 6: Trigger Eval Harness

**Purpose:** Seed a 20-query per-skill eval set and wire it to `skill-creator`'s `run_loop.py` so description quality can be regression-tested.

**Functional Requirements:**
- The system shall create `tests/trigger-evals/<skill>.json` for each of the 9 Arc skills, each containing 20 queries split 10 should-trigger / 10 should-NOT-trigger (near-misses per Anthropic's methodology).
- The system shall document the eval-runner invocation in `tests/trigger-evals/README.md`, including the command line to invoke `skill-creator`'s `run_loop.py` against an Arc skill.
- The system shall commit the baseline eval results (post-description-rewrite) as `tests/trigger-evals/<skill>-baseline.json` so future changes can be compared against it.
- The 10 should-trigger queries per skill shall include at least 3 informal/adjacent phrasings (e.g., `arc-capture` should trigger on "jot this down" not just "capture this idea").
- The 10 should-NOT-trigger queries per skill shall include at least 3 near-misses that share keywords with the target skill but route to a sibling (e.g., `arc-status` near-miss: "audit the pipeline" — should route to arc-audit).

**Proof Artifacts:**
- File: `tests/trigger-evals/*.json` — 9 files, each containing exactly 20 queries with `expected_trigger: true|false` annotations.
- File: `tests/trigger-evals/README.md` documents the runner invocation and interpretation of results.
- File: `docs/specs/15-spec-agent-utilization-upgrade/06-proofs/eval-baseline-summary.md` shows the aggregate accuracy (target ≥ 95%) and per-skill scores.
- CLI: `cat tests/trigger-evals/arc-shape.json | jq '[.queries[].expected_trigger] | group_by(.) | map({key: .[0], count: length})'` returns `[{key: true, count: 10}, {key: false, count: 10}]`.

## Non-Goals (Out of Scope)

- **No runtime enforcement of orchestration invariants.** Validators WARN but do not refuse. (Answer to Q2.)
- **No changes to existing SKILL.md step-level procedures** beyond marker fixes and template references. Behavior stays the same.
- **No new Claude Code plugin permissions** — stays within existing `allowed-tools` declarations per skill.
- **No rewrite of Temper or Claude-Workflow integration.** The read-only contract in `references/cross-plugin-contract.md` is preserved.
- **No `skill-creator` plugin install as a Claude Code plugin.** Its guidance is referenced as external context; the eval runner is invoked as a script, not as a slash command.
- **No migration tool** for users whose BACKLOG/ROADMAP predates schema enforcement. Schemas describe the shape agents already produce; existing artifacts were created by those same agents and should already validate.

## Design Considerations

- **No UI component.** All work is in markdown files, JSON schemas, and shell scripts.
- **Mermaid diagrams** generated by `parse-frontmatter.sh` should follow the existing Arc convention (see `templates/VISION.tmpl.md` for color/style).
- **Placeholder syntax** in new templates follows the existing `{SlotName}` convention from the four current templates.

## Repository Standards

- Conventional commits: `type(scope): description`. Scope conventions from prior specs: `feat(arc-{skill}):`, `docs(arc):`, `test(arc-{skill}):`.
- All new markdown files lint-clean against `scripts/lint-mermaid.sh` if they contain Mermaid blocks.
- Frontmatter YAML validated by `scripts/parse-frontmatter.sh` (introduced in Unit 2).
- Follow the `ARC:` managed-section namespace for any CLAUDE.md or README.md edits.
- Spec artifact naming follows the established `NN-{kind}-{slug}.md` + `NN-proofs/` convention (see `14-spec-wave-time-estimate-opt-in/`).

## Technical Considerations

- **JSON Schema CLI choice.** The validators depend on one of `ajv-cli` or `check-jsonschema`. The implementation phase will pick one; both are lightweight, both are widely available. Prefer the one already in `package.json` (none yet) or the one with the best shell integration. Document the choice in the first validator's header.
- **Frontmatter parsing.** `parse-frontmatter.sh` uses `awk` to extract the YAML block + `yq` to parse. `yq` is not in the existing preflight; spec will call it out in its header and provide an install hint.
- **Mermaid output from parse-frontmatter.** Keep under 50 lines of Mermaid to stay renderable in GitHub markdown preview.
- **state.sh performance target.** < 500 ms on a repository with 50 ideas. Single-pass over `docs/BACKLOG.md`, `docs/ROADMAP.md`, and `docs/specs/` glob.
- **Research artifact co-location.** `research-agent-utilization.md` stays inside `docs/specs/15-spec-agent-utilization-upgrade/`. All proof artifacts for this spec live under `NN-proofs/` directories inside the same folder.

## Security Considerations

- Scripts process only local repository files. No network calls (except the external-context WebFetch that already happened during research).
- No credentials, tokens, or sensitive data involved.
- Validators must not echo file contents that could contain customer names or internal product details beyond what the originating artifact already contains.

## Success Metrics

- **Trigger-eval accuracy:** ≥ 95% correct trigger/no-trigger across 180 eval queries (9 skills × 20).
- **Frontmatter completeness:** 9/9 arc SKILL.md files contain the four new fields; 0 parse errors.
- **Validator coverage:** 4/4 artifact types have a schema; 3/3 validators produce exit 0 on current Arc artifacts (clean baseline).
- **Zero regressions:** every existing arc slash command keeps working — manual smoke test per skill documented in `06-proofs/regression-smoke.md`.
- **Orchestration contract adoption:** `/arc-status` Step 7 precedence list references `references/skill-orchestration.md` and is consistent with the matrix.
- **Surface-fix correctness:** `grep -c ARC-` across the 9 SKILL.md files returns exactly 9 matches, all `ARC-{SKILL-NAME}` form.

## Open Questions

1. **`plugin.json` `skills` array semantics.** User chose "Both — add a skills array to plugin.json". Today Claude Code doesn't document a `skills` field in `plugin.json`; adding it is additive metadata. During implementation, verify whether `claude plugin install` tolerates the extra field (likely yes — strict-mode JSON loaders typically pass through unknown keys). If it causes issues, fall back to a `metadata.skills` nested object.
2. **JSON Schema CLI choice.** `ajv-cli` vs. `check-jsonschema` — decision deferred to implementation. The planner or first implementer should document the choice in the first validator's header.
3. **`skill-creator` `run_loop.py` reachability.** It lives in `anthropics/skills/skills/skill-creator/scripts/`. Determine during implementation whether to (a) document a `git clone` + invocation path, (b) vendor it, or (c) install anthropics/skills as a Claude Code plugin. Option (a) is the lowest-commitment default.
4. **Near-miss query design for `arc-help`.** `arc-help` has no sibling to near-miss against. Consider whether its eval is simpler (only should-trigger queries) or whether near-misses should test "obvious-looking help questions that should actually route to a substantive skill" (e.g., "how do I ship this?" → should trigger `arc-ship`, not `arc-help`).

## References

- Research report: [`research-agent-utilization.md`](research-agent-utilization.md) in this directory.
- External authoring guide: `https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md` (fetched 2026-04-22; key principles reproduced in the research report).
- Existing coordinator logic: `skills/arc-status/SKILL.md` Step 7 (reproduce in `references/skill-orchestration.md` "Dispatcher Precedence" section).
- Existing cross-plugin contract: `references/cross-plugin-contract.md` (preserve read-only relationships).
- Existing template conventions: `templates/BACKLOG.tmpl.md`, `templates/VISION.tmpl.md` (placeholder syntax reference).
- Prior comparable spec: `02-spec-arc-plugin-enhancement/` (multi-unit refactor baseline).
