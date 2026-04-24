# Source: docs/specs/16-spec-arc-status-wave-precedence/16-spec-arc-status-wave-precedence.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Wave-Priority Next-Step Precedence

  Scenario: Priority 1 — empty active wave recommends /arc-wave
    Given a repository where docs/ROADMAP.md active wave is "Wave 4 — Foo" with Status "active"
    And no row in docs/BACKLOG.md has "Wave 4 — Foo" in its Wave column
    When the user runs "/arc-status" from the repository root
    Then the Next Step section recommends "/arc-wave"
    And the recommendation reason contains the substring "Wave 4 — Foo is active but has no ideas assigned"
    And the AskUserQuestion options include a label marked "(Recommended)" for "/arc-wave"
    And the AskUserQuestion options include "/arc-audit" as an alternative
    And the AskUserQuestion options include "Done for now"

  Scenario: Priority 6 beats backlog-only LG-2 when wave has an unshaped P1 idea
    Given a repository where docs/ROADMAP.md active wave is "Wave 4 — Foo" with Status "planned"
    And docs/BACKLOG.md lists idea "Idea-Wave" with Wave "Wave 4 — Foo", Priority "P1", status "captured", and no shaping artifact
    And docs/BACKLOG.md lists idea "Idea-Stray" with an empty Wave column, status "shaped", and no spec
    When the user runs "/arc-status" from the repository root
    Then the Next Step section recommends "/arc-shape"
    And the recommendation reason contains "Idea-Wave"
    And the recommendation reason contains "Wave 4 — Foo"
    And the recommendation reason contains "P1"
    And the recommendation does not mention "Idea-Stray"

  Scenario: Priority 8 — active wave with clean wave-linked work recommends /arc-audit
    Given a repository where docs/ROADMAP.md active wave is "Wave 4 — Foo" with Status "active"
    And every idea in docs/BACKLOG.md whose Wave column equals "Wave 4 — Foo" is in status "shipped"
    And docs/BACKLOG.md lists idea "Idea-P0-Stray" with an empty Wave column, Priority "P0", status "captured"
    When the user runs "/arc-status" from the repository root
    Then the Next Step section recommends "/arc-audit"
    And the recommendation reason contains "Wave 4 — Foo is active and wave-linked work is clean"
    And the recommendation does not recommend "/arc-shape"
    And the AskUserQuestion options include "/arc-wave" as an alternative

  Scenario: Priority 7 — planned wave with no wave-linked gaps recommends activation via /arc-wave
    Given a repository where docs/ROADMAP.md active wave is "Wave 4 — Foo" with Status "planned"
    And every idea in docs/BACKLOG.md whose Wave column equals "Wave 4 — Foo" has completed its lifecycle through shipped
    When the user runs "/arc-status" from the repository root
    Then the Next Step section recommends "/arc-wave"
    And the recommendation reason contains "Wave 4 — Foo is planned with no open gaps on assigned ideas"
    And the AskUserQuestion options include "/arc-audit" as an alternative

  Scenario: Priority 2 — wave-linked LG-5 recommends /arc-ship
    Given a repository where docs/ROADMAP.md active wave is "Wave 4 — Foo" with Status "active"
    And docs/BACKLOG.md lists idea "Idea-Validated" with Wave "Wave 4 — Foo", status "spec-ready", and a "Spec:" field pointing to "docs/specs/09-spec-foo/"
    And "docs/specs/09-spec-foo/" contains a validation report marked PASS
    When the user runs "/arc-status" from the repository root
    Then the Next Step section recommends "/arc-ship"
    And the recommendation reason contains "Idea-Validated"
    And the recommendation reason contains "Wave 4 — Foo"

  Scenario: Backlog-only gap is suppressed from the recommendation when a wave is active
    Given a repository where docs/ROADMAP.md active wave is "Wave 4 — Foo" with Status "active"
    And every idea in docs/BACKLOG.md whose Wave column equals "Wave 4 — Foo" has no open lifecycle gaps
    And docs/BACKLOG.md lists idea "Idea-LG3" with an empty Wave column and a "Spec:" field pointing to "docs/specs/10-spec-bar/" that has a spec but no plan
    When the user runs "/arc-status" from the repository root
    Then the Next Step section does not recommend "/cw-plan"
    And the Lifecycle Gaps table still includes the LG-3 row for "10-spec-bar" with Scope "Backlog (outside wave)"

  Scenario: Priority 12 — no wave and LG-2 gap recommends /cw-spec (fallback unchanged)
    Given a repository with no docs/ROADMAP.md file
    And docs/BACKLOG.md lists idea "Idea-Shaped" with status "shaped" and no spec directory linked
    When the user runs "/arc-status" from the repository root
    Then the Next Step section recommends "/cw-spec"
    And the recommendation reason contains "Idea-Shaped"
    And the AskUserQuestion options include a label marked "(Recommended)" for "/cw-spec"

  Scenario: Priority 14 — no wave and no gaps recommends /arc-wave
    Given a repository where docs/ROADMAP.md has no rows with Status other than "Completed"
    And no lifecycle gaps are detected anywhere in the project
    When the user runs "/arc-status" from the repository root
    Then the Next Step section recommends "/arc-wave"
    And the recommendation reason contains "No gaps and no active wave"
    And the AskUserQuestion options include "/arc-audit" as an alternative

  Scenario: Priority 13 — no wave and LG-1 gap on a P0 idea recommends /arc-shape
    Given a repository where docs/ROADMAP.md has no rows with Status other than "Completed"
    And docs/BACKLOG.md lists idea "Idea-P0" with Priority "P0" and status "captured" with no shaping artifact
    When the user runs "/arc-status" from the repository root
    Then the Next Step section recommends "/arc-shape"
    And the recommendation reason references "Idea-P0"
    And the recommendation reason references "P0"

  Scenario: Priority 6 ignores LG-1 gaps on P2 and lower-priority wave-linked ideas
    Given a repository where docs/ROADMAP.md active wave is "Wave 4 — Foo" with Status "planned"
    And docs/BACKLOG.md lists idea "Idea-P2" with Wave "Wave 4 — Foo", Priority "P2", status "captured"
    And no other wave-linked lifecycle gaps exist
    When the user runs "/arc-status" from the repository root
    Then the Next Step section does not recommend "/arc-shape"
    And the Next Step section recommends "/arc-wave"
    And the recommendation reason contains "Wave 4 — Foo is planned with no open gaps on assigned ideas"

  Scenario: Wave name with em dash is passed verbatim into AskUserQuestion strings
    Given a repository where docs/ROADMAP.md active wave is "Wave 4 — Foo" with Status "active"
    And no idea in docs/BACKLOG.md has "Wave 4 — Foo" in its Wave column
    When the user runs "/arc-status" from the repository root
    Then the AskUserQuestion question text contains the literal substring "Wave 4 — Foo"
    And no backslash-escape sequence precedes the em dash in the rendered question

  Scenario: AskUserQuestion prompt always offers at least three options
    Given a repository where docs/ROADMAP.md active wave is "Wave 4 — Foo" with Status "active"
    And at least one wave-linked lifecycle gap exists
    When the user runs "/arc-status" from the repository root
    Then the AskUserQuestion options list contains exactly one option labeled "(Recommended)"
    And the AskUserQuestion options list contains at least one alternative skill option
    And the AskUserQuestion options list contains "Done for now"

  Scenario: Alternative for Priority 2–6 offers the next-lower matching wave-linked gap skill
    Given a repository where docs/ROADMAP.md active wave is "Wave 4 — Foo" with Status "active"
    And a wave-linked LG-4 gap exists for "docs/specs/11-spec-valid/"
    And a wave-linked LG-3 gap exists for "docs/specs/12-spec-plan/"
    When the user runs "/arc-status" from the repository root
    Then the Next Step section recommends "/cw-validate"
    And the AskUserQuestion options include "/cw-plan" as an alternative

  Scenario: Alternative falls back to /arc-audit when no lower-priority wave-linked gap exists
    Given a repository where docs/ROADMAP.md active wave is "Wave 4 — Foo" with Status "active"
    And the only wave-linked gap is an LG-1 P0 gap on idea "Idea-P0-Wave"
    When the user runs "/arc-status" from the repository root
    Then the Next Step section recommends "/arc-shape"
    And the AskUserQuestion options include "/arc-audit" as an alternative
