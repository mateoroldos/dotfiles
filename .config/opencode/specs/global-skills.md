---
title: Global Skills Library
status: draft
owner: opencode
scope: global
lastUpdated: 2026-03-03
related:
  - /home/runguinator/dotfiles/.config/opencode/opencode.json
---

# Global Skills Library

## Context

- OpenCode skills are defined by `SKILL.md` with YAML frontmatter.
- Skills can live in `.opencode/skills/<name>/SKILL.md` or global equivalents.
- The config should allow the `skill` tool for on-demand loading.

## Goals

- Provide reusable, on-demand skills that keep always-on context small.
- Cover spec-driven development, review, frontend UX guidance, and validation workflows.

## Non-goals

- Do not embed large documentation or external API references in skills.
- Do not add auto-executing scripts unless required.

## Requirements

### Skill locations

- Create global skills under `~/.config/opencode/skills/<name>/SKILL.md`.
- Add `permission.skill = "allow"` in `opencode.json` if not already set.

### Skill list

- `spec-writer`: SDD template with goals, edge cases, acceptance criteria, test plan.
- `reviewer`: prioritized review checklist with severity rubric.
- `frontend-ux`: UI/UX guidance consistent with your frontend rules.
- `lint-runner`: how to run lint/typecheck/test and interpret results.
- `context-harness`: how to decide between rules vs skills, and keep context lean.

### SKILL.md format

- YAML frontmatter with `name`, `description`, `compatibility: opencode`.
- Sections: "What I do", "When to use me", "Outputs".
- Keep each skill under ~200 lines.

## Acceptance Criteria

- Skills appear in OpenCode and load on demand.
- Skills do not bloat always-on context.
- Each skill has consistent structure and clear use cases.

## Validation

- Invoke each skill and confirm content loads correctly.
- Confirm skill tool permission is enabled.

## Risks

- Missing permission blocks skill access.
- Overly long skills reduce usability.

## Open Questions

- None.
