# Wave 4: Status Visibility

- **Theme:** Status Visibility
- **Goal:** Make `/arc-status` and `/arc-assess` accurately reflect lifecycle state — surface orphan specs, hide completed specs from in-flight, and prevent re-duplication of shipped user stories.
- **Target:** TBD
- **Completed:** 2026-05-11T20:00:00Z

## Shipped Ideas

### Detect orphan specs and exclude completed specs from arc-status

- **Status:** shipped
- **Priority:** P0-Critical
- **Captured:** 2026-05-08T00:00:00Z
- **Shaped:** 2026-05-08T18:00:00Z
- **Shipped:** 2026-05-08T20:00:00Z
- **Wave:** Wave 4 — Status Visibility
- **Spec:** docs/specs/18-spec-arc-status-spec-completion

Two related visibility fixes for /arc-status. (1) Add a sixth lifecycle gap (LG-6) for spec directories that have a PASS validation report but no BACKLOG idea whose Spec: field links to them. (2) Filter the In-Flight Specs table to exclude specs already linked to a wave archive entry, so In-Flight means actively in progress, not every spec directory ever created.

#### Problem

`/arc-status` produces misleading pulse output in two ways. First, spec directories that bypassed the `/arc-capture → /arc-shape → /arc-wave → /arc-ship` flow are silently invisible to lifecycle-gap detection — LG-5 explicitly skips a spec when no BACKLOG idea links to it via the `Spec:` field, so PASS-validated orphan specs (today: 14, 15, 16, 17) never surface. Second, the In-Flight Specs table globs every `docs/specs/NN-spec-*/` directory with no completion filter, so already-shipped specs clutter the "actively in progress" view. Together these defeat `/arc-status`'s purpose as a trustworthy pulse check for the Product Owner persona.

#### Proposed Solution

Two additive changes to `skills/arc-status/SKILL.md` and `skills/arc-status/references/status-dimensions.md`, sharing the same data sources (spec directories + wave archives + BACKLOG `Spec:` fields):

1. **Add LG-6 (Orphan Spec).** In Step 6, add a sixth lifecycle gap that fires when a spec directory has a `*-validation-*.md` report containing `**Overall**: PASS` AND no BACKLOG idea has a `Spec:` field linking to that directory. Subject is the spec directory; remediation is `/arc-capture` followed by `/arc-shape` to retroactively create the lifecycle record.
2. **Filter In-Flight Specs.** In Step 4, after globbing `docs/specs/NN-spec-*/`, exclude any spec directory whose name appears as a `### {Title}` subsection title or `Spec:` field value inside `docs/skill/arc/waves/*.md`. The wave archive is the single authoritative completion signal (matches SD-2 shipped-count derivation).
3. **Extend Step 6.6 scope tagging.** LG-6 always evaluates to `scope = backlog-only` because, by construction, no linked backlog idea exists.
4. **Extend Step 7 precedence list.** Append two new priorities — a wave-linked LG-6 priority is unreachable (orphans are by definition backlog-only), so only a no-wave LG-6 priority is needed; insert it between current Priorities 13 and 14, shifting "no wave + no gaps" to Priority 15. The recommended skill is `/arc-capture` with reason "Spec {NN}-spec-{name} has a PASS validation but no BACKLOG idea — capture it?"
5. **Update worked example** in `status-dimensions.md` to show an orphan-spec LG-6 row and a filtered-out completed-spec note.

#### Success Criteria

- Re-running `/arc-status` against today's repo state surfaces spec 17 (and 14, 15, 16 if PASS-validated) as LG-6 rows with the prescribed `/arc-capture` remediation.
- Shipped specs whose dir names appear in `docs/skill/arc/waves/*.md` (e.g., `04-spec-arc-readme`, `05-spec-arc-help`, `10-spec-arc-ship`, `11-spec-shape-skill-discovery`, `12-spec-arc-status`, `13-spec-wave-archive`) no longer appear in the In-Flight Specs table.
- LG-1..LG-5 detection logic and existing precedence priorities 1–13 are unchanged byte-for-byte.
- Lifecycle Gaps "no gaps detected" message and Scope-column rendering rules are unchanged.
- Re-running `/arc-status` after the change is idempotent (read-only, no writes), as before.

#### Constraints

- Read-only skill — no file writes (existing `/arc-status` constraint preserved).
- All summary sections must always emit, even on detection error (existing skipped-check-with-warning model applies to LG-6 too).
- No renumbering of LG-1..LG-5 or existing precedence priorities — append-only changes.
- Wave archive is the single source of truth for completion; do not introduce a separate "validated but unshipped" state.
- All edits target prose in `skills/arc-status/SKILL.md` and `skills/arc-status/references/status-dimensions.md` — no new files, no code execution.

#### Assumptions

- Existing LG-1..LG-5 detection blocks provide a sufficient template for LG-6 (numbered detection, scope tagging in 6.6, precedence priority in Step 7).
- `### {Title}` subsection enumeration in `docs/skill/arc/waves/*.md` (already used by SD-2) is reliable and complete for the In-Flight filter.
- Spec-to-idea linkage rule from WL-3 (BACKLOG `Spec:` field, trailing-slash-tolerant string match) extends cleanly to LG-6's negative-match case.
- Orphan specs are rare enough that always-backlog-only scope tagging is acceptable; if a future spec is wave-linked but the lifecycle record was lost, it shows as orphan and routes through `/arc-capture`.

#### Open Questions

None.

### Classify shipped-spec user stories as merge candidates in arc-assess

- **Status:** shipped
- **Priority:** P2-Medium
- **Captured:** 2026-04-13T00:10:00Z
- **Shaped:** 2026-05-08T18:30:00Z
- **Shipped:** 2026-05-11T20:00:00Z
- **Wave:** Wave 4 — Status Visibility
- **Spec:** docs/specs/19-spec-arc-assess-shipped-merge

Enhance `/arc-assess` classification rules to detect when a KW-19 user story originates from a spec already represented in the wave archive, and emit a "merge-candidate" annotation routing the story to the corresponding shipped skill entry instead of creating a new captured BACKLOG stub.

#### Problem

When `/arc-assess` re-scans a repo whose specs have already shipped, KW-19 (`## User Stories`) matches in shipped spec files re-classify those stories as new captured BACKLOG stubs. The 2026-04-13 re-run produced 9 duplicate captured stubs from shipped specs (08, 09, 01-align-ignore-dirs); only manual user intervention prevented re-duplication. This violates the spec-08 single-representation invariant ("every shipped capability appears once, not twice") and breaks the Tech Lead's safe-rerun JTBD — running `/arc-assess` twice should be idempotent. The original captured framing referenced BACKLOG `status: shipped`, but spec 13 (wave-archive) moved shipped state out of BACKLOG into `docs/skill/arc/waves/*.md`, so detection must re-anchor on the wave archive.

#### Proposed Solution

Add a "merge-candidate" sub-branch to the KW-19 classification rule in `skills/arc-assess/SKILL.md` and `references/import-rules.md`:

1. **Build a shipped-spec index** at the start of `/arc-assess` by reading every `docs/skill/arc/waves/*.md`. A spec dir is "shipped" if its name appears as a `### {Title}` subsection title OR as a `**Spec:** {path}` field value inside any wave archive (both signals OR'd).
2. **Branch KW-19 detection.** When a KW-19 source resides in a shipped spec dir, do NOT create a captured BACKLOG stub. Instead emit a `merge-candidate` row in `align-report.md` with: source path + line range, target wave archive file, target skill heading, and provenance comment.
3. **Multi-match handling.** If ≥2 shipped specs match, list all candidates as a numbered sub-block under the source row and prompt the user to pick during the standard `/arc-assess` interactive confirmation step. Never auto-select.
4. **Persona extraction unchanged.** KW-19's persona-extraction sub-step (CUSTOMER.md side) continues to run for shipped-spec stories — personas are durable cross-cutting context and live separately.
5. **No auto-rewrite.** The merge candidate is report-only; the user runs a separate manual or future-skill merge step. No manifest entry is written (manifest tracks materialized imports only).

#### Success Criteria

- Re-running `/arc-assess` on the current repo produces zero duplicate captured stubs for user stories that originate in specs already present in `docs/skill/arc/waves/*.md`.
- The 9 user stories that were duplicated on 2026-04-13 (from specs 08, 09, 01-align-ignore-dirs) classify as `merge-candidate` rows in `align-report.md` on a fresh re-run.
- Multi-spec matches surface all candidates in the report and require user confirmation before any action.
- Persona extraction from KW-19 sources still produces CUSTOMER.md updates for shipped-spec stories.
- Detection is idempotent across repeat `/arc-assess` runs (same input ⇒ same merge-candidate list).
- Existing KW-1..KW-18 and KW-20..KW-22 classification behavior is unchanged.

#### Constraints

- Must not auto-rewrite wave archive `### User Stories` blocks — `/arc-assess` constraint "NEVER import content without user confirmation" applies.
- Wave archive (`docs/skill/arc/waves/*.md`) is the single source of truth for shipped state; do not re-introduce a BACKLOG `status: shipped` check.
- Do not modify already-completed spec-08 manual merges.
- All edits target prose: `skills/arc-assess/SKILL.md`, `skills/arc-assess/references/import-rules.md`, and `skills/arc-assess/references/detection-patterns.md`.
- Must remain compatible with the existing `align-manifest.md` schema (no merge-candidate manifest rows).

#### Assumptions

- The shipped-spec index can be built from a small bounded set of wave archive files (currently 5; expected to stay <20).
- Spec 08's prior-art Gherkin (`docs/specs/08-spec-backlog-consistency/merge-captured-user-stories-into-shipped-skill-entries.feature`) provides reusable scenarios for `/cw-spec`.
- The KW-19 branch in `import-rules.md` already supports prefix branches (`(deferred)`, `(open question)`); adding a "shipped-spec" branch fits the same shape.
- A future skill (or manual workflow) will perform the actual merge edit — out of scope for this brief.

#### Open Questions

None.
