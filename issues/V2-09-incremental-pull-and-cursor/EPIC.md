# V2-09 — Incremental Pull and Cursor

**Status:** Planned  
**Version:** 2  
**Workspace:** backend + frontend + root  
**Figma:** None  
**Depends on:** V2-08,V2-06  

## Goal

Allow devices to retrieve and safely apply ordered changes after their last successfully consumed server sequence.

## In Scope

- Expose ordered changes-after-cursor retrieval.
- Persist per-device cursor.
- Apply remote changes through a client reconciliation path.
- Advance cursor only after successful local application and make replay safe.

## Out of Scope

- Full bootstrap
- Retention cleanup
- Aggressive polling

## Epic Acceptance Criteria

- [ ] Device B receives Device A changes after its cursor.
- [ ] Repeating a pull from the same cursor is safe.
- [ ] Failed local application does not advance past the failed event.
- [ ] Normal convergence does not require full bootstrap.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-09-01](./V2-09-01-implement-ordered-changes-after-cursor-backend-query.md) | Implement ordered changes-after-cursor backend query | backend | 2 | V2-08-04,V2-06-01 |
| [V2-09-02](./V2-09-02-persist-device-cursor-advancement-server-side.md) | Persist device cursor advancement server-side | backend | 1 | V2-09-01 |
| [V2-09-03](./V2-09-03-implement-client-remote-change-reconciliation.md) | Implement client remote-change reconciliation | frontend | 2 | V2-09-01,V2-08-04 |
| [V2-09-04](./V2-09-04-advance-cursor-only-after-successful-apply.md) | Advance cursor only after successful apply | frontend + root | 2 | V2-09-02,V2-09-03 |

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
