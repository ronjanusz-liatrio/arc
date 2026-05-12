# Source: docs/specs/19-spec-arc-assess-shipped-merge/19-spec-arc-assess-shipped-merge.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Shipped-spec merge-candidate classification end-to-end

  Scenario: Shipped-spec index unions H3 subsection titles and Spec field values
    Given a wave archive at "docs/skill/arc/waves/wave-01.md" containing an "### 08-spec-foo" H3 subsection
    And a wave archive at "docs/skill/arc/waves/wave-02.md" containing a "**Spec:** docs/specs/09-spec-bar/" field
    And spec directories "docs/specs/08-spec-foo/" and "docs/specs/09-spec-bar/" exist
    When the user runs "/arc-assess" against the repository
    Then a "Merge Candidates" section appears in "docs/skill/arc/align-report.md"
    And the section contains rows whose Target Wave Archive references "wave-01.md" for the "08-spec-foo" basename
    And the section contains rows whose Target Wave Archive references "wave-02.md" for the "09-spec-bar" basename

  Scenario: Trailing-slash normalization on Spec field paths still resolves to basename
    Given a wave archive containing a "**Spec:** docs/specs/09-spec-bar/   " field with trailing whitespace and slash
    And the spec directory "docs/specs/09-spec-bar/" exists
    When the user runs "/arc-assess" against the repository
    And a KW-19 user story is detected in "docs/specs/09-spec-bar/09-spec-bar.md"
    Then the merge-candidate row Target Skill Heading column references the "09-spec-bar" basename
    And no captured-stub row is written for that source in "docs/BACKLOG.md"

  Scenario: H3-title-only signal (no Spec field) still classifies as merge-candidate
    Given a wave archive whose only signal for "08-spec-foo" is the "### 08-spec-foo" H3 subsection
    And no "**Spec:**" field is present in any wave archive for that basename
    When the user runs "/arc-assess" against the repository
    And a KW-19 user story is detected in "docs/specs/08-spec-foo/08-spec-foo.md"
    Then the source is classified as merge-candidate
    And a merge-candidate row for "08-spec-foo" appears in "docs/skill/arc/align-report.md"

  Scenario: Spec-field-only signal (no matching H3 title) still classifies as merge-candidate
    Given a wave archive whose only signal for "09-spec-bar" is a "**Spec:** docs/specs/09-spec-bar/" field
    And no "### 09-spec-bar" H3 subsection exists in any wave archive
    When the user runs "/arc-assess" against the repository
    And a KW-19 user story is detected in "docs/specs/09-spec-bar/09-spec-bar.md"
    Then the source is classified as merge-candidate
    And a merge-candidate row for "09-spec-bar" appears in "docs/skill/arc/align-report.md"

  Scenario: Single-match candidate auto-routes without prompting the user
    Given exactly one wave archive entry matches the KW-19 source spec directory basename
    When the user runs "/arc-assess" against the repository
    Then no AskUserQuestion prompt is shown for that source
    And a single merge-candidate row is written to the "Merge Candidates" section of "docs/skill/arc/align-report.md"
    And the Provenance column contains the literal HTML comment "<!-- aligned-from: {source_path}:{line_range} aligned-from-spec: {spec-dir-basename} -->"

  Scenario: Multi-match candidate triggers AskUserQuestion with candidate options plus Skip
    Given two wave archive entries match the KW-19 source spec directory basename
    When the user runs "/arc-assess" against the repository
    Then an AskUserQuestion prompt appears naming the source path and line range
    And the prompt lists each matching spec as an option labeled with the spec directory basename
    And each option description names the wave archive file and skill heading
    And the last option of the prompt is "Skip this source"

  Scenario: User selection on multi-match is applied to the chosen target row
    Given a multi-match merge-candidate prompt with options for "spec-A" and "spec-B"
    When the user selects "spec-A" in the AskUserQuestion prompt
    Then the merge-candidate row written to "docs/skill/arc/align-report.md" lists "spec-A" as Target Skill Heading
    And the row includes a nested sub-bullet "- candidate: spec-B ({wave-archive-file} → {skill-heading})" beneath it
    And no row for "spec-B" appears as a separately-routed entry

  Scenario: User selects Skip this source on multi-match writes annotated row and does not route
    Given a multi-match merge-candidate prompt with two candidate options
    When the user selects "Skip this source" in the AskUserQuestion prompt
    Then the merge-candidate row in "docs/skill/arc/align-report.md" carries a "(skipped by user)" annotation
    And no Target Skill Heading is auto-routed for that source
    And no captured-stub row is created in "docs/BACKLOG.md" for that source

  Scenario: Persona extraction still runs for KW-19 sources in shipped specs
    Given a KW-19 user story in a shipped spec whose narrative implies a new persona inference
    When the user runs "/arc-assess" against the repository
    Then the source is classified as merge-candidate in "docs/skill/arc/align-report.md"
    And the persona inference is written to "docs/CUSTOMER.md" per the existing import-rules pipeline
    And the captured-stub creation for the user story body itself is suppressed

  Scenario: No row is written to align-manifest.md for merge-candidate classifications
    Given a KW-19 source classified as merge-candidate during the run
    When the user runs "/arc-assess" against the repository
    Then "docs/skill/arc/align-manifest.md" contains zero new rows referencing the merge-candidate source path
    And the manifest schema rows present in the parent commit remain byte-identical

  Scenario: Merge Candidates section is positioned between Imported Items and Skipped Items
    Given at least one KW-19 source classifies as merge-candidate
    When the user runs "/arc-assess" against the repository
    Then "docs/skill/arc/align-report.md" contains a "Merge Candidates" top-level section
    And the "Merge Candidates" section appears after the "Imported Items by Artifact" section
    And the "Merge Candidates" section appears before the "Skipped Items" section

  Scenario: Merge Candidates table columns match the documented schema
    Given a single-match merge-candidate row is written to the report
    When the user runs "/arc-assess" against the repository
    Then the "Merge Candidates" section renders a markdown table
    And the header row contains the columns "Source Path | Lines | Target Wave Archive | Target Skill Heading | Provenance" in that order
    And each data row contains exactly five pipe-separated cells matching the header columns

  Scenario: Merge Candidates section is omitted when no candidates are found
    Given no KW-19 source resolves to any entry in the shipped-spec index
    When the user runs "/arc-assess" against the repository
    Then "docs/skill/arc/align-report.md" contains no "Merge Candidates" header
    And no empty merge-candidates table is rendered

  Scenario: KW-1 through KW-18 classification prose is unchanged versus parent commit
    Given the parent commit at HEAD~1 prior to this spec's merge
    When the user diffs "skills/arc-assess/SKILL.md" and "skills/arc-assess/references/import-rules.md" against HEAD~1
    Then the prose blocks for KW-1 through KW-18 show zero byte-level changes
    And the prose blocks for KW-20 through KW-22 show zero byte-level changes

  Scenario: align-manifest schema documentation is byte-identical to parent commit
    Given the parent commit at HEAD~1 prior to this spec's merge
    When the user diffs the align-manifest.md schema documentation in "skills/arc-assess/references/" against HEAD~1
    Then the diff reports zero changes for the manifest schema prose
    And no new manifest column is documented

  Scenario: Spec 08 manual merges in CUSTOMER.md and wave archives are not touched
    Given "docs/CUSTOMER.md" contains spec-08's manually merged persona entries before the run
    And "docs/skill/arc/waves/*.md" contains spec-08's manually merged user-story blocks before the run
    When the user runs "/arc-assess" against the repository
    Then "docs/CUSTOMER.md" retains all spec-08 manually merged persona entries byte-for-byte
    And no wave archive "### User Stories" block is rewritten by the run

  Scenario: Two consecutive runs with identical disambiguation selections produce identical Merge Candidates sections
    Given a repository state with at least one multi-match merge-candidate source
    When the user runs "/arc-assess" once and selects "spec-A" at the multi-match prompt
    And the user runs "/arc-assess" a second time and selects "spec-A" at the same prompt
    Then the "Merge Candidates" section of "docs/skill/arc/align-report.md" produced by the second run is byte-identical to the first run's section
    And no new captured stubs are appended to "docs/BACKLOG.md" between the two runs

  Scenario: Re-run against the current repo state produces the historical 9-source merge-candidate set
    Given the current repository state including specs 08, 09, and 01-align-ignore-dirs as shipped
    And the 2026-04-13 re-run previously duplicated 9 KW-19 user stories from those specs
    When the user runs "/arc-assess" against the repository
    Then the "Merge Candidates" section of "docs/skill/arc/align-report.md" contains 9 rows
    And the "Imported Items by Artifact / BACKLOG" section gains zero new captured-stub rows for those 9 sources

  Scenario: Multi-match prompt with exactly two candidates renders three options total
    Given a KW-19 source matches exactly two shipped specs in the index
    When the user runs "/arc-assess" against the repository
    Then the AskUserQuestion prompt renders three options
    And two options correspond to the two candidate specs
    And the third option is "Skip this source"

  Scenario: Shipped-spec index build is bounded by wave archive count
    Given a "docs/skill/arc/waves/" directory containing N markdown files
    When the user runs "/arc-assess" against the repository
    Then the shipped-spec index pre-pass reads each of the N wave archive files exactly once
    And no wave archive file is written or modified during the pre-pass
    And the pre-pass completes before any KW-N classification fires
