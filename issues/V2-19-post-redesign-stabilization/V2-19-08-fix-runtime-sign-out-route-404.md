# V2-19-08 — Fix runtime sign-out route 404

**Parent epic:** V2-19 — Post-Redesign Stabilization
**Status:** Done
**Workspace:** backend + frontend + root
**Size:** 3 story points
**Dependencies:** completed V2-19-07
**Figma requirement:** None

## Objective

Make **Sign out** revoke the presented backend session and complete the existing
safe local teardown when the app is connected to the backend runtime used by a
physical device.

Do not reopen V2-19-07. This is a regression task for a runtime HTTP route that
was not exercised by its direct-handler coverage.

## Confirmed evidence

The iPad frontend reached the intended request path:

```text
session_revocation_started request_id=fdbb366c-5f25-4bdb-a679-108243c65a73
http_request_started method=POST route=/api/v1/auth/sign-out request_id=fdbb366c-5f25-4bdb-a679-108243c65a73
http_request_finished method=POST phase=session_revocation request_id=fdbb366c-5f25-4bdb-a679-108243c65a73 status=404 network_error=203 backend_code=not_found duration_ms=30
session_revocation_failure request_id=fdbb366c-5f25-4bdb-a679-108243c65a73 status=404 network_error=203 backend_code=not_found
```

Current checked-in code has matching paths:

- frontend posts `/api/v1/auth/sign-out`;
- backend `DLAuthHandler::registerRoutes()` registers
  `/api/v1/auth/sign-out`;
- root `tests/authentication_http_regression.py` expects that route to return
  HTTP 200 and revoke only the presented session.

Therefore the 404 proves that the runtime reached by the iPad did not expose
the checked-in route. It does not yet prove whether the cause is a stale
backend binary, the wrong build/run target, missing handler registration in the
served process, or an intermediary routing mismatch.

## Required investigation loop

Before changing behavior, create or isolate a fast red-capable HTTP test that:

1. starts the same backend application/binary used for device development;
2. registers and signs in a disposable test account;
3. sends `POST /api/v1/auth/sign-out` with the presented bearer session;
4. fails specifically on HTTP 404;
5. proves the revoked session fails and a second session remains valid.

The test must traverse `DLBackendApplication` and the real `QHttpServer` route,
not call `DLAuthHandler::handleSignOut()` directly. Record the backend revision,
binary/build directory and API origin used by the test without logging secrets.

## Fix scope

- Identify the exact process/build serving the physical-device API origin.
- Fix the smallest confirmed route-registration, build, deployment or local
  run-orchestration cause.
- Ensure the documented development start command cannot silently serve a
  stale backend that lacks the route.
- Keep the current security behavior: HTTP 200 means the presented session was
  revoked; HTTP 401 may be treated as already rejected; HTTP 404 must not be
  treated as successful revocation.
- Preserve local account data when remote revocation fails. Successful 200/401
  handling must continue the existing safe local cleanup and return to auth.
- Keep all request diagnostics secret-safe.

## Acceptance criteria

- The new full-HTTP regression test goes red against the failing runtime shape
  and green after the fix.
- The documented backend development run path exposes
  `POST /api/v1/auth/sign-out`.
- A valid presented session receives HTTP 200 and becomes unusable immediately.
- A second session for the same account remains valid.
- An already rejected token returns the approved unauthorized result and the
  frontend may finish safe local sign-out.
- A genuine 404 or network failure leaves the local account/database intact and
  presents the existing retryable failure.
- Frontend coverage verifies that successful revocation reaches local teardown
  and the authentication screen.
- Backend, frontend and root auth regression suites pass.
- Physical-iPad verification against the refreshed backend is recorded
  separately and is not claimed from automated tests.

## Non-goals

- Redesigning Profile or authentication UI.
- Treating every backend failure as successful sign-out.
- Revoking other device sessions.
- Account deletion or account switching changes.

## Completion checkpoint — 2026-11-10

- Reproduced the reported failure against the device-development Compose
  runtime with
  `DELEARNER_SKIP_BACKEND_START=1 tests/sign_out_http_runtime_regression.sh`:
  registration and sign-in succeeded, then the real
  `POST /api/v1/auth/sign-out` returned HTTP 404.
- Confirmed the exact cause: the running image was created at 02:49, before
  backend commit `c43249e` added the route at 07:36. The checked-out handler
  and route were correct; the physical-device API origin was serving a stale
  `/app/de_backend` image.
- Added `scripts/run-backend-dev.sh` as the documented development start path.
  It rebuilds and force-recreates Compose, stamps and verifies the backend Git
  revision, waits for health, and requires the real sign-out POST to return
  HTTP 401 without a bearer session rather than 404.
- Added `tests/sign_out_http_runtime_regression.sh`, which starts that same
  `DLBackendApplication`/`QHttpServer` runtime and records revision, build
  directory, binary, image and API origin before running the live auth matrix.
- Final committed-runtime evidence used backend revision `1fe5487`, build
  directory `/app/build`, binary `/app/de_backend`, image
  `sha256:56ef7bdd852add4863ed1079c22dbd94230860ac9687c1752f23f74174be5b06`
  and API origin `http://127.0.0.1:8080`. The route probe returned 401; live
  sign-out returned 200; the revoked token returned 401; the second session
  remained valid; all 17 correlated HTTP checks passed.
- Added frontend coverage proving both HTTP 404 and connection failure retain
  the SQLite database, local group data, saved session and retryable error.
  Existing successful 200/401 teardown behavior remains unchanged.
- Verification passed: Docker backend CTest 12/12; local backend CTest 14/14;
  focused frontend CTest 4/4; `./scripts/test-all.sh root`; and the final
  served full-HTTP regression matrix.
- Physical-iPad verification against the refreshed backend remains a separate
  human check and is not claimed by these automated results.
