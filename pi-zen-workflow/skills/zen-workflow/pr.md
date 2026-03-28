---
name: pr
description: >
  How to write a PR title and description for one reviewable slice.
---

# Writing a PR description

## Philosophy

A PR description is the final review briefing for a completed build slice. The
first sentence is the most important part — a reviewer skimming a PR list
should understand the whole change from the title and first line alone.

Everything below the first sentence exists only to make review faster. If a
section adds nothing the code and first sentence don't already say, skip it.

## Title

The PR title should be the jj change description / commit message unless there
is a strong reason to clarify it. Use Conventional Commit style:

```txt
<type>(<scope>): <imperative slice summary>
```

Examples:

```txt
feat(auth): track failed login attempts
fix(auth): avoid leaking unknown account lockout state
refactor(storage): deepen model registry seam
```

The title identifies the reviewable slice; the body briefs the reviewer.

```
feat(storage): add model database access contracts
```

No "This PR adds...". The title should already say it.

## First sentence

The first sentence must answer four things at once:

- **what** changed
- **why** it matters
- **how** it behaves
- **where** it lives

It should be dense but readable — one sentence a reviewer can hold in their
head. Every word should earn its place.

Bad:

> This PR adds the access contracts for the new database layer.

Good:

> Adds the shared `GoodchatDbAccess` type, operation inputs, and `Where`
> predicate to `packages/storage` so hooks and plugins have a stable,
> dialect-neutral DB API to depend on before any behavior is implemented.

The difference: the good version says what it adds, why it exists, and where
it lives — all in one sentence.

## Structure

```md
<One sentence: what, why, how, where.>

## Why
<Only if the reason isn't obvious from the first sentence. Skip otherwise.>

## What changed
<2–4 bullets — the diff in prose. What the reviewer will see when they open
the diff. Not a file list.>

## Tests
<Checkboxes with passing tests>

## Out of scope
<What was explicitly not done. Prevents "why didn't you..." comments.
Skip if nothing significant was excluded.>

## Notes for reviewer
<Tricky decisions, known rough edges, where to start reading.
Skip if the code speaks for itself.>
```

Every section below the first sentence is optional. Skip any section that
would just be noise. A simple change may only need the first sentence and
two bullets.

## Section guidance

### Why

Only include this if the motivation isn't already in the first sentence or
obvious from the spec. Most of the time, skip it.

When you do include it, one or two sentences max. Link to the spec, issue,
prototype finding, or ADR if helpful.

### What changed

Prose bullets describing what the reviewer will actually see in the diff.
Not a file list — the diff already shows files. Write what changed
conceptually.

Good:
```md
- Adds `GoodchatDbAccess` with `create`, `findOne`, `findMany`, `update`,
  `updateMany`, `delete`, `deleteMany`, `count`, and `transaction`
- Adds `Where` predicate type with operators, `AND`/`OR` connectors, and
  case sensitivity mode
- Adds `Database.access` to the public database interface — type only,
  no implementation yet
```

Bad:
```md
- Updated packages/storage/src/access/types.ts
- Added new interfaces
- Modified database interface
```

### Out of scope

Include this when something a reviewer might expect is deliberately absent.
It removes "why didn't you also..." comments before they happen.

```md
- No predicate-to-Drizzle translation yet — that is `04-predicates`
- No runtime behavior — this change is type-only
```

Skip if the scope is already obvious from the change name and first sentence.

### Tests

Include when the tests added aren't obvious from "what changed". List what
behaviors are now covered — not file names, not test counts.

```md
## Tests
- Covers lockout trigger at exactly five failures within the window
- Covers counter reset on successful login
- Covers HTTP 423 response shape for locked accounts
```

Skip if "what changed" already makes the test coverage clear.

### Notes for reviewer

Include only genuinely non-obvious things. Where to start reading if the
entry point isn't obvious. A decision that looks wrong but isn't. A known
rough edge being handled in a follow-up.

```md
Start in `src/access/types.ts` — everything else follows from those types.

The `Where` predicate shape is intentionally close to Better Auth's adapter
API. See the commit body or spec notes for why we didn't copy it exactly.
```

Skip if the code and diff are self-explanatory.

## Anti-patterns

### Restating the title

Bad:
```md
feat(storage): add model database access contracts

This PR adds the model database access contracts to the storage package.
```

The first sentence should expand on the title, not repeat it.

### Listing files

Bad:
```md
## What changed
- Modified `src/access/types.ts`
- Updated `src/index.ts`
- Added `src/access/index.ts`
```

The diff already shows this. Write what changed conceptually, not which
files were touched.

### Narrating instead of stating

Bad:
> In this PR, I have added support for...

Good:
> Adds support for...

The description is a briefing, not a story. State it directly.

### Filling sections with noise

Bad:
```md
## Notes for reviewer
I tested this manually and it works.
```

If it adds nothing, skip the section entirely.

### Template cargo-culting

Don't include sections just because the template has them. A one-change PR
with a clear first sentence and two bullets is a perfect PR description.

## Validation checklist

Before submitting:

- [ ] Title is the jj change description / commit message unless clarification is needed
- [ ] First sentence covers what, why, how, and where
- [ ] First sentence stands alone — a reviewer understands the change without reading further
- [ ] "What changed" describes concepts, not files
- [ ] Every included section adds something the code and first sentence don't already say
- [ ] Empty or noisy sections were omitted

## Example

```md
feat(storage): add database model registry

Builds a runtime registry in `packages/storage` that resolves logical model
names like `messages` to Drizzle table objects, so hooks and plugins can
reference tables by name without knowing physical schema keys or dialect
details.

## What changed

- Adds `buildRegistry()` in `src/access/registry.ts` — accepts core, auth,
  and plugin schema declarations plus the runtime Drizzle schema object
- Resolves logical model names to `DbModelDefinition` with namespace, table
  name, schema key, and column metadata
- Throws on startup for missing tables and duplicate physical table names
- Tests cover core/auth registration, plugin resolution, missing tables,
  and duplicate collision errors

## Out of scope

- Access scoping (which callers can see which tables) — that belongs in a
  follow-up slice
- Plugin schema validation beyond table existence

## Notes for reviewer

Start in `src/access/registry.ts`. The collision check errors eagerly rather
than last-write-wins — see the commit body or spec notes for the reasoning.
```
