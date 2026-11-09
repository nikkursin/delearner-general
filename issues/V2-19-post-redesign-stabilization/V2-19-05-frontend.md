# V2-19-05B — Frontend auth/sync diagnostics and startup reliability

**Parent:** V2-19-05
**Status:** Done
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

## Evidence checkpoint — 2026-11-09

- Phase: frontend diagnostics implementation (V2-19-05B).
- Baseline revisions: root `9a4e067`, frontend `6ca3413`, backend `58e65b4`.
  The pre-existing frontend `CMakeLists.txt.user` modification was left
  untouched and excluded from all commits.
- Baseline command:
  `ctest --test-dir build-tests --output-on-failure -R 'Test(AppStateAuthBootstrap|DeviceIdentityAndSyncContext|SyncCoordinator|BootstrapStateRestorer|AuthSessionStore)$'`
  from `delearner-frontend` — 5/5 passed. No external runtime account or
  affected-device environment was available in this child task, so the
  originally reported production symptom was not claimed as reproduced.
- Added `delearner.auth`, `delearner.network` and `delearner.sync` categories,
  configurable message formatting, per-operation `X-Request-ID` generation,
  request timing and safe backend error-code extraction.
- Instrumented auth, device registration, session persistence, startup,
  bootstrap/restore, outbox upload, pull/reconciliation, stale-cursor replay,
  cursor acknowledgement, reachability and sync-trigger outcomes. HTTP status,
  Qt network error, safe backend code, request ID and technical network error
  remain separately available after auth/device failures.
- Added message-capture coverage proving that supplied email/password/session
  token/authorization values and backend-supplied personal vocabulary text do
  not appear in auth or sync logs. Tests also verify distinct valid request IDs
  for auth/device operations and request IDs on sync requests.
- Focused build/check:
  `cmake --build build-tests --target TestDeviceIdentityAndSyncContext TestSyncCoordinator TestAppStateAuthBootstrap -j4 && ctest --test-dir build-tests --output-on-failure -R 'Test(DeviceIdentityAndSyncContext|SyncCoordinator|AppStateAuthBootstrap)$'`
  — build succeeded; 3/3 passed.
- Broader check: `ctest --test-dir build-tests --output-on-failure -E 'Ui$'`
  — 17/17 frontend C++ and root contract-fixture tests passed. No QML files
  changed in this subtask.
- Frontend commit: `e7c58b1` (`feat(frontend): V2-19-05B add auth sync diagnostics`).
- Conclusion: the frontend auth-to-sync path now emits correlated, secret-free
  operational diagnostics and preserves device-registration failure context.
  V2-19-05C is the next executable child; the parent remains In Progress until
  correlated reproduction and integration verification complete.
