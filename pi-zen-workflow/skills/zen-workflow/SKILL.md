---
name: zen-workflow
description: >
  Deep-design, reviewability-first workflow for grilling, specs, prototypes,
  implementation slices, jj stacks, and PR descriptions. Use for non-trivial
  features, refactors, bugs, and architecture/product decisions.
---

# Zen Workflow

## Core idea

Zen Workflow is **deep thinking, calm execution**:

```md
Grill → Spec → Prototype → Build → PR
```

Use only the phases that reduce risk or cognitive load. Skip obvious phases for
small work, but never skip reviewability.

## The phases

### 1. Grill

Understand the problem deeply before committing to a shape.

The agent should actively inspect the codebase, existing docs, examples, tests,
and relevant external repositories when useful. Ask hard questions only when
code/context cannot answer them, one at a time, with a recommended answer.

Output: resolved decisions, open questions, recommended approach, and whether a
spec or prototype is needed.

### 2. Spec

Create big-picture architectural clarity.

A spec is a short north star: it defines the problem, target architecture,
glossary, important pieces, public API direction, constraints, non-goals, and
review strategy. It should not design every implementation detail up front or
turn into a long document reviewers dread opening.

Specs set architectural intent. Slices discover implementation detail.

### 3. Prototype

Learn cheaply before productionizing.

Use throwaway UI, TUI, CLI, state-machine, data-flow, API-shape, or integration
prototypes when an idea is cheaper to prove with code than discussion. Capture
the learning back into the spec, conversation, ADR, or PR.

### 4. Build

Build reviewable production code.

Use the spec as direction, not as a script. Before each slice, locally grill any
implementation details that are still unclear. Update the spec only when a slice
changes architectural intent or durable public contracts.

Use the implementation loop:

```md
Orient → Slice → Validate → Explain
```

Choose slice shape by dominant risk. Prefer tracer bullets when end-to-end
viability is the main uncertainty, and prefer foundation-first migration when a
refactor introduces shared semantics used by many existing callers. Use TDD when
it clarifies behavior. Keep diffs focused. If the work naturally contains
several conceptual changes, make several jj changes/PRs instead of one giant
diff.

Commits, jj changes, and PRs are the source of truth for implementation history.
Do not maintain mirrored Markdown task lists.

### 5. PR

Make review fast.

Each PR should brief the reviewer: what changed, why it matters, how it behaves,
how it was validated, what is out of scope, and where to start reviewing when
that is not obvious.

## Phase selection

| Situation | Use |
|----------|-----|
| Fuzzy problem, risky design, unclear terms | `grill.md` |
| Durable context needed across sessions/reviews | `spec.md` / `to-spec.md` |
| Idea needs proof before production code | `prototype.md` |
| Production implementation | `build.md` |
| Ready for review | `pr.md` |
| Pausing or delegating work | `handoff.md` |

## Artifacts

| Artifact | Use when |
|----------|----------|
| None | Tiny/simple edits |
| Conversation notes | Normal work needs brief shared context |
| `spec.md` | Decisions/behavior must survive sessions or reviews |
| Prototype | Learning is cheaper with throwaway code |
| ADR | Decision is hard to reverse, surprising, and tradeoff-heavy |
| jj change / PR | A conceptual implementation slice needs review |
| PR description | Reviewer needs a clear briefing |
| Handoff | Future agent/session needs concise continuation context |

## Agent behavior

When this skill is active:

1. Optimize for reviewability, low cognitive load, and fast flow.
2. Choose the lightest phase that makes the next step safe.
3. For design uncertainty, grill deeply before coding.
4. For durable architectural direction, write or update a short spec.
5. For uncertain shapes, prototype before productionizing.
6. During build, locally grill implementation details per slice.
7. During build, work one reviewable slice at a time.
8. Split conceptual changes into separate jj changes/PRs when that improves review.
9. Validate every production slice with the fastest reliable signal.
10. Explain decisions and validation where reviewers will see them.
11. Never create mirrored implementation checklists.
12. Avoid long Markdown by default; compress docs before handing them to the user.

## Subfiles

- `grill.md` — deep design grilling and context discovery.
- `spec.md` — flexible durable specs.
- `to-spec.md` — convert context into a spec.
- `prototype.md` — throwaway UI/TUI/logic/data-flow prototypes.
- `build.md` — reviewability-first implementation with risk-based slicing, tracer bullets, foundation-first migrations, TDD, and jj discipline.
- `pr.md` — reviewer-friendly PR descriptions.
- `handoff.md` — concise continuation/delegation briefs.
