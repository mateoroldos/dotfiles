---
name: build
description: >
  Reviewability-first production implementation using risk-based slicing,
  tracer bullets, foundation-first migrations, TDD where useful, fast validation
  loops, jj changes, and PR cycles.
---

# Build

## Purpose

Build production code as reviewable slices. The goal is high-quality code that
is easy to understand, validate, and review.

## Implementation loop

```md
Orient → Slice → Validate → Explain
```

### Orient

Understand enough context for the next slice:

- relevant spec direction, not a step-by-step script
- prototype findings if any
- current code and tests
- public interfaces and callers
- risks and unknowns
- likely validation signal

If implementation details are unclear, run a local grill before editing. Decide
only what this slice needs.

### Slice

Choose one conceptual change. The slice may discover details the spec did not
pre-design; that is expected.

A reviewable slice has:

- one intent
- focused diff
- clear scope and out of scope
- validation signal
- reviewer-friendly explanation

Choose the slice shape by dominant risk. Default to the smallest slice that
proves the highest current risk, not automatically to a tracer bullet.

Prefer vertical tracer bullets when the main uncertainty is end-to-end viability:
whether the important layers, seams, integrations, or deployment path can work
together. Tracer bullets are especially useful for fresh projects, new product
paths, and uncertain architecture.

Avoid forcing tracer bullets when they would leave many existing services partly
legacy and partly migrated. For refactors that introduce a shared primitive used
by many callers, prefer foundation-first migration:

1. define the contract,
2. implement the shared primitive,
3. prove it with one real consumer,
4. migrate consumers in reviewable groups,
5. remove legacy paths.

Do not treat foundation-first as permission for speculative architecture. The
foundation must be directly required by the spec and proven by near-term
consumers.

### Slice selection

| Dominant risk | Prefer | Why |
|---|---|---|
| End-to-end viability or fresh project shape | Tracer bullet / walking skeleton | Proves one real path through the important seams. |
| Shared semantics used by many existing callers | Foundation-first migration with proof consumer | Prevents half-legacy/half-new behavior across services. |
| Public API, event, schema, or caller contract stability | Contract-first slice | Reduces costly churn before broad adoption. |
| Behavior correctness | Test-first behavior slice | Proves one externally visible rule through the caller-facing seam. |
| Unknown UX, API ergonomics, library behavior, or performance | Prototype / spike | Learns cheaply before productionizing. |
| Data or rollout safety | Migration, parallel-run, or strangler slice | Preserves production behavior while changing paths incrementally. |
| Security, privacy, or authorization boundary | Capability / permission slice | Centralizes policy before broad exposure. |
| Large repetitive low-risk change | Mechanical slice | Keeps semantic changes out of noisy diffs. |
| Legacy removal after migration | Cleanup-after slice | Makes deletion reviewable after replacement is proven. |

### Validate

Use the fastest reliable signal:

- failing/passing test
- typecheck/lint
- CLI/repro script
- browser/UI/TUI check
- integration or smoke command

Use TDD when behavior is clear enough to write one useful test first. Do not
write all tests first and all implementation later; prefer one behavior at a
time.

### Explain

Summarize:

- what changed
- why this slice is reviewable
- validation run
- decisions/tradeoffs
- what remains

## jj and PR discipline

Use jj changes/PRs as review units.

- Before starting a new slice, inspect the current jj state and confirm which change is being edited.
- Never assume the active jj change is the intended slice; if it looks wrong, stop and ask before editing.
- One conceptual change should usually be one jj change/PR.
- If the agent needs several conceptual changes, create several jj changes when
  that improves reviewability.
- Do not split so aggressively that reviewers lose the story.
- Do not combine unrelated changes just because they are convenient.
- Run jj-ryu/GitHub commands only when explicitly asked or confirmed.

## Naming conventions

### jj change descriptions / commit messages

Use Conventional Commit style:

```txt
<type>(<scope>): <imperative slice summary>
```

Good examples:

```txt
feat(auth): track failed login attempts
fix(auth): avoid leaking unknown account lockout state
refactor(storage): deepen model registry seam
test(auth): cover lockout expiry window
```

Rules:

- Use imperative phrasing: `add`, `track`, `reject`, `preserve`, `remove`.
- Describe the slice, not the implementation mechanics.
- Keep the first line reviewable and specific.
- Add a commit body only for non-obvious decisions, tradeoffs, validation, or
  reviewer context.

### Bookmark names

Use stable feature-prefixed bookmarks:

```txt
<feature-slug>/<nn>-<slice-slug>
```

Examples:

```txt
account-lockout/01-track-failed-attempts
account-lockout/02-enforce-lockout-threshold
account-lockout/03-reset-counter-on-success
```

Rules:

- `feature-slug` names the feature or stack.
- `nn` preserves review order for stacked work.
- `slice-slug` should match the jj change description closely enough to scan.
- If a slice deserves its own PR, it deserves its own clear bookmark and jj
  description.

### Proposed change descriptions

When a slice changes enough that the jj description should be updated, end the
whole agent response with a proposed Conventional Commit description. Do not run
`jj describe` unless the user explicitly asks or confirms.

Use this format after the normal summary:

```md
Proposed jj description:
<type>(<scope>): <imperative slice summary>
```

Include a short body only when the slice has non-obvious decisions, tradeoffs,
validation, or reviewer context.

### PR titles

Use the jj change description / commit message as the PR title unless there is a
strong reason to clarify it.

### Fixups

For review feedback, prefer a focused fixup change/commit:

```txt
fixup: <short reason>
```

Examples:

```txt
fixup: cover expired lockout window
fixup: clarify registry collision error
```

Explain the feedback addressed in the PR comment/body when useful.

## Code quality techniques

- Keep core logic pure where practical; push side effects to edges.
- Prefer clear public interfaces and small caller knowledge.
- Tests should cross the same interface callers use.
- Avoid speculative seams; two real adapters justify a seam better than one.
- Refactor after green, not while behavior is failing.
- Remove throwaway prototype code unless deliberately absorbed.

## Before editing

For jj repositories, first run a lightweight orientation such as `jj status` and
`jj log -r 'heads(::@) | @ | @-' --limit 8` to verify the active change, parent,
and nearby stack before editing.

```md
Local grill:
- Current jj change:
- Spec direction used:
- Implementation detail to decide:
- Recommended answer:

Next slice:
- Intent:
- Scope:
- Out of scope:
- Validation:
- jj/PR boundary:
```

Skip `Local grill` when the implementation detail is obvious.

## Done

```md
Done:
- Changed:
- Validated:
- Review notes:
- Remaining:
- Spec update needed: yes/no, only for architecture/API/glossary direction
```
