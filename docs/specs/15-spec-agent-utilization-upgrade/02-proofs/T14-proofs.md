# T14 Proof Artifacts: Frontmatter Contract Layer Output

**Task:** T02.4: Capture dependency-graph.md and frontmatter-parse.json proofs  
**Date:** 2026-04-23  
**Status:** COMPLETE

## Summary

Task T14 successfully executed the `scripts/parse-frontmatter.sh` script twice to capture the frontmatter contract layer outputs. Both proof artifacts have been validated:

1. **dependency-graph.md** — Mermaid flowchart visualization of skill dependencies
2. **frontmatter-parse.json** — Structured JSON representation of all skill contracts

## Proof Artifacts

### 1. Mermaid Dependency Graph

**File:** `docs/specs/15-spec-agent-utilization-upgrade/02-proofs/dependency-graph.md`  
**Status:** ✓ PASS  

**Details:**
- Command: `scripts/parse-frontmatter.sh --format mermaid skills/arc-*/SKILL.md`
- Output lines: 21
- Skills represented: 9 (arc-assess, arc-audit, arc-capture, arc-help, arc-shape, arc-ship, arc-status, arc-sync, arc-wave)
- Edges rendered: 6 sibling dependencies + 1 external upstream node
- Style: Liatrio theme (teal #11B5A4, orange #E8662F, dark #1B2A3D)

**Validation:**
- Mermaid fenced block syntax: VALID
- Node definitions: VALID (9 nodes with proper IDs)
- Edge definitions: VALID (proper LR flowchart syntax)
- Theme config: VALID (proper initialization block)
- Artifact proof: `T14-01-mermaid.txt`

### 2. Frontmatter Parse JSON

**File:** `docs/specs/15-spec-agent-utilization-upgrade/02-proofs/frontmatter-parse.json`  
**Status:** ✓ PASS  

**Details:**
- Command: `scripts/parse-frontmatter.sh --format json skills/arc-*/SKILL.md`
- Output lines: 298
- Skills represented: 9 (matching Mermaid output)
- JSON structure: Complete and valid

**Contract Fields Captured:**
Each skill has the full frontmatter contract:
- `requires`: files, artifacts, state (predicate)
- `produces`: files, artifacts, state-transition
- `consumes`: from[] array linking upstream skills
- `triggers`: condition and alternates[]

**Sample Entry (arc-shape):**
```json
{
  "requires": {
    "files": ["docs/BACKLOG.md"],
    "artifacts": ["BACKLOG"],
    "state": "idea.status = 'captured'"
  },
  "produces": {
    "files": ["docs/BACKLOG.md", "docs/skill/arc/shape-report.md"],
    "artifacts": ["BACKLOG", "shape-report"],
    "state-transition": "captured -> shaped"
  },
  "consumes": {
    "from": [
      {"skill": "/arc-capture", "artifact": "BACKLOG"}
    ]
  },
  "triggers": {
    "condition": "at least one idea in BACKLOG has idea.status = 'captured' and is ready for a deep refinement pass",
    "alternates": ["/arc-capture", "/arc-wave"]
  }
}
```

**Validation:**
- JSON syntax: VALID (verified with `jq empty`)
- All 9 skills present
- All contract fields present
- All required arrays populated correctly
- Artifact proof: `T14-02-json.txt`

## Dependency Insights

The captured frontmatter reveals the skill dependency graph:

**Entry Points** (no consumes):
- arc-assess (initial capture from scattered content)
- arc-capture (initial idea recording)
- arc-help (read-only reference)
- arc-audit (periodic reviews)
- arc-status (read-only snapshots)

**Pipeline Stages:**
1. Capture: arc-capture → BACKLOG
2. Shape: arc-shape consumes /arc-capture → shaped ideas
3. Wave: arc-wave consumes /arc-shape → ROADMAP + wave-report
4. Ship: arc-ship consumes /arc-wave (+ /cw-validate external)
5. Sync: arc-sync consumes /arc-wave + /arc-shape → README + distributed artifacts

**External Dependencies:**
- arc-ship consumes `/cw-validate` (validation-report)

## Verification Checklist

- [x] Mermaid syntax valid (21 lines, 9 nodes, 6 edges)
- [x] JSON syntax valid (298 lines, 9 skills, all contract fields)
- [x] Both artifacts committed together
- [x] No sensitive data in outputs
- [x] Proof artifact files created (T14-01-mermaid.txt, T14-02-json.txt)
- [x] Summary document created (this file)

## Notes

- The parse-frontmatter.sh script (T02.3) executed successfully on all 9 SKILL.md files
- No frontmatter parsing errors encountered
- All arc-* skills were discovered and processed
- External upstream dependencies correctly identified (e.g., /cw-validate for arc-ship)
- Mermaid rendering verified to be syntactically correct (standard flowchart LR format)
