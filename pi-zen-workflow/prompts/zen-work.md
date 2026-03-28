---
description: Build the next reviewable Zen Workflow slice
argument-hint: "[slice-or-goal]"
---
Load the `zen-workflow` skill and read `build.md` guidance.

Use the build loop: **Orient → Slice → Validate → Explain**.

Read nearby `spec.md` and prototype findings if they exist. Otherwise use the conversation and code context.

Before editing, use the spec as direction, not as a script. If details are unclear, do a local grill for this slice only.

Choose the slice shape by dominant risk, not by habit. Prefer tracer bullets for end-to-end viability; prefer foundation-first migration when a refactor introduces shared semantics used by many existing callers.

State:

```md
Local grill:
- Spec direction used:
- Detail to decide:
- Recommended answer:

Next slice:
- Dominant risk:
- Slice technique:
- Intent:
- Scope:
- Out of scope:
- Validation:
- jj/PR boundary:
```

Skip `Local grill` when the detail is obvious.

If `$1` is provided, use it as the requested slice/goal. Otherwise choose the smallest valuable reviewable slice that proves the highest current risk.

Implement only that slice. If several conceptual changes are needed, split them into separate jj changes when that improves reviewability.

Use `build.md` naming conventions for jj descriptions, bookmarks, PR titles, and fixups:
- `<type>(<scope>): <imperative slice summary>`
- `<feature-slug>/<nn>-<slice-slug>` for stacked bookmarks

Do not run jj-ryu/GitHub commands unless I explicitly confirm.

Validate and explain what changed, how it was validated, what remains, and whether the spec needs an update. Update the spec only for durable architecture/API/glossary direction, not ordinary implementation detail.
