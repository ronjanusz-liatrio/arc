# Spec Questions — Round 1: arc-assess-shipped-merge

## Resolved during shaping (BACKLOG `Classify shipped-spec user stories as merge candidates in arc-assess`)

| Question | Answer |
|----------|--------|
| What signals mark a spec as "shipped"? | Both signals OR'd — spec dir name appears as `### {Title}` subsection title in any `docs/skill/arc/waves/*.md` OR appears as a `**Spec:** {path}` field value inside any archived idea entry. |
| Multi-match disambiguation? | List all candidates in `align-report.md` and prompt the user to pick during `/arc-assess`'s interactive confirmation step. Never auto-select. |
| Output format? | Report-only annotation in `align-report.md`. No manifest entry. No auto-rewrite of shipped skill entries. |
| Persona extraction behavior? | Continues to run for shipped-spec stories — personas are durable cross-cutting context, separate from the user-story body. Only the captured-stub creation is suppressed. |

## Resolved during cw-spec Round 1

| Question | Answer | Rationale |
|----------|--------|-----------|
| Demoable unit split? | One unit — everything together. | Detection + rendering ship as a single behavior change; smaller task graph; spec stays cohesive. |
| Where do merge-candidate rows render? | New "Merge Candidates" section in `align-report.md` between "Imported Items by Artifact" and "Skipped Items". | Distinct from imports and skips; clear taxonomy. Multi-match cases render as nested numbered list under the source row. |
| User-confirmation flow? | AskUserQuestion per multi-match source (single-match auto-routes without a prompt). | Preserves per-source context; avoids prompt fatigue when most matches are unambiguous. |
| Proof strategy? | Re-run `/arc-assess` against current repo + diff against the 2026-04-13 outcome (9 user stories from shipped specs 08, 09, 01-align-ignore-dirs that duplicated as captured stubs). | Concrete behavioral regression check on real shipped specs. Augmented by auto-generated Gherkin via cw-gherkin. |

## Open questions

None.
