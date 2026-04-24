# Source: docs/specs/16-spec-arc-status-wave-precedence/16-spec-arc-status-wave-precedence.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Wave-Linkage Detection and Gap Scoping

  Scenario: Scope column appears when an active wave exists
    Given a repository where docs/ROADMAP.md contains a row with Wave "Wave 4 — Foo" and Status "active"
    And docs/BACKLOG.md lists one idea "Idea-A" with Wave column "Wave 4 — Foo" that is captured but unshaped
    And docs/BACKLOG.md lists another idea "Idea-B" with an empty Wave column that is shaped but has no spec
    When the user runs "/arc-status" from the repository root
    Then the Lifecycle Gaps table printed to stdout contains a header row with columns "Gap", "Item", "Remediation", and "Scope"
    And the row for "Idea-A" shows the Scope cell "Wave: Wave 4 — Foo"
    And the row for "Idea-B" shows the Scope cell "Backlog (outside wave)"

  Scenario: Scope column is omitted when no active wave exists
    Given a repository where docs/ROADMAP.md has no rows or every row has Status "Completed"
    And docs/BACKLOG.md lists one shaped idea "Idea-C" with no spec
    When the user runs "/arc-status" from the repository root
    Then the Lifecycle Gaps table printed to stdout has exactly three columns "Gap", "Item", and "Remediation"
    And the table contains no "Scope" column header
    And the row for "Idea-C" does not contain the string "Backlog (outside wave)"

  Scenario: Active wave name is extracted verbatim from the first non-Completed ROADMAP row
    Given a repository where docs/ROADMAP.md first non-Completed row has Wave "Wave 4 — Foo" and Status "planned"
    And a later row in the same table has Wave "Wave 5 — Bar" and Status "planned"
    When the user runs "/arc-status" from the repository root
    Then the header region of the stdout output reports the active wave as "Wave 4 — Foo"
    And the reported wave status is "planned"
    And "Wave 5 — Bar" is not reported as the active wave

  Scenario: Active wave is null when all ROADMAP rows are Completed
    Given a repository where every row in docs/ROADMAP.md has Status "Completed"
    When the user runs "/arc-status" from the repository root
    Then the stdout output does not report an active wave name
    And any Lifecycle Gaps table rendered contains no "Scope" column

  Scenario: Wave-linked set uses exact case-sensitive match on the BACKLOG Wave column
    Given a repository where docs/ROADMAP.md active wave name is "Wave 4 — Foo"
    And docs/BACKLOG.md lists idea "Idea-Match" with Wave column "Wave 4 — Foo"
    And docs/BACKLOG.md lists idea "Idea-Case" with Wave column "wave 4 — foo"
    And docs/BACKLOG.md lists idea "Idea-Trim" with Wave column "  Wave 4 — Foo  "
    And each of the three ideas has a lifecycle gap detectable by Step 6
    When the user runs "/arc-status" from the repository root
    Then the row for "Idea-Match" shows Scope "Wave: Wave 4 — Foo"
    And the row for "Idea-Trim" shows Scope "Wave: Wave 4 — Foo"
    And the row for "Idea-Case" shows Scope "Backlog (outside wave)"

  Scenario: Spec-scoped gaps inherit wave scope via the BACKLOG Spec field
    Given a repository where docs/ROADMAP.md active wave name is "Wave 4 — Foo"
    And docs/BACKLOG.md lists idea "Idea-Spec" with Wave column "Wave 4 — Foo" and a "Spec:" field pointing to "docs/specs/07-spec-thing/"
    And the directory "docs/specs/07-spec-thing/" contains a spec markdown file but no plan artifact
    When the user runs "/arc-status" from the repository root
    Then the Lifecycle Gaps table contains an LG-3 row for "07-spec-thing"
    And the Scope cell for that LG-3 row is "Wave: Wave 4 — Foo"

  Scenario: Spec-scoped gap is backlog-only when no BACKLOG idea links the spec
    Given a repository where docs/ROADMAP.md active wave name is "Wave 4 — Foo"
    And the directory "docs/specs/08-spec-orphan/" contains a spec markdown file but no plan artifact
    And no entry in docs/BACKLOG.md has a "Spec:" field that points to "docs/specs/08-spec-orphan/"
    When the user runs "/arc-status" from the repository root
    Then the Lifecycle Gaps table contains an LG-3 row for "08-spec-orphan"
    And the Scope cell for that LG-3 row is "Backlog (outside wave)"

  Scenario: Skipped checks render a dash in the Scope column when a wave is active
    Given a repository where docs/ROADMAP.md active wave name is "Wave 4 — Foo"
    And one Step 6 lifecycle check cannot execute because its required input file is missing
    When the user runs "/arc-status" from the repository root
    Then the Lifecycle Gaps table includes a row whose Gap cell contains "(skipped —"
    And that row's Item cell is "--"
    And that row's Scope cell is "--"

  Scenario: No-gap message is unchanged when wave is active
    Given a repository where docs/ROADMAP.md active wave name is "Wave 4 — Foo"
    And no lifecycle gaps are detected in Step 6
    When the user runs "/arc-status" from the repository root
    Then the Lifecycle Gaps section prints the literal message "No lifecycle gaps detected."
    And no markdown table is rendered in the Lifecycle Gaps section
