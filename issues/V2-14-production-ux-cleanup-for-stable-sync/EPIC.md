# V2-14 — Production UX Cleanup for Stable Sync

**Status:** Done
**Version:** 2  
**Workspace:** Figma + frontend + root  
**Figma:** Design/review required for meaningful new auth/sync/recovery states  
**Depends on:** functional auth/sync/recovery/domain coverage complete  

## Goal

Expose only the minimal user-facing authentication and synchronization states needed for a production-usable Version 2, without pulling the Version 3 redesign forward.

## In Scope

- Review/design minimal sync status/error/recovery states in Figma.
- Implement unobtrusive auth/sync status and recoverable errors.
- Remove/hide manual .devocab import/export from normal production UI after sync is proven stable.
- Keep internal import/export capability testable for diagnostics/migration verification.

## Out of Scope

- Redesigning Words/Groups/Quiz screens
- Premium/paywall UI
- Sharing UI
- Making manual sync the primary workflow

## Epic Acceptance Criteria

- [x] User can understand required sign-in and meaningful sync failures without managing normal sync manually.
- [x] Stale re-bootstrap is normally automatic and does not present a manual reset workflow.
- [x] File import/export is no longer presented as normal production synchronization.
- [x] Internal import/export code remains covered for test/debug uses.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-14-01](./V2-14-01-review-minimal-auth-sync-and-recovery-ux-in-figma.md) | Review minimal auth, sync and recovery UX in Figma | Figma + root | 1 | V2-05-04,V2-11-04,V2-12-04,V2-13-04 |
| [V2-14-02](./V2-14-02-implement-minimal-sync-status-error-presentation.md) | Implement minimal sync status/error presentation | frontend | 2 | V2-14-01,V2-11-01,V2-12-04 |
| [V2-14-03](./V2-14-03-hide-production-import-export-synchronization-ui.md) | Hide production import/export synchronization UI | frontend | 1 | V2-13-04 |
| [V2-14-04](./V2-14-04-retain-and-test-internal-import-export-capability.md) | Retain and test internal import/export capability | frontend + root | 1 | V2-14-03 |

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
