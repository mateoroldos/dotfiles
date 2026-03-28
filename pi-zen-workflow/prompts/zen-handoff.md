---
description: Write a concise Zen Workflow handoff for a future agent/session
argument-hint: "[next-slice-or-context]"
---
Load the `zen-workflow` skill and read `handoff.md` guidance.

Write a short handoff for `$1`, or for the current work if omitted.

Use nearby spec, current diff, commits, prototype findings, grill results, and conversation context as needed.

Keep it concise. Default to 10-20 lines. Link or reference instead of copying long context.

Include:
- goal
- current state
- next reviewable slice
- scope / out of scope
- validation signal
- key context
- watch-outs

Do not create a long spec or implementation checklist.
