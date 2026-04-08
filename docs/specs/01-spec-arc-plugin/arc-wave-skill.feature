# Source: docs/specs/01-spec-arc-plugin/01-spec-arc-plugin.md
# Pattern: CLI/Process + State (skill invocation with multiple file mutations and managed section injection)
# Recommended test type: Integration

Feature: /arc-wave Skill

  Scenario: Skill definition follows plugin conventions
    Given the arc plugin is installed in a project
    When the user inspects skills/arc-wave/SKILL.md
    Then the frontmatter contains name set to "arc-wave"
    And the frontmatter contains user-invocable set to true
    And the frontmatter contains an allowed-tools list

  Scenario: Wave begins with context marker
    Given the arc plugin is installed in a project
    When the user invokes /arc-wave
    Then the skill response begins with "**ARC-WAVE**"

  Scenario: Wave presents shaped ideas for multi-select inclusion
    Given docs/BACKLOG.md contains three ideas with status "shaped"
    When the user invokes /arc-wave
    Then the skill presents an AskUserQuestion with all three shaped ideas as multi-select options
    And each option displays the idea title, priority, and brief summary

  Scenario: Wave constrains scope based on Temper management report in early phases
    Given docs/management-report.md exists indicating a Spike phase project
    And docs/BACKLOG.md contains four shaped ideas
    When the user invokes /arc-wave
    Then the skill recommends a small wave of 1-2 ideas
    And the skill warns about overscoping for the current project phase

  Scenario: Wave allows larger scope in Foundation or later phases
    Given docs/management-report.md exists indicating a Foundation phase project
    And docs/BACKLOG.md contains five shaped ideas
    When the user invokes /arc-wave
    Then the skill allows waves of 3-5 ideas without overscoping warnings

  Scenario: Wave recommends stabilization work when hard gate failures exist
    Given docs/management-report.md exists with hard gate failures
    And docs/BACKLOG.md contains shaped ideas
    When the user invokes /arc-wave
    Then the skill recommends including stabilization work in the wave plan

  Scenario: Wave proceeds without constraints when no management report exists
    Given no docs/management-report.md file exists
    And docs/BACKLOG.md contains shaped ideas
    When the user invokes /arc-wave
    Then the skill proceeds with wave planning without phase-based constraints
    And no error or warning about a missing management report is shown

  Scenario: Wave gathers wave details via interactive questions
    Given the user has selected ideas for the wave
    When the skill prompts for wave details
    Then the skill asks for wave name or theme via AskUserQuestion
    And the skill asks for target timeframe
    And the skill asks for any dependencies or blockers

  Scenario: Wave creates ROADMAP from template when none exists
    Given no docs/ROADMAP.md file exists
    When the user completes /arc-wave
    Then docs/ROADMAP.md is created from the ROADMAP template
    And the file contains the new wave with wave name, goal, selected ideas, timeframe, and status

  Scenario: Wave appends to existing ROADMAP
    Given docs/ROADMAP.md already exists with a previous wave
    When the user completes /arc-wave with wave name "Wave 2" and two selected ideas
    Then docs/ROADMAP.md contains a new wave section for "Wave 2"
    And the wave section lists the two selected ideas with links to their BACKLOG sections
    And the wave section includes the target timeframe and dependencies

  Scenario: Wave updates BACKLOG idea statuses to spec-ready
    Given the user selects two shaped ideas for the wave
    When the user completes /arc-wave
    Then both ideas in docs/BACKLOG.md show status changed from "shaped" to "spec-ready"
    And both ideas include the wave assignment

  Scenario: Wave injects ARC:product-context managed section into project CLAUDE.md
    Given a project CLAUDE.md exists
    When the user completes /arc-wave
    Then CLAUDE.md contains a managed section between "<!--# BEGIN ARC:product-context -->" and "<!--# END ARC:product-context -->"
    And the managed section contains the vision summary
    And the managed section contains the current wave name
    And the managed section contains primary personas
    And the managed section contains backlog status counts

  Scenario: Wave injection respects Temper namespace coexistence rules
    Given a project CLAUDE.md exists with TEMPER: and MM: managed sections
    When the user completes /arc-wave
    Then the ARC:product-context section does not modify any TEMPER: sections
    And the ARC:product-context section does not modify any MM: sections
    And the ARC:product-context section does not nest markers across namespaces

  Scenario: Wave creates stub VISION and CUSTOMER files when absent
    Given no docs/VISION.md and no docs/CUSTOMER.md exist
    When the user completes /arc-wave
    Then docs/VISION.md is created from the VISION template at stub level with a note to fill in
    And docs/CUSTOMER.md is created from the CUSTOMER template at stub level with a note to fill in

  Scenario: Wave saves a wave report with handoff instructions
    Given the user completes /arc-wave
    When the skill finalizes the wave
    Then docs/wave-report.md is created with the wave plan and selected ideas
    And the report contains Temper context if a management report was read
    And the report contains handoff instructions for /cw-spec

  Scenario: Wave reference documents exist
    Given the arc plugin is installed in a project
    When the user inspects skills/arc-wave/references/
    Then wave-report-template.md contains the wave report format
    And bootstrap-protocol.md contains ARC: namespace injection rules

  Scenario: Wave offers next steps after completion
    Given the user has completed wave planning
    When the skill presents next steps
    Then the options include hand off to /cw-spec with the spec-ready brief, plan another wave, or done
