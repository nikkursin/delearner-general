# V2-06 — Device Registration and Lifecycle

**Status:** Done
**Version:** 2  
**Workspace:** backend + frontend + root  
**Figma:** None in this epic; no device-management UI is required  
**Depends on:** V2-05  

## Goal

Give every authenticated installation a stable backend-tracked device identity and lifecycle suitable for multi-device synchronization.

## In Scope

- Persist registered devices per user.
- Register/resolve the client device after authentication.
- Persist device sync cursor/state.
- Support revocation and reject revoked-device uploads.

## Out of Scope

- Hard-coded plan device limits
- Rich device-management UI unless required by a later concrete issue
- Sharing devices between accounts

## Epic Acceptance Criteria

- [x] One account can register multiple devices.
- [x] Each device has stable UUID identity and persisted cursor state.
- [x] Revoked device authorization cannot continue uploading.
- [x] Exact device-count policy remains configurable/deferred.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-06-01](./V2-06-01-add-backend-registered-device-model.md) | Add backend registered-device model | backend | 2 | V2-05-03,V2-04-01 |
| [V2-06-02](./V2-06-02-implement-authenticated-device-register-resolve-api.md) | Implement authenticated device register/resolve API | backend | 2 | V2-06-01 |
| [V2-06-03](./V2-06-03-persist-and-attach-client-device-identity.md) | Persist and attach client device identity | frontend | 1 | V2-06-02,V2-05-04 |
| [V2-06-04](./V2-06-04-implement-device-revocation-enforcement.md) | Implement device revocation enforcement | backend + root | 2 | V2-06-02 |

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
