---
description: Convert current context into a concise Zen Workflow architecture spec
argument-hint: "<feature-name>"
---
Load the `zen-workflow` skill and read `to-spec.md` and `spec.md` guidance.

Convert the current conversation, architecture grill results, prototype findings, and relevant code context into `specs/$1/spec.md`, unless I specify another location.

Do not interview me unless a question is blocking. Use explicit assumptions when reasonable.

The spec should preserve the north star: problem, target architecture, glossary terms when useful, public API direction, important decisions, review strategy, and out-of-scope work.

Respect the brevity budget from `spec.md`. If the draft becomes long, compress it instead of adding more Markdown.

Do not mirror future commits or decide every implementation detail.
