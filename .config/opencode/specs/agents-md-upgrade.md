---
title: AGENTS.md Upgrade
status: draft
owner: opencode
scope: global
lastUpdated: 2026-03-03
related:
  - /home/runguinator/dotfiles/.config/opencode/AGENTS.md
  - /home/runguinator/dotfiles/.config/opencode/opencode.json
---

# AGENTS.md Upgrade

## Context
- `AGENTS.md` exists at `/home/runguinator/dotfiles/.config/opencode/AGENTS.md` and already defines core coding rules.
- OpenCode docs recommend including detailed build/lint/test commands and single-test execution in `AGENTS.md`.
- Current file does not list commands or a project summary.

## Goals
- Make `AGENTS.md` a high-quality, minimal, always-on rules file.
- Add required build/lint/typecheck/test commands with single-test examples.
- Keep it under 500 lines with concise, structured sections.

## Non-goals
- Do not add large API docs or verbose examples that bloat context.
- Do not change existing conventions unless they conflict with tooling.

## Requirements
### Content additions
- Add a brief project summary for the OpenCode config repository.
- Add a "Commands" section with:
  - Build command (if applicable).
  - Lint command.
  - Typecheck command.
  - Test command.
  - Single-test command examples for the dominant stack(s).
- Add a "Validation" section describing when to run which commands.
- Add a "Safety" section (secrets handling, .env access).

### Structure
- Keep existing naming, testing, and error-handling rules.
- Use short sections with bullet points.
- Avoid redundant or generic instructions.

### Config integration
- Optionally split into modular files and add an `instructions` array in `opencode.json` if the file grows beyond 500 lines.

## Acceptance Criteria
- `AGENTS.md` includes explicit build/lint/typecheck/test commands.
- Includes single-test execution examples.
- Remains concise and under 500 lines.
- No conflicting rules with existing content.

## Validation
- Manual review for clarity and brevity.
- Ensure commands match actual project scripts.

## Risks
- Incorrect command definitions cause failed validation.
- Overly verbose additions reduce context efficiency.

## Open Questions
- Exact lint/typecheck/test commands for this repository.
