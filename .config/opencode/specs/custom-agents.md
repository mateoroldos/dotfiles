---
title: Custom Agents
status: draft
lastUpdated: 2026-03-03
related:
  - /home/runguinator/dotfiles/.config/opencode/opencode.json
  - /home/runguinator/dotfiles/.config/opencode/AGENTS.md
---

# Custom Agents: frontend-developer, spec-writer, reviewer, researcher

## Context

- OpenCode config lives at `/home/runguinator/dotfiles/.config/opencode/opencode.json`.
- Custom agents can be defined as markdown files in `~/.config/opencode/agents/` or `.opencode/agents/`.
- Goal is to add three specialized agents to improve output quality and reduce context noise.

## Goals

- Provide clear, role-specific behavior with minimal overlap.
- Ensure reviewer is read-only and cannot modify files.
- Ensure spec-writer produces structured specs in `specs/` and top quality `README.md` files.
- Ensure frontend-developer aligns with `AGENTS.md` conventions.
- Ensure researcher has top quality researching tools and runs a subagent. It should search deeply and return clean and concise information to top agents.

## Non-goals

- Do not change provider models or pricing.
- Do not introduce organization-wide policies beyond this config.

## Requirements

### Agent definitions

- Names: `frontend-developer`, `spec-writer`, `reviewer`, `researcher`.
- Mode: `frontend-developer` and `spec-writer` can be `agent` or `subagent`. `reveiwer` and `researcher` are `subagent`.
- Model: `openai/gpt-5.2-codex` (aligned with configured provider).
- Temperature: low (0.2 or lower).
- Description: concise one-liner for each.
- Prompt: role-specific, with explicit deliverables.

### Tool permissions

- reviewer: read/search only; disable `write`, `edit`, `bash`.
- spec-writer: allow `read`, `write`, `edit`; allow `bash` only for info gathering; must not modify code outside `specs/` or `README.md`.
- frontend-developer: allow standard tools; can run lint/typecheck/test when requested; must follow `AGENTS.md`. Should have browser skills to check it's work.
- researcher: should have read access and have MCP tools like `Context7`, `Vercel GREP`, etc.

### File placement

- Preferred: `~/dotfiles/.config/opencode/agents/<agent>.md` (global).
- Optional: `.opencode/agents/<agent>.md` for project overrides.

## Design

- Use markdown agent files with YAML frontmatter for readability and auditability.
- Keep prompts under 200 lines.
- Include explicit sections: "When to use" and "Outputs".

## Acceptance Criteria

- Agents appear in OpenCode and are selectable.
- reviewer cannot write/edit or run bash commands.
- spec-writer creates specs only under `/home/runguinator/dotfiles/.config/opencode/specs/`.
- frontend-developer follows naming and testing rules from `AGENTS.md`.

## Validation

- Start a session with each agent, request a trivial task, confirm tool restrictions and output format.

## Risks

- Incorrect model id format prevents agent loading.
- Overly long prompts reduce available context.

## Open Questions

- Confirm model id format if OpenCode requires provider prefix or alias.
