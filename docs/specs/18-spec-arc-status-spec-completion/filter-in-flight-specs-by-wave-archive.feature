# Source: docs/specs/18-spec-arc-status-spec-completion/18-spec-arc-status-spec-completion.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Filter In-Flight Specs by Wave Archive

  Scenario: Spec listed under a wave-archive H3 subsection is excluded from the In-Flight Specs table
    Given a spec directory "docs/specs/10-spec-arc-ship/" exists
    And a wave archive file "docs/skill/arc/waves/wave-1.md" contains an H3 subsection with the exact title "10-spec-arc-ship"
    When the user runs the "/arc-status" skill against the repo
    Then the rendered In-Flight Specs table contains no row whose first column is "10-spec-arc-ship"

  Scenario: Spec referenced via a "Spec:" field in a wave archive is excluded from the In-Flight Specs table
    Given a spec directory "docs/specs/13-spec-wave-archive/" exists
    And a wave archive file "docs/skill/arc/waves/wave-2.md" contains a line "**Spec:** docs/specs/13-spec-wave-archive/"
    When the user runs the "/arc-status" skill against the repo
    Then the rendered In-Flight Specs table contains no row whose first column is "13-spec-wave-archive"

  Scenario: Trailing slash on a wave-archive Spec field is normalized before comparison
    Given a spec directory "docs/specs/11-spec-shape-skill-discovery/" exists
    And a wave archive file contains "**Spec:** docs/specs/11-spec-shape-skill-discovery/" with a trailing slash
    When the user runs the "/arc-status" skill against the repo
    Then the rendered In-Flight Specs table contains no row whose first column is "11-spec-shape-skill-discovery"

  Scenario: Substring-but-not-exact title in a wave archive does not exclude a spec
    Given a spec directory "docs/specs/04-spec-arc-readme/" exists
    And the only wave archive references its name as part of a longer subsection title "04-spec-arc-readme-extended"
    And no wave archive contains an H3 subsection with the exact title "04-spec-arc-readme"
    And no wave archive contains a "**Spec:**" field equal to "docs/specs/04-spec-arc-readme"
    When the user runs the "/arc-status" skill against the repo
    Then the rendered In-Flight Specs table contains a row whose first column is "04-spec-arc-readme"

  Scenario: Orphan spec with PASS validation but no wave-archive entry remains in the In-Flight Specs table
    Given a spec directory "docs/specs/17-spec-claude-md-static-references/" exists
    And no wave archive contains an exact H3 title "17-spec-claude-md-static-references"
    And no wave archive contains a "**Spec:**" field resolving to that directory
    When the user runs the "/arc-status" skill against the repo
    Then the rendered In-Flight Specs table contains a row whose first column is "17-spec-claude-md-static-references"

  Scenario: In-flight specs are rendered sorted ascending by NN prefix after exclusion
    Given spec directories "07-spec-foo/", "09-spec-bar/", and "15-spec-baz/" all exist and are not in any wave archive
    When the user runs the "/arc-status" skill against the repo
    Then the rendered In-Flight Specs table lists rows in the order "07-spec-foo", "09-spec-bar", "15-spec-baz"

  Scenario: Filter is silent — no count footer or "Completed Specs" sidebar is emitted
    Given several spec directories are excluded by the completed-spec set
    When the user runs the "/arc-status" skill against the repo
    Then the In-Flight Specs section emits the existing table only
    And no parenthetical row count is appended
    And no separate "Completed Specs" table is rendered

  Scenario: Empty-after-filter case emits the existing fallback notice
    Given every spec directory under "docs/specs/" matches an entry in some wave archive
    When the user runs the "/arc-status" skill against the repo
    Then the In-Flight Specs section emits the literal text "No specs found — run /cw-spec to create a specification."
    And no In-Flight Specs table header is rendered

  Scenario: Per-row artifact detection columns are unchanged for in-flight rows
    Given a spec directory "docs/specs/16-spec-example/" exists with a spec file, a plan file, and a validation report
    And the spec is not present in any wave archive
    When the user runs the "/arc-status" skill against the repo
    Then the In-Flight Specs row for "16-spec-example" shows "yes" in the Spec File column
    And the row shows "yes" in the Plan column
    And the row shows "yes" in the Validation column

  Scenario: /arc-status remains read-only after the filter pass
    Given the working tree is clean before invocation
    When the user runs the "/arc-status" skill against the repo
    Then the working tree status is identical after the run
    And no files under "docs/specs/", "docs/BACKLOG.md", or "docs/skill/arc/waves/" are modified

  Scenario: /arc-status produces identical output across two consecutive invocations (idempotency)
    Given the repo state is unchanged between invocations
    When the user runs the "/arc-status" skill twice in a row
    Then the captured output of the second run is byte-identical to the captured output of the first run

  Scenario: Step 4 per-row artifact detection prose remains byte-identical after the filter is added
    Given the parent commit of the spec-18 implementation
    When a byte-for-byte diff is run on the Step 4 per-row artifact detection prose (Spec File, Plan, Validation logic) between the working tree and the parent commit
    Then the diff reports zero changed bytes in that prose
