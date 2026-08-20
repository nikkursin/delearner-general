# DE Vocab Learner — Issue Planning Rules

## Purpose

Define how roadmap/version scope becomes Loop-agent executable work.

## Issue Hierarchy

```text
Roadmap Version
→ Root Epic / Root Feature Issue
→ Frontend sub-task(s)
→ Backend sub-task(s)
→ Root contract/integration acceptance
```

Not every root issue needs both frontend and backend work. Cross-repository behavior does.

## Root Issue Requirements

Every cross-repository root issue should contain:

- goal;
- user/system outcome;
- in-scope behavior;
- explicit non-goals;
- canonical docs affected;
- Figma reference when user-facing behavior changes;
- frontend responsibilities;
- backend responsibilities;
- shared contract implications;
- migration/schema implications;
- tests required;
- end-to-end acceptance criteria;
- stop/escalation conditions.

## Task Sizing

Prefer small independently verifiable issues.

A useful execution issue should normally represent one coherent change that an agent can implement, test and review without redesigning unrelated parts of either repository.

Avoid issues such as:

- "implement authentication and sync";
- "refactor frontend architecture";
- "finish backend".

Prefer:

- "replace syncable word IDs with UUIDs in SQLite/repository tests";
- "persist registered device cursor in PostgreSQL";
- "create authenticated event-ingestion transaction";
- "bootstrap words/groups for a newly registered device".

## Cross-Repo Contract Rule

If an issue changes the shared contract:

1. update/approve the contract change first;
2. keep the change backward-compatible within the current major version when possible;
3. implement backend/frontend against the same fixtures;
4. update root contract tests;
5. update submodule pointers only after compatible child revisions are ready.

## Figma Rule

For a new screen or meaningful user-facing flow:

```text
product decision
→ Figma definition/review
→ root issue
→ implementation
```

Small local UI fixes that do not change product behavior may bypass a Figma update.

If Figma and code conflict and alignment would cause a large structural change, stop and ask for approval before implementation.

## Agent Autonomy

Agents have moderate autonomy.

Allowed without approval:

- small local refactors required by the issue;
- test helpers;
- narrow cleanup directly required for correctness;
- implementation details that stay inside canonical boundaries.

Require approval / root decision:

- major architecture-boundary changes;
- schema/contract semantics not already approved;
- new product behavior;
- new premium scope;
- large Figma-vs-code structural changes;
- pulling future-version work into the current issue.

## Definition of Done for Cross-Repo Work

A cross-repo feature is done only when:

- frontend child tests pass;
- backend child tests pass;
- root contract/integration tests pass where feasible;
- root acceptance criteria pass;
- docs are updated if behavior/contract changed;
- frontend/backend submodule revisions are pinned together in a root commit.
