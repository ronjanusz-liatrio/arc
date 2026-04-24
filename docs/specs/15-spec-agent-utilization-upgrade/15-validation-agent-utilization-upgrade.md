# Validation Report: agent-utilization-upgrade

**Validated:** 2026-04-24T01:15:00Z
**Re-validated after remediation:** 2026-04-24T01:25:00Z
**Spec:** `docs/specs/15-spec-agent-utilization-upgrade/15-spec-agent-utilization-upgrade.md`
**Overall:** **PASS** (after H1 remediation in commit `303b420`)
**Gates:** A[P] B[P] C[P] D[P] E[P] F[P]

## Executive Summary

- **Implementation Ready:** Yes — initial HIGH issue (H1) remediated in commit `303b420`; all 9 SKILL.md files now have single, consistent `ARC-{SKILL-NAME}` markers.
- **Requirements Verified:** 31/31 requirements verified (100%).
- **Proof Artifacts Working:** All re-executed proofs pass (scripts/state.sh, scripts/parse-frontmatter.sh, scripts/validate-backlog.sh, schema-validation-pass/fail fixtures).
- **Files Changed vs. Expected:** 135 files changed, all in declared scope. Known path-hygiene issues (4 misplaced proof directories, 2 bundled commits) are MEDIUM.

## Coverage Matrix: Functional Requirements by Unit

### Unit 1 — Description Rewrite Pack

| Requirement | Task | Status | Evidence |
|---|---|---|---|
| Rewrite `description:` in 9 SKILL.md to pushy standard | T01.1 | Verified | `01-proofs/description-before-after.md`, 9 files confirmed |
| Update marketplace.json to list all 9 skills | T01.3 | Verified | `marketplace.json` description now mentions all 9 |
| Correct 3 context-marker headers to `ARC-{SKILL-NAME}` | T01.2 + `303b420` | **Verified** | Both header + body "ALWAYS" directive aligned in assess/audit/sync; single-marker check passes 9/9 |
| Document marker convention in CLAUDE.md | T01.4 | Verified | `CLAUDE.md:24-26` — "Skill Context Markers" section present |
| Leave SKILL.md step content unchanged | T01.1/T01.2 | Verified | Diff limited to `description:` field and header marker |

### Unit 2 — Frontmatter Contract Layer

| Requirement | Task | Status | Evidence |
|---|---|---|---|
| Author `references/frontmatter-fields.md` | T02.1 | Verified | 345-line contract doc with 3 worked examples |
| Populate `requires/produces/consumes/triggers` in 9 SKILL.md | T02.2 | Verified | 9 frontmatters yq-parse cleanly; 8-key ordered contract satisfied |
| Implement `scripts/parse-frontmatter.sh` | T02.3 | Verified | Re-executed: 21-line Mermaid, 9 nodes, 6 sibling edges + 1 external upstream |
| Capture `dependency-graph.md` + `frontmatter-parse.json` proofs | T02.4 | Verified | Both files at `02-proofs/` |
| Preserve existing 4 frontmatter fields | T02.2 | Verified | Shape/order unchanged per T12 field-shape proof |

### Unit 3 — Orchestration Contract

| Requirement | Task | Status | Evidence |
|---|---|---|---|
| Create `references/skill-orchestration.md` | T03.1 | Verified | 5 required sections present: State Vector, Skill Validity Matrix, Ordering Invariants (I1-I5), Dispatcher Precedence, Worked Example |
| Cross-link from CLAUDE.md, README.md, references/README.md | T03.2 | Verified | grep finds match in all 3 files |
| Capture state-example proof (≥ 3 rows) | T03.3 | Verified | `03-proofs/state-example.md` has 9 rows |
| Descriptive (not enforcement) framing | T03.1 | Verified | Document explicitly states "descriptive guidance, validators warn not refuse" |

### Unit 4 — Schemas + Validators + State Predicate

| Requirement | Task | Status | Evidence |
|---|---|---|---|
| 4 JSON Schemas under `schemas/` | T04.2 | Verified | All 4 files present with `"$schema": "http://json-schema.org/draft-07/schema#"` |
| Decide JSON Schema CLI | T04.1 | Verified | `references/schema-tooling.md` recommends `ajv-cli@5` + `ajv-formats@2` |
| `scripts/validate-backlog.sh` | T04.3 | Verified | Re-executed: exit 0, "20 entries validated (20 pass, 0 fail)" |
| `scripts/validate-brief.sh` + `scripts/validate-roadmap.sh` | T04.4 | Verified | Both files present, ShellCheck clean, 0/1/2 exit codes |
| `scripts/state.sh` | T04.5 | Verified | Re-executed: valid JSON, all 6 required fields, 17 ms performance |
| `schemas/tests/` fixtures (≥ 8) | T04.6 | Verified | 9 fixture files: 4 pass + 5 fail (one per rule violated) |
| `validate-pass.txt` + `validate-fail.txt` transcripts | T04.7 | Verified | Both files at `04-proofs/` |

### Unit 5 — Output Templates

| Requirement | Task | Status | Evidence |
|---|---|---|---|
| 3 output templates (wave-report, audit-report, shape-report) | T05.1 | Verified | All 3 files in `templates/` |
| Consistent `{SlotName}` placeholder syntax | T05.1 | Verified | Matches existing 4 arc templates |
| Each ends with "Acceptance Criteria" bullet list | T05.1 | Verified | Per T25-proofs |
| Wire arc-wave/audit/shape SKILL.md to new templates | T05.2 | Verified | 3 SKILL.md files updated per T26-proofs |
| Rendered example per template | T05.3 | Verified | 3 rendered files at `05-proofs/` |

### Unit 6 — Trigger Eval Harness

| Requirement | Task | Status | Evidence |
|---|---|---|---|
| 9 per-skill trigger-eval JSON files (20 queries each) | T06.1 | Verified | 180 queries total, 10/10 split confirmed per file |
| ≥ 3 informal phrasings per skill (should-trigger) | T06.1 | Verified | Per T06.1-03 CLI proof |
| ≥ 3 near-miss queries per skill (should-NOT-trigger) | T06.1 | Verified | Per T06.1-03 CLI proof |
| Eval runner README | T06.2 | Verified | `tests/trigger-evals/README.md` present |
| Baseline eval committed | T06.3 | Verified | 9 `<skill>-baseline.json` files; 180/180 match (manual-review method) |
| Aggregate summary ≥ 95% | T06.4 | Verified | 100% match rate; summary at `eval-baseline-summary.md` |

## Coverage Matrix: Repository Standards

| Standard | Status | Evidence |
|---|---|---|
| Conventional commits | Verified | All 25 implementation commits follow `type(scope): subject` |
| Script exit codes (0/1/2) | Verified | validate-backlog exits 0; fail fixtures exit 1 per validate-fail.txt |
| ShellCheck clean at severity=style | Verified | Per T04.3, T04.4, T04.5 proofs |
| Non-interactive, chainable scripts | Verified | Per script headers |
| ARC: managed-section namespace respected | Verified | CLAUDE.md `ARC:product-context` intact after all edits |
| Read-only cross-plugin contract | Verified | No writes to Temper or claude-workflow paths |
| Context-marker convention (ARC-{SKILL-NAME}) | Verified | 9/9 SKILL.md files have single consistent `ARC-{SKILL-NAME}` marker after `303b420` |

## Coverage Matrix: Proof Artifacts (Re-Executed)

| Task | Artifact | Type | Status | Current Result |
|---|---|---|---|---|
| T01.1 | description-before-after.md | file | Verified | File exists, 9-row table |
| T01.2 | marker-fixes.diff | file | Verified (partial) | Fix captured but incomplete (Issue H1) |
| T01.3 | marketplace-update.diff / plugin-json-update.diff | file | Verified | Diffs captured |
| T02.2 | yaml-parse.txt | cli | Verified (re-run) | 9/9 frontmatters parse via yq |
| T02.3 | parse-frontmatter.sh output | cli | Verified (re-run) | 21-line Mermaid, 6 edges |
| T04.2 | 4 schemas compile | cli | Verified (re-run) | All Draft-07, all load |
| T04.3 | validate-backlog.sh | cli | Verified (re-run) | Exit 0, 20/20 entries pass |
| T04.5 | state.sh | cli | Verified (re-run) | Valid JSON, 6 fields, 17 ms |
| T04.6 | 9 schema fixtures | file | Verified | 4 pass + 5 fail present |
| T04.7 | validate-pass.txt / validate-fail.txt | file | Verified | Both present with proof content |
| T05.1 | 3 tmpl.md files | file | Verified | All placeholder-consistent |
| T05.3 | 3 rendered-*.md | file | Verified | Zero residual placeholders |
| T06.1 | 9 trigger-eval JSON | file | Verified (re-run) | 20 queries/file, 10/10 split |
| T06.3 | 9 baseline JSON | file | Verified | All present, 100% match rate |
| T06.4 | eval-baseline-summary.md | file | Verified | 180/180 matches; ≥ 95% target exceeded |

## Validation Issues

| Severity | Issue | Impact | Recommendation |
|---|---|---|---|
| ~~HIGH~~ **RESOLVED** | ~~H1: Context-marker fix incomplete in 3 SKILL.md files.~~ **Remediated in commit `303b420`** — all 9 SKILL.md files now have single, consistent `ARC-{SKILL-NAME}` markers across header instruction and body "ALWAYS" directive. Verification: `for f in skills/arc-*/SKILL.md; do grep -oE "ARC-[A-Z]+" "$f" \| sort -u; done` returns exactly one marker per file, matching its directory name. | — | — |
| MEDIUM | M1: T01.4 proof files landed at `docs/specs/01-spec-description-rewrite-pack/01-proofs/T10-*.txt` (wrong spec dir entirely — worker-15 invented a new spec number). | Proofs are hard to find; audit trail inconsistent. | `git mv docs/specs/01-spec-description-rewrite-pack/01-proofs/T10-*.txt docs/specs/15-spec-agent-utilization-upgrade/01-proofs/`; then `rmdir` the orphan. |
| MEDIUM | M2: T03.2 proofs at `15-spec-agent-utilization-upgrade/15-proofs/` (should be `03-proofs/`). | Same as M1. | `git mv 15-proofs/* 03-proofs/`; `rmdir 15-proofs/`. |
| MEDIUM | M3: T04.6 proofs at `15-spec-agent-utilization-upgrade/23-proofs/` (should be `04-proofs/`). | Same. | `git mv 23-proofs/* 04-proofs/`; `rmdir 23-proofs/`. |
| MEDIUM | M4: T05.2 proofs at `15-spec-agent-utilization-upgrade/T26-proofs/` (should be `05-proofs/`). | Same. | `git mv T26-proofs/* 05-proofs/`; `rmdir T26-proofs/`. |
| MEDIUM | M5: `eval-baseline-summary.md` landed at the spec dir root instead of `06-proofs/` (spec FR: "File: `docs/specs/…/06-proofs/eval-baseline-summary.md`"). | Minor location drift from spec's stated proof path. | `git mv docs/specs/15-spec-agent-utilization-upgrade/eval-baseline-summary.md docs/specs/15-spec-agent-utilization-upgrade/06-proofs/`. |
| MEDIUM | M6: Commit `b6700e3` bundles T04.6 + T05.2 (two unrelated tasks). `15f1298` bundles T01.3 + T01.4. | Git history harder to bisect; reverting one task also reverts the other. | Documented only. Future dispatches should enforce one-commit-per-task. |
| LOW | L1: Worker-17 (T03.2) added a new "## Skill Orchestration" section in CLAUDE.md in addition to cross-links. This is spec-aligned (the spec asks for cross-links from CLAUDE.md) but slightly exceeds the narrow "pointer sentence" I scoped in the prompt. | No functional issue — the section is a valid, useful cross-link. | None — accept. |
| LOW | L2: Worker-23 (T05.2) committed its proofs alongside T04.6's in b6700e3 rather than its own commit. | Same as M6. | None — accept. |

## Gate Results

| Gate | Rule | Status | Rationale |
|---|---|---|---|
| **A** | No CRITICAL or HIGH severity issues | PASS | H1 resolved in `303b420`; no remaining HIGH issues |
| **B** | No `Unknown` entries in coverage matrix | PASS | All 31 requirements have status |
| **C** | All proof artifacts accessible and functional | PASS | All re-executed proofs pass |
| **D** | Changed files in scope or justified | PASS | All 135 changed files map to declared scope |
| **E** | Implementation follows repo standards | PASS | All 9 SKILL.md markers consistent post-remediation |
| **F** | No real credentials in proof artifacts | PASS | grep for api_key/password/token patterns: clean |

All 6 gates pass. MEDIUM issues (M1-M6) are non-blocking hygiene.

## Evidence Appendix

### Git commits in range

```
f4c87e3 feat(arc): rewrite 9 SKILL.md descriptions to pushy standard (T01.1)
a4f9f54 docs(arc): author references/frontmatter-fields.md — frontmatter contract (T02.1)
dc50e90 docs(arc): author skill-orchestration.md with state vector, validity matrix, invariants, and precedence (T03.1)
c940523 feat(arc): populate requires/produces/consumes/triggers in 9 SKILL.md frontmatters (T02.2)
5ab9713 feat(templates): add wave-report, audit-report, and shape-report output templates (T05.1)
ba400f9 feat(arc): author 4 JSON Schemas under schemas/ (T04.2)
9c34b91 docs(arc): decide ajv-cli@5 for schema validation and document canonical invocation (T04.1)
1307d48 test(arc): seed 9 trigger-eval JSON files (T06.1)
2db0add feat(arc): add scripts/parse-frontmatter.sh emitting Mermaid + JSON dependency graphs (T02.3)
a7e9061 feat(arc): implement validate-brief.sh and validate-roadmap.sh (T04.4)
b865488 feat(arc): add scripts/state.sh emitting the Arc project state vector as JSON (T04.5)
cc5dc4c feat(arc): implement scripts/validate-backlog.sh (T04.3)
4f846f6 fix(arc): correct 3 context-marker headers to ARC-{SKILL-NAME} convention (T01.2)
15f1298 feat(arc): update marketplace.json and plugin.json to list all 9 skills (T01.3)  [+ T01.4 bundled]
1cb1a0e docs(arc): cross-link skill-orchestration.md from CLAUDE.md, README.md, references/README.md (T03.2)
6ad4e82 feat(arc): capture dependency-graph.md and frontmatter-parse.json proofs (T02.4)
130fb3f docs(arc): capture state-example.md proof with 9 state→skill mapping rows (T03.3)
b6700e3 test(arc): add schemas/tests/ pass+fail fixtures for all 4 schemas (T04.6)  [+ T05.2 bundled]
3f51c9d docs(arc): document trigger-eval runner invocation in tests/trigger-evals/README.md (T06.2)
6bed4d7 feat(arc): render 3 filled-in template examples as proofs (T05.3)
4bb33c9 test(arc): capture validate-pass.txt and validate-fail.txt proof transcripts (T24)
be08da3 test(arc): commit manual baseline eval results for all 9 trigger-eval skills (T06.3)
d9aa95b test(arc): capture eval-baseline-summary.md with perfect 100% accuracy (T06.4)
```

### Re-executed proofs

```
$ ./scripts/state.sh
{
  "idea_status_counts": {"captured": 20, "shaped": 0, "spec_ready": 0, "shipped": 0},
  "wave_active": false, "current_wave": null, "validation_status": "PASS",
  "gaps": [...], "timestamp": "2026-04-24T01:10:48Z"
}
# exit 0

$ ./scripts/validate-backlog.sh docs/BACKLOG.md
validate-backlog: PASS -- 20 entries validated (20 pass, 0 fail)
# exit 0

$ ./scripts/parse-frontmatter.sh --format mermaid skills/arc-*/SKILL.md
(21-line Mermaid block with 9 nodes, 6 sibling edges, 1 external upstream)
# exit 0
```

### File scope check

All 135 changed files fall into declared spec scope:
- `skills/arc-*/SKILL.md` (9) — Units 1, 2, 5
- `.claude-plugin/{plugin,marketplace}.json` (2) — Unit 1
- `CLAUDE.md`, `README.md` (2) — Units 1, 3
- `references/{frontmatter-fields,schema-tooling,skill-orchestration,README}.md` (4) — Units 2, 3, 4
- `schemas/*.json`, `schemas/tests/*.json` + README (14) — Unit 4
- `scripts/{parse-frontmatter,state,validate-*}.sh` (5) — Units 2, 4
- `templates/{wave,audit,shape}-report.tmpl.md` (3) — Unit 5
- `tests/trigger-evals/*.json`, README.md (19) — Unit 6
- `docs/specs/15-spec-agent-utilization-upgrade/**` (proof artifacts + research report) — all units
- `docs/specs/01-spec-description-rewrite-pack/**` (2 — M1, misplaced) — Unit 1 (misplaced but in-scope)

No out-of-scope changes.

---

**Validation performed by:** Claude Opus 4.7 (1M context) — claude-opus-4-7

## Remediation Log

1. **H1 (HIGH)** — RESOLVED in commit `303b420` (`fix(arc): align body context-markers with header markers in 3 SKILL.md files (H1)`). Verification: single `ARC-{SKILL-NAME}` marker per SKILL.md; all 9 files pass.
2. **M1–M5 (MEDIUM)** — proof-path hygiene items remain. Optional follow-up `git mv` cleanup commits; not blocking.
3. **M6 (MEDIUM)** — bundled commits `b6700e3` (T04.6+T05.2) and `15f1298` (T01.3+T01.4) — history-only; non-blocking. Future dispatches should enforce one-commit-per-task.

Re-run status: Gates A and E promoted to PASS after `303b420`.
