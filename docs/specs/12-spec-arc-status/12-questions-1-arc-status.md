# Questions Round 1: /arc-status

## Q1: Data Sources
**Question:** What should /arc-status read?
**Answer:** Arc + claude-workflow + git — BACKLOG, ROADMAP, spec directories, validation reports, and recent commits for momentum signal.

## Q2: Output Format
**Question:** How should results be delivered?
**Answer:** Inline only — terminal summary, no file artifact written. Keeps it fast and ephemeral.

## Q3: "What's Next" Logic
**Question:** How should /arc-status determine what's next?
**Answer:** Both — show wave progress AND lifecycle gaps (captured→shaped, shaped→spec, spec→plan, plan→validation, validation→shipped).

## Q4: Interaction Model
**Question:** Should /arc-status prompt action, or just report?
**Answer:** Summary + offer next step — suggest the most relevant next skill invocation based on the pulse findings.
