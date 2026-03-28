---
name: pi-subagents
description: |
  Delegate work to user or project subagents with single-agent, chain,
  parallel, async, forked-context, and intercom-coordinated workflows.
  Use for advisory review, implementation handoffs, multi-step tasks,
  and agent or chain management.
---

# Pi Subagents

This local package only provides the subagent engine and this skill. It does **not** ship default agents or prompt recipes.

Use only agents and chains discovered from:

- `~/.pi/agent/agents/**/*.md` and `~/.pi/agent/chains/**/*.chain.md`
- `.pi/agents/**/*.md` and `.pi/chains/**/*.chain.md`
- legacy `~/.agents/**/*.md` and `.agents/**/*.md` where supported

Before delegating, call `subagent({ action: "list" })` and choose an enabled discovered agent. Do not assume builtin names like `worker`, `reviewer`, `scout`, `planner`, `oracle`, `researcher`, `delegate`, or `context-builder` exist.

## Common Tool Shapes

Single agent:

```typescript
subagent({
  agent: "agent-name",
  task: "Concrete goal, relevant files, constraints, expected output."
})
```

Parallel tasks:

```typescript
subagent({
  tasks: [
    { agent: "agent-a", task: "Inspect one angle." },
    { agent: "agent-b", task: "Inspect another angle." }
  ],
  concurrency: 2
})
```

Chain:

```typescript
subagent({
  chain: [
    { agent: "agent-a", task: "Gather context for {task}" },
    { agent: "agent-b", task: "Use this context and produce the result: {previous}" }
  ]
})
```

Management:

```typescript
subagent({ action: "list" })
subagent({ action: "get", agent: "agent-name" })
subagent({ action: "status", id: "run-id-prefix" })
```

## Prompting Subagents

A strong task includes:

- goal
- context/evidence paths
- success criteria
- hard constraints
- validation expectations
- output shape
- stop/escalation rules

Keep parent orchestration in the parent session. Child subagents should receive a concrete task and should not launch their own subagent workflows unless explicitly requested.
