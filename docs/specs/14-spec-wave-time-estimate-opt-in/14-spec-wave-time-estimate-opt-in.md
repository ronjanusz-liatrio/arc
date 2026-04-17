# 14-spec-wave-time-estimate-opt-in

## Introduction/Overview

Make wave time estimates opt-in rather than required when creating a wave with `/arc-wave`. The current flow forces the user to select a "Target timeframe" option during Step 4; this spec removes that question from the default path, renders the missing `Target:` as a placeholder in ROADMAP and the wave report, and adds a plain-text reminder to the post-creation summary so users can still choose to backfill an estimate.

## Goals

1. Eliminate the mandatory "Target timeframe" prompt from the default `/arc-wave` flow.
2. Render a consistent placeholder (`TBD (use /arc-wave to add)`) wherever `Target:` would otherwise appear, when no estimate was captured.
3. Surface a one-line plain-text reminder in the post-wave summary so users know they can add an estimate.
4. Preserve back-compat for existing waves that already have a `Target:` value — none are modified or reformatted.
5. Keep all other wave-creation artifacts (ROADMAP wave entry, wave report, managed section) structurally valid.

## User Stories

- As a **Product Owner**, I want to create a wave without committing to a timeframe so that I can defer estimation until scope is clearer.
- As a **Product Owner**, I want to be reminded that a time estimate can still be added so that I do not forget to record one when I am ready.
- As a **Reader** of ROADMAP.md, I want a clear placeholder in the `Target` field when no estimate exists so that I can tell the estimate is intentionally missing rather than a formatting bug.
- As a **Tech Lead** reviewing a wave report, I want the wave's existing Target value preserved if it was already set so that historical context is not silently rewritten.

## Demoable Units of Work

### Unit 1: Remove the Target prompt from arc-wave Step 4

**Purpose:** The default `/arc-wave` flow no longer asks the user to select a timeframe; the `target` variable downstream is unset unless captured later.

**Functional Requirements:**

- The system shall remove the second question ("Target timeframe for this wave?") from the `AskUserQuestion` call in Step 4 of `skills/arc-wave/SKILL.md`.
- The system shall retain the "What is the wave name/theme?" question as the only Step 4 input.
- The system shall treat the wave's `target` value as unset (logical null) when not captured.
- The system shall not reintroduce the Target question behind any upfront offer, flag, or branching path (opt-in is via the post-creation path only).

**Proof Artifacts:**

- File: `skills/arc-wave/SKILL.md` contains the revised Step 4 with a single `AskUserQuestion` question (theme only) demonstrates the prompt was removed.
- Test: Gherkin scenario "Wave creation does not prompt for timeframe" passes demonstrates the default flow skips the Target question.
- CLI: `grep -n "Target timeframe" skills/arc-wave/SKILL.md` returns no matches in Step 4 demonstrates the removal is clean.

### Unit 2: Render `TBD (use /arc-wave to add)` placeholder when Target is unset

**Purpose:** ROADMAP.md and the wave report render a predictable, user-visible placeholder for missing Target values so the field is never silently omitted in new waves.

**Functional Requirements:**

- The system shall render the `**Target:**` line in the ROADMAP wave entry (Step 6 of `skills/arc-wave/SKILL.md`) as `**Target:** TBD (use /arc-wave to add)` when `target` is unset.
- The system shall render the `**Target:**` header line in the wave report (Step 10) as `**Target:** TBD (use /arc-wave to add)` when `target` is unset.
- The system shall render the ROADMAP summary table `Target` column cell as `TBD` when `target` is unset (table cells stay short; the parenthetical hint only appears in the detailed wave entry and wave report header).
- The system shall preserve any existing `Target:` value in waves already present in `docs/ROADMAP.md` and in archived waves under `docs/skill/arc/waves/` — no rewriting or migration is performed.
- The system shall update `skills/arc-wave/references/wave-report-template.md` to document both the populated form and the `TBD (use /arc-wave to add)` placeholder form.
- The system shall update `templates/ROADMAP.tmpl.md` to note that Target Timeframe is optional at Vertical Slice and later phases, with the documented placeholder form.

**Proof Artifacts:**

- File: `skills/arc-wave/SKILL.md` Step 6 template contains the literal string `**Target:** TBD (use /arc-wave to add)` demonstrates the placeholder convention.
- File: `skills/arc-wave/references/wave-report-template.md` documents the `TBD (use /arc-wave to add)` placeholder demonstrates the template is aligned.
- File: `templates/ROADMAP.tmpl.md` notes Target Timeframe as optional at Vertical Slice+ demonstrates the phase template was updated.
- Test: Gherkin scenario "ROADMAP wave entry shows TBD placeholder when estimate is skipped" passes demonstrates the rendered output is correct.

### Unit 3: Post-creation reminder note in the wave summary

**Purpose:** After a wave is created without a time estimate, the summary surfaces a one-line plain-text reminder so users who want to capture an estimate are not left guessing how.

**Functional Requirements:**

- The system shall emit a one-line plain-text note in the post-wave summary when `target` is unset, in the form: `Tip: no time estimate was captured. Add one by editing docs/ROADMAP.md or rerunning /arc-wave.`
- The system shall emit the note in the text response printed alongside Step 11's `AskUserQuestion` — not as an extra option inside the question.
- The system shall not emit the note when `target` has a value (the wave already has an estimate).
- The system shall not prompt, ask, or collect the estimate during the post-creation summary — the reminder is informational only.
- The system shall document the note's exact text in `skills/arc-wave/SKILL.md` Step 11 so behavior is reproducible.

**Proof Artifacts:**

- File: `skills/arc-wave/SKILL.md` Step 11 contains the exact reminder-note text and the "emit only when target is unset" rule demonstrates the behavior is specified.
- Test: Gherkin scenario "Summary shows reminder when estimate is skipped" passes demonstrates the note is emitted only on the unset path.
- Test: Gherkin scenario "Summary omits reminder when estimate is present" passes demonstrates the suppression path.

## Non-Goals (Out of Scope)

- Introducing a new `/arc-wave` sub-command (e.g., `/arc-wave estimate <wave>`) to add an estimate to an existing wave. The literal placeholder text names `/arc-wave` as a hint, but the mechanics of post-hoc estimate capture are deferred — see Open Questions.
- Migrating, rewriting, or normalizing Target values in existing ROADMAP entries or archived waves.
- Changing wave sizing, phase constraints, or any other Step 2 (scope assessment) behavior.
- Adding estimate-tracking fields beyond the existing single `Target` value (no min/max, no confidence bands).
- Modifying `/arc-audit` or `/arc-sync` to enforce or validate Target presence — both skills must continue to tolerate missing or `TBD`-placeholder Target values.
- Modifying the wave archive schema (`docs/skill/arc/waves/*.md`).

## Design Considerations

- The placeholder string `TBD (use /arc-wave to add)` is used verbatim wherever the full field appears (ROADMAP wave entry, wave report header). In the ROADMAP summary table's `Target` column, use the shorter `TBD` only — table cells must stay concise.
- The reminder note is plain text in the assistant's response, not a markdown artifact written to disk. It appears above or below the `AskUserQuestion` call in Step 11, clearly distinct from the wave report content.
- No UI color, icon, or emoji is required — Arc skills avoid emoji per repo conventions.

## Repository Standards

- Follow conventional commits: `feat(arc-wave): ...` for behavior changes, `docs(arc): ...` for template updates.
- Match existing SKILL.md formatting conventions: step numbering, markdown headers, `AskUserQuestion` code blocks, and inline decision notes.
- Keep Gherkin scenarios under `docs/specs/14-spec-wave-time-estimate-opt-in/*.feature`, one feature file per demoable unit, using the Given/When/Then structure seen in earlier specs.
- Preserve existing ARC/TEMPER namespace rules in `references/bootstrap-protocol.md` — this spec does not touch managed-section injection.

## Technical Considerations

- The `target` variable is not currently persisted as a named symbol — it is captured only through `AskUserQuestion` selection inside the skill flow. Implementation should ensure the downstream renderers in Steps 6 and 10 use a consistent "unset" signal (e.g., empty string or missing key) and branch to the placeholder form.
- The current `/arc-wave` Step 4 uses a multi-question `AskUserQuestion` call. After this change, only the theme question remains, so consider whether a single-question `AskUserQuestion` is still the right UX or whether the theme prompt should be rephrased.
- The note text references `docs/ROADMAP.md` by path. If the file is relocated in the future, this string becomes stale — accept that risk and update alongside any future path changes.
- No changes are required to `skills/arc-audit`, `skills/arc-status`, `skills/arc-sync`, or `skills/arc-ship`. However, implementers should run a grep pass after changes to confirm those skills do not assume a non-empty Target value.

## Security Considerations

- No new input channels, no secrets, no external API calls. The change is textual and confined to Arc skill documentation and two templates.

## Success Metrics

- **Behavior:** After the change, running `/arc-wave` from a clean slate never triggers a Target-timeframe selection prompt.
- **Correctness:** A wave created without an estimate renders `TBD (use /arc-wave to add)` in both the ROADMAP wave entry and the wave report header, and `TBD` in the ROADMAP summary table.
- **Back-compat:** Running `/arc-wave` against a project with existing waves does not alter the Target values of any prior wave.
- **Discoverability:** The post-creation summary emits the exact reminder-note text when and only when `target` is unset.

## Open Questions

1. The placeholder string `TBD (use /arc-wave to add)` names `/arc-wave` as the command to add an estimate later. `/arc-wave` presently only creates new waves — there is no flow to edit an existing wave's Target. Options for resolution:
   - Keep the placeholder string as-is and rely on manual edits to `docs/ROADMAP.md` (the reminder note already mentions this path) — lightest-weight.
   - Add a follow-up spec for `/arc-wave estimate <wave>` or similar — out of scope for this spec but worth flagging.
   - Change the placeholder text to `TBD (edit docs/ROADMAP.md to add)` so it only references capabilities that exist today.

   **Recommendation:** Proceed with `TBD (use /arc-wave to add)` as chosen, and treat the edit-existing-wave flow as a candidate backlog item.

2. The reminder-note text currently names both `docs/ROADMAP.md` and `/arc-wave` as paths. If the first open question is resolved by changing the placeholder, the reminder text should be aligned.
