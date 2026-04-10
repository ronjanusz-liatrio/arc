# Source: docs/specs/02-spec-arc-plugin-enhancement/02-spec-arc-plugin-enhancement.md
# Pattern: State (file content mutations for version bump and documentation updates)
# Recommended test type: Integration

Feature: Plugin Metadata and Documentation Update

  Scenario: plugin.json version is bumped to 0.3.0
    Given the arc plugin repository at its current state
    When the version bump is applied
    Then .claude-plugin/plugin.json contains version "0.3.0"

  Scenario: marketplace.json version is bumped to 0.3.0
    Given the arc plugin repository at its current state
    When the version bump is applied
    Then .claude-plugin/marketplace.json contains version "0.3.0"

  Scenario: Skills README includes arc-audit entry
    Given skills/README.md lists existing skills
    When the documentation update is applied
    Then skills/README.md contains a section for /arc-audit
    And the section includes a one-line description
    And the section includes invocation syntax
    And the section includes a link to arc-audit/SKILL.md

  Scenario: Project README includes arc-audit in Skills section
    Given README.md documents existing skills
    When the documentation update is applied
    Then README.md contains /arc-audit in the Skills section
    And /arc-audit is described alongside /arc-capture, /arc-shape, and /arc-wave

  Scenario: Project README includes arc-audit in Plugin Structure
    Given README.md contains a Plugin Structure file tree
    When the documentation update is applied
    Then README.md Plugin Structure section includes the arc-audit/ directory

  Scenario: No internal links are broken after updates
    Given all documentation files have been updated for 0.3.0
    When each internal markdown link in README.md and skills/README.md is checked
    Then every link target file exists in the repository
    And no link references a missing path
