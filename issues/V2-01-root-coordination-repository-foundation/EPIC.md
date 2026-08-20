# V2-01 — Root Coordination Repository Foundation

**Status:** Done
**Version:** 2  
**Workspace:** root  
**Figma:** None  
**Depends on:** MVP1 complete; canonical documentation set available  

## Goal

Create the system-level workspace that coordinates the existing frontend and backend repositories without merging their implementation ownership.

## In Scope

- Create the root DELearner coordination repository and add frontend/backend as Git submodules.
- Install the canonical docs and root agent workflow without duplicating child-repository implementation docs.
- Add shared development-environment scaffolding and root orchestration entry points.
- Make fresh clone, submodule initialization, build/test delegation and system status reproducible.

## Out of Scope

- Feature implementation
- Moving frontend/backend source code into the root repository
- Duplicating child CMake/build logic

## Epic Acceptance Criteria

- [x] A fresh clone can initialize both pinned submodules using documented commands.
- [x] Root scripts delegate to child build/test commands rather than reimplementing them.
- [x] Cross-repo agents can identify canonical docs, current issue and repository ownership from the root.
- [x] Root commits pin an exact compatible frontend/backend revision pair.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-01-01](./V2-01-01-create-root-repository-skeleton-and-submodule-layout.md) | Create root repository skeleton and submodule layout | root | 1 | — |
| [V2-01-02](./V2-01-02-install-canonical-docs-and-root-agent-entry-points.md) | Install canonical docs and root agent entry points | root | 1 | V2-01-01 |
| [V2-01-03](./V2-01-03-add-shared-environment-scaffold.md) | Add shared environment scaffold | root | 2 | V2-01-01 |
| [V2-01-04](./V2-01-04-add-root-bootstrap-build-test-orchestration.md) | Add root bootstrap/build/test orchestration | root | 2 | V2-01-01,V2-01-03 |

## Canonical References

- `docs/00-SYSTEM-CONCEPT.md`
- `docs/01-SHARED-DATA-CONTRACT.md`
- `docs/02-SYNC-PROTOCOL.md`
- `docs/03-PRODUCT-ROADMAP.md`
- `docs/04-VERSION-2-PLAN.md`
- `docs/07-ISSUE-PLANNING-RULES.md`
- `AGENTS.md`

## Stop / Escalate If

- The work requires a new product behavior not already approved.
- The work requires changing shared contract/schema semantics beyond this epic.
- A Figma/code discrepancy would require a large structural change.
- The task begins pulling Version 3+ scope into Version 2.
