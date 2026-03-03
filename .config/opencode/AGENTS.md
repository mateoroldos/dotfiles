# AGENTS.md

## Core Principles

- Concise over correct grammar.
- Think before acting: decompose tasks into logical steps first.
- Comments explain _why_, never _what_. If none needed, write none.

## Version Control (jj)

- jj changes are the atomic unit of work. Every logical change = one jj change.
- The `jj` history should read like a clear narrative of the project's evolution.
- Messages must communicate intent clearly. Read the jj skill before starting.
- Before creating the next jj change, check the projects linting and formatting scripts and run them.

## Naming Conventions

- **Files & folders:** `kebab-case` everywhere. `user-profile.ts`, `billing-service.ts`, `use-auth.ts`.
- **Components:** `kebab-case` filename matches the exported component. `user-profile.svelte`, `billing-card.tsx`.
- **Variables & functions:** `camelCase`. Booleans prefix with `is`, `has`, `can`, `should`. `isLoading`, `hasPermission`.
- **Types & interfaces:** `PascalCase`. No `I` prefix, no `Type` suffix. `User`, `BillingRecord`, not `IUser` or `UserType`.
- **Constants & `as const` objects:** `SCREAMING_SNAKE_CASE`. `MAX_RETRIES`, `UserError.NOT_FOUND`.
- **Zod schemas:** suffix with `Schema`. `userSchema`, `billingEventSchema`.
- **Service interfaces:** `[domain].interface.ts` — `payment.interface.ts`.
- **Test files:** co-located, same name, `.test.ts` suffix. `user-service.test.ts`.
- **Event handlers:** prefix with `on` at call-site, `handle` at definition. `onClick={handleSubmit}`.
- **Generics:** single uppercase letter for trivial cases (`T`, `K`, `V`); full descriptive name when multiple or non-obvious (`TValue`, `TError`).
- **Avoid:** abbreviations (`usr`, `ctx`, `mgr`), Hungarian notation (`strName`), filler words (`Manager`, `Helper`, `Utils` as standalone names).

## Types: The Source of Truth

- **Domain types** (entities, shared shapes) live in `src/types/`. One file per domain (`user.ts`, `billing.ts`). These are the project's source of truth.
- **Local types** (prop types, function-specific shapes, component internals) live co-located with their owner. Never hoist a type until it's shared.
- Promote to `src/types/` only when two or more unrelated places need it.
- No `any`. No type assertions unless at a parsing boundary (e.g. API response validation).
- `type` for shapes, `interface` for extensible contracts. No enums — use `as const` objects.
- Validate at the edges (API in/out, form input) with zod or equivalent. Infer types from schemas.
- Types describe the domain, not the code structure. Never leak implementation details into types.

## Interfaces & Services

- Define the interface before any implementation. Think hard on ergonomics and call-site clarity.
- Bind all consumers to interfaces, never concrete implementations.
- Service interfaces should be placed in the service directory, not in `src/types/`. They should be called `[service-name].interface.ts`.

## Business Logic & TDD

- Write the interface, then the test, then the implementation. In that order.
- Tests are the first consumer of your API — if the test is awkward, the interface is wrong.
- TDD cycle: write failing test → implement to pass → refactor → only then mark complete.
- Unit test pure functions directly. Integration test service boundaries via `Result` assertions.
- No component-level unit tests. UI correctness belongs in integration/e2e.

## Testing Rules

- Test what code does, not what mocks do. If you're asserting on a mock, stop.
- Never add test-only methods to production classes. Test utilities live in `test-utils/`.
- Never mock without understanding the full dependency chain and its side effects.
  - Run with real implementation first. Mock only what's truly external or slow.
  - Mock at the lowest possible level — never mock a method the test depends on for its logic.
- Mock the complete data structure. Partial mocks hide structural assumptions and fail silently.
- Mock setup longer than test logic is a red flag. Consider an integration test instead.

## Components (Svelte / React)

- One component per file.
- Compose, don't configure. No boolean props for behaviour variants — create explicit variant components.
- Providers own state management. Components consume, never manage.
- Complex components use shared context, not prop drilling.
- Always think if components need loading

## Async State & Boundaries

- Components receive resolved data only. No loading/error logic inside feature components.
- React: use Suspense + ErrorBoundary at route/provider boundaries. Use `use()` inside components.
- Svelte: use a composable `<AsyncBoundary>` component with snippets wrapping `{#await}`.
- Providers manage promise lifecycle and error mapping. Boundaries own rendering transitions.
- `AsyncState` discriminated union for complex internal flows only (multi-step, dependent fetches).
- Error Boundaries catch unrecoverable thrown exceptions. Domain errors are mapped before reaching the boundary.

## Functional Programming

- Pure functions in core logic. Side effects only in service implementations and lifecycle methods.
- Immutable data. No mutable state outside providers/services.

## Error Handling

- Services return `ResultAsync<Value, DomainError>` (neverthrow). Never throw from a service.
- Define domain errors as typed `as const` objects per domain (`UserError`, `BillingError`). No generic `Error` strings.
- External/API errors: validate with Zod at the boundary, map parse failures to a typed domain error, return as `Err()`. Never let raw API errors leak inward.
- Core logic is error-transparent: pure functions return `Result`, never throw.
- Thrown exceptions = unrecoverable programmer errors only. Error Boundaries catch these as a last resort.
- UI never inspects raw errors. Providers map `Err()` results to error state; components render from state.
- No swallowing errors silently. Every `Err()` is either handled, propagated, or explicitly logged.

## Code Quality

- No dead code, commented-out blocks, or unresolved TODOs.
- Test pure functions as units. Test service boundaries as integration. Never mock implementations.
- No barrel files (`index.ts` re-exports). Import directly.
