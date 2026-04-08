# Source: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md
# Pattern: CLI/Process + State (skill invocation producing file mutations)
# Recommended test type: Integration

Feature: /arc-capture Skill

  Scenario: Skill definition follows plugin conventions
    Given the arc plugin is installed in a project
    When the user inspects skills/arc-capture/SKILL.md
    Then the frontmatter contains name set to "arc-capture"
    And the frontmatter contains user-invocable set to true
    And the frontmatter contains an allowed-tools list

  Scenario: Capture begins with context marker
    Given the arc plugin is installed in a project
    When the user invokes /arc-capture
    Then the skill response begins with "**ARC-CAPTURE**"

  Scenario: Capture prompts for idea details via interactive questions
    Given the arc plugin is installed in a project
    When the user invokes /arc-capture
    Then the skill presents an AskUserQuestion prompt for idea title as freeform input
    And the skill presents a prompt for one-line summary as freeform input
    And the skill presents a single-select prompt for priority with options P0-Critical, P1-High, P2-Medium, and P3-Low

  Scenario: Capture creates BACKLOG from template when none exists
    Given the arc plugin is installed in a project
    And no docs/BACKLOG.md file exists
    When the user completes /arc-capture with title "Widget API", summary "REST API for widgets", and priority "P2-Medium"
    Then a new docs/BACKLOG.md file is created from the BACKLOG template at Foundation phase level
    And the file contains a "## Widget API" section with status "captured"

  Scenario: Capture appends to existing BACKLOG
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md already exists with one captured idea
    When the user completes /arc-capture with title "Search Feature", summary "Full-text search", and priority "P1-High"
    Then docs/BACKLOG.md contains a new "## Search Feature" section with status "captured"
    And the section includes priority "P1-High" and the one-line summary
    And the section includes a timestamp
    And the summary table at the top of BACKLOG.md includes a row for "Search Feature"

  Scenario: Capture offers next steps after completion
    Given the arc plugin is installed in a project
    When the user completes /arc-capture successfully
    Then the skill presents options to capture another idea, shape this idea with /arc-shape, or done

  Scenario: arc-capture error scenarios cover empty title input
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists
    When the user invokes /arc-capture and submits an empty title
    Then the skill displays an error message indicating the title is required
    And no new section is added to docs/BACKLOG.md

  Scenario: arc-capture error scenarios cover empty summary input
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists
    When the user invokes /arc-capture with title "Widget API" and an empty summary
    Then the skill displays an error message indicating the summary is required
    And no new section is added to docs/BACKLOG.md

  Scenario: arc-capture handles BACKLOG write failure gracefully
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md exists but is not writable
    When the user completes /arc-capture with valid inputs
    Then the skill displays an error message indicating the file could not be written
    And the skill does not report a successful capture
    And the original BACKLOG.md content is unchanged

  Scenario: arc-capture handles duplicate idea title
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md contains an idea titled "Widget API"
    When the user invokes /arc-capture with title "Widget API"
    Then the skill warns that an idea with this title already exists
    And the skill offers options to rename, overwrite, or cancel
