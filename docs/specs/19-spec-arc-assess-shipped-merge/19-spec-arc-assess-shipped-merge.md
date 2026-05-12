# 19-spec-arc-assess-shipped-merge

## Introduction/Overview

`/arc-assess` re-creates duplicate captured BACKLOG stubs from KW-19 user stories that originate in already-shipped specs, undoing the single-representation invariant that spec 08 enforced manually. This spec adds a "merge-candidate" sub-branch to KW-19 detection: when a user-story source resides in a spec whose dir is already present in `docs/skill/arc/waves/*.md`, `/arc-assess` emits a merge-candidate row in `align-report.md` instead of creating a captured stub. The user reviews candidates during the existing interactive confirmation flow and merges them manually into the shipped skill entry — `/arc-assess` never auto-rewrites wave archives.

## Goals

1. Eliminate duplicate captured stubs from KW-19 sources that live in already-shipped specs, restoring idempotency to `/arc-assess` re-runs.
2. Build a shipped-spec index from `docs/skill/arc/waves/*.md` using both subsection-title (`### {Title}`) and `**Spec:**` field signals OR'd.
3. Render merge candidates in a new "Merge Candidates" section of `docs/skill/arc/align-report.md` between "Imported Items by Artifact" and "Skipped Items".
4. Prompt the user via `AskUserQuestion` to disambiguate multi-match cases (≥2 shipped specs match) before writing the merge-candidate row. Auto-route single-match cases without prompting.
5. Preserve persona extraction (CUSTOMER.md side) for KW-19 sources from shipped specs — only the captured-stub creation is suppressed.
6. Make no changes to `align-manifest.md` schema, no auto-rewrites of wave archive `### User Stories` blocks, no changes to KW-1..KW-18 or KW-20..KW-22 classification.

## User Stories

- As a Tech Lead who reruns `/arc-assess` to audit migration health, I want shipped-spec user stories to be recognized as already-managed so that running the scan twice does not re-create the same captured stubs and break the single-representation invariant.
- As a Product Owner reviewing `align-report.md`, I want a distinct "Merge Candidates" section so I can see which user stories belong in shipped skill entries and route them manually without confusing them with new imports.
- As a Product Owner running `/arc-assess`, when a KW-19 source could merge into multiple shipped specs, I want an interactive prompt asking me which target to pick so the report records an unambiguous decision.
- As a Tech Lead auditing CUSTOMER.md after `/arc-assess`, I want persona extraction to still fire on shipped-spec stories so that any persona inferences continue to land in CUSTOMER.md even when the story body itself is a merge-candidate.

## Demoable Units of Work

### Unit 1: Shipped-spec merge-candidate classification end-to-end

**Purpose:** Build the shipped-spec index, branch KW-19 detection to emit merge-candidate rows, route multi-match cases through interactive confirmation, and render the new "Merge Candidates" section in `align-report.md`. Persona extraction continues to run unchanged. Everything ships as a single behavior change — detection, confirmation, and rendering land together.

**Functional Requirements:**

- The system shall, at the start of every `/arc-assess` run, build a "shipped-spec index" by reading every file matching `docs/skill/arc/waves/*.md` and collecting two sets: (a) `### {Title}` H3 subsection titles whose exact value matches a spec directory basename in `docs/specs/NN-spec-*/`, and (b) `**Spec:** {path}` field values whose path (after whitespace trim and trailing-slash normalization) resolves to a spec directory basename. The shipped-spec index is the union of (a) ∪ (b), keyed by spec directory basename, with each entry carrying back-references to the wave archive file and the matching skill heading.
- The system shall, when a KW-19 (`## User Stories`) match fires during scanning, look up the source spec directory basename in the shipped-spec index. If the basename is present, classify the match as `merge-candidate` instead of `captured-stub` and suppress the captured-stub creation for that source.
- The system shall, when a `merge-candidate` classification fires with exactly one matching shipped spec, auto-route the candidate to that target without prompting the user, and emit a single-row entry in the "Merge Candidates" section of `align-report.md`.
- The system shall, when a `merge-candidate` classification fires with ≥2 matching shipped specs, present an `AskUserQuestion` prompt naming the source path + line range and listing each matching spec as an option (label = spec directory basename, description = wave archive file + skill heading). Include `Skip this source` as the last option. Apply the user's selection to the merge-candidate row written to `align-report.md`. If the user selects `Skip this source`, write the row with a `(skipped by user)` annotation and do not auto-route.
- The system shall add a new top-level "Merge Candidates" section to `docs/skill/arc/align-report.md`, positioned between "Imported Items by Artifact" and "Skipped Items". The section shall render as a markdown table with columns `Source Path | Lines | Target Wave Archive | Target Skill Heading | Provenance`. The `Provenance` column shall contain the literal HTML-comment string used today in BACKLOG aligned-from headers, e.g., `<!-- aligned-from: {source_path}:{line_range} aligned-from-spec: {spec-dir-basename} -->`.
- The system shall, for multi-match rows in the "Merge Candidates" section, render each unselected candidate as a nested sub-bullet under the chosen-target row with the format `- candidate: {spec-dir-basename} ({wave-archive-file} → {skill-heading})` so the audit trail of the decision is preserved in-report.
- The system shall continue to run the KW-19 persona-extraction sub-step (CUSTOMER.md side) on shipped-spec sources — only the captured-stub creation is suppressed. Persona inferences land in CUSTOMER.md per the existing import-rules pipeline.
- The system shall write no rows to `docs/skill/arc/align-manifest.md` for merge-candidate classifications. The manifest tracks materialized imports only; merge candidates are report-only.
- The system shall update `skills/arc-assess/SKILL.md` to document the merge-candidate branch in the KW-19 classification rule and the new shipped-spec index pre-pass. The shipped-spec index build shall be described as a deterministic, side-effect-free read at the start of the run, with worst-case bounded I/O equal to the number of wave archive files (currently <10, expected to stay <50).
- The system shall update `skills/arc-assess/references/import-rules.md` KW-19 row to add the "shipped-spec" prefix branch alongside the existing `(deferred)` and `(open question)` prefix branches, with explicit handling for the merge-candidate routing.
- The system shall update `skills/arc-assess/references/detection-patterns.md` KW-19 entry to cross-reference the shipped-spec index pre-pass.
- The system shall update `skills/arc-assess/references/align-report-template.md` to document the new "Merge Candidates" section with column definitions, multi-match nested-bullet rendering, and worked example.
- The system shall keep KW-1..KW-18 and KW-20..KW-22 classification logic byte-for-byte unchanged in `skills/arc-assess/SKILL.md` and the references.
- The system shall keep `align-manifest.md` schema documentation unchanged.
- The system shall keep already-completed spec-08 manual merges in CUSTOMER.md and the wave archives untouched.

**Proof Artifacts:**

- File: `skills/arc-assess/SKILL.md` contains a new "Shipped-Spec Index" sub-section and a documented merge-candidate branch in KW-19 classification.
- File: `skills/arc-assess/references/import-rules.md` KW-19 row contains the "shipped-spec" branch with merge-candidate routing.
- File: `skills/arc-assess/references/detection-patterns.md` KW-19 entry cross-references the shipped-spec index pre-pass.
- File: `skills/arc-assess/references/align-report-template.md` contains a "Merge Candidates" section definition with column schema and worked example.
- CLI: Running `/arc-assess` against the current repo state produces an `align-report.md` whose "Merge Candidates" section contains rows for the 9 user stories that duplicated on the 2026-04-13 re-run (originating in specs 08, 09, 01-align-ignore-dirs). The same run produces zero new captured stubs in the "BACKLOG — Imported Items" table for those 9 sources.
- CLI: Running `/arc-assess` against the current repo state produces a CUSTOMER.md diff (or no-op manifest entry) for any persona inferences from KW-19 sources in shipped specs — persona extraction is observable.
- Test: A byte-for-byte diff of KW-1..KW-18 and KW-20..KW-22 detection prose in `skills/arc-assess/SKILL.md` and `references/import-rules.md` between the working tree and the parent commit shows zero changes.
- Test: A byte-for-byte diff of the `align-manifest.md` schema documentation between the working tree and the parent commit shows zero changes.
- CLI: Running `/arc-assess` twice consecutively produces identical `align-report.md` Merge Candidates sections (idempotency) when the user makes the same disambiguation selections both times.

## Non-Goals (Out of Scope)

- Auto-rewriting wave archive `### User Stories` blocks. This spec emits report-only annotations; the actual merge edit is a separate manual or future-skill workflow.
- Adding a manifest schema for merge-candidate entries. The manifest tracks materialized imports only.
- Backporting merge-candidate classification to pre-existing captured stubs in `docs/BACKLOG.md`. Applies prospectively from this spec's merge.
- Modifying spec 08's already-completed manual merges in `docs/CUSTOMER.md` or any wave archive's `### User Stories` block.
- Changing the existing `align-manifest.md` schema, the `align-report.md` template's other sections (Run Metadata, Imported Items, Skipped Items, Excluded from Scanning, Remaining Unmanaged Content, Discovery Flow), or any KW-N classification other than KW-19.
- Detecting merge candidates from non-spec sources (root README, prose docs, etc.). The shipped-spec index keys on spec directory basenames only.
- Updating `align-report.md` for already-shipped runs whose report files predate this spec's merge.

## Design Considerations

This spec is documentation-only — `/arc-assess` is a prose-driven Markdown skill plus reference files. All "design" lives in the rule prose, the align-report template, and the import-rules KW-19 branch. There is no UI, no CLI argument, and no new file format. The shipped-spec index is an in-memory computation during the run; it is not persisted.

The new "Merge Candidates" section in `align-report.md` matches the existing table style (pipe-separated, header + separator + rows). Multi-match nested-bullet rendering uses standard Markdown list nesting.

The `AskUserQuestion` prompt for multi-match cases reuses the existing `/arc-assess` interactive confirmation idiom — same `header` style, same `Skip this source` fallback option.

## Repository Standards

- Conventional commits per `CLAUDE.md`: `type(scope): description` with `scope = arc-assess` for skill edits, `scope = arc-assess-ref` for reference doc edits, or a single `feat(arc-assess):` if grouped.
- Edits use `Edit`/`Write` tools, never shell text-processing tools (per project convention).
- Skill SKILL.md frontmatter (`requires`, `produces`, `consumes`) is unchanged — this spec does not change the skill's I/O contract.
- The skill context marker `**ARC-ASSESS**` at the top of `skills/arc-assess/SKILL.md` is preserved.
- Markdown table formatting matches existing tables (pipe-separated, header + separator + rows).
- All edits target prose in `skills/arc-assess/SKILL.md`, `skills/arc-assess/references/import-rules.md`, `skills/arc-assess/references/detection-patterns.md`, and `skills/arc-assess/references/align-report-template.md` — no new files.

## Technical Considerations

- The shipped-spec index is built once per `/arc-assess` invocation and held in memory for the duration of the run. No caching, no persistence, no staleness.
- The trailing-slash normalization rule on `**Spec:** {path}` field comparisons matches the LG-3/LG-4 lookup in `/arc-status` (WL-3 in `status-dimensions.md`): strip trailing slash before comparison.
- Single-match auto-routing avoids prompt fatigue when most matches are unambiguous; multi-match interactive prompting preserves per-source context.
- The `AskUserQuestion` prompt for multi-match cases must include at least 2 options per the AskUserQuestion tool constraint. When only 2 candidates exist, the prompt renders 3 options total (candidate A, candidate B, Skip this source).
- Provenance comments follow the existing format used in BACKLOG aligned-from headers — no new format invented.
- The "Merge Candidates" section in `align-report.md` is omitted entirely when no merge candidates are found. The "no candidates" case renders no header and no empty table.

## Security Considerations

None. `/arc-assess` reads project-local Markdown files only — no network I/O, no secrets handling. The new shipped-spec index reads from `docs/skill/arc/waves/*.md` and `docs/specs/NN-spec-*/`, both already read by the existing skill. No new file reads outside the existing scope.

## Success Metrics

- Re-running `/arc-assess` against the current repo state surfaces all KW-19 sources from shipped specs (08, 09, 01-align-ignore-dirs at minimum) as "Merge Candidates" rows in `align-report.md` — not as "Imported Items by Artifact / BACKLOG" rows.
- The 9 user stories that duplicated on the 2026-04-13 re-run produce zero new captured stubs in `docs/BACKLOG.md` on a fresh `/arc-assess` run.
- Multi-match cases surface an interactive prompt and require user confirmation before any row is written.
- Persona inferences from shipped-spec KW-19 sources continue to land in `docs/CUSTOMER.md` (verifiable by a CUSTOMER.md diff or manifest entry).
- A `git diff` of `skills/arc-assess/SKILL.md` and references shows only additive changes — no deletions or rewrites in pre-existing rule prose for KW-1..KW-18 or KW-20..KW-22.
- `align-manifest.md` schema documentation is byte-identical to the parent commit.
- Two consecutive `/arc-assess` runs with the same multi-match disambiguation selections produce identical "Merge Candidates" sections (idempotency).

## Open Questions

No open questions at this time.
