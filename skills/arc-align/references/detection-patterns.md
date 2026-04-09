# Detection Patterns

`/arc-align` discovers product-direction content using two detection strategies applied in sequence: **keyword matching** followed by **structural matching**. This document defines every pattern, provides example snippets showing what each pattern matches, and explains the detection ordering rationale.

---

## Detection Ordering

Keyword matching runs first because it uses Grep and completes quickly across the entire non-excluded file set. Structural matching runs second on files not already flagged by keyword matching, since it requires line-by-line parsing with Read and is slower.

**Sequence:**

1. **Keyword scan** — Grep for each keyword across all non-excluded files. Fast, broad coverage.
2. **Structural scan** — Read remaining unflagged files and parse for structural indicators. Slower, catches content that lacks explicit keywords but uses recognizable formatting patterns.

This ordering minimizes file reads while maximizing coverage. A file matched by keyword scan is not re-scanned for structural patterns — the keyword match is sufficient to flag it for classification.

---

## Keyword Patterns

Each keyword is searched case-insensitively via Grep. A match flags the file and surrounding context for classification in Step 2c.

---

### KW-1: roadmap

**Purpose:** Detect roadmap or planning content that should be consolidated into BACKLOG or ROADMAP.

**Search term:** `roadmap`

**Example match:**

```markdown
## Roadmap

- Q3: Launch dark mode
- Q4: Add team collaboration features
- Q1 2027: Mobile app beta
```

**Typical target artifact:** BACKLOG (individual items)

---

### KW-2: backlog

**Purpose:** Detect explicit backlog content outside Arc's managed `docs/BACKLOG.md`.

**Search term:** `backlog`

**Example match:**

```markdown
## Product Backlog

| Feature | Priority | Status |
|---------|----------|--------|
| SSO login | High | Planned |
| Export CSV | Medium | In progress |
```

**Typical target artifact:** BACKLOG

---

### KW-3: todo

**Purpose:** Detect TODO items, task lists, and work-tracking content.

**Search term:** `todo`

**Example match:**

```markdown
## TODO

- [ ] Refactor authentication module
- [ ] Add rate limiting to API endpoints
- [x] Fix broken pagination
```

**Typical target artifact:** BACKLOG

---

### KW-4: planned

**Purpose:** Detect planned features or work items.

**Search term:** `planned`

**Example match:**

```markdown
### Planned Features

We have several features planned for the next release:

1. Dashboard analytics
2. Webhook integrations
3. Custom themes
```

**Typical target artifact:** BACKLOG

---

### KW-5: upcoming

**Purpose:** Detect upcoming work or release plans.

**Search term:** `upcoming`

**Example match:**

```markdown
## Upcoming Changes

- New onboarding flow (targeting v2.1)
- Performance improvements for large datasets
- Deprecation of legacy REST endpoints
```

**Typical target artifact:** BACKLOG

---

### KW-6: feature list

**Purpose:** Detect enumerated feature lists.

**Search term:** `feature list`

**Example match:**

```markdown
## Feature List

1. Real-time notifications
2. Role-based access control
3. Audit logging
4. Multi-tenant support
```

**Typical target artifact:** BACKLOG

---

### KW-7: future work

**Purpose:** Detect sections describing future plans or deferred work.

**Search term:** `future work`

**Example match:**

```markdown
## Future Work

This section tracks ideas we want to explore after the initial release:

- AI-powered search suggestions
- Plugin marketplace
- Self-hosted deployment option
```

**Typical target artifact:** BACKLOG

---

### KW-8: next steps

**Purpose:** Detect action items and follow-up work.

**Search term:** `next steps`

**Example match:**

```markdown
## Next Steps

1. Finalize the API contract with the mobile team
2. Write integration tests for the payment flow
3. Schedule UX review for the new settings page
```

**Typical target artifact:** BACKLOG

---

### KW-9: milestone

**Purpose:** Detect milestone-based planning content.

**Search term:** `milestone`

**Example match:**

```markdown
## Milestones

### Milestone 1: Core Platform (March 2026)
- User authentication
- Basic CRUD operations
- CI/CD pipeline

### Milestone 2: Integrations (June 2026)
- Slack integration
- GitHub webhook support
```

**Typical target artifact:** BACKLOG

---

### KW-10: sprint

**Purpose:** Detect sprint-based planning content from agile workflows.

**Search term:** `sprint`

**Example match:**

```markdown
## Sprint 14 Goals

- Complete checkout redesign
- Fix 3 critical bugs from QA
- Deploy monitoring dashboard
```

**Typical target artifact:** BACKLOG

---

### KW-11: epic

**Purpose:** Detect epic-level work items from agile workflows.

**Search term:** `epic`

**Example match:**

```markdown
## Epics

### Epic: User Onboarding
Improve the first-run experience to reduce time-to-value from 15 minutes to under 5.

### Epic: Data Export
Allow users to export all their data in CSV and JSON formats.
```

**Typical target artifact:** BACKLOG

---

### KW-12: user story

**Purpose:** Detect user story definitions.

**Search term:** `user story`

**Example match:**

```markdown
## User Stories

- As a developer, I want to see build logs in real time so I can debug failures faster.
- As an admin, I want to configure SSO so that team members use corporate credentials.
```

**Typical target artifact:** BACKLOG

---

### KW-13: persona

**Purpose:** Detect persona definitions or references.

**Search term:** `persona`

**Example match:**

```markdown
## Personas

### Alex — Platform Engineer
- Maintains CI/CD pipelines
- Needs fast feedback on build failures
- Uses the CLI daily

### Jordan — Product Manager
- Prioritizes features based on customer feedback
- Needs visibility into delivery timelines
```

**Typical target artifact:** CUSTOMER

---

### KW-14: target audience

**Purpose:** Detect audience or market segment descriptions.

**Search term:** `target audience`

**Example match:**

```markdown
## Target Audience

This tool is designed for:

- **Small engineering teams** (2-10 developers) shipping SaaS products
- **Product owners** who manage backlogs without dedicated PM tooling
- **Solo developers** who want lightweight product management
```

**Typical target artifact:** CUSTOMER

---

### KW-15: mission

**Purpose:** Detect mission statement content.

**Search term:** `mission`

**Example match:**

```markdown
## Our Mission

To make product management accessible to every engineering team,
regardless of size or budget.
```

**Typical target artifact:** VISION

---

### KW-16: vision

**Purpose:** Detect product vision or strategic direction content.

**Search term:** `vision`

**Example match:**

```markdown
## Product Vision

Arc becomes the default upstream companion for every Claude Code project —
the place where product direction lives before engineering begins.
```

**Typical target artifact:** VISION

---

### KW-17: north star

**Purpose:** Detect north-star metric or guiding principle content.

**Search term:** `north star`

**Example match:**

```markdown
## North Star

Every idea captured in Arc reaches a spec-ready state within one wave cycle.
Our north star metric is the capture-to-spec-ready conversion rate.
```

**Typical target artifact:** VISION

---

### KW-18: ## Goals

**Purpose:** Detect goal statement sections in spec and design documents. Goal sections define intended outcomes and strategic direction, making them a strong VISION signal.

**Search term:** `## Goals`

**Example match:**

```markdown
## Goals

- Enable teams to consolidate product-direction content into a single source of truth
- Reduce time from idea capture to spec-ready state
- Provide full traceability from discovery source to Arc artifact
```

**Typical target artifact:** VISION

---

### KW-19: ## User Stories

**Purpose:** Detect user story sections in spec and design documents. Each story becomes a separate BACKLOG stub.

**Search term:** `## User Stories`

**Example match:**

```markdown
## User Stories

- As a product manager, I want to see all captured ideas in one place so I can prioritize effectively.
- As a developer, I want traceability markers in imported content so I know where each item originated.
- As a team lead, I want arc-align to run idempotently so repeated scans don't create duplicates.
```

**Typical target artifact:** BACKLOG (one stub per story)

---

### KW-20: ## Non-Goals

**Purpose:** Detect non-goal sections in spec and design documents. Non-goals document explicitly deferred or out-of-scope items, which are imported as BACKLOG stubs with a `(deferred)` prefix so teams can revisit them later.

**Search term:** `## Non-Goals`

**Example match:**

```markdown
## Non-Goals

- Real-time collaboration editing is out of scope for this release
- We will not support importing from Jira or Linear in v1
- Mobile-native UI is deferred until post-launch feedback is gathered
```

**Typical target artifact:** BACKLOG (each item imported with `(deferred)` prefix)

---

### KW-21: ## Open Questions

**Purpose:** Detect open question sections in spec and design documents. Unresolved questions represent future decision points and are imported as BACKLOG stubs with an `(open question)` prefix.

**Search term:** `## Open Questions`

**Example match:**

```markdown
## Open Questions

- Should arc-align support binary file scanning for embedded metadata?
- How do we handle circular references between spec files?
- What is the right deduplication strategy when the same idea appears in three different specs?
```

**Typical target artifact:** BACKLOG (each item imported with `(open question)` prefix)

---

### KW-22: ## Introduction / ## Overview

**Purpose:** Detect introduction and overview sections that contain mission or strategic direction language. These sections are common in specs, READMEs, and design documents. Only sections containing mission/direction language are classified as VISION — generic overviews without directional content are skipped.

**Search term:** `## Introduction` (first Grep call) and `## Overview` (second Grep call); results are unioned.

**Conditional classification:** After matching, scan the section content for any of the following terms: `mission`, `direction`, `purpose`, `vision`. If none are present, do not import — skip the section.

**Example match (qualifies):**

```markdown
## Overview

Arc is a Claude Code plugin whose purpose is to capture and shape product direction
before engineering begins. Our mission is to give every team a lightweight, AI-native
product management layer that lives inside their codebase.
```

**Example match (does not qualify — skip):**

```markdown
## Overview

This document describes the configuration format for the arc-align skill.
Each field is documented with its type, default value, and valid options.
```

**Typical target artifact:** VISION (conditional on mission/direction language)

---

## Structural Patterns

Structural patterns detect product-direction content through formatting conventions rather than keywords. These are checked via Read on files not already flagged by keyword matching.

---

### ST-1: Markdown Task Lists

**Purpose:** Detect checkbox-style task lists that represent actionable work items.

**Pattern:** Lines matching `- [ ]` or `- [x]` (markdown task list syntax).

**Detection logic:** Scan for consecutive task list lines. Flag sections with 2 or more items as product-direction content. Each task list item becomes a separate discovery (one captured stub per checkbox item) for maximum import granularity.

**Example match:**

```markdown
- [ ] Add input validation to signup form
- [ ] Write API documentation for /users endpoint
- [x] Fix timezone bug in scheduler
- [ ] Add retry logic to webhook delivery
```

**Typical target artifact:** BACKLOG

---

### ST-2: Numbered Feature Lists

**Purpose:** Detect sequential numbered lists that enumerate features or planned work.

**Pattern:** Three or more consecutive lines matching `N. {text}` where N increments sequentially starting from 1.

**Detection logic:** Identify runs of 3+ sequential numbered items. Single numbered items or non-sequential numbering (e.g., `1. ... 3. ...`) are not flagged.

**Example match:**

```markdown
1. User authentication with OAuth2
2. Role-based access control
3. Audit logging for admin actions
4. Data export in CSV and JSON
5. Webhook support for external integrations
```

**Typical target artifact:** BACKLOG

---

### ST-3: Heading Patterns

**Purpose:** Detect section headings that indicate product-direction content by their title.

**Pattern:** Level-2 headings matching these titles (case-insensitive):

- `## Roadmap`
- `## TODO`
- `## Planned Features`
- `## Backlog`

**Detection logic:** Match the heading itself, then flag the entire section (from the heading to the next same-level or higher heading, or end of file) as product-direction content.

**Example match:**

```markdown
## Planned Features

We're working toward these capabilities for the next major release:

- Real-time collaboration editing
- Advanced search with filters
- Custom dashboard widgets
```

**Typical target artifact:** BACKLOG

---

### ST-4: Kanban-Style Markers

**Purpose:** Detect kanban board columns rendered as markdown headings, indicating work-tracking content.

**Pattern:** Level-3 headings matching these titles (case-insensitive):

- `### To Do`
- `### In Progress`
- `### Done`

**Detection logic:** The presence of any two of these three headings in the same file indicates kanban-style work tracking. Flag the entire kanban structure (from the first kanban heading through the last) as product-direction content.

**Example match:**

```markdown
### To Do

- Implement search API
- Add pagination to list views

### In Progress

- Redesign settings page
- Migrate to new auth provider

### Done

- Deploy monitoring stack
- Fix memory leak in worker process
```

**Typical target artifact:** BACKLOG

---

## Code Comment Patterns

Code comment patterns detect actionable content embedded in source code files as comment markers. These are checked via Grep against all non-excluded source code files during Step 2c (after keyword and structural matching).

**Scanned file extensions:** `.py`, `.ts`, `.tsx`, `.js`, `.jsx`, `.go`, `.rs`, `.java`, `.kt`, `.rb`, `.sh`, `.bash`, `.zsh`, `.swift`, `.c`, `.cpp`, `.h`, `.hpp`, `.cs`

All code comment discoveries classify as **BACKLOG** targets. The exclusion set applies — files inside excluded directories (`node_modules`, `vendor`, `dist`, `build`, `.venv`, `__pycache__`, `.mypy_cache`, `.pytest_cache`, `.ruff_cache`, `.tox`, `*.egg-info`, `target`, `.gradle`, `.next`, `.nuxt`, `coverage`) are not scanned.

---

### CC-1: TODO

**Purpose:** Detect actionable work items left in source code as reminders for future implementation.

**Search term:** `TODO` (case-insensitive)

**Example match:**

```python
# TODO: refactor this module to use the new auth client
def authenticate(user_id):
    ...
```

```typescript
// TODO: add input validation before calling the API
function submitForm(data: FormData) {
```

```go
// TODO: replace polling with webhook subscription when API supports it
func pollForUpdates() {
```

**Typical target artifact:** BACKLOG

**Priority mapping:** P2-Medium

---

### CC-2: FIXME

**Purpose:** Detect known bugs or issues explicitly marked for correction.

**Search term:** `FIXME` (case-insensitive)

**Example match:**

```python
# FIXME: this breaks when timezone is not UTC — see issue #42
def parse_timestamp(raw: str) -> datetime:
    ...
```

```typescript
// FIXME: race condition when multiple tabs update the same record
async function saveRecord(id: string, data: Record) {
```

```go
// FIXME: error is silently swallowed here, needs proper propagation
result, _ := db.Query(query)
```

**Typical target artifact:** BACKLOG

**Priority mapping:** P1-High (known defect requiring attention)

---

### CC-3: HACK

**Purpose:** Detect temporary workarounds that bypass proper solutions and accumulate technical debt.

**Search term:** `HACK` (case-insensitive)

**Example match:**

```python
# HACK: force-reload config on every call until we have a watcher
def get_config():
    return load_from_disk()
```

```typescript
// HACK: setTimeout to work around the modal not rendering in time
setTimeout(() => modal.focus(), 100);
```

```go
// HACK: duplicate the struct because the upstream package doesn't export it
type internalEvent struct {
```

**Typical target artifact:** BACKLOG

**Priority mapping:** P1-High (technical debt requiring proper solution)

---

### CC-4: XXX

**Purpose:** Detect areas flagged for review or attention without a specific fix instruction.

**Search term:** `XXX` (case-insensitive)

**Example match:**

```python
# XXX: is this the right place to initialize the connection pool?
_pool = create_pool(DB_URL)
```

```typescript
// XXX: not sure this handles the empty array case correctly
const first = items[0];
```

```go
// XXX: review this locking strategy under high concurrency
mu.Lock()
defer mu.Unlock()
```

**Typical target artifact:** BACKLOG

**Priority mapping:** P2-Medium (needs review)

---

## Pattern Confidence

Not all matches are equally strong signals. The classification step (Step 2c) uses detection method as an input to confidence:

| Signal Strength | Description |
|----------------|-------------|
| **Strong** | Keyword match inside a heading (e.g., `## Roadmap`) or structural pattern with 5+ items |
| **Moderate** | Keyword match in body text with surrounding context confirming product-direction content |
| **Weak** | Keyword match that may be incidental (e.g., "vision" in a CSS class name) or structural pattern with only 2-3 items |

Weak signals are still imported per the inclusivity principle — when in doubt, import as a captured stub rather than skip. The alignment report marks weak-signal imports so the user can review them.

---

## Cross-References

- `skills/arc-align/references/import-rules.md` — How detected content is classified into artifact targets and imported, including code comment priority overrides and the `aligned-from-code` marker format
- `references/idea-lifecycle.md` — The Capture stage that imported stubs enter
- `skills/arc-align/SKILL.md` — Step 2 references this document for the full pattern set; Step 2a uses KW-1 through KW-22 for keyword scanning; Step 2c invokes code comment scanning using CC-1 through CC-4
