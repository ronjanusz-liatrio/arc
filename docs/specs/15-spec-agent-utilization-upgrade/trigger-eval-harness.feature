# Source: docs/specs/15-spec-agent-utilization-upgrade/15-spec-agent-utilization-upgrade.md
# Pattern: CLI/Process
# Recommended test type: Integration

Feature: Trigger Eval Harness

  Scenario: An eval file exists for every arc skill
    Given the repository after this unit lands
    When a reader lists "tests/trigger-evals/"
    Then the directory contains one "<skill>.json" file for each of the 9 arc skills
    And each file is a single valid JSON document

  Scenario: Each eval file contains exactly 20 queries split 10 should-trigger / 10 should-NOT-trigger
    Given an arbitrary arc skill "<skill>" from the 9-skill set
    When the user runs "cat tests/trigger-evals/<skill>.json | jq '[.queries[].expected_trigger] | group_by(.) | map({key: .[0], count: length})'"
    Then the jq invocation exits with code 0
    And the returned value equals "[{key: false, count: 10}, {key: true, count: 10}]" (order-independent)

  Scenario: arc-shape eval includes the required 10/10 split
    Given the file "tests/trigger-evals/arc-shape.json" exists in the repository
    When the user runs "cat tests/trigger-evals/arc-shape.json | jq '[.queries[].expected_trigger] | group_by(.) | map({key: .[0], count: length})'"
    Then the jq output contains "{key: true, count: 10}"
    And the jq output contains "{key: false, count: 10}"

  Scenario: Should-trigger queries include at least 3 informal phrasings per skill
    Given the arc-capture eval at "tests/trigger-evals/arc-capture.json"
    When a reviewer reads the 10 "expected_trigger: true" queries
    Then at least 3 of those queries use informal or adjacent phrasing rather than the exact skill verb
    And "jot this down" or a semantically equivalent informal phrasing is among them

  Scenario: Should-NOT-trigger queries include at least 3 sibling near-misses per skill
    Given the arc-status eval at "tests/trigger-evals/arc-status.json"
    When a reviewer reads the 10 "expected_trigger: false" queries
    Then at least 3 of those queries share keywords with arc-status but should route to a sibling arc skill
    And a query such as "audit the pipeline" is among them and is annotated to route to arc-audit

  Scenario: The eval runner is documented with an executable invocation
    Given a reader opens "tests/trigger-evals/README.md"
    When the reader follows the documented invocation to run the eval against a single arc skill
    Then the documented command invokes skill-creator's "run_loop.py" against the selected arc eval file
    And the documented command prints a per-query pass/fail table and an aggregate accuracy number

  Scenario: Baseline eval results are committed for regression comparison
    Given the repository after this unit lands
    When a reader lists "tests/trigger-evals/"
    Then one "<skill>-baseline.json" file is present for each of the 9 arc skills
    And each baseline file records the post-rewrite accuracy result for its skill

  Scenario: Aggregate eval accuracy meets the 95% target
    Given the baseline eval summary at "docs/specs/15-spec-agent-utilization-upgrade/06-proofs/eval-baseline-summary.md"
    When a reader reads the aggregate accuracy line
    Then the reported aggregate accuracy across 180 queries (9 skills × 20) is 95% or higher
    And the per-skill scores table lists an accuracy value for each of the 9 arc skills
