---
description: Address Zen Workflow review feedback with a focused fixup
argument-hint: "[branch-or-bookmark]"
---
Load the `zen-workflow` skill.

Use **Orient → Slice → Validate → Explain** for the review feedback on `$1`, or the current branch/bookmark if omitted.

Before editing, identify the smallest fixup slice:
- feedback being addressed
- scope
- out of scope
- validation

Make only the requested fix. Use fixup naming when creating a fixup change/commit:

```txt
fixup: <short reason>
```

Do not rewrite history unless I explicitly ask.

Only run jj-ryu submit commands if I explicitly confirm pushing to GitHub.

Explain what changed, how it was validated, and whether the PR description should be updated.
