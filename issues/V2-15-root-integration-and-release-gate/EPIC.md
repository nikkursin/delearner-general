# V2-15 — Root Integration and Release Gate

**Status:** In Progress
**Version:** 2  
**Workspace:** root + frontend + backend  
**Figma:** Verification only against approved Version 2 Figma flows  
**Depends on:** V2-01 through V2-14  

## Goal

Make Version 2 completion objectively testable against pinned frontend/backend revisions and the canonical root acceptance criteria.

## In Scope

- Run shared contract and child test suites from root.
- Verify authentication/account isolation and device lifecycle.
- Verify two-device push/pull/offline/conflict/bootstrap/rebootstrap behavior.
- Run free-core regression tests and publish a root release checklist/gate.

## Out of Scope

- Version 3 redesign work
- Payments/premium
- Relaxing failed acceptance criteria to ship

## Epic Acceptance Criteria

- [ ] Pinned child revisions pass frontend, backend and feasible root integration suites.
- [ ] Critical multi-device scenarios pass from a clean environment.
- [ ] Existing free-core regression suite remains green.
- [ ] Version 2 cannot be marked complete while a root acceptance criterion is failing.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-15-01](./V2-15-01-create-root-contract-and-environment-smoke-gate.md) | Create root contract and environment smoke gate | root | 2 | V2-02-04,V2-01-04 |
| [V2-15-02](./V2-15-02-add-authentication-isolation-and-device-lifecycle-scenarios.md) | Add authentication isolation and device lifecycle scenarios | root | 2 | V2-06-04,V2-13-04 |
| [V2-15-03](./V2-15-03-add-two-device-sync-conflict-and-offline-reconnect-scenarios.md) | Add two-device sync, conflict and offline/reconnect scenarios | root | 2 | V2-13-04,V2-11-04 |
| [V2-15-04](./V2-15-04-add-bootstrap-rebootstrap-regression-gate-and-version-2-release-checklist.md) | Add bootstrap/rebootstrap regression gate and Version 2 release checklist | root | 2 | V2-12-04,V2-14-04,V2-15-01,V2-15-02,V2-15-03 |

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
