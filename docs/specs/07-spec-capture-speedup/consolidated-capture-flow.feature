# Source: docs/specs/07-spec-capture-speedup/07-spec-capture-speedup.md
# Pattern: CLI/Process + State (interactive skill invocation with file system writes)
# Recommended test type: Integration

Feature: Consolidated Capture Flow

  Scenario: Inline idea triggers single confirmation-and-priority prompt
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists with at least one prior entry
    When the user invokes /arc-capture with inline text "add dark mode support"
    Then exactly one AskUserQuestion interaction is presented before writing to the backlog
    And the interaction includes a confirmation question showing a parsed title and summary
    And the interaction includes a priority question with options P0-Critical, P1-High, P2-Medium, P3-Low

  Scenario: Inline idea is parsed into title and summary automatically
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists
    When the user invokes /arc-capture with inline text "add dark mode support for better nighttime readability"
    Then the confirmation prompt displays a parsed title derived from the inline text
    And the confirmation prompt displays a one-line summary derived from the inline text
    And the user is not asked to manually enter a title or summary

  Scenario: No inline idea triggers free-text prompt followed by confirmation-and-priority
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists
    When the user invokes /arc-capture with no inline idea
    Then a free-text AskUserQuestion is presented asking the user to describe their idea
    And after the user provides a description, a second prompt shows parsed title and summary with priority selection
    And no further prompts are presented after the second interaction

  Scenario: User selects Adjust and gets one retry then capture proceeds
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists
    When the user invokes /arc-capture with inline text "dark mode"
    And the user selects "Adjust" on the confirmation prompt
    And provides corrected text via the re-presented prompt
    Then the system re-parses and re-presents confirmation with priority selection
    And if the user selects "Adjust" again, the system captures the idea as-is without further retry

  Scenario: User provides free-text correction via Other option
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists
    When the user invokes /arc-capture with inline text "dark mode"
    And the user selects "Other" and types a free-text correction on the confirmation prompt
    Then the system re-parses the free-text into a new title and summary
    And re-presents the confirmation with priority selection

  Scenario: Context enrichment captures conversation context when available
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists
    And the user is in an active conversation about API design
    When the user invokes /arc-capture with inline text "rate limiting for public endpoints"
    And confirms the parsed title and selects a priority
    Then the idea section written to docs/BACKLOG.md includes context about the API design discussion

  Scenario: Backlog is not written until both confirmation and priority are collected
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists with known content
    When the user invokes /arc-capture with inline text "dark mode support"
    And the confirmation prompt is displayed but not yet answered
    Then docs/BACKLOG.md content remains unchanged from its initial state

  Scenario: Confirmation message is printed after successful capture
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists
    When the user invokes /arc-capture with inline text "dark mode support"
    And the user confirms with "Looks good" and selects priority "P2-Medium"
    Then the system prints exactly: Captured "Dark Mode Support" (priority: P2-Medium) to docs/BACKLOG.md.
    And no further prompts or menus are presented

  Scenario: No next-steps menu is shown after capture completes
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists
    When the user completes a full /arc-capture flow with confirmation and priority selection
    Then control returns immediately after the confirmation line
    And no "What would you like to do next?" prompt is displayed
    And no menu of follow-up actions is presented
