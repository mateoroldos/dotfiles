---
description: Draft or update a PR description for one reviewable Zen Workflow slice
argument-hint: "[branch-or-bookmark]"
---
Load the `zen-workflow` skill and read `pr.md` guidance.

Inspect the current diff/commits for `$1`, or the current branch/bookmark if omitted. Use nearby `spec.md` or prototype findings only for durable context.

Write a PR title and description following `pr.md` guidance:
- Title: jj change description / commit message unless clarification is needed
- Title format: `<type>(<scope>): <imperative slice summary>`
- First sentence: what, why, how, where — dense and standalone
- Sections: include only what helps review faster
- Explain validation and out-of-scope work when useful
- Mention follow-up slices only if they help reviewers understand scope

If an open PR exists, ask before updating it with `gh pr edit`.
Print the final title/body or PR URL.
