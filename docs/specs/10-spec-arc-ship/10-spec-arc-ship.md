# 10-spec-arc-ship

## Introduction/Overview

Arc automates every idea lifecycle transition except the final one — marking an idea as `shipped` after the SDD pipeline completes. Today, the Product Owner manually edits `docs/BACKLOG.md` with no verification that proof artifacts exist, creating drift risk where shipped items sit in stale status and downstream skills (`/arc-audit`, `/arc-sync`) report incorrect state.

This feature delivers `/arc-ship`, a new Arc skill that verifies a cw-validate report with `**Overall**: PASS` exists for a completed idea, then transitions its BACKLOG status to `shipped`. It also extends `/arc-wave` to populate a `- **Spec:**` field during wave assignment, enabling automated proof lookup.

## Goals

1. Automate the `spec-ready → shipped` lifecycle transition with proof-artifact verification
2. Require a cw-validate report with `**Overall**: PASS` before allowing the shipped transition
3. Support optional batch mode for shipping multiple wave items in one invocation
4. Update ROADMAP wave status to `Completed` when all wave items are shipped
5. Refresh `ARC:product-context` in CLAUDE.md after shipping (backlog counts change)
6. Extend `/arc-wave` to populate a `- **Spec:**` field on BACKLOG entries during wave assignment
7. Offer interactive backfill of the `Spec` field on legacy shipped items (Wave 0)
8. Update `references/idea-lifecycle.md` and `references/cross-plugin-contract.md` to document the new skill and its cw artifact dependency

## User Stories

- As a **product owner** who just finished an SDD cycle, I want the backlog updated to `shipped` automatically so lifecycle counts and README stay accurate without manual editing.
- As a **tech lead** reviewing pipeline health, I want shipped transitions gated by proof-artifact verification so I can trust that `shipped` status means the work actually passed validation.
- As a **developer** shipping a wave of features, I want to batch-ship all items in a wave so I don't repeat the same flow for each idea individually.
- As a **product owner** using `/arc-audit`, I want ROADMAP wave status to reflect reality so audits don't flag shipped waves as incomplete.

## Demoable Units of Work

### Unit 1: Core Ship Skill — Single Idea Flow

**Purpose:** Deliver the end-to-end `/arc-ship` flow for a single idea: select an eligible idea, verify the cw-validate report, and transition BACKLOG status to `shipped`.

**Functional Requirements:**

- The system shall provide `skills/arc-ship/SKILL.md` with frontmatter matching the existing pattern: `name: arc-ship`, `description`, `user-invocable: true`, `allowed-tools: Glob, Grep, Read, Write, Edit, AskUserQuestion`.
- The system shall include a `## Walkthrough` section with a mermaid flowchart (Arc brand theme, ≤15 nodes) immediately after `## Overview`, depicting the common success path: select idea → resolve spec path → verify validation report → update BACKLOG → update ROADMAP (if applicable) → refresh CLAUDE.md → confirm.
- The system shall read `docs/BACKLOG.md` and present ideas with status `spec-ready` for selection via `AskUserQuestion` (single-select mode).
- If invoked with an argument (e.g., `/arc-ship "Idea Title"`), the system shall search for a matching idea by title (case-insensitive partial match) and confirm the match before proceeding.
- If no `spec-ready` ideas exist, the system shall inform the user: "No spec-ready ideas found in docs/BACKLOG.md. Run `/arc-wave` to promote shaped ideas."
- The system shall resolve the spec directory path from the idea's `- **Spec:**` field in BACKLOG. If the field is absent, the system shall ask the user to provide the spec directory path via `AskUserQuestion`.
- The system shall search the resolved spec directory for a file matching `*-validation-*.md` and verify it contains `**Overall**: PASS` (using Grep).
- If no validation report is found in the spec directory, the system shall report the failure and refuse the transition: "No cw-validate report found in `{spec-dir}/`. Run `/cw-validate` first."
- If a validation report is found but `**Overall**` is not `PASS`, the system shall report the failure: "Validation report found but status is `{status}`, not PASS. Resolve validation failures before shipping."
- On successful verification, the system shall update both the BACKLOG summary table row (status → `shipped`, wave column preserved) and the idea detail section: change `- **Status:**` to `shipped`, add `- **Spec:** {spec-dir-path}` (if not already present), add `- **Shipped:** {ISO 8601 timestamp}`.
- The system shall provide `skills/arc-ship/references/ship-criteria.md` documenting the proof verification rules, eligible statuses, and the complete list of BACKLOG fields added during shipping.
- The system shall display a confirmation message after shipping: "Shipped: {Title} — verified via {validation-report-path}."

**Proof Artifacts:**

- File: `skills/arc-ship/SKILL.md` exists with correct frontmatter, `## Walkthrough` mermaid diagram, `## Critical Constraints`, and step-by-step process.
- File: `skills/arc-ship/references/ship-criteria.md` exists documenting verification rules.
- CLI: `bash scripts/lint-mermaid.sh` exits `0` including the new SKILL.md walkthrough diagram.
- File: After running `/arc-ship` on a spec-ready idea with a passing validation report, the BACKLOG summary table row shows `shipped` status and the detail section contains `- **Shipped:**` timestamp and `- **Spec:**` path.

---

### Unit 2: arc-wave Spec Field + Legacy Backfill

**Purpose:** Enable automated spec-path lookup by extending `/arc-wave` to populate a `- **Spec:**` field, and provide a one-time backfill mechanism for Wave 0 items that predate this convention.

**Functional Requirements:**

- The system shall update `skills/arc-wave/SKILL.md` Step 7 (Update BACKLOG) to add a `- **Spec:**` metadata line to each idea's detail section when promoting from `shaped` to `spec-ready`. The value shall be left as a placeholder: `- **Spec:** (set during /cw-spec)` — indicating it should be filled when the spec directory is created.
- The system shall update `skills/arc-wave/SKILL.md` Step 7 to document that `/cw-spec` should update the `- **Spec:**` field with the actual spec directory path when creating the spec (advisory documentation, not enforcement).
- When `/arc-ship` encounters a shipped or spec-ready idea without a `- **Spec:**` field, it shall offer interactive backfill: present the user with a list of spec directories from `docs/specs/` via `AskUserQuestion` and allow them to assign the correct spec path.
- The backfill flow shall be triggered on first run or whenever `/arc-ship` encounters an idea missing the `Spec` field. It shall not automatically backfill all items — only the item being shipped (or explicitly selected for backfill).
- For batch backfill of Wave 0 items, `/arc-ship` shall offer a "Backfill Wave 0" option when it detects shipped items without `- **Spec:**` fields: present each shipped item and its likely spec match (by title similarity) for user confirmation.
- The system shall update `references/cross-plugin-contract.md` to add a new section documenting the claude-workflow artifacts that Arc reads: validation reports (`docs/specs/NN-spec-name/NN-validation-*.md`) and proof files (`docs/specs/NN-spec-name/NN-proofs/`).

**Proof Artifacts:**

- File: `skills/arc-wave/SKILL.md` Step 7 includes the `- **Spec:**` field in the BACKLOG update procedure.
- File: `references/cross-plugin-contract.md` contains a "Claude-Workflow Artifacts Read by Arc" section.
- File: After backfilling a Wave 0 item, its BACKLOG detail section contains `- **Spec:** docs/specs/{NN}-spec-{name}/`.

---

### Unit 3: Batch Mode + ROADMAP Rollup + CLAUDE.md Update

**Purpose:** Support shipping multiple ideas at once, automatically updating ROADMAP wave status when complete, and refreshing `ARC:product-context` after every ship operation.

**Functional Requirements:**

- When multiple `spec-ready` ideas exist in the same wave, `/arc-ship` shall offer batch mode via `AskUserQuestion` with `multiSelect: true`, allowing the user to select multiple ideas to ship in one invocation.
- In batch mode, the system shall verify each selected idea's validation report independently. If any idea fails verification, it shall report the failure for that idea and proceed with the remaining ideas (partial success).
- After updating BACKLOG for all successfully shipped ideas, the system shall check `docs/ROADMAP.md` (if it exists) to determine whether all ideas in the wave have reached `shipped` status.
- If all ideas in a wave are `shipped`, the system shall update the wave's `**Status:**` field in ROADMAP from `Planned` or `Active` to `Completed`.
- After every ship operation (single or batch), the system shall refresh the `ARC:product-context` managed section in CLAUDE.md by recalculating backlog status counts from the BACKLOG summary table and updating the `**Backlog:**` line. Follow the injection algorithm in `skills/arc-wave/references/bootstrap-protocol.md`.
- If CLAUDE.md does not exist, skip the product-context refresh without error.
- If `docs/ROADMAP.md` does not exist, skip the wave rollup without error.
- The system shall display a batch summary after completion: "{N} ideas shipped, {M} failed verification. Wave '{name}': {Completed|In Progress}."

**Proof Artifacts:**

- File: After batch-shipping all spec-ready ideas in a wave, the ROADMAP wave status reads `Completed`.
- File: After any ship operation, the `ARC:product-context` section in CLAUDE.md shows updated backlog counts.
- File: After a partial batch (one fails verification), the BACKLOG shows shipped status for passing ideas and unchanged status for the failing idea.

---

### Unit 4: Reference Updates + Plugin Integration

**Purpose:** Update lifecycle documentation, plugin metadata, and README references to reflect the new skill.

**Functional Requirements:**

- The system shall update `references/idea-lifecycle.md`:
  - Add `/arc-ship` as the mechanism for the `Spec-Ready → Shipped` transition in the Shipped stage's Entry Criteria.
  - Add a note to the Shipped data fields documenting that `- **Spec:**` and `- **Shipped:**` are added by `/arc-ship`.
  - Update the lifecycle diagram's `SpecReady --> Shipped` transition label from `SDD pipeline` to `SDD pipeline + /arc-ship`.
- The system shall bump the version in `.claude-plugin/plugin.json` from `0.12.0` to `0.13.0`.
- The system shall update `README.md` to reference `/arc-ship` in:
  - The skills summary table (if one exists)
  - The mermaid lifecycle or pipeline diagram (if `/arc-ship` fits the flow)
  - Any bullet list of available skills
- The system shall update `skills/README.md` (if it exists) to include `/arc-ship` in the skills table and workflow description.

**Proof Artifacts:**

- File: `references/idea-lifecycle.md` mentions `/arc-ship` in the Shipped stage and lifecycle diagram.
- File: `.claude-plugin/plugin.json` reads version `0.13.0`.
- File: `README.md` references `/arc-ship` in at least 2 locations.
- Test: `grep -c 'arc-ship' README.md` returns ≥ 2.

## Non-Goals (Out of Scope)

- Automatic ship detection — `/arc-ship` requires explicit user invocation, consistent with Arc's "intentional product thinking" principle.
- Modifying proof artifacts — read-only verification only; `/arc-ship` never creates, edits, or restructures cw-validate proofs.
- Re-running or deeply evaluating cw-validate gate results — `/arc-ship` checks for `**Overall**: PASS`, not individual gate pass/fail.
- Accepting proof files (`*-proofs.md`) as a substitute for a validation report — strict cw-validate requirement enforced.
- Creating CLAUDE.md if it doesn't exist — follows the existing bootstrap protocol (warn and skip).
- Adding a walkthrough diagram to other skills beyond `/arc-ship` — out of scope for this spec.

## Design Considerations

No specific UI/design requirements identified beyond:
- AskUserQuestion patterns must match existing Arc skills (single-select for idea choice, multi-select for batch mode)
- Walkthrough diagram must use Arc brand theme (`#11B5A4` teal, `#E8662F` orange, `#1B2A3D` navy)
- Confirmation messages should be concise, matching `/arc-capture`'s terse style

## Repository Standards

| Standard | Pattern to Follow |
|----------|------------------|
| SKILL.md frontmatter | Match `arc-capture`: name, description, user-invocable, allowed-tools |
| Reference doc location | `skills/arc-ship/references/` |
| Mermaid theme block | `%%{init: {'theme': 'base', 'themeVariables': {...}}}%%` from README.md |
| Walkthrough placement | Between `## Overview` and `## Critical Constraints` per spec 09 |
| Conventional commits | `feat(arc-ship): ...` for implementation, `docs(arc-ship): ...` for reference docs |
| Cross-plugin contract | Read-only access, graceful degradation per `references/cross-plugin-contract.md` |
| Bootstrap protocol | `ARC:product-context` injection per `skills/arc-wave/references/bootstrap-protocol.md` |

## Technical Considerations

- **Validation report discovery:** Use `Glob` with pattern `docs/specs/{spec-dir}/*-validation-*.md` to find the report, then `Grep` for `**Overall**: PASS`.
- **Spec field placeholder:** During `/arc-wave`, the `- **Spec:**` field is set to `(set during /cw-spec)` because the spec directory doesn't exist yet at wave-planning time. `/cw-spec` should update it when creating the directory (advisory, not enforced by this spec).
- **BACKLOG edit atomicity:** Both the summary table row and the detail section must be updated in the same operation to avoid inconsistent state. Use two sequential `Edit` calls — table row first, then detail section.
- **ROADMAP rollup logic:** Read the wave's "Selected Ideas" table from ROADMAP, cross-reference each title against the BACKLOG summary table, and check if all have `shipped` status.
- **ARC:product-context refresh:** Recount statuses from the BACKLOG summary table after shipping, then apply the bootstrap-protocol injection algorithm.

## Security Considerations

- No external API calls — all operations are local file reads and writes.
- Proof verification is read-only — `/arc-ship` never modifies cw-validate artifacts.
- No credentials or secrets are involved in any operation.

## Success Metrics

- After shipping, `grep -c 'shipped' docs/BACKLOG.md` (summary table) increases by the number of ideas shipped.
- BACKLOG and ROADMAP remain in valid markdown format after every operation.
- `bash scripts/lint-mermaid.sh` passes with the new walkthrough diagram.
- All 7 existing shipped Wave 0 items can be backfilled with their correct spec paths.

## Open Questions

- No open questions at this time.
