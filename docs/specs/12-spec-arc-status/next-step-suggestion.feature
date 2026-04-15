# Source: docs/specs/12-spec-arc-status/12-spec-arc-status.md
# Pattern: CLI/Process
# Recommended test type: Integration

Feature: Next-Step Suggestion

  Scenario: Validation-to-Shipped gap triggers arc-ship recommendation
    Given a Validation-to-Shipped lifecycle gap exists for an idea
    When the user invokes /arc-status
    Then an AskUserQuestion prompt is presented with /arc-ship labeled "(Recommended)"
    And the prompt includes the reason referencing the validated but unshipped idea

  Scenario: Plan-to-Validation gap triggers cw-validate recommendation
    Given a Plan-to-Validation lifecycle gap exists and no Validation-to-Shipped gap exists
    When the user invokes /arc-status
    Then an AskUserQuestion prompt is presented with /cw-validate labeled "(Recommended)"

  Scenario: Spec-to-Plan gap triggers cw-plan recommendation
    Given a Spec-to-Plan lifecycle gap exists and no higher-precedence gaps exist
    When the user invokes /arc-status
    Then an AskUserQuestion prompt is presented with /cw-plan labeled "(Recommended)"

  Scenario: Shaped-to-Spec gap triggers cw-spec recommendation
    Given a Shaped-to-Spec lifecycle gap exists and no higher-precedence gaps exist
    When the user invokes /arc-status
    Then an AskUserQuestion prompt is presented with /cw-spec labeled "(Recommended)"

  Scenario: Captured-to-Shaped gap on P0 or P1 idea triggers arc-shape recommendation
    Given a Captured-to-Shaped lifecycle gap exists on a P0 or P1 priority idea
    And no higher-precedence gaps exist
    When the user invokes /arc-status
    Then an AskUserQuestion prompt is presented with /arc-shape labeled "(Recommended)"

  Scenario: No gaps with active wave suggests rollup or audit
    Given no lifecycle gaps are detected
    And a current wave is in progress
    When the user invokes /arc-status
    Then an AskUserQuestion prompt is presented suggesting /arc-wave rollup or /arc-audit

  Scenario: No gaps and no active wave suggests new wave planning
    Given no lifecycle gaps are detected
    And no current wave is in progress
    When the user invokes /arc-status
    Then an AskUserQuestion prompt is presented with /arc-wave labeled "(Recommended)"

  Scenario: AskUserQuestion offers at least three options
    Given the pulse check and gap detection have completed
    When the user invokes /arc-status
    Then the AskUserQuestion prompt includes at least 3 options
    And one option is labeled "(Recommended)"
    And one option is an alternative skill
    And one option is "Done for now"

  Scenario: Selecting Done for now exits without invoking any skill
    Given the AskUserQuestion prompt is displayed after /arc-status completes
    When the user selects "Done for now"
    Then no skill is invoked
    And the session ends silently

  Scenario: Selecting a recommended skill invokes it
    Given the AskUserQuestion prompt is displayed with /arc-ship as the recommended skill
    When the user selects the /arc-ship option
    Then the /arc-ship skill is invoked via the Skill tool
    And no other skill is invoked

  Scenario: No skill is invoked without user confirmation
    Given the pulse check has completed with gaps detected
    When the user invokes /arc-status
    Then the system presents recommendations but does not invoke any skill automatically
    And a skill is only invoked after the user explicitly selects an option
