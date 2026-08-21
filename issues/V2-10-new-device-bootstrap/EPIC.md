# V2-10 — New-Device Bootstrap

**Status:** Planned  
**Version:** 2  
**Workspace:** backend + frontend + root  
**Figma:** No Figma before V2-14; use minimal functional startup states only  
**Depends on:** V2-05,V2-06,V2-09  

## Goal

Reconstruct supported current user state on a newly authenticated device without missing changes that occur during bootstrap.

## In Scope

- Produce a consistent authenticated current-state export from PostgreSQL.
- Associate the export with a matching server sequence.
- Initialize/rebuild local SQLite from that state.
- Pull changes occurring after the bootstrap sequence and transition to incremental sync.

## Out of Scope

- Permanent snapshot files
- Migrating pre-release local data
- Raw quiz history bootstrap

## Epic Acceptance Criteria

- [ ] New device reconstructs all Version 2 supported personal state.
- [ ] Changes created during bootstrap are not missed.
- [ ] Bootstrap ends with a valid incremental cursor.
- [ ] No permanent server snapshot artifact is required.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-10-01](./V2-10-01-implement-consistent-bootstrap-state-export.md) | Implement consistent bootstrap state export | backend | 2 | V2-09-01,V2-04-03 |
| [V2-10-02](./V2-10-02-implement-client-bootstrap-database-restore.md) | Implement client bootstrap database restore | frontend | 2 | V2-10-01,V2-03-01 |
| [V2-10-03](./V2-10-03-catch-up-events-after-bootstrap-sequence.md) | Catch up events after bootstrap sequence | frontend + backend | 2 | V2-10-01,V2-10-02,V2-09-04 |
| [V2-10-04](./V2-10-04-integrate-sign-in-to-bootstrap-startup-transition.md) | Integrate sign-in-to-bootstrap startup transition | frontend + root | 2 | V2-05-04,V2-06-03,V2-10-03 |

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
