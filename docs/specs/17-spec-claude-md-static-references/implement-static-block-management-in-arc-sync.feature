# Source: docs/specs/17-spec-claude-md-static-references/17-spec-claude-md-static-references.md
# Pattern: CLI/Process + State (file injection, migration, idempotency)
# Recommended test type: Integration

Feature: Implement static-block management in /arc-sync

  Scenario: /arc-sync skips silently when CLAUDE.md does not exist
    Given a project root with no CLAUDE.md file
    When the user runs /arc-sync
    Then no CLAUDE.md file is created in the project root
    And the /arc-sync summary output reports the action as "skipped (no CLAUDE.md)"
    And the command completes without raising an error

  Scenario: /arc-sync injects the static block into a CLAUDE.md that lacks the markers
    Given a project root containing a CLAUDE.md with no "<!--# BEGIN ARC:product-context -->" marker
    And the CLAUDE.md contains other narrative content and no TEMPER: or Snyk markers
    When the user runs /arc-sync
    Then the resulting CLAUDE.md contains exactly one "<!--# BEGIN ARC:product-context -->" marker
    And the resulting CLAUDE.md contains exactly one "<!--# END ARC:product-context -->" marker
    And the content between the markers matches the static template (intro sentence + four bullets to BACKLOG.md, ROADMAP.md, VISION.md, CUSTOMER.md)
    And the /arc-sync summary output reports the action as "injected"

  Scenario: /arc-sync inserts the block before the first TEMPER: marker when one is present
    Given a project root containing a CLAUDE.md with a "<!--# BEGIN TEMPER:" marker but no ARC: markers
    When the user runs /arc-sync
    Then the new ARC:product-context block appears earlier in the file than the first TEMPER: marker
    And the TEMPER: section content is unchanged byte-for-byte
    And the /arc-sync summary output reports the action as "injected"

  Scenario: /arc-sync migrates a legacy live block in place
    Given a project root containing a CLAUDE.md whose ARC:product-context block contains "**Backlog:** 12 captured, 3 shaped, 2 spec-ready, 7 shipped"
    And the same block contains "**Current Wave:**", "**Phase:**", "**Primary Personas:**", and "**Vision:**" lines
    When the user runs /arc-sync
    Then the resulting block between the ARC: markers contains markdown links to docs/BACKLOG.md, docs/ROADMAP.md, docs/VISION.md, and docs/CUSTOMER.md
    And the resulting block contains no "**Backlog:**" line
    And the resulting block contains no "**Current Wave:**" line
    And the resulting block contains no "**Phase:**" line
    And the resulting block contains no "**Primary Personas:**" line
    And the resulting block contains no "**Vision:**" line
    And the /arc-sync summary output reports the action as "migrated" or "refreshed"

  Scenario: /arc-sync is byte-idempotent across consecutive runs
    Given a project root containing a CLAUDE.md with a current static ARC:product-context block written by /arc-sync
    When the user runs /arc-sync
    And then runs /arc-sync a second time without any other change
    Then "git diff" between the two runs shows zero changes to CLAUDE.md
    And the byte length of CLAUDE.md is identical to its byte length before the second run

  Scenario: Output bytes are identical regardless of starting state
    Given three separate project roots — one with no ARC: block, one with a legacy live block, one with an already-migrated static block
    When the user runs /arc-sync in each project
    Then the bytes between the ARC: BEGIN and END markers in all three resulting CLAUDE.md files are identical to one another

  Scenario: /arc-sync does not touch TEMPER: or MM: managed sections
    Given a project root containing a CLAUDE.md with adjacent TEMPER: and MM: managed sections in addition to the ARC: section
    When the user runs /arc-sync
    Then the bytes inside the TEMPER: BEGIN/END markers are unchanged
    And the bytes inside the MM: BEGIN/END markers are unchanged
    And only content inside the ARC:product-context BEGIN/END markers has been rewritten

  Scenario: /arc-sync SKILL.md describes the CLAUDE.md handling step
    Given a developer opens skills/arc-sync/SKILL.md
    When the developer reads the execution steps in order
    Then a step appears after the README sync step describing CLAUDE.md product-context management
    And that step references the bootstrap-protocol for the static template definition

  Scenario: readme-mapping reference cross-links to the new responsibility
    Given a developer opens skills/arc-sync/references/readme-mapping.md
    When the developer reads the cross-references section
    Then the document notes that /arc-sync also manages the ARC:product-context section in CLAUDE.md
    And the note appears alongside or near the existing README mapping references

  Scenario: Diagnostic line appears in summary output for every action class
    Given /arc-sync has executed against a project
    When the user reads the printed summary
    Then exactly one line reports the CLAUDE.md action taken
    And the reported value is one of: "injected", "migrated", "refreshed", or "skipped (no CLAUDE.md)"
