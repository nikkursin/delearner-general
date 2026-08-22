# V2-08 — Backend Mutation Processing

**Status:** Done  
**Version:** 2  
**Workspace:** backend + root  
**Figma:** None  
**Depends on:** V2-04 plus backend auth/device prerequisites; frontend outbox is not required  

## Goal

Process pushed client mutations as authenticated, idempotent, conflict-resolved PostgreSQL transactions that return canonical results.

## In Scope

- Validate authenticated event ingestion.
- Enforce eventId idempotency and device authorization.
- Apply centralized LWW/tombstone conflict behavior with timestamp sanity hook.
- Atomically write canonical current state plus server sync event/sequence and return canonical result.

## Out of Scope

- Inventing a permanent timestamp tolerance
- Client-specific backend response tailoring
- Permanent event sourcing

## Epic Acceptance Criteria

- [x] Duplicate event delivery is safe.
- [x] Revoked/unauthorized devices cannot mutate state.
- [x] Accepted current-state mutation and sync event/sequence cannot diverge transactionally.
- [x] Response contains canonical entity state or tombstone metadata.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-08-01](./V2-08-01-implement-authenticated-event-ingestion-and-validation.md) | Implement authenticated event ingestion and validation | backend | 2 | V2-05-03,V2-06-04,V2-02-04 |
| [V2-08-02](./V2-08-02-implement-durable-eventid-idempotency.md) | Implement durable eventId idempotency | backend | 2 | V2-08-01,V2-04-04 |
| [V2-08-03](./V2-08-03-centralize-lww-and-tombstone-conflict-resolution.md) | Centralize LWW and tombstone conflict resolution | backend | 2 | V2-08-01,V2-02-03 |
| [V2-08-04](./V2-08-04-commit-canonical-mutation-sync-event-and-sequence-atomically.md) | Commit canonical mutation, sync event and sequence atomically | backend + root | 2 | V2-08-02,V2-08-03,V2-04-04 |

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
