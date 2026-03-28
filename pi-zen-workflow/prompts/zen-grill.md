---
description: Deeply grill a Zen Workflow feature, architecture change, or implementation strategy
argument-hint: "[topic]"
---
Load the `zen-workflow` skill and read `grill.md` guidance.

Deeply analyze `$1` using the project code, tests, docs, examples, and relevant external repositories when useful.

Choose the grill level:
- Architecture grill: big-picture direction before or during spec work.
- Local grill: implementation details for one build slice.

Do not just ask questions. Explore first. Ask only when context cannot answer, one question at a time, with your recommended answer.

Pressure-test:
- problem and desired behavior
- domain terms
- public APIs and caller contracts
- architecture seams and data flow
- implementation strategies
- validation approach
- out of scope

End with a grill result and recommended next phase: Spec, Prototype, or Build. Mark which findings belong in the spec versus only the current slice.
