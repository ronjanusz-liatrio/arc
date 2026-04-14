# Source: docs/specs/10-spec-arc-ship/10-spec-arc-ship.md
# Pattern: CLI/Process + State + Error handling
# Recommended test type: Integration

Feature: Core Ship Skill — Single Idea Flow

  Scenario: User selects a spec-ready idea and ships it with a passing validation report
    Given docs/BACKLOG.md contains an idea "Widget Export" with status "spec-ready" and a Spec field pointing to "docs/specs/05-spec-widget-export/"
    And docs/specs/05-spec-widget-export/05-validation-widget-export.md exists containing "**Overall**: PASS"
    When the user invokes /arc-ship and selects "Widget Export"
    Then the BACKLOG summary table row for "Widget Export" shows status "shipped"
    And the BACKLOG detail section for "Widget Export" contains "- **Status:** shipped"
    And the BACKLOG detail section contains "- **Shipped:" followed by an ISO 8601 timestamp
    And the BACKLOG detail section contains "- **Spec:** docs/specs/05-spec-widget-export/"
    And a confirmation message is displayed: "Shipped: Widget Export — verified via docs/specs/05-spec-widget-export/05-validation-widget-export.md"

  Scenario: User ships an idea by providing a title argument with partial match
    Given docs/BACKLOG.md contains a spec-ready idea titled "Dashboard Access Control"
    And a passing validation report exists in the idea's spec directory
    When the user invokes /arc-ship "dashboard access"
    Then the system finds "Dashboard Access Control" via case-insensitive partial match
    And the system asks the user to confirm the match before proceeding
    And after confirmation the BACKLOG detail section for "Dashboard Access Control" shows status "shipped"

  Scenario: No spec-ready ideas exist in the backlog
    Given docs/BACKLOG.md contains ideas but none have status "spec-ready"
    When the user invokes /arc-ship
    Then the system displays "No spec-ready ideas found in docs/BACKLOG.md. Run `/arc-wave` to promote shaped ideas."
    And no changes are made to docs/BACKLOG.md

  Scenario: Idea is missing the Spec field so user is prompted for the spec path
    Given docs/BACKLOG.md contains a spec-ready idea "Auth Tokens" without a "- **Spec:**" field
    When the user invokes /arc-ship and selects "Auth Tokens"
    Then the system asks the user to provide the spec directory path via AskUserQuestion
    And after the user provides "docs/specs/03-spec-auth-tokens/" the system proceeds with validation lookup in that directory

  Scenario: No validation report found in the spec directory
    Given docs/BACKLOG.md contains a spec-ready idea "Metrics Pipeline" with Spec field "docs/specs/06-spec-metrics/"
    And docs/specs/06-spec-metrics/ contains no file matching "*-validation-*.md"
    When the user invokes /arc-ship and selects "Metrics Pipeline"
    Then the system displays "No cw-validate report found in `docs/specs/06-spec-metrics/`. Run `/cw-validate` first."
    And the BACKLOG status for "Metrics Pipeline" remains "spec-ready"

  Scenario: Validation report exists but overall status is not PASS
    Given docs/BACKLOG.md contains a spec-ready idea "Search Rewrite" with Spec field "docs/specs/07-spec-search/"
    And docs/specs/07-spec-search/07-validation-search.md contains "**Overall**: PARTIAL"
    When the user invokes /arc-ship and selects "Search Rewrite"
    Then the system displays "Validation report found but status is `PARTIAL`, not PASS. Resolve validation failures before shipping."
    And the BACKLOG status for "Search Rewrite" remains "spec-ready"

  Scenario: SKILL.md exists with correct frontmatter and walkthrough diagram
    Given the /arc-ship skill has been implemented
    When the user invokes /arc-ship
    Then the skill loads from skills/arc-ship/SKILL.md
    And the skill frontmatter contains name "arc-ship" and user-invocable "true"
    And the skill body contains a "## Walkthrough" section with a mermaid flowchart before "## Critical Constraints"
