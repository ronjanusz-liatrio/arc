# Source: docs/specs/14-spec-wave-time-estimate-opt-in/14-spec-wave-time-estimate-opt-in.md
# Pattern: State / CLI-Process (file output)
# Recommended test type: Integration

Feature: Render TBD placeholder when Target is unset

  Scenario: ROADMAP wave entry shows TBD placeholder when estimate is skipped
    Given a project with a valid "docs/ROADMAP.md" and no active wave
    And the user completes "/arc-wave" without providing a time estimate
    When Step 6 writes the new wave entry into "docs/ROADMAP.md"
    Then the wave entry contains the literal line "**Target:** TBD (use /arc-wave to add)"
    And the Target line is not omitted, blank, or replaced with a different hint string

  Scenario: Wave report header shows TBD placeholder when estimate is skipped
    Given the user has completed "/arc-wave" without a time estimate
    When Step 10 generates the wave report file under the wave directory
    Then the wave report header contains the literal line "**Target:** TBD (use /arc-wave to add)"
    And the placeholder string matches the one used in the ROADMAP wave entry

  Scenario: ROADMAP summary table Target column shows short TBD
    Given the user has completed "/arc-wave" without a time estimate
    When Step 6 updates the ROADMAP summary table row for the new wave
    Then the Target column cell for that row contains the value "TBD"
    And the cell does not contain the parenthetical "(use /arc-wave to add)" hint
    And the table remains structurally valid markdown

  Scenario: Existing Target values in prior ROADMAP waves are preserved
    Given "docs/ROADMAP.md" contains a prior wave entry with "**Target:** 2 weeks"
    When the user creates a new wave via "/arc-wave" without a time estimate
    Then the prior wave's "**Target:** 2 weeks" line is unchanged in "docs/ROADMAP.md"
    And no reformatting or migration is applied to earlier wave entries
    And only the newly appended wave entry contains the TBD placeholder

  Scenario: Archived wave reports are not rewritten
    Given "docs/skill/arc/waves/" contains an archived wave report with a populated Target value
    When the user runs "/arc-wave" to create a new wave without a time estimate
    Then the archived wave report file is byte-identical to its prior state
    And no archived wave under "docs/skill/arc/waves/" has been modified

  Scenario: A populated Target value renders without the TBD placeholder
    Given a project in which a user provides an explicit Target value (e.g., via a future code path or manual edit)
    When Step 6 and Step 10 render the wave entry and wave report
    Then the "**Target:**" line contains the supplied value verbatim
    And the "TBD (use /arc-wave to add)" placeholder does not appear on that line

  Scenario: Wave report template documents both populated and placeholder forms
    Given the repository contains "skills/arc-wave/references/wave-report-template.md"
    When a reader opens the template file
    Then the template shows an example "**Target:**" line with a populated value
    And the template shows an example "**Target:**" line with "TBD (use /arc-wave to add)" for the unset case
    And both example forms are rendered in the order and style matching a real wave report

  Scenario: ROADMAP template notes Target is optional at Vertical Slice and later phases
    Given the repository contains "templates/ROADMAP.tmpl.md"
    When a reader opens the ROADMAP template
    Then the Vertical Slice (and later phase) section indicates that Target Timeframe is optional
    And the documented placeholder form "TBD (use /arc-wave to add)" is shown as the unset rendering
