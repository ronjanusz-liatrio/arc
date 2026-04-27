# Source: docs/specs/17-spec-claude-md-static-references/17-spec-claude-md-static-references.md
# Pattern: State (real-repo migration with byte-level invariants)
# Recommended test type: Integration

Feature: Dogfood migration on arc repo CLAUDE.md

  Scenario: /arc-sync rewrites the arc repo's ARC:product-context block to the static format
    Given the working directory is /home/ron.linux/arc/
    And Units 1, 2, and 3 of this spec have been implemented
    And /home/ron.linux/arc/CLAUDE.md currently contains a legacy ARC:product-context block with live counts
    When the maintainer runs /arc-sync
    Then the resulting /home/ron.linux/arc/CLAUDE.md contains exactly one "<!--# BEGIN ARC:product-context -->" marker
    And the resulting CLAUDE.md contains exactly one "<!--# END ARC:product-context -->" marker
    And the content between the markers is the new static block (intro sentence + four labeled links)

  Scenario: Migrated block contains the four required artifact links
    Given /arc-sync has run against /home/ron.linux/arc/
    When a reader inspects the bytes between the ARC:product-context BEGIN and END markers
    Then a markdown link to docs/BACKLOG.md is present
    And a markdown link to docs/ROADMAP.md is present
    And a markdown link to docs/VISION.md is present
    And a markdown link to docs/CUSTOMER.md is present
    And each link is followed by an em-dash and a one-line usage hint

  Scenario: Migrated block contains no live status fields
    Given /arc-sync has run against /home/ron.linux/arc/
    When a reader inspects the bytes between the ARC:product-context BEGIN and END markers
    Then no line beginning with "**Backlog:**" is present
    And no line beginning with "**Current Wave:**" is present
    And no line beginning with "**Phase:**" is present
    And no line beginning with "**Primary Personas:**" is present
    And no line beginning with "**Vision:**" is present

  Scenario: Block is not relocated within the file during migration
    Given the legacy ARC:product-context block sat at byte offset X in /home/ron.linux/arc/CLAUDE.md before migration
    When /arc-sync rewrites the block in place
    Then the new ARC:product-context BEGIN marker appears in the same relative position to surrounding non-ARC content as before
    And the order of all top-level sections in CLAUDE.md is unchanged

  Scenario: Non-ARC content in CLAUDE.md is preserved byte-for-byte
    Given /home/ron.linux/arc/CLAUDE.md contains content outside the ARC:product-context markers — narrative prose, the SKILLZ:installed-skills section, and any TEMPER: blocks if present
    When /arc-sync runs
    Then the bytes outside the ARC:product-context BEGIN/END marker pair are byte-identical to their pre-run state
    And running "diff" on the file scoped to non-ARC regions reports zero differences

  Scenario: Commit diff is confined to the ARC: marker boundaries
    Given the maintainer commits the migrated CLAUDE.md
    When the maintainer runs "git diff HEAD~1 HEAD -- CLAUDE.md"
    Then every changed line in the diff falls between the "<!--# BEGIN ARC:product-context -->" and "<!--# END ARC:product-context -->" markers, modulo whitespace
    And no changes appear in the SKILLZ:installed-skills section
    And no changes appear in unmanaged narrative sections above or below the ARC: block

  Scenario: Re-running /arc-sync on the dogfooded repo is a no-op
    Given /home/ron.linux/arc/CLAUDE.md has been migrated and committed
    When the maintainer runs /arc-sync a second time without other changes
    Then "git status" reports CLAUDE.md as unchanged
    And the working tree is clean for that file
