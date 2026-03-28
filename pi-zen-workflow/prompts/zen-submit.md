---
description: Submit current Zen Workflow slice or stack via jj-ryu
argument-hint: "[branch-or-bookmark-prefix]"
---
Load the `zen-workflow` skill and read `pr.md` guidance.

Inspect the current jj stack or `$1` if provided. Use commits and PRs as the source of truth.
If a nearby `spec.md` exists, use it only for durable context.

Only continue if I explicitly confirm pushing to GitHub.

For each PR being submitted:
1. Ensure the bookmark/branch exists and is ready.
2. Run the requested jj-ryu submit command.
3. Write or update the PR title/body using `pr.md` guidance.

Use `gh` only after confirmation when it modifies GitHub state.
Print a summary of PR URLs when done.
