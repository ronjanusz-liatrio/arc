# Validation Report: arc-status Wave Precedence

**Validated**: 2026-04-24T12:00:00Z
**Spec**: /home/ron.linux/arc/docs/specs/16-spec-arc-status-wave-precedence/16-spec-arc-status-wave-precedence.md
**Overall**: PASS
**Gates**: A[P] B[P] C[P] D[P] E[P] F[P]

## Executive Summary

- **Implementation Ready**: Yes — Every Unit 1 and Unit 2 functional requirement has corresponding edits in `skills/arc-status/SKILL.md` and `skills/arc-status/references/status-dimensions.md`, all 8 proof artifacts re-executed successfully, and file-scope is precisely bounded to the two files the spec names as Proof Artifacts (plus proof-artifact files under the spec directory).
- **Requirements Verified**: 23/23 (100%) — All Unit 1 (11) + Unit 2 (12) functional requirement bullets covered by at least one proof.
- **Proof Artifacts Working**: 24/24 (100%) — 8 proof summary `.md` files plus 24 individual proof outputs across T01.1–T01.5 and T02.1–T02.3. Re-execution of key verification commands confirms current state matches recorded expectations.
- **Files Changed vs Expected**: 2 implementation files changed (`skills/arc-status/SKILL.md`, `skills/arc-status/references/status-dimensions.md`); both are named verbatim in the spec's Proof Artifacts. Remaining 33 changed paths are proof artifacts under the spec directory.

## Coverage Matrix: Functional Requirements

### Unit 1 — Wave-Linkage Detection and Gap Scoping

| Requirement | Task | Status | Evidence |
|-------------|------|--------|----------|
| Extract active wave name from ROADMAP first non-Completed row (null fallback) | T01.1 | Verified | `SKILL.md` Step 2 lines 60, 68–76; re-executed grep yields 5 hits. T01.1-02-cli.txt. |
| Extract active wave status (`planned`/`active`) from same row; null when wave name is null | T01.1 | Verified | `SKILL.md` Step 2 line 76 "active wave status — the verbatim string in the Status column". T01.1-proofs.md. |
| Compute wave-linked idea set via exact case-sensitive match + whitespace trim | T01.2 | Verified | `SKILL.md` Step 6.0 lines 173–186; `status-dimensions.md` WL-2 lines 407–439. Re-executed grep yields 16 matches. |
| Tag each gap with scope (wave-linked / backlog-only / -- for skipped) | T01.3 | Verified | `SKILL.md` Step 6.6 lines 234–251; `status-dimensions.md` WL-3 lines 441–465. Re-executed grep yields 12 matches across LG-1..LG-5. |
| LG-3/LG-4 spec-to-idea linkage via `Spec:` field | T01.2, T01.3 | Verified | `SKILL.md` line 188 (preamble); Step 6.6 item 3 lines 242–245; `status-dimensions.md` WL-3 steps 2a–2c. |
| Render Scope column only when active wave exists; Wave: {name} / Backlog (outside wave) cells | T01.4 | Verified | `SKILL.md` lines 280–295 (four-col branch) vs. lines 267–279 (three-col branch). T01.4-02-cli.txt shows 10 render-string matches. |
| Three-column fallback when no active wave | T01.4 | Verified | `SKILL.md` lines 266–278 (no-wave branch). |
| Skipped-check rows render `--` in Scope column when present | T01.4 | Verified | `SKILL.md` line 295 `(skipped — {reason}) \| -- \| --`; line 278 three-column variant. |
| `No lifecycle gaps detected.` message unchanged | T01.4 | Verified | `SKILL.md` lines 259–264; line 297 trailing reminder. |
| Wave name verbatim pass-through (em dashes, colons) | T01.4, T02.1 | Verified | `SKILL.md` line 293 "no escaping, no trimming, no case folding"; `status-dimensions.md` WL-2 line 427 (hyphen vs. em-dash warning). |
| `status-dimensions.md` documents Wave Linkage Detection (WL-1..WL-4) | T01.5 | Verified | Section `## Wave Linkage Detection` at line 371 with WL-1 (377), WL-2 (407), WL-3 (441), WL-4 (468), Worked Example (483). |

### Unit 2 — Wave-Priority Next-Step Precedence

| Requirement | Task | Status | Evidence |
|-------------|------|--------|----------|
| Replace Step 7 with 14-row precedence table (first-match-wins) | T02.1 | Verified | `SKILL.md` Step 7 lines 305–322. Re-executed row count: 14 rows. |
| Priority 1 empty wave → `/arc-wave` | T02.1 | Verified | `SKILL.md` line 309. |
| Priorities 2–6 wave-linked LG-5..LG-1 remediation skills | T02.1 | Verified | `SKILL.md` lines 310–314. |
| Priority 7 planned clean wave → `/arc-wave`; Priority 8 active clean wave → `/arc-audit` | T02.1 | Verified | `SKILL.md` lines 315–316. |
| Priorities 9–13 no-wave LG-5..LG-1 remediation skills | T02.1 | Verified | `SKILL.md` lines 317–321. |
| Priority 14 no-wave no-gaps → `/arc-wave` | T02.1 | Verified | `SKILL.md` line 322. |
| Alternative-skill selection rules for all 14 priorities | T02.2 | Verified | `SKILL.md` lines 339–353 (14-row alternative table). Reference has 14 matching rows at lines 576–589. |
| Backlog-only gaps never satisfy P2–6; not considered by P7/P8 | T02.1 | Verified | `SKILL.md` line 326 "Wave scope and backlog-only gaps" clarifier paragraph; `status-dimensions.md` Evaluation Logic step 2 lines 550–551. |
| AskUserQuestion always includes Recommended + alternative + Done for now (≥3 options) | T02.2 | Verified | `SKILL.md` line 334 (three-options body directive); line 385 "ALWAYS include 'Done for now'"; prompt-shape code block at lines 360–371. |
| Priority 6/13 P0/P1 filter reads `Priority:` from BACKLOG metadata | T02.1 | Verified | `SKILL.md` line 324 clarifier paragraph; `status-dimensions.md` Evaluation Logic lines 556–557. |
| Wave-name verbatim interpolation (no escaping beyond JSON) | T02.1 | Verified | `SKILL.md` line 328; `status-dimensions.md` line 562. |
| `status-dimensions.md` Next-Step Precedence section rewritten | T02.3 | Verified | Section at line 517, 14-row precedence table at line 527, 14-row alternative-skill table at line 576, User Selection Handling preserved at line 613. |

## Coverage Matrix: Repository Standards

| Standard | Status | Evidence |
|----------|--------|----------|
| Arc skill context marker `**ARC-STATUS**` preserved | Verified | SKILL.md line 27 unchanged. |
| Read-only skill operation | Verified | Frontmatter `produces: files: []` preserved (line 13). No write/edit tool in `allowed-tools` (line 5). |
| AskUserQuestion for all skill invocation prompts | Verified | Step 7 prompt block lines 360–371; no auto-invocation. Critical Constraint line 384 "NEVER invoke a skill automatically". |
| Conventional commit messages (`feat(arc-status): ...`, `docs(arc-status): ...`) | Verified | All 8 commits follow `type(scope): subject (TNN.M)` pattern. |
| Bash vs. built-in tools rules from CLAUDE.md | Verified | No `cat`/`head`/`sed` in SKILL.md procedure; uses Glob/Grep/Read per frontmatter `allowed-tools`. |
| Frontmatter validity | Verified | `parse-frontmatter.sh --format json` exits 0; `validate-backlog.sh` PASS (20 entries); `validate-roadmap.sh` PASS. |

## Coverage Matrix: Proof Artifacts

| Task | Artifact | Type | Capture | Status | Current Result |
|------|----------|------|---------|--------|----------------|
| T01.1 | Step 2 diff | file | auto | Verified | T01.1-01-file.txt present (4029 B). |
| T01.1 | `active wave name`/`status` grep (Step 2) | cli | auto | Verified (re-run) | 5 hits — matches recorded expectation. |
| T01.1 | Frontmatter JSON parse | cli | auto | Verified (re-run) | `parse-frontmatter.sh --format json` exits 0. |
| T01.2 | Step 6.0 diff | file | auto | Verified | T01.2-01-file.txt present (3752 B). |
| T01.2 | Step 6.0 content grep | cli | auto | Verified (re-run) | 16 hits — exceeds recorded 8-hit threshold. |
| T01.2 | Combined validators | cli | auto | Verified (re-run) | validate-backlog PASS; validate-roadmap PASS. |
| T01.3 | Step 6.6 diff | file | auto | Verified | T01.3-01-file.txt present (5097 B). |
| T01.3 | Step 6.6 content grep | cli | auto | Verified (re-run) | 12 hits across LG-1..LG-5 + skipped-check + no-active-wave + Spec:-field. |
| T01.3 | Structural ordering | cli | auto | Verified (re-run) | `grep -n '^#### Step\|^#### LG-\|^#### Emit\|^### Step'` shows Step 6 (167) → 6.0 (173) → LG-1..5 → 6.6 (234) → Emit (255) → Step 7 (301). |
| T01.4 | Emit-block diff | file | auto | Verified | T01.4-01-file.txt present (4392 B). |
| T01.4 | Render-string content check | cli | auto | Verified (re-run) | 5 unique render strings match (`Gap \| Item \| Remediation \| Scope`, `Backlog (outside wave)`, `Wave: {wave_name}`, `No lifecycle gaps detected`). |
| T01.4 | Structural preservation | cli | auto | Verified (re-run) | Step ordering preserved; validators PASS. |
| T01.5 | Section-structure file check | file | auto | Verified | WL-1..WL-4 + Worked Example headings present at documented line numbers. |
| T01.5 | Content-completeness check | file | auto | Verified | All required tokens present in `status-dimensions.md`. |
| T01.5 | Section-ordering check | file | auto | Verified | Lifecycle Gap Detection (181) → Wave Linkage Detection (371) → Next-Step Precedence (517). |
| T02.1 | Step 7 hunk diff | file | auto | Verified | T02.1-01-file.txt present (6791 B). |
| T02.1 | 14-row precedence count | cli | auto | Verified (re-run) | `awk ... \| grep -nE '^\| [0-9]+ \|' \| wc -l` returns 14. |
| T02.1 | Three clarifier paragraphs | cli | auto | Verified (re-run) | `grep -cE '^\*\*Priority 6.*\*\*\|...'` returns 3. |
| T02.2 | Alternative-skill table content | file | auto | Verified | T02.2-01-file.txt present (4050 B). |
| T02.2 | Three-options invariant | file | auto | Verified | `SKILL.md` line 334 directive; Done-for-now in prompt block. |
| T02.2 | Scope confinement | file | auto | Verified | Edits only in Step 7 Present Recommendation block. |
| T02.3 | Precedence table rewrite | file | auto | Verified (re-run) | Reference lines 525–542 contain 14-row table matching SKILL.md. |
| T02.3 | Alternative-skill rewrite | file | auto | Verified (re-run) | Reference lines 574–589 contain 14-row alternative table matching SKILL.md. |
| T02.3 | Evaluation Logic + branches + WL cross-ref | file | auto | Verified | Reference line 521 cross-references Wave Linkage Detection; Evaluation Logic section at line 546. |
| T02.3 | Scope confinement | file | auto | Verified | User Selection Handling preserved at line 613; Wave Linkage Detection (371–515) untouched. |

## Gherkin Scenario Coverage

Both feature files' scenarios map onto documented SKILL.md behavior:

- **wave-linkage-detection-and-gap-scoping.feature** (9 scenarios): All covered by `SKILL.md` Steps 2 / 6.0 / 6.6 / Emit Lifecycle Gaps and `status-dimensions.md` WL-1..WL-4.
- **wave-priority-next-step-precedence.feature** (14 scenarios): All covered by `SKILL.md` Step 7 Precedence List (P1–P14), clarifier paragraphs (P6/P13 filter, backlog-only suppression, wave-name interpolation), and Present Recommendation alternative-selection table.

The spec explicitly defers CLI end-to-end fixture runs to future work (Non-Goals: "No new test runner is added"). Proof-artifact verification is therefore structural/content-level, which matches the spec's proof strategy.

## Validation Issues

| Severity | Issue | Impact | Recommendation |
|----------|-------|--------|----------------|
| OK | — | — | — |

No CRITICAL, HIGH, or MEDIUM findings. No missing proofs. No out-of-scope file changes. No credential leakage. All re-executed commands produce expected output. Structural invariants (Step ordering, section ordering, row counts, frontmatter validity) hold.

## Evidence Appendix

### Git Commits (implementation)

```
046db50 feat(arc-status): extract active wave status in Step 2 (T01.1)
574dbe1 docs(arc-status): document wave-linkage algorithm in status-dimensions.md (T01.5)
c1cb3b9 feat(arc-status): compute wave-linked idea set in Step 6 preamble (T01.2)
eaa12bc feat(arc-status): rewrite Step 7 precedence with 14 priorities (T02.1)
7a15ba5 feat(arc-status): tag each lifecycle gap with scope field (T01.3)
178b7bf feat(arc-status): implement alternative-skill selection rules (T02.2)
4d26641 feat(arc-status): render conditional Scope column in Lifecycle Gaps table (T01.4)
304c71b docs(arc-status): rewrite Next-Step Suggestion Precedence reference section (T02.3)
```

### Re-Executed Proofs (summary)

- `awk '/^### Step 2/,/^### Step 3/' skills/arc-status/SKILL.md | grep -nE '(active wave name|active wave status)'` → 5 hits (T01.1 ✓)
- `awk '/^### Step 6/,/^### Step 7/' skills/arc-status/SKILL.md | grep -nE '(wave-linked idea set|active wave name|exact case-sensitive|Step 6.0)'` → 16 hits (T01.2 ✓)
- `awk '/^#### Step 6.6:/,/^#### Emit Lifecycle Gaps/' skills/arc-status/SKILL.md | grep -nE '(LG-[1-5]|Skipped checks|No active wave|Spec: field|wave-linked idea set)'` → 12 hits (T01.3 ✓)
- `awk '/^#### Emit Lifecycle Gaps/,/^### Step 7:/' skills/arc-status/SKILL.md | grep -cE '...render strings...'` → 5 unique hits (T01.4 ✓)
- `awk '/^### Step 7/,/^### Step 8|^## References/' skills/arc-status/SKILL.md | grep -nE '^\| [0-9]+ \|' | wc -l` → 14 (T02.1 ✓)
- Clarifier paragraph count → 3 (T02.1 ✓)
- `awk '/^### AskUserQuestion Format/,/^### User Selection Handling/' skills/arc-status/references/status-dimensions.md | grep -cE '^\| [0-9]+'` → 14 (T02.2/T02.3 ✓)
- `awk '/^## Next-Step Suggestion Precedence/,/^## Cross-References/' skills/arc-status/references/status-dimensions.md | grep -cE '^\| [0-9]+ \|'` → 14 (T02.3 ✓)
- `bash scripts/parse-frontmatter.sh skills/arc-status/SKILL.md --format json` → exit 0
- `bash scripts/validate-backlog.sh` → PASS (20 entries)
- `bash scripts/validate-roadmap.sh` → PASS (empty table acceptable)

### File Scope Check

Implementation files changed across the 8 commits:

| File | In Spec's Proof Artifacts? | Notes |
|------|----------------------------|-------|
| `skills/arc-status/SKILL.md` | Yes (Unit 1 and Unit 2 both name it) | Edits confined to Step 2 (T01.1), Step 6.0 (T01.2), Step 6.6 (T01.3), Emit block (T01.4), Step 7 precedence table + clarifier paragraphs (T02.1), Step 7 Present Recommendation (T02.2). |
| `skills/arc-status/references/status-dimensions.md` | Yes (Unit 1 and Unit 2 both name it) | New Wave Linkage Detection section (T01.5); Next-Step Suggestion Precedence section rewritten (T02.3). User Selection Handling preserved. |
| 33 proof-artifact files under `docs/specs/16-spec-arc-status-wave-precedence/{01,02,16}-proofs/` | N/A (proofs live by convention under the spec dir) | Scoped entirely to this spec. |

No out-of-scope implementation files were changed.

### Credential Scan

Regex sweep over all proof `.txt`/`.md` files for `(api[_-]?key|password|secret|token|AKIA|BEGIN.*PRIVATE KEY|aws_secret|bearer [...]|xox[baprs]-|ghp_[...]|sk-[...])` returned 2 hits — both are prose uses of the word "token" in T01.5 proof text and the spec-row reference in T02.1 proofs ("wave-name substitution token"). No real credentials.

### Gate Determinations

- **Gate A — No CRITICAL/HIGH severity issues**: PASS. No issues at any severity above OK.
- **Gate B — No Unknown entries in coverage matrix**: PASS. Every requirement row is marked Verified.
- **Gate C — All proof artifacts accessible and functional**: PASS. All 8 proof summary files present; all 24 individual proof files readable; re-execution of structural/content commands produces expected results.
- **Gate D — Changed files in scope or justified**: PASS. Only the two files named verbatim in the spec's Proof Artifacts are changed in implementation; all other changes are proof-artifact files under the spec directory. Each commit's scope matches its task ID (T01.1…T02.3).
- **Gate E — Implementation follows repository standards**: PASS. Arc skill context marker preserved, read-only frontmatter invariant preserved, AskUserQuestion mandatory, conventional commit messages, frontmatter/backlog/roadmap validators all PASS.
- **Gate F — No real credentials in proof artifacts**: PASS. Credential regex sweep returns only prose matches; no API keys, secrets, or tokens.

---
Validation performed by: Opus 4.7 (1M context) acting as Validator agent.
