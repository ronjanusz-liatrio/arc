# Source: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md
# Pattern: State (file creation with specific content structure)
# Recommended test type: Integration

Feature: Reference Documents

  Scenario: Idea lifecycle reference defines all four stages with transitions
    Given the arc plugin is installed in a project
    When the user reads references/idea-lifecycle.md
    Then the document contains the four stages: Capture, Shape, Spec-Ready, and Shipped
    And the document defines forward transitions between consecutive stages
    And the document defines backward transitions: Shape to Capture for "needs context" and Spec-Ready to Shape for "scope change"

  Scenario: Brief format reference provides the spec-ready brief template
    Given the arc plugin is installed in a project
    When the user reads references/brief-format.md
    Then the document contains all required brief sections: Problem, Proposed Solution, Success Criteria, Constraints, Assumptions, Wave Assignment, and Open Questions
    And each section includes a field description and example content

  Scenario: Wave planning reference describes organization principles
    Given the arc plugin is installed in a project
    When the user reads references/wave-planning.md
    Then the document covers capacity constraints for wave sizing
    And the document covers precedence rules for idea ordering
    And the document covers theme grouping for related ideas
    And the document covers Temper phase compatibility guidance

  Scenario: References README serves as a directory hub
    Given the arc plugin is installed in a project
    When the user reads references/README.md
    Then the document lists idea-lifecycle.md with a one-line description
    And the document lists brief-format.md with a one-line description
    And the document lists wave-planning.md with a one-line description
