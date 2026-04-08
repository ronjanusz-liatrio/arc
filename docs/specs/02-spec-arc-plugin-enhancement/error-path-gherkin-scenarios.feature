# Source: docs/specs/02-spec-arc-plugin-enhancement/02-spec-arc-plugin-enhancement.md
# Pattern: Error handling + State (error-path scenarios appended to existing feature files)
# Recommended test type: Integration

Feature: Error-Path Gherkin Scenarios

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

  Scenario: arc-shape handles no captured ideas in BACKLOG
    Given the arc plugin is installed in a project
    And docs/BACKLOG.md contains only ideas with status "shaped" or "spec-ready"
    When the user invokes /arc-shape
    Then the skill displays a message that no captured ideas are available for shaping
    And no selection prompt is presented

  Scenario: arc-shape handles argument matching no idea
    Given docs/BACKLOG.md contains ideas titled "Widget API" and "Search Feature"
    When the user invokes /arc-shape with argument "Nonexistent Idea"
    Then the skill displays a message that no idea matching "Nonexistent Idea" was found
    And the skill lists available captured ideas for the user to choose from

  Scenario: arc-shape handles brief validation failure with multiple criteria
    Given the user is shaping an idea and gap-filling is complete
    When the skill validates the brief and multiple required sections fail validation
    Then the skill displays each failing section with a specific reason
    And the skill offers to re-enter the failing sections interactively

  Scenario: arc-shape handles subagent returning incomplete analysis
    Given the user has selected an idea for shaping
    When one of the four parallel dimension subagents returns without analysis results
    Then the skill marks that dimension as incomplete in the synthesis
    And the skill warns the user about the missing dimension analysis
    And the skill proceeds with available dimensions rather than failing entirely

  Scenario: arc-shape handles backward transition from shaped to captured
    Given docs/BACKLOG.md contains an idea with status "shaped"
    When the user invokes /arc-shape on that idea and critical gaps are unresolvable
    Then the skill transitions the idea status back from "shaped" to "captured" in BACKLOG.md
    And the skill displays a message explaining the idea needs further development before reshaping

  Scenario: arc-wave handles no shaped ideas in BACKLOG
    Given docs/BACKLOG.md exists with only captured ideas and no shaped ideas
    When the user invokes /arc-wave
    Then the skill displays a message that no shaped ideas are available for wave planning
    And the skill recommends running /arc-shape first

  Scenario: arc-wave handles absent BACKLOG.md
    Given the arc plugin is installed in a project
    And no docs/BACKLOG.md file exists
    When the user invokes /arc-wave
    Then the skill displays a message that BACKLOG.md was not found
    And the skill recommends running /arc-capture first to create the backlog

  Scenario: arc-wave handles zero ideas selected
    Given docs/BACKLOG.md contains shaped ideas
    When the user invokes /arc-wave and selects zero ideas from the multi-select prompt
    Then the skill displays a message that at least one idea must be selected
    And the skill re-presents the idea selection prompt

  Scenario: arc-wave handles scope exceeding phase recommendation with user override
    Given docs/management-report.md indicates a Spike phase project
    And docs/BACKLOG.md contains four shaped ideas
    When the user selects all four ideas for the wave exceeding the 1-2 recommendation
    Then the skill warns that the selection exceeds the recommended scope for Spike phase
    And the skill offers options to reduce scope or override and proceed
    And if the user chooses to override, the wave plan includes all four ideas

  Scenario: arc-wave handles absent CLAUDE.md during context injection
    Given no project CLAUDE.md exists
    When the user completes /arc-wave
    Then the skill logs a warning that CLAUDE.md was not found
    And the skill skips the ARC:product-context section injection
    And wave planning completes successfully without the context injection

  Scenario: arc-wave prevents ARC section nesting inside TEMPER block
    Given a project CLAUDE.md exists with a TEMPER: managed block
    And the insertion point for ARC:product-context would fall inside the TEMPER: block
    When the user completes /arc-wave
    Then the skill places the ARC:product-context section outside all TEMPER: blocks
    And the TEMPER: managed block content is unchanged

  Scenario: New error-path scenarios follow existing Gherkin conventions
    Given the existing .feature files use source comments, pattern annotations, and Given/When/Then structure
    When error-path scenarios are appended to arc-capture-skill.feature, arc-shape-skill.feature, and arc-wave-skill.feature
    Then each new scenario uses Given/When/Then structure consistent with existing scenarios
    And no existing scenarios are modified or removed
