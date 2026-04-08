# Source: docs/specs/02-spec-arc-plugin-enhancement/02-spec-arc-plugin-enhancement.md
# Pattern: CLI/Process + State + Error handling (skill invocation with file reads, audit logic, report generation, and interactive fixes)
# Recommended test type: Integration

Feature: /arc-review Skill

  Scenario: Skill definition follows plugin conventions
    Given the arc plugin is installed in a project
    When the user inspects skills/arc-review/SKILL.md
    Then the frontmatter contains name set to "arc-review"
    And the frontmatter contains user-invocable set to true
    And the frontmatter contains an allowed-tools list including Glob, Grep, Read, Write, Edit, and AskUserQuestion

  Scenario: Review begins with context marker
    Given the arc plugin is installed in a project
    When the user invokes /arc-review
    Then the skill response begins with "**ARC-REVIEW**"

  Scenario: Review reads all product artifacts when available
    Given docs/BACKLOG.md, docs/ROADMAP.md, docs/VISION.md, docs/CUSTOMER.md, and docs/management-report.md all exist
    When the user invokes /arc-review
    Then the skill reads all five files and proceeds to analysis
    And the review report references findings from each artifact

  Scenario: Review exits gracefully when BACKLOG.md is absent
    Given no docs/BACKLOG.md file exists
    When the user invokes /arc-review
    Then the skill displays "No backlog found" and exits without producing a report
    And no docs/review-report.md file is created

  Scenario: Review detects stale captured ideas
    Given docs/BACKLOG.md contains an idea with status "captured" and a timestamp older than 14 days
    When the user invokes /arc-review
    Then the review report lists that idea as stale under backlog health findings
    And the finding severity is "warning"

  Scenario: Review allows configurable staleness threshold
    Given docs/BACKLOG.md contains a captured idea with a timestamp 10 days old
    When the user invokes /arc-review and adjusts the staleness threshold to 7 days
    Then the review report lists that idea as stale
    And the finding reflects the user-configured 7-day threshold

  Scenario: Review detects priority imbalance when majority is single priority
    Given docs/BACKLOG.md contains five non-shipped ideas all at priority P1-High
    When the user invokes /arc-review
    Then the review report flags a priority imbalance warning
    And the finding notes that more than 50% of ideas are at a single priority level

  Scenario: Review detects priority imbalance when mid-low priorities are empty
    Given docs/BACKLOG.md contains ideas only at P0-Critical and P1-High with none at P2-Medium or P3-Low
    When the user invokes /arc-review
    Then the review report flags a priority imbalance warning
    And the finding notes that zero ideas exist at P2-Medium or P3-Low

  Scenario: Review reports status distribution with bottleneck warnings
    Given docs/BACKLOG.md contains five shaped ideas and zero spec-ready ideas
    When the user invokes /arc-review
    Then the review report includes a status distribution table with counts per status
    And the report warns about a bottleneck at the shaped-to-spec-ready transition

  Scenario: Review detects missing brief fields in shaped ideas
    Given docs/BACKLOG.md contains a shaped idea missing the "Constraints" and "Assumptions" sections
    When the user invokes /arc-review
    Then the review report lists the missing sections for that idea
    And the finding severity is "warning"

  Scenario: Review detects invalid status values
    Given docs/BACKLOG.md contains an idea with status "in-progress" which is not in the allowed set
    When the user invokes /arc-review
    Then the review report flags the invalid status value
    And the finding severity is "critical"

  Scenario: Review detects broken ROADMAP references
    Given docs/ROADMAP.md references a BACKLOG idea by anchor "widget-api"
    And docs/BACKLOG.md does not contain a section with that anchor
    When the user invokes /arc-review
    Then the review report flags the broken ROADMAP reference under wave alignment findings
    And the finding severity is "critical"

  Scenario: Review detects status mismatch in ROADMAP wave entries
    Given docs/ROADMAP.md includes an idea in a wave
    And that idea has status "captured" in docs/BACKLOG.md instead of "spec-ready" or "shipped"
    When the user invokes /arc-review
    Then the review report flags the status mismatch
    And the finding notes the idea should be "spec-ready" or "shipped" to be in a wave

  Scenario: Review detects orphaned spec-ready ideas
    Given docs/BACKLOG.md contains an idea with status "spec-ready"
    And docs/ROADMAP.md does not reference that idea in any wave
    When the user invokes /arc-review
    Then the review report flags the orphaned spec-ready idea under wave alignment findings
    And the finding severity is "warning"

  Scenario: Review checks VISION.md exists and is not a stub
    Given docs/VISION.md exists but contains only the auto-created template note
    When the user invokes /arc-review
    Then the review report warns that VISION.md is a stub and needs to be filled in
    And the finding severity is "info"

  Scenario: Review checks CUSTOMER.md has named personas
    Given docs/CUSTOMER.md exists with at least one named persona
    And docs/BACKLOG.md contains a shaped idea referencing a persona not found in CUSTOMER.md
    When the user invokes /arc-review
    Then the review report warns about the unrecognized persona reference
    And the finding severity is "warning"

  Scenario: Review verifies cross-reference integrity between summary table and sections
    Given docs/BACKLOG.md has a summary table row for "Widget API" but no corresponding "## Widget API" section
    When the user invokes /arc-review
    Then the review report flags the orphaned summary table row
    And the finding severity is "critical"

  Scenario: Review generates report with health rating and structured findings
    Given docs/BACKLOG.md contains a mix of healthy and problematic ideas
    When the user invokes /arc-review
    Then docs/review-report.md is created with a timestamp
    And the report contains an overall health rating of "Healthy", "Needs Attention", or "Critical"
    And the report contains per-dimension findings with severity levels
    And the report contains recommended actions for each finding

  Scenario: Review offers interactive fixes for stale ideas
    Given docs/BACKLOG.md contains a stale captured idea
    When the user invokes /arc-review and the review completes
    Then the skill presents AskUserQuestion offering to mark the stale idea with a reviewed comment
    And if the user accepts, BACKLOG.md contains "<!-- stale: reviewed" followed by the current date

  Scenario: Review offers interactive fix for summary table mismatches
    Given docs/BACKLOG.md has an orphaned summary table row
    When the user invokes /arc-review and selects the fix
    Then BACKLOG.md summary table is updated to match the actual section headings
    And no content sections are deleted

  Scenario: Review offers interactive fix for missing brief fields
    Given docs/BACKLOG.md contains a shaped idea missing the "Constraints" section
    When the user invokes /arc-review and selects the fix
    Then BACKLOG.md contains "<!-- TODO: fill Constraints -->" in that idea section

  Scenario: Review offers interactive fix for broken ROADMAP references
    Given docs/ROADMAP.md contains a broken reference to a nonexistent BACKLOG idea
    When the user invokes /arc-review and selects the fix with user confirmation
    Then the broken reference is removed from docs/ROADMAP.md
    And the user was presented with a confirmation prompt before the removal

  Scenario: Review never modifies VISION.md or CUSTOMER.md
    Given docs/VISION.md is a stub and docs/CUSTOMER.md has missing personas
    When the user invokes /arc-review and applies all offered fixes
    Then docs/VISION.md content is unchanged
    And docs/CUSTOMER.md content is unchanged

  Scenario: Review offers next steps after completion
    Given the user has completed a review and applied fixes
    When the skill presents next steps
    Then the options include running review again, proceeding to /arc-capture or /arc-wave, or done

  Scenario: Audit dimensions reference document exists
    Given the arc plugin is installed in a project
    When the user inspects skills/arc-review/references/audit-dimensions.md
    Then the file contains backlog health check definitions with thresholds
    And the file contains wave alignment check definitions with severity levels

  Scenario: Review report template reference document exists
    Given the arc plugin is installed in a project
    When the user inspects skills/arc-review/references/review-report-template.md
    Then the file contains the report format with timestamp, health rating, findings, and actions sections
