---
name: grill
description: >
  Deeply analyze a fuzzy feature, architecture change, domain concept, or
  implementation strategy before committing to a shape.
---

# Grill

## Purpose

Grilling is the deep-thinking phase. Its job is to pressure-test the problem,
project context, and possible implementation shapes until the next phase is
safe: spec, prototype, or build.

There are two levels of grilling:

- **Architecture grill** before the spec: resolve big-picture direction.
- **Local grill** during build: resolve only the details needed for the current slice.

## Explore first

Before asking the human, inspect what can be learned from:

- current code and tests
- existing docs, specs, ADRs, and examples
- neighboring implementations in the same project
- relevant external repositories or libraries when useful
- current public interfaces and data flow

Ask only when exploration cannot answer the question.

## Question discipline

1. Ask one question at a time.
2. Explain why the question matters.
3. Include your recommended answer.
4. Use concrete scenarios to expose edge cases.
5. Challenge fuzzy or overloaded terms immediately.
6. Stop when the next phase is safe.

## What to pressure-test

- current problem and desired behavior
- domain vocabulary and user-visible concepts
- public APIs and caller contracts
- architecture seams and data flow
- examples from existing code or external repos
- sequencing and rollout constraints
- validation strategy
- out-of-scope boundaries
- hard-to-reverse tradeoffs

## Output

```md
## Grill result

Level:
- Architecture / Local slice

Resolved:
- ...

Recommended approach:
- ...

Open questions:
- ...

Recommended next phase:
- Spec / Prototype / Build

Spec notes:
- Only durable architecture/API/glossary decisions.

Slice notes:
- Implementation details for the current slice.
```

## Capture durable decisions

- Put behavior, API, glossary, and architecture decisions in `spec.md` when they
  affect the big-picture direction.
- Compress before writing docs; do not preserve every discussion detail.
- Offer an ADR only when the decision is hard to reverse, surprising without
  context, and the result of a real tradeoff.
- Keep transient reasoning in the conversation.
