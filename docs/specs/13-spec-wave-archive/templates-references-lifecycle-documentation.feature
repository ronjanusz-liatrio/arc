# Source: docs/specs/13-spec-wave-archive/13-spec-wave-archive.md
# Pattern: State
# Recommended test type: Integration

Feature: Templates, references, and lifecycle documentation

  Scenario: BACKLOG template no longer includes shipped as a status value
    Given templates/BACKLOG.tmpl.md has been updated per the spec
    When a user initializes a new project using the BACKLOG template
    Then the Status column definition lists only "captured", "shaped", and "spec-ready"
    And no example row in the template shows a "shipped" status value

  Scenario: ROADMAP template no longer includes completed as a wave status
    Given templates/ROADMAP.tmpl.md has been updated per the spec
    When a user initializes a new project using the ROADMAP template
    Then the wave Status values list only "planned" and "active"
    And no "Completed Wave Retrospectives" section appears in the template
    And references to completed-wave content point to docs/skill/arc/waves/ instead

  Scenario: Idea lifecycle reference describes shipped ideas as archived
    Given references/idea-lifecycle.md has been updated per the spec
    When a reader reviews the Shipped stage description
    Then the description states that the idea is removed from BACKLOG
    And the description states that idea detail lives in docs/skill/arc/waves/NN-wave-name.md
    And the mermaid diagram still shows Shipped as a terminal state
    And the data-fields note clarifies the archive location

  Scenario: Trust signals reference reads from wave archive for TS-3 and TS-6
    Given skills/arc-sync/references/trust-signals.md has been updated per the spec
    When a reader reviews the TS-3 and TS-6 detection logic
    Then both signals reference docs/skill/arc/waves/*.md as their data source
    And neither signal references BACKLOG.md for shipped-idea detection

  Scenario: Wave archive reference document exists and documents the schema
    Given references/wave-archive.md has been created per the spec
    When a reader opens references/wave-archive.md
    Then the document describes the archive file location as docs/skill/arc/waves/NN-wave-name.md
    And the document describes the archive schema including wave heading, metadata block, and Shipped Ideas section
    And the document lists the lifecycle: created by /arc-sync or /arc-ship, read by /arc-status, /arc-audit, and /arc-sync

  Scenario: All skill SKILL.md files reference wave archive correctly
    Given skills/arc-ship/SKILL.md, skills/arc-wave/SKILL.md, skills/arc-sync/SKILL.md, skills/arc-status/SKILL.md, skills/arc-audit/SKILL.md, and skills/arc-help/SKILL.md have been updated
    When a reader searches all SKILL.md files for references to shipped ideas
    Then no SKILL.md file describes BACKLOG.md as the location for shipped items
    And skill files that discuss shipped ideas reference docs/skill/arc/waves/ as the archive location

  Scenario: /arc-help output references the wave archive
    Given all skill documents have been updated per the spec
    When the user runs /arc-help
    Then the help output mentions docs/skill/arc/waves/ as the shipped-idea archive
    And the help output does not describe BACKLOG.md as the home for shipped items
