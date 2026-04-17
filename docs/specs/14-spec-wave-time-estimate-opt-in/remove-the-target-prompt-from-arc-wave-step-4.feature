# Source: docs/specs/14-spec-wave-time-estimate-opt-in/14-spec-wave-time-estimate-opt-in.md
# Pattern: CLI/Process
# Recommended test type: Integration

Feature: Remove the Target prompt from arc-wave Step 4

  Scenario: Wave creation does not prompt for timeframe
    Given a project with Arc installed and no active wave
    When the user invokes "/arc-wave" and reaches Step 4
    Then the assistant presents a single AskUserQuestion asking only for the wave name/theme
    And no "Target timeframe for this wave?" question is presented to the user
    And the user can complete Step 4 by supplying only a theme value

  Scenario: Only the theme question remains in Step 4
    Given the user is at Step 4 of the "/arc-wave" flow
    When the assistant renders the Step 4 AskUserQuestion payload
    Then the payload contains exactly one question
    And the question header is related to the wave name or theme
    And the payload contains no question referencing "Target timeframe" or a timeframe selection list

  Scenario: The target variable is treated as unset when Step 4 completes
    Given a user has just completed Step 4 by providing only a theme
    When the flow advances to Step 5
    Then the internal "target" value carried forward to Steps 6, 10, and 11 is logically null (unset)
    And no default or implicit timeframe is substituted for the missing target

  Scenario: No upfront opt-in offer is reintroduced before Step 4
    Given a user invokes "/arc-wave" from a clean slate
    When the flow progresses from Step 1 through Step 4
    Then at no point before or during Step 4 is the user asked whether they want to provide a time estimate
    And no flag, branch, or pre-prompt reintroduces the removed Target question
