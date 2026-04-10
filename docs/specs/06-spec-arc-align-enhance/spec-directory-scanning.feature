# Source: docs/specs/06-spec-arc-assess-enhance/06-spec-arc-assess-enhance.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Spec Directory Scanning

  Scenario: Spec files are scanned after removing blanket exclusion
    Given a repository with spec files under docs/specs/
    And docs/specs/ is no longer in the hardcoded exclusion list
    When the user runs /arc-assess and completes the discovery phase
    Then discoveries include items extracted from spec markdown files
    And the discovery list tags spec-sourced items with a "[spec]" label

  Scenario: Proof artifacts and feature files remain excluded
    Given a repository with spec files that include proofs/, .feature files, and questions-*.md
    When the user runs /arc-assess and completes the discovery phase
    Then no discoveries originate from docs/specs/*/proofs/ directories
    And no discoveries originate from .feature files
    And no discoveries originate from questions-*.md files

  Scenario: Goals sections are extracted as VISION content
    Given a repository with a spec containing a "## Goals" section listing three objectives
    When the user runs /arc-assess and confirms the import
    Then docs/VISION.md contains content extracted from the spec goals section
    And the imported content includes an "<!-- aligned-from-spec: {spec_name} -->" comment

  Scenario: User stories are extracted as BACKLOG items
    Given a repository with a spec containing a "## User Stories" section with two "As a..." stories
    When the user runs /arc-assess and confirms the import
    Then docs/BACKLOG.md contains two new captured stubs, one per user story
    And each stub includes an "<!-- aligned-from-spec: {spec_name} -->" comment

  Scenario: Non-goals are imported as deferred BACKLOG items
    Given a repository with a spec containing a "## Non-Goals" section with items
    When the user runs /arc-assess and confirms the import
    Then docs/BACKLOG.md contains stubs with a "(deferred)" prefix in their titles
    And those stubs have P3-Low default priority

  Scenario: Open questions are imported as BACKLOG items
    Given a repository with a spec containing an "## Open Questions" section with items
    When the user runs /arc-assess and confirms the import
    Then docs/BACKLOG.md contains stubs with an "(open question)" prefix in their titles
    And those stubs have P2-Medium default priority

  Scenario: Persona references in user stories are extracted to CUSTOMER
    Given a repository with multiple specs where user stories consistently reference "product owner" as a persona
    When the user runs /arc-assess and confirms the import
    Then docs/CUSTOMER.md contains a persona entry for "product owner"
    And the persona entry traces back to the originating spec

  Scenario: Overview sections with direction language are extracted as VISION
    Given a repository with a spec whose "## Introduction/Overview" contains declarative product-direction language
    When the user runs /arc-assess and confirms the import
    Then docs/VISION.md contains content from that overview section
    And the content is tagged with "<!-- aligned-from-spec: {spec_name} -->"

  Scenario: Overview sections with only feature descriptions are not extracted
    Given a repository with a spec whose "## Introduction/Overview" is a purely technical feature description
    When the user runs /arc-assess and completes the discovery phase
    Then no VISION discovery is generated from that overview section

  Scenario: Detection patterns document includes new KW-18 through KW-22 entries
    Given the arc-assess detection-patterns.md has been updated
    When the user reviews detection-patterns.md
    Then it documents KW-18 through KW-22 patterns with descriptions and examples

  Scenario: Import rules document includes spec-specific classification rules
    Given the arc-assess import-rules.md has been updated
    When the user reviews import-rules.md
    Then it contains classification rules mapping Goals to VISION, User Stories to BACKLOG, Non-Goals to BACKLOG with deferred prefix, and Open Questions to BACKLOG with open question prefix
