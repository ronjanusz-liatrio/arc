# Source: docs/specs/11-spec-shape-skill-discovery/11-spec-shape-skill-discovery.md
# Pattern: CLI/Process + Error Handling
# Recommended test type: Integration

Feature: Graceful Fallback When Skillz Is Not Installed

  Scenario: Shaping completes with skip notice when skillz is not installed
    Given a captured idea exists in docs/BACKLOG.md
    And the skillz plugin is not installed
    When the user runs /arc-shape and the feasibility subagent executes
    Then the feasibility assessment output contains the notice "Skill discovery skipped — `/skillz` plugin not installed. Install with: `claude plugin install skillz@skillz`"
    And the feasibility assessment includes standard analysis for Temper phase, technical risk, and pattern fit
    And the shaping process completes without errors

  Scenario: Fallback does not add latency to the shaping process
    Given a captured idea exists in docs/BACKLOG.md
    And the skillz plugin is not installed
    When the feasibility subagent runs its analysis
    Then the subagent proceeds with standard feasibility analysis without waiting for a skill discovery timeout
    And the feasibility assessment is returned in the same time frame as a run without skill discovery enabled

  Scenario: Output format is consistent with or without skill discovery
    Given two captured ideas exist in docs/BACKLOG.md
    And the skillz plugin is installed for the first shaping run
    And the skillz plugin is not installed for the second shaping run
    When both ideas are shaped through /arc-shape
    Then the feasibility assessment output for the first run includes the "#### Relevant Skills" subsection with discovered skills
    And the feasibility assessment output for the second run omits the "#### Relevant Skills" subsection
    And both outputs contain identical sections for Temper phase, technical risk, risk factors, unknowns, pattern fit, and feasibility rating

  Scenario: Skillz-find invocation failure is treated as not installed
    Given a captured idea exists in docs/BACKLOG.md
    And /skillz-find is invoked but fails due to a network error or timeout
    When the feasibility subagent handles the failure
    Then the feasibility assessment output contains the skip notice rather than an error
    And the shaping process continues without interruption

  Scenario: No changes required to arc-shape allowed-tools frontmatter
    Given the current skills/arc-shape/SKILL.md frontmatter
    When skill discovery is added to the feasibility subagent
    Then the allowed-tools list in the SKILL.md frontmatter remains unchanged
    And skill discovery runs entirely within the sub-Agent spawned by the feasibility subagent
