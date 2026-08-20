# V2-02 — Contract and Schema Baseline

**Status:** Planned  
**Version:** 2  
**Workspace:** root + frontend + backend  
**Figma:** None  
**Depends on:** V2-01  

## Goal

Turn the approved semantic contract into an executable Version 2 compatibility baseline shared by frontend and backend.

## In Scope

- Assign initial MAJOR.MINOR versions to SQLite schema, PostgreSQL schema and sync/API contract.
- Define concrete payloads for words, groups, review statistics, synced learning settings and tombstones.
- Define common event envelope, timestamp encoding and compatibility behavior.
- Create shared fixtures/tests used by both repositories.

## Out of Scope

- Changing approved LWW semantics
- Selecting deferred retry/retention/timestamp tolerance constants
- Mirroring SQLite and PostgreSQL schemas table-for-table

## Epic Acceptance Criteria

- [ ] Contract fixtures represent every Version 2 synced entity and operation.
- [ ] Create/update fixtures contain full entity state and delete fixtures contain tombstone metadata only.
- [ ] Unknown optional fields are tolerated within the same major version; unknown required semantics fail explicitly.
- [ ] Frontend and backend validate against the same root-owned semantic fixtures.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-02-01](./V2-02-01-establish-version-2-version-identifiers.md) | Establish Version 2 version identifiers | root | 1 | V2-01-02 |
| [V2-02-02](./V2-02-02-define-word-and-group-contract-fixtures.md) | Define word and group contract fixtures | root | 2 | V2-02-01 |
| [V2-02-03](./V2-02-03-define-review-settings-and-tombstone-fixtures.md) | Define review, settings and tombstone fixtures | root | 2 | V2-02-01 |
| [V2-02-04](./V2-02-04-implement-contract-compatibility-tests.md) | Implement contract compatibility tests | root + frontend + backend | 2 | V2-02-02,V2-02-03 |

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
