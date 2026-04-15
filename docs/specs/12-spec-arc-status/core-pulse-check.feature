# Source: docs/specs/12-spec-arc-status/12-spec-arc-status.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Core Pulse Check — Data Aggregation and Inline Summary

  Scenario: Skill file exists with required frontmatter
    Given the arc plugin is installed locally
    When the user invokes /arc-status
    Then the response begins with "**ARC-STATUS**"
    And the output contains a "Current Wave" section
    And the output contains a "Backlog Snapshot" section
    And the output contains an "In-Flight Specs" section
    And the output contains a "Recent Activity" section

  Scenario: Backlog snapshot counts ideas by status
    Given docs/BACKLOG.md contains a summary table with 20 captured, 0 shaped, 1 spec-ready, and 8 shipped ideas
    When the user invokes /arc-status
    Then the "Backlog Snapshot" section displays idea counts per status matching the summary table
    And the total count across all statuses matches the number of rows in the backlog

  Scenario: Current wave is identified from roadmap
    Given docs/ROADMAP.md contains a wave summary table with Wave 1 completed and Wave 2 in progress
    When the user invokes /arc-status
    Then the "Current Wave" section identifies "Wave 2" as the active wave
    And the section includes the wave title and progress summary

  Scenario: In-flight specs are detected from spec directories
    Given docs/specs/ contains directories matching the NN-spec-* pattern with spec files inside
    When the user invokes /arc-status
    Then the "In-Flight Specs" section lists each spec directory found
    And each entry indicates whether a validation report is present

  Scenario: Recent activity shows git commit history
    Given the repository has at least one commit
    When the user invokes /arc-status
    Then the "Recent Activity" section displays up to 10 recent commits in one-line format

  Scenario: Skill output is strictly read-only
    Given the repository working tree is clean
    When the user invokes /arc-status
    Then no files are created, modified, or deleted in the working tree
    And the git status remains clean after the skill completes

  Scenario: Missing ROADMAP.md is handled gracefully
    Given docs/ROADMAP.md does not exist in the repository
    When the user invokes /arc-status
    Then the "Current Wave" section displays a single-line notice that no roadmap was found
    And the remaining sections (Backlog Snapshot, In-Flight Specs, Recent Activity) are still displayed

  Scenario: Missing specs directory is handled gracefully
    Given docs/specs/ directory does not exist
    When the user invokes /arc-status
    Then the "In-Flight Specs" section displays a single-line notice that no specs were found
    And the remaining sections are still displayed
