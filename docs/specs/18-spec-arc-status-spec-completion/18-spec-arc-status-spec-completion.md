# 18-spec-arc-status-spec-completion

## Introduction/Overview

`/arc-status` produces misleading pulse output today: spec directories that bypassed the `/arc-capture → /arc-shape → /arc-wave → /arc-ship` lifecycle are silently invisible to lifecycle-gap detection, and the In-Flight Specs table lists every spec directory ever created with no completion filter. This spec adds a sixth lifecycle gap (LG-6) that surfaces PASS-validated orphan specs and extends the In-Flight Specs table to exclude specs already present in the wave archive — restoring `/arc-status` as a trustworthy pulse check for the Product Owner persona.

## Goals

1. Surface every PASS-validated spec directory that has no linked BACKLOG idea as an LG-6 row in the Lifecycle Gaps table, so lifecycle bypasses are visible.
2. Filter the In-Flight Specs table to only show spec directories that are not yet present in `docs/skill/arc/waves/*.md` (the authoritative completion signal from spec 13).
3. Preserve LG-1..LG-5 detection logic and existing precedence priorities 1–13 byte-for-byte — this spec is append-only.
4. Keep `/arc-status` read-only and idempotent across repeat invocations.
5. Extend the worked example in `status-dimensions.md` so documentation reflects the new behavior.

## User Stories

- As a Product Owner running `/arc-status`, I want to see PASS-validated spec directories that lack a BACKLOG idea so I know which work shipped without lifecycle bookkeeping and can retroactively capture it.
- As a Product Owner running `/arc-status`, I want the In-Flight Specs table to exclude specs that have already shipped so the table reflects work actually in progress.
- As a Tech Lead reading the `/arc-status` output, I want LG-1..LG-5 row content and existing precedence priority numbering to remain stable so my mental model of the skill is preserved.
- As a maintainer of `/arc-status`, I want the worked example in `status-dimensions.md` to demonstrate LG-6 and the filtered In-Flight behavior so future contributors have a concrete reference.

## Demoable Units of Work

### Unit 1: Add LG-6 (Orphan Spec) Detection

**Purpose:** Surface PASS-validated spec directories that have no BACKLOG `Spec:` linkage as a new lifecycle gap, so specs that bypassed the Arc lifecycle become visible in `/arc-status`.

**Functional Requirements:**

- The system shall add a new section `LG-6: Orphan Spec` to Step 6 of `skills/arc-status/SKILL.md`, positioned after the existing `LG-5: Validation → Shipped` section and before `Step 6.6: Tag Each Gap with Scope (Postamble)`.
- The system shall define LG-6 detection as: (a) glob `docs/specs/NN-spec-*/` directories; (b) for each spec dir, glob `{dir}/*-validation-*.md` and search for the literal string `**Overall**: PASS`; (c) if a PASS validation report exists, scan `docs/BACKLOG.md` idea entries for any `Spec:` field whose value (after whitespace trim and trailing-slash normalization) equals the spec directory path; (d) if no matching idea is found, flag the spec directory as an LG-6 gap.
- The system shall set the LG-6 detection error model to skipped-check-with-warning, matching LG-1..LG-5 behavior — unreadable validation report, malformed BACKLOG metadata, or directory enumeration failure shall not abort the gap pass.
- The system shall extend Step 6.6 (Tag Each Gap with Scope) so that LG-6 gaps always evaluate to `scope = backlog-only` because, by construction, no linked backlog idea exists. The new rule shall be added as item 6 in the existing numbered list (between current item 5 for LG-5 and current item 6 for skipped checks); the existing items 6 and 7 shall be renumbered to 7 and 8 respectively. This is the only renumbering this spec performs and applies only to the post-detection scope-tagging numbered list inside Step 6.6.
- The system shall add a new precedence priority for the no-wave LG-6 case to Step 7's precedence table, inserted between current Priority 13 (no-wave LG-1 P0/P1) and current Priority 14 (no wave, no gaps). The recommended skill is `/arc-capture` with reason template `"{NN}-spec-{name} has a PASS validation report but no BACKLOG idea — capture it?"`. The previous Priority 14 row ("No active wave AND no gaps") shall be renumbered to Priority 15. No other priorities shall be renumbered.
- The system shall add a corresponding row to Step 7's "Alternative Skill Selection Rule" table for the new no-wave LG-6 priority, with alternative = `/arc-audit` (no lower-priority no-wave gap exists).
- The system shall extend the Lifecycle Gaps table emit logic in Step 6 to render LG-6 gaps using the row format `| Orphan Spec | {NN}-spec-{name} | Run /arc-capture |` (three-column form) or `| Orphan Spec | {NN}-spec-{name} | Run /arc-capture | Backlog (outside wave) |` (four-column form when an active wave exists).
- The system shall update `skills/arc-status/references/status-dimensions.md` to add a `LG-6 Orphan Spec` subsection under Lifecycle Gap Detection that mirrors the LG-5 detection format (predicates, output format, error handling) and to extend WL-3 (Gap Scope Tagging) with the LG-6 always-`backlog-only` rule.
- The system shall keep all existing LG-1..LG-5 detection text byte-for-byte unchanged — no edits to those subsections beyond the addition of a new sibling subsection after them.
- The system shall keep all existing precedence priorities 1–13 byte-for-byte unchanged — no edits to existing rows except inserting the new no-wave LG-6 row between rows 13 and 14, renumbering only the previous Priority 14 row to Priority 15.

**Proof Artifacts:**

- File: `skills/arc-status/SKILL.md` contains a new `#### LG-6: Orphan Spec` section between LG-5 and Step 6.6, and Step 7's precedence table contains a new row referencing `/arc-capture` for the no-wave orphan-spec case.
- File: `skills/arc-status/references/status-dimensions.md` contains an `LG-6 Orphan Spec` subsection under Lifecycle Gap Detection and a WL-3 entry covering LG-6 scope tagging.
- CLI: A manual run of `/arc-status` against the current repo state surfaces spec 17 (`17-spec-claude-md-static-references`) and any other PASS-validated orphan specs as LG-6 rows in the Lifecycle Gaps table, with remediation text `Run /arc-capture`.
- Test: A byte-for-byte diff of the LG-1..LG-5 subsections in `skills/arc-status/SKILL.md` between the working tree and the parent commit shows zero changes.
- Test: A byte-for-byte diff of precedence rows 1–13 in Step 7's precedence table between the working tree and the parent commit shows zero changes.

### Unit 2: Filter In-Flight Specs by Wave Archive

**Purpose:** Exclude already-shipped spec directories from the In-Flight Specs table so the section reflects spec directories actively in progress, not every spec ever created.

**Functional Requirements:**

- The system shall extend Step 4 (In-Flight Specs) of `skills/arc-status/SKILL.md` so that, after globbing `docs/specs/NN-spec-*/` directories, a "completed-spec set" is computed from the wave archive.
- The system shall define the completed-spec set as: the union of (a) every `### {Title}` H3 subsection title that exactly matches a spec directory basename, and (b) every `**Spec:** {path}` field value whose path (after trailing-slash normalization) resolves to a spec directory basename, across all `docs/skill/arc/waves/*.md` files.
- The system shall exclude spec directories whose basename is in the completed-spec set from the rendered In-Flight Specs table.
- The system shall apply the exclusion silently — no count footer, no parenthetical, no separate "Completed Specs" table. The output shape stays exactly as defined today, only the row set is reduced.
- The system shall preserve the existing fallback behavior: if no spec directories remain in-flight after exclusion, emit the existing fallback notice `No specs found — run /cw-spec to create a specification.` (already specified for the empty-glob case; the empty-after-filter case shall use the same notice).
- The system shall sort remaining in-flight specs by NN prefix ascending, identical to the existing behavior.
- The system shall update `skills/arc-status/references/status-dimensions.md` SD-3 (In-Flight Specs) section to document the completed-spec exclusion rule, including the union signal definition and silent-exclusion behavior.
- The system shall not change the per-row artifact detection columns (Spec File, Plan, Validation) or their existing yes/no logic.

**Proof Artifacts:**

- File: `skills/arc-status/SKILL.md` Step 4 contains the completed-spec set definition and exclusion rule, with a reference to SD-3 in `status-dimensions.md`.
- File: `skills/arc-status/references/status-dimensions.md` SD-3 documents the union signal (subsection-title-match OR `Spec:`-field-match) and the silent-exclusion rule.
- CLI: A manual run of `/arc-status` against the current repo state shows the In-Flight Specs table with shipped spec directories (e.g., `04-spec-arc-readme`, `05-spec-arc-help`, `10-spec-arc-ship`, `11-spec-shape-skill-discovery`, `12-spec-arc-status`, `13-spec-wave-archive`) absent from the table.
- CLI: A manual run of `/arc-status` against the current repo state shows orphan specs (e.g., `17-spec-claude-md-static-references`) still present in the In-Flight Specs table — orphans are not "completed" and remain in-flight by definition.
- Test: A byte-for-byte diff of the `Step 4` per-row artifact detection prose (Spec File / Plan / Validation logic) between the working tree and the parent commit shows zero changes.

## Non-Goals (Out of Scope)

- Auto-creating BACKLOG entries for orphan specs. LG-6 surfaces them; the user runs `/arc-capture` separately.
- Adding a "validated but unshipped" intermediate status. Wave archive remains the single completion source of truth.
- Modifying `/arc-ship`, `/arc-assess`, or any non-`/arc-status` skill.
- Renumbering or rewording existing LG-1..LG-5 detection text or precedence priorities 1–13.
- Changing the existing scope-column rendering rules (WL-4) for skipped checks or for active-wave gaps. LG-6 plugs into the existing rules.
- Adding a count footer, "Completed Specs" sidebar, or any other output surface to the In-Flight Specs table.
- Detecting orphan specs that lack a validation report (those would be caught by LG-3 or LG-4 if linked, and are out of scope when unlinked — the user's intent is "shipped without lifecycle bookkeeping," which implies PASS validation).
- Backporting LG-6 to past `/arc-status` runs — applies prospectively from this spec's merge.

## Design Considerations

This spec is documentation-only — `/arc-status` is a prose-driven Markdown skill (`skills/arc-status/SKILL.md`). All "design" lives in the rule prose and the worked example in `status-dimensions.md`. There is no UI, no CLI argument, and no new file format. The rendered output of `/arc-status` is plain Markdown text the agent emits inline; this spec changes which rows appear and adds one new row type, not the table syntax itself.

## Repository Standards

- Conventional commits per `CLAUDE.md`: `type(scope): description` with `scope = arc-status` for skill edits and `scope = arc-status-ref` for reference doc edits, or a single `feat(arc-status):` if grouped.
- Edits use `Edit`/`Write` tools, never shell text-processing tools (per project convention).
- Skill SKILL.md frontmatter (`requires`, `produces`, `consumes`) is unchanged — this spec does not change the skill's I/O contract.
- The skill context marker `**ARC-STATUS**` at the top of `skills/arc-status/SKILL.md` is preserved.
- Markdown table formatting matches existing tables (pipe-separated, header + separator + rows).
- Both demoable units are independent — no cross-unit edit ordering required.

## Technical Considerations

- The completed-spec union is computed from wave archive files only; there is no caching or precomputation. Each `/arc-status` invocation re-reads the archives. This matches existing SD-2 shipped-count derivation.
- The LG-6 detection scan is bounded by the number of spec directories (currently 18) times the validation-report glob (small constant). Negligible runtime impact.
- Trailing-slash normalization on `Spec:` field comparisons reuses the same rule already used for LG-3/LG-4 spec-to-idea linkage (WL-3) — strip trailing slash before comparison.
- The In-Flight filter uses spec directory basename matching. If a wave archive subsection title contains a spec directory basename as a substring but is not exact, it must not match. Comparisons are exact, case-sensitive, after whitespace trim.
- LG-6 always evaluates to `scope = backlog-only` because there is no linked backlog idea. In the active-wave four-column rendering, the Scope cell is the literal `Backlog (outside wave)` (existing rendering rule applies — no new rule needed).
- The new no-wave LG-6 precedence priority sits below LG-1 P0/P1 (Priority 13) because orphan-spec remediation is non-blocking — the user can choose to capture the spec or not. Placing it before "no wave, no gaps" (formerly Priority 14) ensures it surfaces before the empty-state recommendation.

## Security Considerations

None. `/arc-status` is read-only, performs no network I/O, and reads only project-local Markdown files. The new logic does not introduce any new file reads outside `docs/specs/`, `docs/BACKLOG.md`, and `docs/skill/arc/waves/` — all already read by the existing skill.

## Success Metrics

- Re-running `/arc-status` against the current repo state produces an LG-6 row for `17-spec-claude-md-static-references` (and any other PASS-validated orphan specs present at the time of the run).
- Re-running `/arc-status` against the current repo state shows the In-Flight Specs table with shipped specs (those linked to a wave archive entry) absent.
- A `git diff` of `skills/arc-status/SKILL.md` and `skills/arc-status/references/status-dimensions.md` shows only additive changes plus the single Step 6.6 numbered-list renumbering and the single Priority 14 → 15 renumbering — no other deletions or rewrites in pre-existing rule prose.
- `/arc-status` output remains read-only (no file writes during invocation).
- Re-running `/arc-status` twice in a row produces identical output (idempotency).

## Open Questions

No open questions at this time.
