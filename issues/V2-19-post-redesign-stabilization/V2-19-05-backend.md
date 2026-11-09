# V2-19-05A — Backend HTTP/auth/device/sync request tracing

**Parent:** V2-19-05
**Status:** Ready
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
