# Questions — Round 1

## Q1: Inline capture behavior

**Question:** When the user provides the idea inline, should we skip all interactive prompts?

**Answer:** Single AskUserQuestion showing what was parsed + priority picker together. Options: confirm, adjust, or free-text via "Other". If still unclear after parsing, just log it as-is with relevant chat context. One prompt total.

## Q2: Full interactive flow

**Question:** Combine title and summary into a single prompt?

**Answer:** Yes — single free-text prompt ("Describe your idea in a sentence or two"), AI parses title + summary.

## Q3: Default priority

**Question:** What default priority before user picks?

**Answer:** No default — block on priority. Priority is collected in the same confirmation prompt so it doesn't add a step.

## Q4: Next steps prompt

**From invocation:** Remove "what do you want to do next" entirely. Just return control.

**Answer:** Confirmed — remove Step 5, print confirmation line and exit.
