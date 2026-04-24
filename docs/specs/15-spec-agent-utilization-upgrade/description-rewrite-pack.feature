# Source: docs/specs/15-spec-agent-utilization-upgrade/15-spec-agent-utilization-upgrade.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Description Rewrite Pack

  Scenario: Autonomous dispatcher selects the correct arc skill on a "pushy"-phrased prompt
    Given all 9 arc skills have been rewritten with "pushy"-standard descriptions including 2-4 explicit "user says X" trigger scenarios
    And the user issues the prompt "jot this idea down before I forget"
    When an autonomous dispatcher evaluates the arc skill descriptions against the prompt
    Then the dispatcher selects "arc-capture" as the invoked skill
    And no sibling skill (such as arc-shape or arc-status) is selected as a competing match

  Scenario: Sibling skills no longer collide on shared verbs
    Given arc-audit and arc-status both previously triggered on the verb "review"
    And the rewritten descriptions explicitly disambiguate audit (artifact integrity) from status (state report)
    When the user issues the prompt "review the pipeline for issues"
    Then an autonomous dispatcher selects "arc-audit" and not "arc-status"
    And when the user issues the prompt "review where the project stands" the dispatcher selects "arc-status" and not "arc-audit"

  Scenario: marketplace.json lists all 9 arc skills
    Given the repository at the current HEAD after the rewrite pack is applied
    When a reader opens ".claude-plugin/marketplace.json"
    Then the plugin description (or accompanying field) enumerates all 9 arc skills
    And both "/arc-ship" and "/arc-help" appear in the enumeration
    And no skill directory under "skills/arc-*/" is absent from the enumeration

  Scenario: Context markers match their containing skill directory
    Given the repository contains 9 "skills/arc-*/SKILL.md" files
    When a user runs "grep -E '^\*\*ARC-' skills/arc-*/SKILL.md"
    Then the output lists exactly 9 matches
    And each matched marker is of the form "**ARC-{SKILL-NAME}**" where {SKILL-NAME} matches the parent directory's suffix
    And no match contains the legacy tokens "ARC-README", "ARC-REVIEW", or "ARC-ALIGN"

  Scenario: CLAUDE.md documents the context-marker convention for future skills
    Given a contributor adds a new arc skill "skills/arc-example/SKILL.md"
    When the contributor reads CLAUDE.md for naming guidance
    Then CLAUDE.md states that each SKILL.md must begin with a context marker "**ARC-{SKILL-NAME}**"
    And the contributor can infer that "skills/arc-example/SKILL.md" must use "**ARC-EXAMPLE**"

  Scenario: Step-level procedural content in SKILL.md files is unchanged except for marker corrections
    Given the repository state immediately before the rewrite pack was applied
    When a reviewer diffs the 9 "skills/arc-*/SKILL.md" files after the rewrite against the prior revision
    Then the only body-level changes in "skills/arc-sync/SKILL.md", "skills/arc-audit/SKILL.md", and "skills/arc-assess/SKILL.md" are the three context-marker lines
    And in the remaining 6 SKILL.md files the body (everything after the frontmatter and context marker) is byte-identical to the prior revision
