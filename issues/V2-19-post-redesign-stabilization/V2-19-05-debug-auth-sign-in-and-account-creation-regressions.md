# V2-19-05 — Debug sign-in and account-creation regressions

**Parent epic:** V2-19 — Post-Redesign Stabilization  
**Status:** Blocked
**Workspace:** frontend + backend + root  
**Size:** 5 story points  
**Dependencies:** completed authentication/sync baseline, completed V2-17-05

## Objective

Identify and fix the functional regressions that prevent reliable sign-in to an existing account and reliable creation of a new account.

## Observed symptoms

- Existing-account sign-in can reach: `Could not prepare your vocabulary. Check your connection and sign in to try again.`
- Creating an account may report that the email/account cannot be created or fail with a generic account-creation error.

## Investigation order

1. Inspect the current frontend authentication state machine, session handling, bootstrap path and error mapping.
2. Inspect backend registration/sign-in handlers, database constraints, transaction boundaries and returned status/error bodies.
3. Inspect V2-17-05 and related regression tests to determine why the pre-existing-local-vocabulary/bootstrap path still fails.
4. Reproduce with automated/integration tests where possible:
   - successful new-account registration;
   - duplicate-email registration;
   - successful existing-account sign-in;
   - sign-in with existing local vocabulary;
   - bootstrap with empty local database;
   - invalid credentials;
   - network/backend failure after authentication.
5. Only if code/tests cannot isolate the problem, ask the user for runtime logs with exact capture instructions.

## Log-request rule if needed

Do not ask vaguely for "the logs." Specify:

- which frontend process/device;
- which backend process/container;
- the exact action to reproduce;
- the timestamp/window to capture;
- the expected endpoint/status information to include.

Never request passwords, session tokens, authorization headers or other secrets. If logging currently prints them, redact them before sharing.

## Fix requirements

- Distinguish authentication failure from post-auth bootstrap/sync failure.
- Existing-account sign-in must not fail merely because local vocabulary already exists.
- Duplicate account/email cases must return a specific, actionable result rather than a generic creation failure.
- Generic server/network failures must remain distinguishable from validation/duplicate-account errors.
- Preserve offline-after-initial-auth behavior.
- Do not redesign the login page in this task.

## Current reference

See `references/V2-19-05/`.

## Acceptance criteria

- New-account registration succeeds for a valid unused account.
- Duplicate registration has deterministic behavior and clear error mapping.
- Existing valid account can sign in and bootstrap/reconcile without losing pending/local vocabulary.
- Relevant frontend/backend automated tests cover the reproduced root cause.
- No credentials/secrets are added to logs.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.

## Investigation checkpoint — 2026-09-19

This task is **not Done**. A reproducible error-mapping defect is fixed, but the reported runtime bootstrap failure has not been reproduced against the current checkout. Runtime evidence from the affected installation is required before claiming the acceptance criteria are satisfied.

### Confirmed defect and changes

- Authentication credential/user lookup failures were treated as invalid credentials or continued into registration. Database errors from registration/session creation were returned as HTTP 400. A failing backend regression test demonstrated `BadRequest` where `InternalServerError` was required.
- Lookup failures now remain database errors, and the auth handler returns HTTP 500 with a safe generic message instead of SQL details. Tests cover credential lookup, user lookup, session-write failures, duplicate normalized email, registration and existing-account sign-in.
- The frontend explicitly identifies duplicate email and says authentication succeeded when subsequent bootstrap fails. Registration now shares the fresh-bootstrap test coverage with sign-in; existing populated-local-vocabulary and offline-access regression tests still pass.
- `tests/authentication_http_regression.py --base-url <disposable-backend-url>` exercises real HTTP registration, normalized duplicate email, invalid credentials, sign-in, device registration, empty bootstrap, fixture-based vocabulary upload, populated bootstrap and incremental pull. It creates test accounts/data and must only target a disposable database; it never prints credentials or authorization headers.

### Verification performed

- Built frontend and backend with `cmake --build build/delearner-frontend -j4` and `cmake --build build/delearner-backend -j4`.
- `ctest --test-dir build/delearner-backend --output-on-failure`: 13/13 passed. Expanded `build/delearner-backend/tests/test_auth_service`: 9 test results passed.
- `ctest --test-dir build/delearner-frontend --output-on-failure`: all 18 C++ suites passed, including auth/bootstrap, existing local vocabulary, offline access, reconciliation and outbox tests. Seven QML suites were killed before test startup by the local runner; no QML tests are claimed to pass.
- `./scripts/test-all.sh root`: passed, including canonical fixture checks.
- `tests/domain_relationship_tombstone_matrix.sh --auth-only`: passed.
- Built the current backend in the existing Linux builder image; all 11 configured Linux backend suites passed.
- `python3 tests/authentication_http_regression.py --base-url http://127.0.0.1:18089`: passed against that backend and a separate disposable PostgreSQL database. Both empty and populated bootstrap succeeded. Test container/database were removed afterward.
- The native Qt installation has only a usable SQLite driver; a Linux cross-repo harness attempt also hit its older Qt's missing `QSqlQuery::boundValueNames`. Neither limitation is presented as an application failure. PostgreSQL HTTP testing used the Linux backend instead.

### Evidence needed to unblock

On the affected frontend process/device, reproduce one existing-account sign-in failure and record the timestamp and platform/build. Capture Qt Creator Application Output for that minute and, for a Docker backend, run `docker compose logs --since 2m backend` immediately afterward. Record endpoint/status/error-code results for `POST /api/v1/auth/sign-in`, `POST /api/v1/devices/register`, `GET /bootstrap`, and `GET /events` if available. If they are not logged, say which endpoint results are available instead of guessing. Also state whether the failure reproduces with this checkout and whether local vocabulary already existed.

Never include passwords, session tokens, authorization headers, personal vocabulary or other secrets. Do not erase local data to obtain a reproduction. The seven QML suites also require a functioning Qt Quick test runner before the full frontend suite can be declared passing.
