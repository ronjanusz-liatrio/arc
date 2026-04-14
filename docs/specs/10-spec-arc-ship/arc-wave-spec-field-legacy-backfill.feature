# Source: docs/specs/10-spec-arc-ship/10-spec-arc-ship.md
# Pattern: State + CLI/Process
# Recommended test type: Integration

Feature: arc-wave Spec Field + Legacy Backfill

  Scenario: arc-wave populates a Spec placeholder when promoting an idea to spec-ready
    Given docs/BACKLOG.md contains a shaped idea "Notification System"
    When the user runs /arc-wave and assigns "Notification System" to a wave
    Then the BACKLOG detail section for "Notification System" contains "- **Spec:** (set during /cw-spec)"
    And the idea's status is updated to "spec-ready"

  Scenario: arc-ship offers interactive backfill when a shipped idea lacks the Spec field
    Given docs/BACKLOG.md contains a spec-ready idea "Legacy Feature" without a "- **Spec:**" field
    And docs/specs/ contains directories including "02-spec-legacy-feature/"
    When the user invokes /arc-ship and selects "Legacy Feature"
    Then the system presents a list of spec directories from docs/specs/ via AskUserQuestion
    And after the user selects "docs/specs/02-spec-legacy-feature/" the BACKLOG detail section for "Legacy Feature" contains "- **Spec:** docs/specs/02-spec-legacy-feature/"

  Scenario: Batch backfill of Wave 0 items missing Spec fields
    Given docs/BACKLOG.md contains 3 shipped Wave 0 items without "- **Spec:**" fields
    And docs/specs/ contains matching spec directories for each item
    When the user invokes /arc-ship and the system detects shipped items without Spec fields
    Then the system offers a "Backfill Wave 0" option
    And for each shipped item the system presents the likely spec match by title similarity for user confirmation
    And after confirmation each item's BACKLOG detail section contains a "- **Spec:**" field with the confirmed path

  Scenario: cross-plugin-contract documents cw artifacts read by Arc
    Given the /arc-ship skill has been implemented
    When the user reads references/cross-plugin-contract.md
    Then the file contains a section titled "Claude-Workflow Artifacts Read by Arc"
    And that section documents validation reports at "docs/specs/NN-spec-name/NN-validation-*.md"
    And that section documents proof files at "docs/specs/NN-spec-name/NN-proofs/"
