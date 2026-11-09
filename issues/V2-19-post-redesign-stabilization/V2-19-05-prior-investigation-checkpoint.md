# V2-19-05 prior investigation checkpoint — 2026-09-19

This is the detailed evidence captured before V2-19-05 was reprioritized and
expanded with mandatory end-to-end diagnostics on 2026-11-09. It is historical
evidence, not the current task status.

## Status at the checkpoint

The task was not Done. A reproducible error-mapping defect was fixed, but the
reported runtime bootstrap failure had not been reproduced against that
checkout. Runtime evidence from the affected installation was still required
before claiming the original acceptance criteria were satisfied.

## Confirmed defect and changes

- Authentication credential/user lookup failures were treated as invalid
  credentials or continued into registration. Database errors from
  registration/session creation were returned as HTTP 400. A failing backend
  regression test demonstrated `BadRequest` where `InternalServerError` was
  required.
- Lookup failures were changed to remain database errors, and the auth handler
  returned HTTP 500 with a safe generic message instead of SQL details. Tests
  covered credential lookup, user lookup, session-write failures, duplicate
  normalized email, registration and existing-account sign-in.
- The frontend explicitly identified duplicate email and said authentication
  succeeded when subsequent bootstrap failed. Registration shared the fresh
  bootstrap test coverage with sign-in; existing populated-local-vocabulary
  and offline-access regression tests still passed.
- `tests/authentication_http_regression.py --base-url <disposable-backend-url>`
  exercised real HTTP registration, normalized duplicate email, invalid
  credentials, sign-in, device registration, empty bootstrap, fixture-based
  vocabulary upload, populated bootstrap and incremental pull. It created test
  accounts/data and was restricted to a disposable database; it did not print
  credentials or authorization headers.

## Verification performed

- Built frontend and backend with
  `cmake --build build/delearner-frontend -j4` and
  `cmake --build build/delearner-backend -j4`.
- `ctest --test-dir build/delearner-backend --output-on-failure`: 13/13 passed.
  Expanded `build/delearner-backend/tests/test_auth_service`: 9 test results
  passed.
- `ctest --test-dir build/delearner-frontend --output-on-failure`: all 18 C++
  suites passed, including auth/bootstrap, existing local vocabulary, offline
  access, reconciliation and outbox tests. Seven QML suites were killed before
  test startup; no QML tests were claimed to pass.
- `./scripts/test-all.sh root`: passed, including canonical fixture checks.
- `tests/domain_relationship_tombstone_matrix.sh --auth-only`: passed.
- Built the backend in the existing Linux builder image; all 11 configured
  Linux backend suites passed.
- `python3 tests/authentication_http_regression.py --base-url http://127.0.0.1:18089`:
  passed against that backend and a separate disposable PostgreSQL database.
  Both empty and populated bootstrap succeeded. The test container/database
  were removed afterward.
- The native Qt installation had only a usable SQLite driver. A Linux
  cross-repository harness attempt also hit its older Qt's missing
  `QSqlQuery::boundValueNames`. Neither limitation was presented as an
  application failure. PostgreSQL HTTP testing used the Linux backend instead.

## Evidence that was still needed

The requested reproduction was one existing-account sign-in failure on the
affected frontend process/device, with timestamp, platform and build. The
requested capture was Qt Creator Application Output for that minute and, for a
Docker backend, `docker compose logs --since 2m backend` immediately afterward.
The desired endpoint/status/error-code sequence was:

- `POST /api/v1/auth/sign-in`;
- `POST /api/v1/devices/register`;
- `GET /bootstrap`;
- `GET /events`.

The request explicitly excluded passwords, session tokens, authorization
headers, personal vocabulary and other secrets. It also prohibited erasing
local data to obtain a reproduction.

## Relationship to the current task

The missing affected-device evidence no longer blocks starting V2-19-05.
Current Phase 1 adds the diagnostics needed to generate correlated evidence.
The checkpoint still constrains completion: do not claim the original
device-specific symptom is verified unless it is reproduced or equivalent
correlated evidence establishes the same failing seam.
