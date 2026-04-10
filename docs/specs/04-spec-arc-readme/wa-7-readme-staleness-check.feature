# Source: docs/specs/04-spec-arc-sync/04-spec-arc-sync.md
# Pattern: State
# Recommended test type: Integration

Feature: WA-7 README Trust-Signal Audit

  Scenario: Detects failing trust signals when README drifts from artifacts
    Given a project with BACKLOG.md containing 3 shipped ideas
    And README.md has an ARC:features section listing only 1 of the 3 shipped ideas
    When the user runs /arc-audit
    Then the WA-7 trust-signal scorecard reports TS-3 (Features) as failing
    And TS-6 (Currency) reports shipped count mismatch "1 in README vs 3 in BACKLOG"
    And the recommended action says "Run /arc-sync"

  Scenario: Reports all signals passing when README is current
    Given a project with VISION.md, CUSTOMER.md, BACKLOG.md, and ROADMAP.md
    And README.md ARC: sections accurately reflect all 4 artifacts
    And ARC:features lists all shipped ideas
    And ARC:audience lists the primary persona from CUSTOMER.md
    When the user runs /arc-audit
    Then the WA-7 scorecard reports 8 of 8 signals passing
    And WA-7 severity is info

  Scenario: Detects placeholder text when source artifact has real content
    Given a project with CUSTOMER.md containing a primary persona "Platform Engineer"
    And README.md ARC:audience section contains "Not yet defined"
    When the user runs /arc-audit
    Then TS-8 (No Placeholders) fails for ARC:audience
    And TS-2 (Audience) also fails because no persona name matches CUSTOMER.md

  Scenario: Permits placeholder text when source artifact is absent
    Given a project with VISION.md but no CUSTOMER.md
    And README.md ARC:audience section contains "Not yet defined"
    When the user runs /arc-audit
    Then TS-8 (No Placeholders) passes for ARC:audience
    And TS-2 (Audience) is not evaluable and excluded from the scorecard

  Scenario: Detects missing traceability links
    Given a project with README.md containing ARC: managed sections
    And no ARC: section contains a docs/ link
    When the user runs /arc-audit
    Then TS-7 (Traceability) fails
    And the scorecard reports the signal and expected fix

  Scenario: Detects decorative lifecycle diagram with all-zero counts
    Given a project with README.md containing an ARC:lifecycle-diagram section
    And the mermaid diagram has all status counts at zero
    When the user runs /arc-audit
    Then TS-5 (Lifecycle Diagram) fails because all node labels are zero

  Scenario: Skips gracefully when README.md does not exist
    Given a project with no README.md at the project root
    When the user runs /arc-audit
    Then WA-7 reports severity info with "No README.md found"

  Scenario: Skips gracefully when README has no ARC markers
    Given a project with README.md containing no ARC: managed section markers
    When the user runs /arc-audit
    Then WA-7 reports severity info with "No ARC: sections in README"
    And suggests "Run /arc-sync to scaffold"

  Scenario: Severity is warning when fewer than 75 percent of signals pass
    Given a project where 3 of 8 evaluable trust signals pass
    When the health rating is calculated
    Then WA-7 contributes 1 warning to the warning count

  Scenario: Severity is info when 75 percent or more signals pass
    Given a project where 7 of 8 evaluable trust signals pass
    When the health rating is calculated
    Then WA-7 does not contribute to the warning count
