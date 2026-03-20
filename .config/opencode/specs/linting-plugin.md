---
title: Linting and Validation Plugin
status: draft
owner: opencode
scope: global
lastUpdated: 2026-03-03
related:
  - /home/runguinator/dotfiles/.config/opencode/opencode.json
  - /home/runguinator/dotfiles/.config/opencode/package.json
---

# Linting and Validation Plugin

## Context
- OpenCode plugins are event-driven and can hook into `tool.execute.before` and other lifecycle events.
- Current config includes plugins in `opencode.json` and `@opencode-ai/plugin` dependency.
- Goal is to add a plugin that improves linting and validation feedback.

## Goals
- Provide consistent lint/typecheck/test workflow across sessions.
- Reduce human intervention by surfacing validation results early.
- Keep behavior deterministic and easy to disable.

## Non-goals
- Do not enforce organization-wide CI policies.
- Do not run heavy test suites automatically on every small edit.

## Requirements
### Plugin location
- Create plugin under `~/.config/opencode/plugins/linting-guard/` (global).
- Add plugin entry to `opencode.json` if required by OpenCode.

### Behavior
- Provide a predictable linting command path, either as:
  - A plugin-registered command (preferred if supported), or
  - A guarded workflow that prompts the agent to run lint/typecheck before completion.
- Use repository scripts (e.g., `npm run lint`, `npm run typecheck`, `npm test`).
- Allow configuration of commands via a small JSON file in the plugin directory.

### Safety
- Never run destructive commands.
- Time out long-running checks if supported.

## Design
- Implement as a TypeScript plugin using `@opencode-ai/plugin` types.
- Use the most appropriate lifecycle hook once confirmed in docs or source.
- If command registration is supported, expose `/lint`, `/typecheck`, `/test` shortcuts.
- If lifecycle hooks are limited, fall back to a skill-based instruction flow that the agent can invoke.

## Acceptance Criteria
- Users can trigger lint/typecheck/test from the OpenCode session.
- Validation output is visible to the agent and user.
- Plugin can be disabled by removing it from `opencode.json`.

## Validation
- Run a sample lint command and verify output is captured.
- Confirm plugin does not interfere with unrelated tools.

## Risks
- Missing or undocumented lifecycle events limit enforcement.
- Incorrect command configuration causes false failures.

## Open Questions
- Confirm lifecycle hook names for session completion or command registration in OpenCode.
