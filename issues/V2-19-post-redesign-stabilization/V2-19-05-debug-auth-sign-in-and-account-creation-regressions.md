# V2-19-05 — Stabilize auth-to-sync startup and add end-to-end diagnostics

**Parent epic:** V2-19 — Post-Redesign Stabilization
**Status:** In Progress — execute its child subtasks first
**Workspace:** frontend + backend + root
**Size:** 8 story points
**Dependencies:** completed authentication/sync baseline, completed V2-17-05
**Does not depend on:** V2-18-06 or any V2-19 UI task

## Objective

Make account creation and existing-account sign-in reliably complete the whole
startup sequence:

```text
authenticate
→ register/resolve device
→ bootstrap current canonical state
→ preserve/replay pending local work
→ complete incremental synchronization
→ enter the offline-capable free core
```

Instrument this sequence first so every state transition and terminal outcome
can be correlated across frontend and backend without exposing credentials or
personal vocabulary.

## Observed symptoms

- Existing-account sign-in can reach: `Could not prepare your vocabulary. Check
  your connection and sign in to try again.`
- Creating an account may report that the email/account cannot be created or
  fail with a generic account-creation error.
- Current generic messages do not reveal whether failure occurred during
  authentication, device registration, bootstrap, local restore, outbox replay
  or incremental pull.

## Known observability gap

- Frontend auth and sync code currently emits no Qt category logs.
- Device-registration failures discard useful HTTP/network diagnostics.
- Backend auth, device and event handlers emit no request/result logs.
- There is no shared request/correlation ID between client and backend.
- Existing sync-outbox diagnostic rows are persistence diagnostics, not an
  operational auth/sync log.
- The backend only logs startup/database initialization; the legacy root-level
  `delearner-backend/backend.cpp` is not part of the compiled target.

## Child subtasks

- **A — Done:** [Backend request and auth/sync operation tracing](./V2-19-05-backend.md)
- **B — Done:** [Frontend instrumentation and auth/sync state tracing](./V2-19-05-frontend.md)
- **C — Planned after A and B:** [Correlated reproduction, fixes and integration verification](./V2-19-05-integration.md)

The parent task owns end-to-end reproduction, integration tests, final
acceptance and the evidence checkpoint. Child subtasks may add stricter local
criteria but cannot weaken this issue.

Ralph/AFK execution must complete A, then B, then C. Keep this parent task
`In Progress` after A or B. Mark it `Done` only after C satisfies the parent
acceptance criteria and records final cross-repository evidence.

## Required execution sequence

### Phase 0 — Establish the baseline

1. Record the current root, frontend and backend revisions and working-tree
   state without modifying unrelated changes.
2. Run the smallest existing auth/bootstrap frontend tests, backend auth/device
   tests and root auth contract tests.
3. Record which symptom is reproducible before changing behavior.
4. Do not erase the affected local SQLite database or pending outbox work to
   simplify reproduction.

### Phase 1 — Add diagnostics before behavioral fixes

1. Add frontend Qt logging categories for at least auth, network and sync.
2. Add backend Qt logging categories for at least HTTP, auth, device, sync and
   database operations.
3. Generate a correlation/request ID for each frontend HTTP operation, send it
   in `X-Request-ID`, and have the backend echo and log it. If an external
   request has no valid ID, the backend generates one.
4. Add a configurable Qt message pattern for development capture with timestamp,
   severity, category, source location and message.
5. Ensure all early-return/failure branches in the auth-to-sync sequence emit a
   terminal diagnostic event.
6. Add tests that capture representative Qt messages and prove supplied
   passwords, tokens and authorization values never appear.

The correlation header is diagnostic metadata. It must not change contract
versioning or endpoint semantics.

### Phase 2 — Trace and reproduce the complete path

Reproduce and correlate each case through frontend and backend logs:

1. successful new-account registration;
2. normalized duplicate-email registration;
3. successful existing-account sign-in;
4. invalid credentials;
5. device registration success and rejection;
6. empty-local-database bootstrap;
7. existing local vocabulary plus pending outbox work;
8. bootstrap response parse/restore failure;
9. upload acceptance/rejection;
10. incremental pull and cursor acknowledgement;
11. stale-cursor rebootstrap and pending-work replay;
12. network/backend failure after authentication.

Each reproduction must identify the first failing seam, not merely the final
user-facing message.

### Phase 3 — Fix verified root causes

- Fix only behavior demonstrated by a failing test or correlated reproduction.
- Distinguish authentication failure from device-registration,
  bootstrap/restore and later synchronization failure.
- Existing-account sign-in must not discard or overwrite local vocabulary or
  pending outbox work.
- Duplicate account/email behavior must remain deterministic and actionable.
- Preserve backend-owned conflict resolution and all current contract semantics.
- Keep the login screen design unchanged.

### Phase 4 — Verify and close

1. Run focused frontend/backend tests after each local fix.
2. Run the root auth behavior and integration gates.
3. Run the disposable PostgreSQL HTTP regression suite.
4. Reproduce on the affected platform/build when available, with frontend and
   backend logs from the same correlation IDs.
5. Run the broader relevant test suites before marking Done.
6. Append a final evidence checkpoint listing exact results and any environment
   limitations.

Absence of logs from the originally affected installation does not block
starting this task. It may block claiming that a device-specific symptom is
fully verified if the symptom cannot be reproduced elsewhere.

## Mandatory runtime events

The implementation must log the following logical steps. It does not need to
log every line or full payload.

### Frontend

- app/auth service initialization and sanitized API origin;
- network reachability changes;
- sign-in or registration start and terminal result;
- HTTP method, route, request ID, status, duration and Qt network error;
- auth response validation, using booleans/counts rather than token values;
- device identity load/create and registration result;
- session persistence success/failure without session contents;
- bootstrap start, response status, parse, local restore and terminal result;
- sync trigger reason and skipped-trigger reason;
- outbox pending count, upload count and accepted/rejected counts;
- pull cursor, returned event count, next cursor and `hasMore`;
- stale-cursor detection, rebootstrap and pending-event replay;
- cursor acknowledgement and final sync outcome;
- every failure with phase, stable error code and technical error text.

### Backend

- request start/completion with request ID, method, normalized route, status and
  duration;
- auth registration/sign-in result code without email/password/token values;
- bearer-auth result without logging the bearer value;
- device registration/resolve result;
- bootstrap start/completion with safe entity counts and server sequence;
- event upload batch size, authorization result, accepted/rejected counts,
  transaction outcome and server-sequence range;
- pull input cursor, output count, next cursor, `hasMore` and stale-cursor result;
- cursor-advance result;
- safe database error context with operation name and database error, but no
  connection password, bound secret value or raw payload.

## Logging levels

- `Debug`: detailed state transitions, safe identifiers, counts and cursor
  movement used during reproduction.
- `Info`: lifecycle milestones, request completion and successful phase
  summaries.
- `Warning`: rejected/recoverable operations and failures that require retry or
  user action.
- `Critical`: startup failure, transaction/invariant failure or risk of losing
  local unsynced work.

Development reproduction enables the relevant debug categories. Normal release
defaults may remain quieter, but warnings/critical failures and backend request
outcomes needed for operations must remain visible.

## Diagnostic data policy

Verbose development logs may contain routes, HTTP statuses, correlation IDs,
user/device/event UUIDs, cursor values, entity types, event/entity counts,
durations, stable error codes and technical network/database errors.

Never log:

- passwords, hashes or salts;
- session tokens or bearer/authorization header values;
- raw auth bodies or complete auth responses;
- database passwords or connection strings containing credentials;
- full email addresses;
- personal vocabulary, notes or full sync payloads;
- persisted session-file contents.

When a payload is relevant, log only its type, schema/contract version, byte
length, item count and validation result. Secret-redaction tests are mandatory.

## Acceptance criteria

- A developer can follow one request ID from frontend auth through backend
  authentication, device registration, bootstrap and first sync.
- Every logical step listed above has a start/result or skip/failure diagnostic.
- New-account registration succeeds for a valid unused account.
- Duplicate registration has deterministic behavior and a clear mapped error.
- An existing valid account can sign in and bootstrap/reconcile without losing
  local vocabulary or pending outbox work.
- Authentication failures are distinguishable from device, bootstrap, restore,
  upload, pull and cursor-acknowledgement failures.
- Frontend and backend tests cover the reproduced root causes and main failure
  mappings.
- Root HTTP/integration coverage exercises empty and populated bootstrap.
- Logs contain no password, token, authorization value, raw auth body, database
  credential or personal vocabulary supplied by the tests.
- Existing offline-after-initial-auth behavior is preserved.
- No auth, sync or shared-contract semantics changed unintentionally.

## Current reference

See `references/V2-19-05/`.

## Non-goals

- Login-page visual redesign.
- New authentication providers or account-linking behavior.
- New sync conflict, retention, retry or ownership semantics.
- Remote log ingestion, analytics or a third-party logging framework.
- Logging full request/response bodies for convenience.

## Prior investigation checkpoint — 2026-09-19

The full command/results record is preserved in
[the 2026-09-19 investigation checkpoint](./V2-19-05-prior-investigation-checkpoint.md).

This evidence remains valid and must not be discarded. It established that:

- backend credential/user lookup failures were incorrectly mapped as client
  failures and are now mapped to HTTP 500 with safe messages;
- duplicate normalized email, registration, existing-account sign-in and
  frontend fresh-bootstrap mappings have automated coverage;
- frontend C++ auth/bootstrap/reconciliation/outbox suites, backend suites,
  root auth gates and the disposable PostgreSQL HTTP regression passed in the
  recorded environment;
- seven QML suites could not start in the local runner and were not claimed as
  passing;
- the originally reported runtime bootstrap failure was not reproduced against
  that checkout.

The former runtime-evidence requirement is no longer a blocker to beginning
work. Phase 1 diagnostics are now the next executable step. Preserve all
previously fixed behavior while establishing the first currently failing seam.

## Interaction quality

- Diagnostic logging must not block the UI thread.
- Do not synchronously write large payloads or files from request callbacks.
- Authentication and bootstrap progress must remain responsive.
- Do not add unrelated visual or animation changes.
