# V2-19-08 — Fix runtime sign-out route 404

**Parent epic:** V2-19 — Post-Redesign Stabilization
**Status:** Planned
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
