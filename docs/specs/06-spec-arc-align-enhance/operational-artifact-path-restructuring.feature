# Source: docs/specs/06-spec-arc-assess-enhance/06-spec-arc-assess-enhance.md
# Pattern: CLI/Process + State
# Recommended test type: Integration

Feature: Operational Artifact Path Restructuring

  Scenario: Align report is written to the new path
    Given a repository where /arc-assess completes a full run
    When the align report is generated
    Then the report is saved to docs/skill/arc/align-report.md
    And no file is created at docs/align-report.md

  Scenario: Align manifest is written to the new path
    Given a repository where /arc-assess completes a full run
    When the align manifest is generated
    Then the manifest is saved to docs/skill/arc/align-manifest.md
    And no file is created at docs/align-manifest.md

  Scenario: Align analysis is written to the new path
    Given a repository where /arc-assess completes a full run with the analysis phase
    When the analysis artifact is generated
    Then the analysis is saved to docs/skill/arc/align-analysis.md
    And no file is created at docs/align-analysis.md

  Scenario: Wave report is written to the new path
    Given a repository where /arc-wave completes a full run
    When the wave report is generated
    Then the report is saved to docs/skill/arc/wave-report.md
    And no file is created at docs/wave-report.md

  Scenario: Review report is written to the new path
    Given a repository where /arc-audit completes a full run
    When the review report is generated
    Then the report is saved to docs/skill/arc/review-report.md
    And no file is created at docs/review-report.md

  Scenario: Shape report is written to the new path
    Given a repository where /arc-shape completes a full run
    When the shape report is generated
    Then the report is saved to docs/skill/arc/shape-report.md
    And no file is created at docs/shape-report.md

  Scenario: Product-direction artifacts remain at docs/ root
    Given a repository where /arc-assess completes a full run with imports
    When stubs are imported into product-direction artifacts
    Then docs/BACKLOG.md exists at the docs/ root
    And docs/VISION.md exists at the docs/ root
    And docs/CUSTOMER.md exists at the docs/ root
    And docs/ROADMAP.md exists at the docs/ root
    And no product-direction artifacts exist under docs/skill/arc/

  Scenario: Hardcoded exclusion list references new operational paths
    Given the arc-assess SKILL.md has been updated for path restructuring
    When the exclusion configuration is applied in Step 1a
    Then the hardcoded exclusion list references docs/skill/arc/ for Arc-managed operational files
    And docs/skill/arc/align-report.md is excluded from scanning
    And docs/skill/arc/align-manifest.md is excluded from scanning

  Scenario: All Arc skill SKILL.md files reference new paths
    Given path restructuring has been applied across all Arc skills
    When the arc-assess SKILL.md is inspected
    Then all read and write references to operational artifacts use docs/skill/arc/ paths
    When the arc-capture SKILL.md is inspected
    Then all operational artifact references use docs/skill/arc/ paths
    When the arc-shape SKILL.md is inspected
    Then all operational artifact references use docs/skill/arc/ paths
    When the arc-wave SKILL.md is inspected
    Then all operational artifact references use docs/skill/arc/ paths
    When the arc-audit SKILL.md is inspected
    Then all operational artifact references use docs/skill/arc/ paths
    When the arc-sync SKILL.md is inspected
    Then all operational artifact references use docs/skill/arc/ paths

  Scenario: Reference documents reflect new paths
    Given path restructuring has been applied to reference documents
    When skills/arc-assess/references/align-report-template.md is inspected
    Then the output path references docs/skill/arc/
    When skills/arc-assess/references/import-rules.md is inspected
    Then manifest path references use docs/skill/arc/
    When skills/arc-audit/references/review-report-template.md is inspected
    Then the output path references docs/skill/arc/
    When skills/arc-audit/references/audit-dimensions.md is inspected
    Then any report path references use docs/skill/arc/
    When skills/arc-wave/references/wave-report-template.md is inspected
    Then the output path references docs/skill/arc/

  Scenario: README.md shows the new path structure
    Given path restructuring has been applied to README.md
    When README.md is inspected
    Then the plugin structure tree includes docs/skill/arc/ as a directory
    And operational artifact paths in the README reference docs/skill/arc/

  Scenario: docs/skill/arc/ directory is created during bootstrap
    Given a fresh repository with no docs/skill/arc/ directory
    When /arc-assess runs and reaches the artifact bootstrap step
    Then the docs/skill/arc/ directory is created
    And subsequent artifact writes to docs/skill/arc/ succeed

  Scenario: Migration reads old-path artifacts and copies to new path
    Given a repository with a prior align manifest at docs/align-manifest.md
    And no file exists at docs/skill/arc/align-manifest.md
    When /arc-assess runs
    Then the system reads docs/align-manifest.md for manifest continuity
    And writes the manifest to docs/skill/arc/align-manifest.md
    And informs the user that docs/align-manifest.md can be deleted

  Scenario: Migration reads old-path report and copies to new path
    Given a repository with a prior align report at docs/align-report.md
    And no file exists at docs/skill/arc/align-report.md
    When /arc-assess runs
    Then the system reads docs/align-report.md
    And writes the report to docs/skill/arc/align-report.md
    And informs the user that docs/align-report.md can be deleted

  Scenario: Migration does not delete old-path files automatically
    Given a repository with prior artifacts at docs/align-manifest.md and docs/align-report.md
    When /arc-assess completes with migration
    Then docs/align-manifest.md still exists on disk
    And docs/align-report.md still exists on disk
    And the user was informed that old files can be manually removed

  Scenario: No migration needed when old-path artifacts do not exist
    Given a fresh repository with no prior Arc operational artifacts
    When /arc-assess runs for the first time
    Then no migration messages are shown to the user
    And operational artifacts are written directly to docs/skill/arc/
