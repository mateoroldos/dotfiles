---
name: handoff
description: >
  Write a concise handoff for another agent or future session. Use when pausing
  work, delegating a slice, marking something ready for an agent, or preserving
  context without writing a long spec.
---

# Handoff

## Purpose

A handoff gives the next agent enough context to continue calmly without
re-reading the whole conversation.

It should be durable, behavioral, and short. Do not write a mini-spec or a task
novel.

## When to use

Use a handoff when:

- pausing mid-feature
- delegating the next reviewable slice
- turning a discussion into agent-ready work
- summarizing prototype/grill findings for implementation
- handing off review feedback

Do not use a handoff when the next step is obvious from the current diff or PR.

## Brevity budget

Default: 10-20 lines.

If it gets longer, compress. Link to the spec, PR, issue, or prototype instead
of copying context.

## Template

```md
## Handoff

Goal:
- ...

Current state:
- ...

Next slice:
- Intent:
- Scope:
- Out of scope:
- Validation:

Key context:
- ...

Watch out:
- ...
```

## Rules

- Describe behavior and decisions, not step-by-step file edits.
- Include paths only when they are stable and genuinely useful.
- Include the validation signal the next agent should use.
- Include out-of-scope boundaries to prevent gold-plating.
- Mention spec updates only if architecture/API/glossary direction changed.
