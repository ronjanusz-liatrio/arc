# Source: docs/specs/14-spec-wave-time-estimate-opt-in/14-spec-wave-time-estimate-opt-in.md
# Pattern: CLI/Process (assistant output)
# Recommended test type: Integration

Feature: Post-creation reminder note in the wave summary

  Scenario: Summary shows reminder when estimate is skipped
    Given the user has just completed "/arc-wave" without providing a time estimate
    When the assistant prints the Step 11 post-wave summary
    Then the response contains the exact line "Tip: no time estimate was captured. Add one by editing docs/ROADMAP.md or rerunning /arc-wave."
    And the line appears as plain assistant text alongside the Step 11 AskUserQuestion call
    And the line is not written to any file on disk

  Scenario: Summary omits reminder when estimate is present
    Given the user has just completed "/arc-wave" and the wave's target has a value
    When the assistant prints the Step 11 post-wave summary
    Then the response does not contain the string "Tip: no time estimate was captured"
    And no variation of the reminder note is printed
    And the Step 11 AskUserQuestion is still presented to the user

  Scenario: Reminder is not rendered as an AskUserQuestion option
    Given a wave was just created without a time estimate
    When the assistant issues the Step 11 AskUserQuestion call
    Then the AskUserQuestion options list does not include the reminder string
    And the reminder appears only in the surrounding plain-text response

  Scenario: Reminder does not prompt for input
    Given the post-creation summary emits the reminder note
    When the user reads the assistant's Step 11 response
    Then the assistant does not ask, prompt, or otherwise collect a time-estimate value at Step 11
    And the Step 11 flow proceeds using only the standard "next steps" question

  Scenario: Reminder wording is documented in SKILL.md
    Given the repository contains "skills/arc-wave/SKILL.md"
    When a reader opens the Step 11 section of the skill
    Then Step 11 documents the exact reminder-note text "Tip: no time estimate was captured. Add one by editing docs/ROADMAP.md or rerunning /arc-wave."
    And Step 11 documents the rule that the note is emitted only when "target" is unset
