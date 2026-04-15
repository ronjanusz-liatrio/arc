# Source: docs/specs/13-spec-wave-archive/13-spec-wave-archive.md
# Pattern: State + CLI/Process
# Recommended test type: Integration

Feature: Downstream readers re-point to wave archive

  Scenario: /arc-status derives Shipped count from wave archive files
    Given docs/skill/arc/waves/ contains archive files with a total of 10 "### " subsections
    And docs/BACKLOG.md contains 5 captured, 3 shaped, and 2 spec-ready ideas with no shipped rows
    When the user runs /arc-status
    Then the Backlog Snapshot section shows "Shipped: 10"
    And the Shipped count matches the total "### " subsection count across docs/skill/arc/waves/*.md
    And the output still presents four buckets: Captured, Shaped, Spec-Ready, and Shipped

  Scenario: /arc-status shows Shipped count of 0 when archive directory is absent
    Given the directory docs/skill/arc/waves/ does not exist
    And docs/BACKLOG.md contains ideas with statuses captured, shaped, and spec-ready only
    When the user runs /arc-status
    Then the Backlog Snapshot section shows "Shipped: 0"

  Scenario: /arc-audit counts shipped ideas from wave archive for status distribution
    Given docs/skill/arc/waves/ contains archive files with a total of 10 "### " subsections
    When the user runs /arc-audit
    Then the BH-3 status distribution check reports 10 shipped ideas
    And the shipped count matches the /arc-status Shipped value

  Scenario: /arc-audit cross-reference integrity excludes shipped ideas
    Given docs/skill/arc/waves/ contains archived ideas that were previously in BACKLOG
    And docs/BACKLOG.md contains only captured, shaped, and spec-ready ideas
    When the user runs /arc-audit
    Then the WA-6 cross-reference integrity check applies only to captured, shaped, and spec-ready rows
    And no errors are raised for ideas that exist in the archive but not in BACKLOG

  Scenario: /arc-sync features list is sourced from wave archive
    Given docs/skill/arc/waves/00-bootstrap.md contains 7 "### " subsections
    And docs/skill/arc/waves/01-lifecycle-closure.md contains 1 "### " subsection
    And docs/skill/arc/waves/02-shaping-intelligence.md contains 2 "### " subsections
    When the user runs /arc-sync
    Then the ARC:features section in README.md lists 10 bullet items
    And the bullets are ordered by wave number ascending (Wave 0 ideas first, then Wave 1, then Wave 2)
    And each bullet corresponds to a "### " subsection title from the archive files

  Scenario: /arc-sync lifecycle diagram Shipped count is sourced from wave archive
    Given docs/skill/arc/waves/ contains archive files with a total of 10 "### " subsections
    When the user runs /arc-sync
    Then the ARC:lifecycle-diagram section in README.md displays a Shipped count of 10
    And the count matches the total "### " subsection count in docs/skill/arc/waves/*.md

  Scenario: Trust signals TS-3 and TS-6 are evaluable when archive files exist
    Given docs/skill/arc/waves/00-bootstrap.md exists with at least one "### " subsection
    When the user runs /arc-sync
    Then trust signal TS-3 (Features) is marked as evaluable
    And trust signal TS-6 (Currency) is marked as evaluable

  Scenario: Trust signals TS-3 and TS-6 are not evaluable when no archive files exist
    Given the directory docs/skill/arc/waves/ does not exist or contains no files with "### " subsections
    When the user runs /arc-sync
    Then trust signal TS-3 (Features) is marked as not evaluable
    And trust signal TS-6 (Currency) is marked as not evaluable

  Scenario: CLAUDE.md product-context Backlog line reads shipped count from archive
    Given docs/skill/arc/waves/ contains archive files with a total of 10 "### " subsections
    When /arc-sync refreshes the ARC:product-context block in CLAUDE.md
    Then the "Backlog:" line in CLAUDE.md includes "10 shipped"
    And the shipped number equals the total "### " subsection count from docs/skill/arc/waves/*.md
