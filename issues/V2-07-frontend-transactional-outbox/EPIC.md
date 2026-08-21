# V2-07 — Frontend Transactional Outbox

**Status:** Planned  
**Version:** 2  
**Workspace:** frontend  
**Figma:** None  
**Depends on:** V2-02,V2-03,V2-06  

## Goal

Guarantee that every committed local syncable mutation has a durable retryable synchronization event in the same SQLite transaction.

## In Scope

- Add durable outbox and short acknowledged-history storage.
- Generate stable UUID eventId values and contract-compatible event envelopes.
- Integrate local domain mutations with atomic outbox writes.
- Implement acknowledgement/retry state without deleting events on send.

## Out of Scope

- Network scheduling
- Backend processing
- Permanent local event archive

## Epic Acceptance Criteria

- [ ] Local domain mutation and outbox event succeed/fail atomically.
- [ ] Retry reuses the same eventId.
- [ ] Active outbox removes/marks an event complete only after backend acknowledgement.
- [ ] Acknowledged diagnostic history is bounded/configurable rather than permanent.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-07-01](./V2-07-01-add-outbox-and-diagnostic-history-sqlite-schema.md) | Add outbox and diagnostic-history SQLite schema | frontend | 2 | V2-03-01,V2-02-04 |
| [V2-07-02](./V2-07-02-create-contract-event-serialization-layer.md) | Create contract event serialization layer | frontend | 2 | V2-07-01,V2-02-02,V2-02-03 |
| [V2-07-03](./V2-07-03-make-domain-mutation-plus-outbox-write-atomic.md) | Make domain mutation plus outbox write atomic | frontend | 2 | V2-07-02,V2-03-04,V2-05-04,V2-06-03 |
| [V2-07-04](./V2-07-04-implement-acknowledgement-retry-state-and-bounded-history-transition.md) | Implement acknowledgement, retry state and bounded history transition | frontend | 2 | V2-07-01,V2-07-03 |

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
