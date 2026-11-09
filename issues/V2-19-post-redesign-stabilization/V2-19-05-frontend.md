# V2-19-05B — Frontend auth/sync diagnostics and startup reliability

**Parent:** V2-19-05
**Status:** Planned
**Workspace:** frontend
**Dependencies:** V2-19-05A

## Objective

Make every frontend auth-to-sync transition observable and preserve enough
technical failure context to locate the first failing seam, without changing
user-facing product behavior or exposing secrets.

## Scope

- Add `delearner.auth`, `delearner.network` and `delearner.sync` Qt categories.
- Add safe diagnostics to `DLClientAuthService`, `DLAppStateManager`,
  `DLSyncCoordinator` and directly related session/device/bootstrap helpers.
- Generate and propagate `X-Request-ID` per HTTP operation.
- Preserve HTTP status, Qt network error, safe backend error code and request ID
  separately from the user-facing message.
- Log each start, success, skip and failure transition required by the parent.
- Add focused message-capture and secret-redaction tests.
- Fix a frontend auth/device/bootstrap/sync defect only when a new failing
  focused test proves it and the fix remains local to this subtask.

## Rules

- Never log passwords, session tokens, authorization values, raw auth bodies,
  full auth responses, session-file contents or personal vocabulary.
- Do not make logging synchronous or block the UI thread.
- Do not change bootstrap, outbox, reconciliation or offline-access semantics.
- Do not redesign QML authentication screens.

## Acceptance criteria

- One auth/bootstrap/sync attempt can be traced by request ID and phase.
- Device-registration failures retain status, network error and safe backend
  error code instead of collapsing immediately to a generic message.
- All early exits in the auth-to-sync state machine produce a terminal log.
- Tests prove representative supplied secrets do not appear in captured logs.
- Existing frontend auth/bootstrap/sync tests pass.
