# Source: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md
# Pattern: CLI/Process + State + Async (skill invocation with parallel subagents and file mutations)
# Recommended test type: Integration

Feature: /arc-shape Skill

  Scenario: Skill definition follows plugin conventions
    Given the arc plugin is installed in a project
    When the user inspects skills/arc-shape/SKILL.md
    Then the frontmatter contains name set to "arc-shape"
    And the frontmatter contains user-invocable set to true
    And the frontmatter contains an allowed-tools list

  Scenario: Shape begins with context marker
    Given the arc plugin is installed in a project
    When the user invokes /arc-shape
    Then the skill response begins with "**ARC-SHAPE**"

  Scenario: Shape presents captured ideas for selection
    Given docs/BACKLOG.md contains two ideas with status "captured"
    When the user invokes /arc-shape
    Then the skill presents an AskUserQuestion with both captured ideas as single-select options
    And each option displays the idea title and summary

  Scenario: Shape accepts title argument to bypass selection
    Given docs/BACKLOG.md contains an idea titled "Widget API" with status "captured"
    When the user invokes /arc-shape with argument "Widget API"
    Then the skill proceeds directly to analysis without presenting a selection prompt

  Scenario: Shape launches four parallel dimension analyses
    Given docs/BACKLOG.md contains an idea with status "captured"
    When the user selects an idea for shaping
    Then the skill launches a problem clarity subagent analyzing problem specificity and impact
    And the skill launches a customer fit subagent checking alignment with docs/CUSTOMER.md personas
    And the skill launches a scope boundaries subagent identifying constraints and non-goals
    And the skill launches a feasibility subagent assessing engineering capacity from project context

  Scenario: Shape presents aggregated analysis and guides gap-filling
    Given the four parallel subagents have completed their analysis
    When the skill aggregates the results
    Then the user sees a synthesis highlighting gaps and recommendations from all four dimensions
    And the skill presents AskUserQuestion prompts to fill identified gaps

  Scenario: Shape produces spec-ready brief and updates BACKLOG
    Given the user has completed the interactive Q&A to fill gaps
    When the skill generates the shaped brief
    Then the brief contains all required sections: Problem, Proposed Solution, Success Criteria, Constraints, Assumptions, Wave Assignment, and Open Questions
    And docs/BACKLOG.md shows the idea with status changed from "captured" to "shaped"
    And the idea section in BACKLOG.md contains the full brief subsections replacing the original stub

  Scenario: Shape saves a shaping report
    Given the user has completed shaping an idea
    When the skill finalizes the shaping process
    Then docs/shape-report.md is created with a timestamp
    And the report contains a before/after comparison of the idea
    And the report contains dimension summaries from each subagent

  Scenario: Shape reference documents exist for subagent prompts
    Given the arc plugin is installed in a project
    When the user inspects skills/arc-shape/references/
    Then shaping-dimensions.md contains definitions for all four analysis dimensions
    And brief-validation.md contains readiness criteria for spec-ready status

  Scenario: Shape offers next steps after completion
    Given the user has completed shaping an idea
    When the skill presents next steps
    Then the options include shape another idea, approve as spec-ready, plan a wave with /arc-wave, or done
