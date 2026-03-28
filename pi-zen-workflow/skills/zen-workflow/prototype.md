---
name: prototype
description: >
  Build throwaway UI, TUI, CLI, logic, state-machine, data-flow, API-shape, or
  integration prototypes to prove ideas before production code.
---

# Prototype

## Purpose

A prototype is throwaway code that answers one question. Use it when proving an
idea is cheaper than debating or committing production code.

Prototype from a conversation, grill result, or spec.

## Prototype types

### Logic / state prototype

For behavior, reducers, workflows, state machines, and edge cases.

Typical shape: tiny CLI or script that runs scenarios and prints state after
each step.

### UI prototype

For visual design, layout, interaction, and product feel.

Typical shape: temporary route/page with multiple variants and a simple switcher.

### TUI prototype

For terminal interactions, command flows, keyboard navigation, and text layouts.

Typical shape: minimal runnable TUI or mocked terminal output flow.

### Data-flow / API prototype

For public API shape, adapters, event flow, integrations, or module seams.

Typical shape: small harness showing inputs, transformations, outputs, and error
modes.

## Rules

1. Start with the question being answered.
2. Mark prototype files clearly as throwaway.
3. Keep the prototype close to the code it informs when practical.
4. Provide one command, route, or interaction path to run it.
5. Avoid persistence unless persistence is the question.
6. Skip production polish and abstractions.
7. Surface state/output so humans can judge quickly.
8. Delete it or absorb the validated idea when done.

## Before coding

```md
Question:
Prototype type:
How to run/view:
What would prove the idea:
Deletion/absorption plan:
```

## After coding

```md
Question answered:
Finding:
Decision:
Spec update needed:
Recommended production slice:
```
