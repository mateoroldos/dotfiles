---
name: to-spec
description: >
  Convert conversation, grill results, prototype findings, or code exploration
  into a concise architectural north-star spec.
---

# To Spec

## Purpose

Create the smallest spec that preserves big-picture direction: problem, target
architecture, glossary terms when useful, public API direction, major decisions,
review strategy, and out-of-scope boundaries.

Do not design every implementation detail. Those are grilled and decided during
build slices.

## Process

1. Use conversation, architecture grill results, prototype findings, and code
   exploration first.
2. Ask only blocking questions.
3. Make reasonable assumptions explicit.
4. Preserve durable architecture/API/glossary decisions.
5. Include diagrams, API shapes, file trees, or examples only when they clarify
   the target architecture.
6. Keep acceptance criteria high-level.
7. Compress before finishing: remove repeated ideas, exhaustive edge cases, and
   details better decided during slices.
8. Do not create an implementation checklist or exhaustive test plan.

## Brevity budget

Default limits unless the user explicitly asks for more:

- small change: ~20 lines
- medium feature: ~60 lines
- large/risky feature: ~120 lines

If the draft exceeds the budget, summarize the overflow instead of writing more.

## Output

Write or update `spec.md` using `spec.md` guidance.

A good spec lets an agent understand the north star, then locally grill and
build the next reviewable slice without re-reading the whole conversation.
