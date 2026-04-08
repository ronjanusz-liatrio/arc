---
name: arc-capture
description: "Fast idea capture — record a raw idea to the backlog in under 30 seconds"
user-invocable: true
allowed-tools: Glob, Grep, Read, Write, Edit, AskUserQuestion
---

# /arc-capture — Fast Idea Capture

## Context Marker

Always begin your response with: **ARC-CAPTURE**

## Overview

You capture raw product ideas quickly and append them to `docs/BACKLOG.md`. The goal is speed — get the thought down before it's lost. No shaping, no analysis, no refinement. That comes later with `/arc-shape`.

## Critical Constraints

- **NEVER** refine or analyze the idea — capture only
- **NEVER** modify existing BACKLOG entries — append only
- **NEVER** skip the AskUserQuestion flow — always gather title, summary, and priority interactively
- **ALWAYS** begin your response with `**ARC-CAPTURE**`
- **ALWAYS** use ISO 8601 timestamps

## Process

### Step 1: Gather Idea Details

Use AskUserQuestion to collect the three required fields. If the user provided an idea in their invocation message, pre-populate what you can and confirm.

**If idea details are provided in the invocation:**

Parse the user's message for title, summary, and priority. Present what you found and ask for confirmation or correction:

```
AskUserQuestion({
  questions: [{
    question: "I captured these details from your message. Confirm or adjust?",
    header: "Confirm",
    options: [
      { label: "Looks good", description: "Title: {parsed title} | Summary: {parsed summary}" },
      { label: "Adjust", description: "Let me provide corrected details" }
    ],
    multiSelect: false
  }]
})
```

If confirmed, ask only for priority (if not provided). If adjusting, fall through to the full flow below.

**Full interactive flow (no pre-populated details):**

```
AskUserQuestion({
  questions: [
    {
      question: "What is the idea title? (Short, descriptive name)",
      header: "Title",
      options: [
        { label: "Provide title", description: "Type your idea title in the text field" }
      ],
      multiSelect: false
    }
  ]
})
```

Then gather summary:

```
AskUserQuestion({
  questions: [
    {
      question: "One-line summary of the idea?",
      header: "Summary",
      options: [
        { label: "Provide summary", description: "Type a brief description of what this idea does or solves" }
      ],
      multiSelect: false
    }
  ]
})
```

Then gather priority:

```
AskUserQuestion({
  questions: [
    {
      question: "What priority level?",
      header: "Priority",
      options: [
        { label: "P0-Critical", description: "Blocks current work or causes user-visible failure" },
        { label: "P1-High", description: "Important for current or next wave; significant impact" },
        { label: "P2-Medium", description: "Valuable but not urgent; can wait 1-2 waves" },
        { label: "P3-Low", description: "Nice to have; consider if capacity allows" }
      ],
      multiSelect: false
    }
  ]
})
```

### Step 2: Ensure BACKLOG Exists

Check for `docs/BACKLOG.md`:

1. **Read** `docs/BACKLOG.md`
2. **If it exists:** Proceed to Step 3
3. **If it does not exist:**
   - Read `templates/BACKLOG.tmpl.md` for the Foundation phase format
   - Create `docs/BACKLOG.md` with:
     - A heading: `# BACKLOG`
     - A brief overview paragraph
     - Priority definitions table (from the template's Foundation section)
     - An empty summary table header:
       ```markdown
       | Title | Status | Priority | Wave |
       |-------|--------|----------|------|
       ```
   - Create `docs/` directory if needed

### Step 3: Append Idea to BACKLOG

#### 3a. Update Summary Table

Add a new row to the summary table at the top of `docs/BACKLOG.md`:

```markdown
| [{Title}](#{anchor}) | captured | {Priority} | -- |
```

Where `{anchor}` is the title converted to a markdown anchor (lowercase, hyphens for spaces, strip special characters).

#### 3b. Append Idea Section

Append a new section at the end of `docs/BACKLOG.md`:

```markdown
## {Title}

- **Status:** captured
- **Priority:** {Priority}
- **Captured:** {ISO 8601 timestamp}

{One-line summary}
```

### Step 4: Confirm Capture

Present a brief inline confirmation:

```
Captured "{Title}" (priority: {Priority}) to docs/BACKLOG.md.
```

### Step 5: Offer Next Steps

```
AskUserQuestion({
  questions: [{
    question: "What would you like to do next?",
    header: "Next",
    options: [
      { label: "Capture another", description: "Record another idea to the backlog" },
      { label: "Shape this idea", description: "Run /arc-shape to refine this idea into a spec-ready brief" },
      { label: "Done", description: "Finish capturing" }
    ],
    multiSelect: false
  }]
})
```

**Handle selection:**
- **Capture another:** Loop back to Step 1
- **Shape this idea:** Inform the user to run `/arc-shape` (or invoke it if available as a skill)
- **Done:** Summarize total ideas captured this session and exit

## References

- `references/idea-lifecycle.md` — Capture stage definition, entry/exit criteria
- `references/brief-format.md` — Format the idea will eventually be shaped into
- `templates/BACKLOG.tmpl.md` — Template for creating BACKLOG.md if absent
