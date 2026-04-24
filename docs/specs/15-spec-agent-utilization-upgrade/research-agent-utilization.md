# Research Report: Optimizing Arc for Agent Utilization

**Topic:** `agent-utilization` — How can Arc's skills be optimized for autonomous/agent-led project management, and what guidance is missing to help local agents manage their projects using this plugin?

**Generated:** 2026-04-22
**Scope:** `/home/ron.linux/arc` (v0.18.0). External context: Anthropic's `skill-creator` SKILL.md (fetched 2026-04-22).

---

## Summary

Arc is a 9-skill Claude Code plugin (`arc-assess`, `arc-audit`, `arc-capture`, `arc-help`, `arc-shape`, `arc-ship`, `arc-status`, `arc-sync`, `arc-wave`) with uniform frontmatter, consistent naming, and layered documentation. For **interactive/human-in-the-loop** use, the average agent-instruction clarity is ~8.5/10, templates are phase-mapped, and the SDD handoff to `claude-workflow` is explicit.

For **autonomous-agent** use, four systemic gaps surface. These map cleanly onto Anthropic's own skill-authoring guidance (see External Context):

1. **Descriptions undertrigger.** Anthropic's own guide: *"Claude has a tendency to undertrigger skills… combat this by making descriptions a little 'pushy'."* Zero of Arc's 9 descriptions declare invocation triggers; most state only what the skill *does*. Sibling pairs (`arc-status` vs. `arc-audit`, `arc-assess` vs. `arc-sync`) collide on verbs like "check" and "consolidate".
2. **No machine-readable contracts.** No JSON Schema, no validation scripts, no `state()` predicate, no `done-looks-like` checklist. Agents cannot self-validate artifacts.
3. **No orchestration contract.** No document defines prerequisite ordering, invariants, or an autonomous-dispatch protocol. `requires` / `produces` / `consumes` relationships live only in prose inside each SKILL.md Step-11 block.
4. **Surface inconsistencies break agent heuristics.** Three context markers diverge from the `ARC-{SKILL-NAME}` convention (`ARC-README`, `ARC-REVIEW`, `ARC-ALIGN`); `marketplace.json` omits 2 of 9 skills; `Agent()` calls in `arc-shape`/`arc-assess` lack timeouts/fallbacks.

The research produced concrete rewrite proposals for all 9 skill descriptions (with eval utterances), a skill-orchestration contract, frontmatter additions (`requires`/`produces`/`consumes`/`triggers`), four JSON Schemas, four validation scripts, and three missing output templates. Adopting these upgrades Arc from an interactive authoring tool to an autonomous project-management substrate.

---

## External Context — Anthropic's Skill-Authoring Principles

Fetched from `https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md`.

**Key rules that anchor this research's recommendations:**

1. **"Pushy" descriptions combat undertriggering.** *"Claude has a tendency to undertrigger skills — to not use them when they'd be useful. To combat this, make skill descriptions a little bit 'pushy'."* Descriptions should enumerate trigger scenarios, keywords, and adjacent use cases; include implicit-need phrasings ("user mentions X, even if they don't explicitly ask for Y").
2. **Bodies under 500 lines; progressive disclosure.** Beyond that, split into `references/` with clear pointers.
3. **Explain the *why*, not just the *what*.** Imperative form, but reasoning-driven. *"If you find yourself writing ALWAYS or NEVER in all caps… that's a yellow flag."*
4. **20-query trigger eval** — 8-10 should-trigger + 8-10 should-NOT-trigger near-misses — is the validation instrument. Near-misses are the most valuable test cases.
5. **Autonomous use raises the bar.** *"Skills must be self-contained and unambiguous… descriptions must robustly trigger without human intervention."* Interactive skills can rely on inline feedback loops; autonomous skills cannot.
6. **Anti-patterns to avoid.** Overfitting to 2-3 examples; rigid ALL-CAPS constraints; stripping the *why*; forcing quantitative metrics onto subjective tasks; passive descriptions that assume users name the skill.
7. **Frontmatter minimum.** `name` and `description` required; `compatibility` optional.

Every finding and proposal below ties back to one or more of these rules. Arc's current state violates (1), (5), and (6) most significantly.

---

## 1. Tech Stack & Project Structure

### Initial Findings

- **Plugin packaging:** v0.18.0; declared companions `temper` (required), `claude-workflow` (required), `readme-author` (optional). Strict-mode marketplace manifest.
- **Skill inventory:** 9 skills, 4-field YAML frontmatter (`name`, `description`, `user-invocable: true`, `allowed-tools`). 6 of 9 have `references/` subdirs. `allowed-tools` scoped per skill.
- **Layout:** `/CLAUDE.md` (dev + `ARC:product-context` managed block), `/README.md`, `/references/` (8 shared conceptual docs), `/templates/` (4 artifact templates), `/scripts/` (1 helper: `lint-mermaid.sh`), `/skills/`.
- **Naming is strict:** `arc-{action}` prefix; `ARC:` namespace; archive path `docs/skill/arc/waves/`.

### Structural Gaps

| Gap | Impact | Where |
|---|---|---|
| `marketplace.json` description lists only 7 of 9 skills (omits `/arc-ship`, `/arc-help`) | Marketplace-browsing agents miss 2 skills | `.claude-plugin/marketplace.json` |
| No `skills` key in `plugin.json` | No machine-readable skill registry | `.claude-plugin/plugin.json` |
| No top-level `SKILLS.md` or index | Agents enumerate `skills/` by hand | repo root |
| Interdependencies (e.g., arc-wave ← temper management report) are implicit | Agents cannot precompute prerequisite checks | frontmatter lacks `requires:` |

### Deep-Dive Findings

Addressed via frontmatter schema proposal in Section 5 (Orchestration Infrastructure).

---

## 2. Trigger Patterns & Descriptions

### Initial Findings

All 9 descriptions are concise (60-140 chars), self-contained, and domain-rich, but **none specify invocation triggers**. Zero skills have a "When to Invoke" section. Prerequisites (e.g., "only shaped ideas" for `/arc-wave`) are implicit. Overlapping verbs create sibling confusion.

### Deep-Dive Findings — Concrete Description Rewrites

Per Anthropic's "pushy" principle, each arc skill description should:
- State what it does (concise opening clause)
- List 2-4 trigger scenarios with "user says X" phrasings
- Declare prerequisites where applicable
- Disambiguate against sibling skills
- Include informal/adjacent-use phrasings

Full rewrites (abbreviated for each skill here; full `should-trigger` / `should-not-trigger` utterances in Appendix A):

#### arc-capture

- **Current:** `Fast idea capture — record a raw idea to the backlog in under 30 seconds`
- **Proposed:** `Fast idea capture — record raw product ideas to the backlog before they're forgotten, no analysis required. Invoke when you have a raw thought, feature request, bug report, or user feedback that needs capturing. Does not refine or prioritize — that happens in /arc-shape. Prerequisites: none (creates BACKLOG if absent).`

#### arc-shape

- **Current:** `Interactive idea refinement — transform a captured idea into a spec-ready brief using parallel subagent analysis`
- **Proposed:** `Interactive idea refinement — take a captured idea and transform it into a spec-ready brief with problem clarity, customer fit, scope, and feasibility analysis. Invoke when an idea is captured and ready for a 15-20 minute deep dive. Requires captured status; produces shaped status and brief. Produces the brief handed to /cw-spec.`

#### arc-wave

- **Current:** `Delivery cycle management — group shaped ideas into a wave, update the roadmap, and prepare handoff to the SDD pipeline`
- **Proposed:** `Delivery cycle management — organize spec-ready ideas into a themed wave with a clear goal and target, then hand off to /cw-spec. Invoke when you have 2-5 shaped ideas ready to commit to in the next cycle. Requires shaped ideas; promotes to spec-ready; updates ROADMAP and ARC:product-context. Validates wave scope against Temper phase if present.`

#### arc-ship

- **Current:** `Mark a validated idea as shipped — verify proof artifacts exist, archive to wave file, then remove from BACKLOG`
- **Proposed:** `Mark validated ideas as shipped — transition spec-ready to shipped after /cw-validate confirms PASS, archive to wave file, remove from BACKLOG. Invoke when implementation is complete and validation passed, or when batch-shipping a wave. Requires **Overall: PASS** in validation report.`

#### arc-status

- **Current:** `Project pulse check — summarize current wave, backlog, in-flight specs, and recent activity in one inline view`
- **Proposed:** `Project pulse check — read-only snapshot of project health across five dimensions: current wave, backlog distribution, in-flight specs, git momentum, lifecycle gaps. Invoke anytime you want a quick overview without making changes. Emits a next-step recommendation. Lightweight alternative to /arc-audit (which writes a report and fixes).`

#### arc-audit

- **Current:** `Pipeline health audit — check backlog health, wave alignment, and cross-reference integrity across all product artifacts`
- **Proposed:** `Pipeline health audit — comprehensive health check across 10+ dimensions (stale ideas, priority imbalance, brief completeness, wave alignment, broken ROADMAP refs, persona coverage, phase alignment). Writes a diagnostic report and offers interactive fixes. Invoke when diagnosing pipeline problems or before major milestones. More thorough than /arc-status.`

#### arc-assess

- **Current:** `Codebase discovery and migration — consolidate scattered product-direction content into Arc-managed artifacts`
- **Proposed:** `Codebase discovery and migration — scan a project for product-direction content scattered across README, TODO lists, docs/, and code comments, then import into Arc artifacts (BACKLOG, VISION, CUSTOMER). Invoke at project inception or when adopting Arc into an existing project. One-time or periodic consolidation before major planning.`

#### arc-sync

- **Current:** `README lifecycle management — scaffold or update README.md with Arc-managed sections synced to product direction artifacts`
- **Proposed:** `README lifecycle management — scaffold a new README from Arc artifacts or update managed sections to match VISION, CUSTOMER, BACKLOG, ROADMAP, wave archives. Invoke when scaffolding a project README for the first time, when artifacts have drifted from README, or before sharing the project. Runs migration sweep on each invocation.`

#### arc-help

- **Current:** `Quick reference guide — overview of all Arc skills, artifacts, workflow, and installation`
- **Proposed:** Unchanged — already adequate. Consider adding one informal phrasing: *"Invoke when you need a skill index, workflow diagram, or installation instructions, or when someone says 'what can arc do?'."*

### Surface-Level Fixes

- **Context markers** must follow `ARC-{SKILL-NAME}`:
  - `skills/arc-sync/SKILL.md:12` `**ARC-README**` → `**ARC-SYNC**`
  - `skills/arc-audit/SKILL.md:12` `**ARC-REVIEW**` → `**ARC-AUDIT**`
  - `skills/arc-assess/SKILL.md:13` `**ARC-ALIGN**` → `**ARC-ASSESS**`
- **`marketplace.json`** description should list all 9 skills.

---

## 3. Dependencies & Integrations

### Declared Pipeline

`arc-assess` → `arc-capture` → `arc-shape` → `arc-wave` → `/cw-spec` → `/cw-plan` → `/cw-dispatch` → `/cw-validate` → `arc-ship`. Temper is read-only alongside.

### What works

- `arc-wave` Step 11 explicitly offers "Hand off to `/cw-spec`" with a ready-to-paste brief in `docs/skill/arc/wave-report.md`.
- `arc-ship` reads cw-validate reports for `**Overall**: PASS` before shipping.
- `arc-status` detects in-flight specs via `docs/specs/NN-spec-*/` glob.
- Temper graceful-degradation: arc-wave skips engineering readiness if management report absent.
- `references/cross-plugin-contract.md` defines read-only Temper artifact paths.

### What's missing

- **`arc-shape` does not suggest `/cw-spec` directly.** Single-idea workflows route through wave-planning.
- **No programmatic handoff.** All cross-plugin handoffs require human (or meta-agent) to type the next slash command.
- **No interdependency declaration in frontmatter.** `requires:` / `produces:` / `consumes:` absent.
- **Handoff data is markdown, not machine-readable.** `wave-report.md`'s "Next Action" column is plain markdown.

---

## 4. Templates & References

### Templates (`/templates/`)

`BACKLOG`, `CUSTOMER`, `ROADMAP`, `VISION` — consistent `{Slot}` placeholders, inline instructions, example values, phase-mapped across Temper's 7 phases. High agent-readiness for *authoring*.

### References (`/references/`)

| File | Agent-Executable? | Schema? |
|---|---|---|
| brief-format.md | Yes (7-item validation checklist) | Markdown only |
| idea-lifecycle.md | Yes (state machine, field tables) | Mermaid only |
| wave-planning.md | Yes (capacity + precedence rules) | Tables + Mermaid |
| wave-archive.md | Yes (naming, idempotency, schema) | Markdown schema |
| vocabulary-mapping.md | Human reference | None |
| cross-plugin-contract.md | Yes (read-only access) | Path tables |
| README.md | Index | — |

### Scripts (`/scripts/`)

Only `lint-mermaid.sh`. No artifact validators, no state predicate, no audit script.

### Critical Gaps

- **No JSON Schema** for any Arc artifact.
- **No self-test command.**
- **No `done-looks-like` acceptance checklist** per template.
- **No templates for skill *outputs*** — `wave-report`, `audit-report`, `shape-report` are generated inline without a shared skeleton.

---

## 5. Agent-Facing Instruction Clarity — Orchestration Infrastructure

### Per-Skill Clarity (restated)

| Skill | Goal | Precond | Steps | Output | Error | Idempotent | Score |
|---|---|---|---|---|---|---|---|
| capture | ✓ | ⚠ | ✓ | ✓ | ✓ | ✓ | 8.5 |
| shape | ✓ | ⚠ | ✓ | ✓ | ✓ | ✓ | 8.5 |
| wave | ✓ | ⚠ | ✓ | ✓ | ⚠ | ✓ | 8.0 |
| status | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9.5 |
| sync | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9.5 |
| audit | ✓ | ✓ | ✓ | ✓ | ⚠ | ✓ | 9.0 |
| assess | ⚠ | ⚠ | ⚠ | ⚠ | ⚠ | ✓ | 6.5 |
| ship | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9.5 |
| help | ✓ | — | ✓ | ✓ | — | — | 9.0 |

**Average: ~8.5/10** — strong for interactive use, weak for autonomous dispatch.

### Deep-Dive Findings — Orchestration Contract

The biggest gap is not in any single SKILL.md; it is the absent **contract layer** that would let a dispatcher chain skills without human intervention. Proposed artifacts:

#### 5.1 `references/skill-orchestration.md` (new)

**State vector:**
```
{
  idea_status: "captured" | "shaped" | "spec-ready" | "shipped",
  shaped_count: integer,
  spec_ready_count: integer,
  wave_active: boolean,
  validation_status: "PASS" | "PENDING" | "FAIL" | "N/A"
}
```

**Skill validity matrix (abbreviated):**

| Skill | Valid When | Preconditions |
|---|---|---|
| `/arc-capture` | Always | BACKLOG exists or creatable |
| `/arc-shape` | idea.status = captured | CUSTOMER.md present/creatable |
| `/arc-wave` | shaped_count ≥ 1 AND wave_active = false | VISION.md; ROADMAP creatable |
| `/arc-ship` | idea.status = spec-ready AND validation_status = PASS | validation report |
| `/arc-status` / `/arc-audit` / `/arc-sync` / `/arc-assess` / `/arc-help` | Always | artifact-specific |

**Ordering invariants (I1-I5):**
- I1: BACKLOG Consistency — shaped ideas have all brief fields.
- I2: Wave Closure — no spec-ready → shipped without `Overall: PASS`.
- I3: ROADMAP Closure — no wave archived until all ideas shipped.
- I4: Temporal Monotonicity — captured < shaped < shipped timestamps.
- I5: Brief Atomicity — shaped brief fields all-or-nothing.

**Coordinator skill: `/arc-status`.** Precedence list in its Step 7 already models this (validation→ship gap first, then plan→validation, etc.). Formalize it as the canonical dispatch order.

#### 5.2 Frontmatter Additions

Per skill, add:
```yaml
requires:
  files: [...]
  artifacts: [BACKLOG, ROADMAP]
  state: "shaped_count >= 1 AND wave_active = false"
produces:
  files: [...]
  artifacts: [...]
  state-transition: "shaped -> spec-ready"
consumes:
  from:
    - { skill: /arc-shape, artifact: shaped-brief }
triggers:
  condition: "no gaps AND no active wave"
  alternates: [/arc-audit]
```

Rationale: structured fields make dispatcher resolution deterministic. `description` stays prose; these fields augment.

#### 5.3 JSON Schemas (new `schemas/` directory)

Four schemas, Draft-07 style:

| Schema | Required fields | Key rules |
|---|---|---|
| `backlog-entry.json` | title, status, priority, captured | If status=shaped → brief required |
| `brief.json` | problem, proposed_solution, success_criteria (≥3), constraints, assumptions | All minLength enforced |
| `wave.json` | number, name, theme, goal, status, ideas (≥1) | status enum Planned/Active/Completed |
| `roadmap-row.json` | wave, goal, status, target, ideas (count) | wave pattern `^Wave \d+: .+$` |

#### 5.4 Validation Scripts (`scripts/`)

- `validate-backlog.sh` — summary table well-formed, all sections match table rows, shaped ideas have brief fields, no duplicate titles.
- `validate-brief.sh` — given an idea title, verify all 5 brief fields present and non-trivial.
- `validate-roadmap.sh` — ROADMAP refs exist in BACKLOG; exactly 0 or 1 wave has status=Active.
- `state.sh` — emit the state vector as JSON so agents can decide next action without re-globbing.

All scripts: exit 0=pass, 1=fail, 2=recoverable. Chainable: `validate-backlog.sh && validate-roadmap.sh`.

#### 5.5 Missing Output Templates

- `templates/wave-report.tmpl.md` — matches arc-wave Step 10.
- `templates/audit-report.tmpl.md` — 10 check dimensions with Severity column (info/warning/critical) and Recommended Action.
- `templates/shape-report.tmpl.md` — 4-dimension analysis (problem clarity, customer fit, scope, feasibility) + brief fields.

Each template ends with an "Acceptance Criteria" bullet list an agent can self-check against.

---

## 6. Cross-Dimension Synthesis — Prioritized Action List

Ranked by agent-utilization leverage × implementation cost:

### Tier 1 — High leverage, low cost (weekend-scale)

1. **Rewrite all 9 descriptions** to Anthropic's "pushy" standard (proposals in §2). Add explicit triggers, prerequisites, sibling disambiguation.
2. **Fix 3 context markers** to `ARC-{SKILL-NAME}`; document the convention in `CLAUDE.md`.
3. **List all 9 skills in `marketplace.json`.** Add a top-level `SKILLS.md` index.
4. **Add `requires` / `produces` / `consumes` / `triggers` frontmatter** to each SKILL.md (§5.2).

### Tier 2 — High leverage, medium cost (week-scale)

5. **Create `references/skill-orchestration.md`** (§5.1) — state vector, validity matrix, ordering invariants, coordinator designation.
6. **Ship 4 JSON Schemas** (§5.3) and matching `scripts/validate-*.sh` + `scripts/state.sh` (§5.4). Let agents self-check.
7. **Add timeout/fallback guidance** to `Agent()` calls in `arc-shape` and `arc-assess` (soft 5-min timeout, skip-with-notice).
8. **Rewrite `arc-assess`** — split compound goal, specify output files, add worked example.

### Tier 3 — Durable infrastructure

9. **Output templates** — `wave-report`, `audit-report`, `shape-report` in `/templates/` (§5.5).
10. **Machine-readable `/cw-spec` handoff** — turn wave-report's "Next Action" column into a YAML block.
11. **Autonomous-mode flag** — per-skill way to suppress `AskUserQuestion` and use documented defaults when run by a scheduled routine.
12. **Trigger eval suite** — per Anthropic's guide, 20 queries per skill (10 trigger / 10 near-miss). Store in `tests/trigger-evals/<skill>.json`. Use `skill-creator`'s `run_loop.py` to iterate descriptions against this set.

---

## What Would Guide Local Agents Towards Using Arc for Project Management

The user's question: *"Is there anything missing that would guide local agents towards managing their projects using this skill?"*

**Yes — four missing capabilities, each mapped to a concrete artifact:**

| Agent need | What's missing | Minimum artifact |
|---|---|---|
| **Discovery** — "Which skill runs for this intent?" | No triggers in descriptions | Per-skill "pushy" description + `triggers:` frontmatter (§2, §5.2) |
| **Prereq check** — "Can I run `/arc-wave` now?" | No `requires:` declaration | `references/skill-orchestration.md` + `requires:` frontmatter (§5.1, §5.2) |
| **Validation** — "Is my BACKLOG valid?" | No schema, no validator | JSON Schemas + `scripts/validate-*.sh` (§5.3, §5.4) |
| **Continuation** — "What runs next?" | No `produces:`/`consumes:` map | Frontmatter + state predicate `scripts/state.sh` (§5.2, §5.4) |

A starter delivery bundle (1 wave):
- `references/triggers.md` (canonical trigger format) + rewrite all 9 descriptions
- `references/skill-orchestration.md`
- `schemas/{backlog,brief,wave,roadmap}.schema.json`
- `scripts/{validate-backlog,validate-brief,validate-roadmap,state}.sh`
- `templates/{wave-report,audit-report,shape-report}.tmpl.md`
- Frontmatter additions: `requires:`, `produces:`, `consumes:`, `triggers:`
- Surface fixes: 3 context markers + `marketplace.json` + `SKILLS.md`

---

## Appendix A — Trigger Eval Seeds (per skill)

Each skill gets 3 should-trigger + 2 should-NOT-trigger utterances. These seed the full 20-query eval per Anthropic's skill-creator methodology (`run_loop.py` can expand and iterate).

**arc-capture** ✓: "I have a quick idea — add keyboard shortcuts"; "Customer asked for SSO"; "We found a bug in the auth flow". ✗: "Let me shape this idea"; "What's the backlog status?"

**arc-shape** ✓: "Shape the 'Dark Mode' idea for me"; "I want to prepare this for the next wave"; "Refine these three ideas". ✗: "Just record this quick thought"; "Write the detailed spec for this feature".

**arc-wave** ✓: "Plan the next delivery wave with these 4 ideas"; "Time to group these ideas into a wave"; "I'm ready to commit to the next 2 weeks". ✗: "What's the current status?"; "Write specs for the next wave ideas".

**arc-ship** ✓: "Ship this validated feature"; "The wave is done, mark these ideas as shipped"; "Validation passed, move to archive". ✗: "Write a validation report"; "What's pipeline health?"

**arc-status** ✓: "What's the status?"; "Show me the project pulse"; "Quick overview before standup". ✗: "Audit the pipeline and fix issues"; "Update the README".

**arc-audit** ✓: "Audit the product pipeline"; "Something feels off in the backlog"; "Check for issues before release". ✗: "Quick status check"; "Audit engineering gates".

**arc-assess** ✓: "Scan the codebase and migrate ideas into Arc"; "We're starting to use Arc — consolidate existing ideas"; "Check if there's scattered roadmap content". ✗: "Record this new idea"; "Update the README".

**arc-sync** ✓: "Scaffold a README from our product direction"; "Update the README with the new wave"; "Sync the README features list". ✗: "Consolidate scattered backlog items"; "What's the current status?"

**arc-help** ✓: "What Arc skills are available?"; "Show me the workflow"; "How do I install Arc?". ✗: (all invocations appropriate.)

---

## Appendix B — Source Files Consulted

- `/home/ron.linux/arc/.claude-plugin/{plugin,marketplace}.json`
- `/home/ron.linux/arc/skills/arc-*/SKILL.md` (all 9)
- `/home/ron.linux/arc/templates/{BACKLOG,CUSTOMER,ROADMAP,VISION}.tmpl.md`
- `/home/ron.linux/arc/references/{brief-format,idea-lifecycle,wave-planning,wave-archive,vocabulary-mapping,cross-plugin-contract,README}.md`
- `/home/ron.linux/arc/scripts/lint-mermaid.sh`
- `/home/ron.linux/arc/CLAUDE.md`, `/home/ron.linux/arc/README.md`
- External: `https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md` (fetched 2026-04-22)

---

## Meta-Prompt for /cw-spec

Ready-to-use starter prompt for the next pipeline step.

---

**Feature name:** agent-utilization-upgrade

**Problem:** Arc is a 9-skill Claude Code plugin optimized for interactive product-direction authoring. For autonomous-agent use, four systemic gaps prevent reliable orchestration: (1) descriptions undertrigger because they state *what* skills do but never *when* to invoke them, and sibling skills (`arc-status`/`arc-audit`, `arc-assess`/`arc-sync`) collide on verbs; (2) no machine-readable artifact contracts exist — no JSON schemas, no validation scripts, no state predicate; (3) no orchestration contract defines prerequisites, ordering invariants, or autonomous dispatch; (4) surface inconsistencies (three context markers diverging from `ARC-{SKILL-NAME}`, `marketplace.json` missing 2 skills, `Agent()` calls with no timeouts) break agent heuristics. Agents today cannot reliably discover the right skill, verify preconditions, validate outputs, or chain skills without human prompting.

**Goal:** Upgrade Arc into an autonomous-agent-ready project-management substrate, anchored on Anthropic's skill-creator authoring guidance (pushy descriptions, `<500` line bodies, progressive disclosure, trigger eval methodology, explicit WHY).

**Key components to touch:**
- All 9 SKILL.md files under `skills/arc-*/` — rewrite `description` fields, add `requires/produces/consumes/triggers` frontmatter, standardize context markers.
- `.claude-plugin/marketplace.json`, optional `plugin.json` skills key.
- New `references/skill-orchestration.md`.
- New `schemas/{backlog-entry,brief,wave,roadmap-row}.json`.
- New `scripts/{validate-backlog,validate-brief,validate-roadmap,state}.sh`.
- New `templates/{wave-report,audit-report,shape-report}.tmpl.md`.
- New `tests/trigger-evals/<skill>.json` (optional tier 3).

**Architectural constraints:**
- No breaking changes to existing skill invocations — every current `/arc-*` command must keep working.
- Arc's read-only relationship with Temper and Claude-Workflow must be preserved (see `references/cross-plugin-contract.md`).
- Existing `ARC:` namespace managed-section convention must be respected.
- No new external runtime dependencies unless trivially installable (`jq` is acceptable; heavier validators are not).

**Patterns to follow:**
- Frontmatter is the single source of truth for agent routing; descriptions augment but don't replace structured fields.
- `/arc-status` is the autonomous dispatcher (canonical precedence list already lives in its Step 7).
- All new scripts: exit 0 pass, 1 fail, 2 recoverable; chainable; no interactive prompts.
- Schemas validate real sample artifacts before being adopted.

**Suggested demoable units:**
1. **Description Rewrite Pack** — all 9 descriptions updated; context markers fixed; marketplace.json corrected. *Demo:* invoke each skill with ambiguous prompts ("what's going on with the project?") and show correct skill resolution.
2. **Frontmatter Contract Layer** — `requires/produces/consumes/triggers` added to all 9 SKILL.md files. *Demo:* a parser reads all 9 frontmatters and prints a dependency graph; dispatcher resolves `arc-ship` by finding its prerequisite chain.
3. **Orchestration Contract** — `references/skill-orchestration.md` with state vector, validity matrix, invariants. *Demo:* given a state vector, the contract correctly names the next valid skill.
4. **Schemas + Validators** — 4 JSON Schemas and 4 `validate-*.sh` scripts. *Demo:* `state.sh` emits valid JSON; running validators on a malformed BACKLOG returns a specific, actionable error.
5. **Output Templates** — 3 `templates/*.tmpl.md` files. *Demo:* `arc-wave`, `arc-audit`, and `arc-shape` each write their reports from the new templates; diff against current inline generation is minimal.
6. **Trigger Eval Bundle** (optional) — `tests/trigger-evals/*.json` + harness integration with `skill-creator`'s `run_loop.py`. *Demo:* eval report shows ≥95% correct triggering across 180 test queries (9 skills × 20 queries).

**Code references:**
- Research report: `docs/specs/research-agent-utilization/research-agent-utilization.md`
- Existing coordinator precedence list: `skills/arc-status/SKILL.md` Step 7
- Existing read-only contract: `references/cross-plugin-contract.md`
- External authoring guide: `https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md`
- Project dev protocol: `CLAUDE.md` ("Build this plugin using SDD: `/cw-research` → `/cw-spec` → `/cw-plan` → `/cw-dispatch`")

**Proof artifacts to produce per unit:**
- Description rewrite: before/after table, 20-query eval result per skill.
- Frontmatter contract: dependency graph visualization (markdown or mermaid).
- Orchestration contract: worked example state → next-skill mapping table.
- Schemas + validators: sample pass + sample fail runs in `docs/specs/.../proofs/`.
- Output templates: rendered example artifact per template.
- Trigger eval: aggregated accuracy table + per-skill score.
