# Source: docs/specs/04-spec-arc-sync/04-spec-arc-sync.md
# Pattern: State + CLI/Process
# Recommended test type: Integration

Feature: /arc-sync Scaffold Mode

  Scenario: Scaffolds full README from VISION.md when no README exists
    Given a project with docs/VISION.md containing a Vision Summary and Problem Statement
    And no README.md exists at the project root
    When the user runs /arc-sync
    Then the system enters scaffold mode
    And the generated README contains a title derived from the VISION.md Vision Summary first sentence
    And the generated README contains an ARC:overview managed section with the problem statement
    And the generated README contains an ARC:lifecycle-diagram managed section with a mermaid diagram
    And the generated README contains static placeholder sections for Install, Contributing, and License

  Scenario: Scaffold includes audience section when CUSTOMER.md exists
    Given a project with docs/VISION.md and docs/CUSTOMER.md containing a primary persona
    And no README.md exists
    When the user runs /arc-sync
    Then the generated README contains an ARC:audience managed section
    And the audience section lists the primary persona name and role from CUSTOMER.md
    And TS-2 (Audience) passes in the trust-signal scorecard

  Scenario: Scaffold uses placeholder when CUSTOMER.md is absent
    Given a project with docs/VISION.md but no docs/CUSTOMER.md
    And no README.md exists
    When the user runs /arc-sync
    Then the generated README contains an ARC:audience managed section with "Not yet defined"
    And TS-8 (No Placeholders) passes because CUSTOMER.md is absent
    And TS-2 (Audience) is excluded from the scorecard as not evaluable

  Scenario: Scaffold includes shipped features when BACKLOG.md has shipped items
    Given a project with docs/VISION.md and docs/BACKLOG.md with 2 shipped ideas
    And no README.md exists
    When the user runs /arc-sync
    Then the generated README contains an ARC:features managed section
    And the features section lists both shipped idea titles as bullet points
    And the features section does not expose priority metadata
    And TS-3 (Features) and TS-6 (Currency) both pass

  Scenario: Scaffold includes roadmap when ROADMAP.md exists
    Given a project with docs/VISION.md and docs/ROADMAP.md with an active wave
    And no README.md exists
    When the user runs /arc-sync
    Then the generated README contains an ARC:roadmap managed section
    And the roadmap section shows the active wave name and theme
    And TS-4 (Roadmap) passes

  Scenario: Scaffold includes traceability links to docs
    Given a project with docs/VISION.md
    And no README.md exists
    When the user runs /arc-sync
    Then at least one ARC: managed section contains a link to a file in docs/
    And the linked file exists on disk
    And TS-7 (Traceability) passes

  Scenario: Refuses to run when VISION.md is absent
    Given a project with no docs/VISION.md
    When the user runs /arc-sync
    Then the system displays a warning "Run /arc-capture or create VISION.md first"
    And no README.md is created

  Scenario: Refuses to run when VISION.md is a stub
    Given a project with docs/VISION.md containing fewer than 200 non-whitespace characters
    When the user runs /arc-sync
    Then the system displays a warning about insufficient VISION content
    And no README.md is created

  Scenario: Presents scaffolded README with trust-signal scorecard for approval
    Given a project with docs/VISION.md and no README.md
    When the user runs /arc-sync
    Then the system presents the scaffolded README content for review
    And displays a trust-signal scorecard showing all evaluable signals passing
    And asks the user to approve before writing to disk

  Scenario: Lifecycle diagram shows live status counts
    Given a project with BACKLOG.md containing 3 captured, 2 shaped, 1 spec-ready, and 4 shipped ideas
    When the user runs /arc-sync in scaffold mode
    Then the lifecycle diagram mermaid code includes node labels with counts
    And the diagram uses Liatrio brand colors
    And TS-5 (Lifecycle Diagram) passes because at least one count is non-zero

  Scenario: All evaluable trust signals pass on scaffold output
    Given a project with VISION.md, CUSTOMER.md, BACKLOG.md with shipped items, and ROADMAP.md
    And no README.md exists
    When the user runs /arc-sync
    Then the trust-signal scorecard reports 8 of 8 signals passing
