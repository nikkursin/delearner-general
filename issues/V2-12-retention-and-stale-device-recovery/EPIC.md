# V2-12 — Retention and Stale-Device Recovery

**Status:** Done
**Version:** 2  
**Workspace:** backend + frontend + root  
**Figma:** No Figma before V2-14; recovery behavior first, visual review later  
**Depends on:** backend pull/bootstrap for V2-12-01/02; client scheduling/bootstrap for V2-12-03/04  

## Goal

Bound server event history while allowing stale devices to recover automatically without silently discarding offline work.

## In Scope

- Implement cursor-aware retention inputs and configurable maximum history window.
- Detect cursors older than retained history.
- Attempt incremental recovery first, then signal fresh bootstrap when impossible.
- Preserve pending local outbox across re-bootstrap and replay it through normal conflict rules.

## Out of Scope

- Hard-coding the final retention duration
- Manual database reset as normal recovery
- Deleting unsynced local work

## Epic Acceptance Criteria

- [x] Abandoned devices cannot force infinite event retention.
- [x] Stale device recovers automatically through re-bootstrap when needed.
- [x] Pending local outbox survives re-bootstrap.
- [x] Replayed local events are resolved by normal backend LWW/idempotency behavior.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-12-01](./V2-12-01-implement-cursor-aware-retention-boundary-and-configurable-max-window.md) | Implement cursor-aware retention boundary and configurable max window | backend | 2 | V2-09-02,V2-10-01 |
| [V2-12-02](./V2-12-02-detect-stale-cursor-and-return-recoverable-protocol-result.md) | Detect stale cursor and return recoverable protocol result | backend + root | 2 | V2-12-01,V2-09-01 |
| [V2-12-03](./V2-12-03-preserve-pending-outbox-during-client-re-bootstrap.md) | Preserve pending outbox during client re-bootstrap | frontend | 2 | V2-12-02,V2-10-02 |
| [V2-12-03A](./V2-12-03A%20%E2%80%94%20Route%20live%20mutations%20through%20canonical%20conflict%20resolution.md) | Route live mutations through canonical conflict resolution | backend + root | 2 | V2-08-04,V2-10-03 |
| [V2-12-04](./V2-12-04-replay-preserved-mutations-and-verify-convergence.md) | Replay preserved mutations and verify convergence | frontend + backend + root | 2 | V2-12-03,V2-12-03A,V2-08-04,V2-10-03 |

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
