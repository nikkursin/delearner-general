# V2-03 — Frontend UUID + Migration Baseline

**Status:** Done  
**Version:** 2  
**Workspace:** frontend  
**Figma:** Review only if ID assumptions leak into UI; no redesign  
**Depends on:** V2-02  

## Goal

Replace pre-release integer identity with canonical UUID identity and establish the first durable SQLite migration/version baseline.

## In Scope

- Create a clean disposable SQLite baseline using UUIDs for syncable entities.
- Introduce explicit MAJOR.MINOR schema versioning and future migration infrastructure.
- Update repositories/services/QML-facing identifiers and relationships.
- Introduce tombstone-compatible delete semantics and enable relevant tests.

## Out of Scope

- Preserving existing developer database contents
- Keeping legacy integer IDs as permanent secondary identities
- Unrelated frontend architecture refactors

## Epic Acceptance Criteria

- [x] Syncable entities no longer require integer IDs.
- [x] Clean database creation produces the versioned UUID schema.
- [x] Existing CRUD and relationships work with UUIDs.
- [x] Syncable delete paths preserve tombstone state rather than hard-deleting immediately.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-03-01](./V2-03-01-create-versioned-uuid-sqlite-baseline.md) | Create versioned UUID SQLite baseline | frontend | 2 | V2-02-01 |
| [V2-03-02](./V2-03-02-migrate-words-and-groups-to-uuid-interfaces.md) | Migrate words and groups to UUID interfaces | frontend | 2 | V2-03-01,V2-02-02 |
| [V2-03-03](./V2-03-03-migrate-review-statistics-and-synced-settings-identity-paths.md) | Migrate review statistics and synced settings identity paths | frontend | 2 | V2-03-01,V2-02-03 |
| [V2-03-04](./V2-03-04-implement-tombstone-delete-baseline-and-regression-tests.md) | Implement tombstone delete baseline and regression tests | frontend | 2 | V2-03-02,V2-03-03 |

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
