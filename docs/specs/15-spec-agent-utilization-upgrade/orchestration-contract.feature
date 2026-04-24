# Source: docs/specs/15-spec-agent-utilization-upgrade/15-spec-agent-utilization-upgrade.md
# Pattern: State + CLI/Process
# Recommended test type: Integration

Feature: Orchestration Contract

  Scenario: A reader can locate every required section of the orchestration contract
    Given the repository after the orchestration contract lands
    When a reader opens "references/skill-orchestration.md"
    Then the document contains a section titled "State Vector"
    And the document contains a section titled "Skill Validity Matrix"
    And the document contains a section titled "Ordering Invariants"
    And the document contains a section titled "Dispatcher Precedence"
    And the document contains a section titled "Worked Example"

  Scenario: The skill-validity matrix lists a "valid when" condition for each arc skill
    Given a reader opens "references/skill-orchestration.md" at the "Skill Validity Matrix" section
    When the reader scans the matrix rows
    Then each of the 9 arc skills appears as a row
    And each row has a non-empty "valid when" condition referring to one or more state-vector fields (idea_status, shaped_count, spec_ready_count, wave_active, validation_status)

  Scenario: Ordering invariants I1 through I5 are each explicitly documented
    Given a reader opens the "Ordering Invariants" section
    When the reader scans the subsection labels
    Then invariants labelled "I1", "I2", "I3", "I4", and "I5" each appear with a one-line description covering backlog consistency, wave closure, roadmap closure, temporal monotonicity, and brief atomicity respectively

  Scenario: Dispatcher precedence names /arc-status as the coordinator and reproduces its Step 7 ordering
    Given a reader opens the "Dispatcher Precedence" section
    When the reader reads the section body
    Then the section names "/arc-status" as the coordinator skill
    And the precedence list reproduces the ordering of skills named in "skills/arc-status/SKILL.md" Step 7

  Scenario: The orchestration contract is descriptive, not enforcement
    Given an agent operates on a repository whose current state violates ordering invariant I2 (wave closure)
    When the agent invokes any arc skill whose "requires.state" is satisfied
    Then the skill runs to completion without refusing to execute
    And if the skill or a validator emits an advisory, that advisory is a warning (exit code 2) and not a failure (exit code 1)

  Scenario: The worked example maps a concrete state vector to a recommended next skill
    Given a reader opens the "Worked Example" section of "references/skill-orchestration.md"
    When the reader follows the example from input to recommendation
    Then the example shows a populated state vector (at least the five fields)
    And the example concludes with the name of a specific arc skill as the recommended next action
    And the recommended skill's "valid when" condition (from the matrix) is satisfied by the example state vector

  Scenario: The orchestration contract is cross-linked from all three entry points
    Given the repository after the orchestration contract lands
    When a user runs "grep -l skill-orchestration.md CLAUDE.md README.md references/README.md"
    Then the command exits with code 0
    And stdout lists all three paths: "CLAUDE.md", "README.md", and "references/README.md"
