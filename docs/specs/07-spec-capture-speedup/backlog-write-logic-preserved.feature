# Source: docs/specs/07-spec-capture-speedup/07-spec-capture-speedup.md
# Pattern: State (file system persistence with format integrity)
# Recommended test type: Integration

Feature: Backlog Write Logic Preserved

  Scenario: New backlog is created from template when none exists
    Given the arc plugin is installed in a project
    And no docs/BACKLOG.md file exists
    When the user completes /arc-capture with title "Widget API" and priority P1-High
    Then docs/BACKLOG.md is created from the backlog template
    And the file contains the captured idea with all required fields

  Scenario: Summary table row uses correct format with anchor link
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists
    When the user completes /arc-capture with title "Widget API" and priority P1-High
    Then docs/BACKLOG.md contains a summary table row matching "| [Widget API](#widget-api) | captured | P1-High | -- |"

  Scenario: Idea section contains all required data fields
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists
    When the user completes /arc-capture with title "Widget API", summary "REST API for widgets", and priority P2-Medium
    Then docs/BACKLOG.md contains an idea section headed "Widget API"
    And the section includes a Status field set to "captured"
    And the section includes a Priority field set to "P2-Medium"
    And the section includes a Captured field with an ISO 8601 timestamp
    And the section includes the one-line summary "REST API for widgets"

  Scenario: ISO 8601 timestamp is used for the Captured field
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists
    When the user completes /arc-capture with any valid idea and priority
    Then the Captured field in the new idea section matches the ISO 8601 format (e.g., 2026-04-10T14:30:00Z)

  Scenario: Anchor link format strips special characters and uses hyphens
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists
    When the user completes /arc-capture with title "Widget API (v2) -- Beta!"
    Then the summary table row anchor link is "#widget-api-v2----beta" with special characters stripped and spaces replaced by hyphens
    And the anchor link correctly references the corresponding idea section heading
