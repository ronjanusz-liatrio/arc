# Source: docs/specs/17-spec-claude-md-static-references/17-spec-claude-md-static-references.md
# Pattern: State (documentation artifact)
# Recommended test type: Integration

Feature: Define static block schema and update bootstrap-protocol

  Scenario: Bootstrap protocol describes a static ARC:product-context block with no live status fields
    Given a developer opens skills/arc-wave/references/bootstrap-protocol.md
    When the developer reads the ARC:product-context section schema
    Then the schema description contains no "Backlog count" wording
    And the schema description contains no "shipped count" wording
    And the schema description contains no "captured, shaped, spec-ready" enumeration
    And the schema description states the section content is fixed and not derived from artifacts

  Scenario: Static block template specifies the required structural elements
    Given the bootstrap-protocol.md file is open
    When a reader inspects the literal template between the BEGIN/END markers
    Then the template contains a "## Product Context" H2 heading
    And the template contains a short intro sentence noting that live status lives in linked artifacts
    And the template contains a markdown link to docs/BACKLOG.md followed by an em-dash and a usage hint
    And the template contains a markdown link to docs/ROADMAP.md followed by an em-dash and a usage hint
    And the template contains a markdown link to docs/VISION.md followed by an em-dash and a usage hint
    And the template contains a markdown link to docs/CUSTOMER.md followed by an em-dash and a usage hint

  Scenario: Static block uses the existing managed-section markers
    Given the bootstrap-protocol.md template
    When the reader inspects the marker syntax surrounding the static block
    Then the opening marker is exactly "<!--# BEGIN ARC:product-context -->"
    And the closing marker is exactly "<!--# END ARC:product-context -->"
    And no other namespace markers (TEMPER:, MM:) appear inside the ARC: marker pair

  Scenario: Insertion priority for the block is unchanged
    Given a CLAUDE.md file in a project may already contain TEMPER: or Snyk markers
    When the bootstrap-protocol describes where to insert the ARC:product-context block
    Then the document specifies "before first TEMPER: marker" as priority 1
    And the document specifies "before Snyk" as priority 2
    And the document specifies "at EOF" as priority 3

  Scenario: Migration overwrites prior content with the static template via the same code path as routine writes
    Given the bootstrap-protocol describes migration behavior
    When a reader looks for legacy-vs-new branching logic
    Then the document states that any content found between BEGIN/END markers is replaced wholesale
    And the document states the same code path applies to legacy live blocks and already-migrated static blocks
    And the document does not describe a separate "detect legacy format" branch

  Scenario: Idempotency is documented as a guarantee
    Given the bootstrap-protocol describes the write algorithm
    When a reader looks for the idempotency clause
    Then the document states that running the protocol twice produces identical bytes between marker positions

  Scenario: /arc-sync is named the sole writer of the block
    Given the bootstrap-protocol describes writer attribution
    When a reader looks for the writer-attribution sentence
    Then the document names "/arc-sync" as the sole writer of ARC:product-context
    And the document explicitly notes that /arc-wave no longer writes the block
    And the document explicitly notes that /arc-ship no longer writes the block

  Scenario: The legacy "Update Behavior" table is removed
    Given the bootstrap-protocol previously contained a table mapping Vision/Phase/Wave/Personas/Backlog fields to data sources
    When a reader inspects the updated document
    Then the "Update Behavior" table is absent
    And no table maps managed-section fields to artifact data sources
    And the section contains no references to dynamic data sources for the static block

  Scenario: Grep on the static-block template produces no live-field labels
    Given skills/arc-wave/references/bootstrap-protocol.md has been updated
    When a developer runs "grep -nE 'Backlog:|Current Wave:|Phase:|Primary Personas:|Vision:' skills/arc-wave/references/bootstrap-protocol.md"
    Then no matches are returned from inside the static-block template definition
    And the command exits with a non-zero status indicating zero matches
