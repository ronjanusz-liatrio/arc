# Source: docs/specs/04-spec-arc-readme/04-spec-arc-readme.md
# Pattern: State
# Recommended test type: Integration

Feature: /arc-readme Update Mode

  Scenario: Updates managed sections in existing README
    Given a project with README.md containing ARC:features and ARC:roadmap managed sections
    And BACKLOG.md has a new shipped idea not yet in README
    When the user runs /arc-readme
    Then the system enters update mode
    And the ARC:features section is rebuilt to include all shipped ideas
    And the ARC:roadmap section is rebuilt from current ROADMAP.md

  Scenario: Does not modify content outside managed sections
    Given a project with README.md containing manually-authored Install and Contributing sections
    And ARC:features managed section exists between them
    When the user runs /arc-readme
    Then the Install section content is unchanged
    And the Contributing section content is unchanged
    And only content between ARC: markers is modified

  Scenario: Does not modify TEMPER managed sections
    Given a project with README.md containing a TEMPER:phase-status managed section
    And ARC:features managed section exists in the same file
    When the user runs /arc-readme
    Then the TEMPER:phase-status section content is unchanged
    And the ARC:features section is updated with current data

  Scenario: Shows diff summary and trust-signal scorecard before writing
    Given a project with README.md containing outdated ARC: managed sections
    When the user runs /arc-readme
    Then the system displays a summary of sections to be updated and line count delta
    And displays the post-update trust-signal scorecard
    And asks the user to confirm before writing changes to disk

  Scenario: Warns on trust-signal regression after update
    Given a project with README.md where TS-7 (Traceability) was passing
    And an update would remove the only docs/ link from a managed section
    When the user runs /arc-readme
    Then the post-update scorecard warns that TS-7 regressed from pass to fail
    And explains what caused the regression

  Scenario: Reports newly evaluable trust signals
    Given a project with README.md scaffolded before CUSTOMER.md existed
    And CUSTOMER.md has now been created with a primary persona
    And ARC:audience still contains "Not yet defined"
    When the user runs /arc-readme
    Then TS-2 (Audience) is newly evaluable and passes after update
    And TS-8 (No Placeholders) passes because placeholder text was replaced with persona data

  Scenario: Offers to inject markers into README without existing ARC sections
    Given a project with README.md that contains no ARC: managed section markers
    When the user runs /arc-readme
    Then the system offers to inject ARC: markers at appropriate positions
    And explains which sections will be added

  Scenario: Updates mermaid diagrams in docs directory
    Given a project with docs/architecture.md containing an ARC:wave-pipeline-diagram marker
    And the current wave has 3 spec-ready ideas
    When the user runs /arc-readme
    Then the wave pipeline diagram in docs/architecture.md is regenerated
    And the diagram reflects the 3 current spec-ready ideas and their statuses

  Scenario: Lifecycle diagram updates with current BACKLOG counts
    Given a project with README.md containing an ARC:lifecycle-diagram section
    And BACKLOG.md status counts have changed since last update
    When the user runs /arc-readme
    Then the lifecycle diagram node labels reflect current status counts
    And the diagram uses Liatrio brand colors
    And TS-5 (Lifecycle Diagram) passes

  Scenario: Reports summary after update
    Given a project with README.md containing 3 ARC: managed sections
    When the user runs /arc-readme and confirms the update
    Then the system reports the number of sections updated
    And the number of diagrams updated
    And the line count delta
    And the trust-signal scorecard
