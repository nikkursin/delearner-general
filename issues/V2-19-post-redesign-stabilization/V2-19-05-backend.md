# V2-19-05A — Backend HTTP/auth/device/sync request tracing

**Parent:** V2-19-05
**Status:** Done
**Workspace:** backend
**Dependencies:** none beyond the completed parent baselines

## Objective

Provide request-correlated operational logging for authentication, device
registration, bootstrap and synchronization while keeping the backend contract
client-independent and secret-free.

## Scope

- Add backend Qt logging categories for HTTP, auth, device, sync and database.
- Accept a valid `X-Request-ID` or generate one, echo it in the response and use
  it for all logs related to that request.
- Log request start/completion, normalized route, method, status and duration.
- Log safe operation outcomes in auth, device, bootstrap, event upload/pull and
  cursor-advance handlers.
- Add safe database-operation context for failures.
- Add focused request-correlation and secret-redaction tests.
- Fix a backend auth/device/sync defect only when a new failing focused test
  proves it and the fix remains local to this subtask.

## Rules

- Never log passwords, hashes, salts, session/bearer tokens, authorization
  values, raw auth bodies, full sync payloads, personal vocabulary or database
  credentials.
- Do not expose internal SQL details in HTTP responses.
- Do not change endpoint, ownership, transaction, conflict or sync semantics.
- Do not add client-specific response behavior beyond optional diagnostic
  request-ID propagation.

## Acceptance criteria

- Each relevant HTTP request has one correlated start/completion record.
- Auth/device/sync results include stable safe outcome/error codes.
- Event and bootstrap logs use counts and identifiers rather than payload data.
- Tests prove representative credentials and payload content do not appear in
  captured logs.
- Existing backend auth/device/event tests pass.

## Evidence checkpoint — 2026-11-09

- Phase: backend diagnostics implementation (V2-19-05A).
- Baseline revisions: root `2edba88`, frontend `6ca3413`, backend `c51cb64`.
  The pre-existing frontend `CMakeLists.txt.user` modification was left
  untouched and excluded from all commits.
- Baseline command:
  `ctest --test-dir delearner-backend/build-codex-arm64 --output-on-failure -R 'test_(auth_service|device_registration|event_characterization|sync_transaction_repository)'`
  — 4/4 passed.
- Changed backend diagnostics and handlers: `src/common/DLDiagnostics.*`,
  `src/handlers/DLAuthHandler.*`, `src/handlers/DLDeviceHandler.*`,
  `src/handlers/DLEventsCompatibilityHandler.*`, `src/main.cpp`, build files
  and backend logging documentation.
- Added live HTTP request-ID echo/validation coverage plus auth and sync log
  capture tests. The fixed test correlation IDs were
  `diagnostic-request-42`, `auth-redaction-request` and
  `sync-redaction-request`.
- Redaction assertions cover an email, password, generated session token,
  bearer authorization value and personal vocabulary payload.
- Final build/check:
  `ninja -C build-codex-arm64 -j 2 && ctest --test-dir build-codex-arm64 --output-on-failure && git diff --check`
  from `delearner-backend` — build succeeded; 14/14 tests passed, including
  both root contract-fixture checks; diff check passed.
- Backend commit: `58e65b4` (`feat(backend): V2-19-05A add correlated request tracing`).
- Conclusion: backend auth/device/bootstrap/event/cursor requests now accept or
  generate `X-Request-ID`, echo it, and emit correlated safe start/result and
  HTTP completion events. V2-19-05B is the next executable child; the parent
  remains In Progress until V2-19-05C completes integration verification.
