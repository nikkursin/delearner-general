# V2-17-04 — Complete sync/bootstrap/reconciliation coverage

**Parent epic:** V2-17 — Word/Group Domain and Sync Evolution  
**Status:** Ready
**Workspace:** frontend + backend + root  
**Size:** 5 story points  
**Dependencies:** V2-17-02, V2-17-03

## Objective

Carry the new Word/Group state through push, canonical mutation results, incremental pull, new-device bootstrap and local reconciliation.

## Scope

- Push full Word state including the finalized membership set and new fields.
- Return canonical membership/field state in mutation results.
- Incremental pull applies membership and field changes deterministically.
- New-device bootstrap reconstructs the same Word/Group relationships and values.
- Stale-device re-bootstrap preserves pending outbox work under the existing recovery model.
- Backend remains authoritative for conflicts; do not add client-side merge policies for membership arrays.
- Existing last-modification-wins behavior continues at the entity level unless the canonical contract explicitly says otherwise.

## Acceptance criteria

- Two-device create/edit/group-membership changes converge to canonical state.
- Four memberships survive bootstrap and incremental sync.
- Group deletion propagates without deleting the word.
- New morphology/icon/memo/literal-translation fields survive push/pull/bootstrap.
- Repeated event delivery remains idempotent.
- Pending unsynced local work is not silently lost during stale-device recovery.
