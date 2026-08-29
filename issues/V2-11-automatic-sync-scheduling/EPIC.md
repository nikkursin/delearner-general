# V2-11 — Automatic Sync Scheduling

**Status:** Done
**Version:** 2  
**Workspace:** frontend  
**Figma:** No Figma before V2-14; minimal functional status states only  
**Depends on:** V2-07,V2-09,V2-10  

## Goal

Run synchronization automatically and conservatively at the moments already approved by product behavior.

## In Scope

- Centralize sync coordination.
- Trigger on active+connected, app resume and connectivity restoration.
- Drain queued local work and pull remote work without constant polling.
- Provide a manual diagnostic/fallback trigger only if useful.

## Out of Scope

- Aggressive background polling
- Premium/background-cloud behavior
- New sync semantics

## Epic Acceptance Criteria

- [x] Ordinary users do not need to manually sync.
- [x] Offline changes remain immediate and queued.
- [x] Reconnect/resume eventually pushes pending work and pulls remote changes.
- [x] Concurrent triggers do not launch conflicting sync cycles.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-11-01](./V2-11-01-create-single-client-sync-coordinator.md) | Create single client sync coordinator | frontend | 2 | V2-07-04,V2-09-04 |
| [V2-11-02](./V2-11-02-trigger-sync-while-active-and-connected.md) | Trigger sync while active and connected | frontend | 1 | V2-11-01 |
| [V2-11-03](./V2-11-03-trigger-sync-on-resume-and-network-restoration.md) | Trigger sync on resume and network restoration | frontend | 1 | V2-11-01 |
| [V2-11-04](./V2-11-04-add-manual-diagnostic-sync-entry-point-and-scheduling-tests.md) | Add manual diagnostic sync entry point and scheduling tests | frontend | 1 | V2-11-02,V2-11-03 |

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
