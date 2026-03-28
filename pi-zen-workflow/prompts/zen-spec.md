---
description: Create or update a concise Zen Workflow architecture spec
argument-hint: "<feature-name>"
---
Load the `zen-workflow` skill and read `to-spec.md` and `spec.md` guidance.

Create or update `specs/$1/spec.md` unless I specify another location.

Use conversation, architecture grill results, prototype findings, and code exploration first. Ask only blocking questions.

Write a concise north-star spec. Include durable problem context, target architecture, glossary terms when useful, important pieces, public API direction, major decisions, review strategy, high-level acceptance criteria, and out-of-scope notes.

Respect the brevity budget from `spec.md`. If the draft becomes long, compress it instead of adding more Markdown.

Do not design every implementation detail. Those should be locally grilled while building each reviewable slice.

Do not write implementation code.
Do not create implementation checklists.
