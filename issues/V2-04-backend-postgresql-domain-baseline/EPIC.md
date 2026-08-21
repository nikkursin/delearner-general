# V2-04 — Backend PostgreSQL Domain Baseline

**Status:** Done  
**Version:** 2  
**Workspace:** backend  
**Figma:** None  
**Depends on:** V2-02,V2-01-03  

## Goal

Establish PostgreSQL as canonical current-state persistence for Version 2 domain data, independent from the client SQLite shape.

## In Scope

- Add PostgreSQL connectivity and migration/version infrastructure.
- Create user-owned relational current-state models for Version 2 sync data.
- Add repository/service operations for current state and tombstones.
- Prepare one atomic transaction boundary for canonical mutation plus sync-event persistence.

## Out of Scope

- Permanent event sourcing
- Copying the SQLite schema table-for-table
- Payment/sharing tables not required for Version 2

## Epic Acceptance Criteria

- [x] PostgreSQL schema version is explicit and migration-tested.
- [x] Canonical user-owned words/groups/review/settings can be CRUD/tombstoned.
- [x] Ownership is enforced in persistence/service queries.
- [x] Current state can be read directly without replaying event history.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-04-01](./V2-04-01-add-postgresql-connection-and-migration-framework.md) | Add PostgreSQL connection and migration framework | backend | 2 | V2-01-03,V2-02-01 |
| [V2-04-02](./V2-04-02-create-version-2-canonical-domain-schema.md) | Create Version 2 canonical domain schema | backend | 2 | V2-04-01,V2-02-02,V2-02-03 |
| [V2-04-03](./V2-04-03-implement-ownership-scoped-persistence-services.md) | Implement ownership-scoped persistence services | backend | 2 | V2-04-02 |
| [V2-04-04](./V2-04-04-establish-atomic-domain-plus-sync-transaction-api.md) | Establish atomic domain-plus-sync transaction API | backend | 2 | V2-04-03 |

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
