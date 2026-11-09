# V2-19-05C — Correlated auth/sync reproduction, fixes and verification

**Parent:** V2-19-05
**Status:** Done
**Workspace:** frontend + backend + root
**Dependencies:** V2-19-05A, V2-19-05B

## Objective

Use the newly correlated frontend/backend diagnostics to reproduce the reported
account-creation and existing-account startup failures, fix the first verified
failing seams, and verify the parent issue end to end.

## Required sequence

1. Run the parent reproduction matrix with frontend and backend logs captured
   from matching request IDs.
2. Identify the first failing seam for each reproduced failure.
3. Add a failing test at the owning seam before changing behavior.
4. Implement the smallest fix in the owning repository.
5. Rerun focused tests after each fix.
6. Run empty and populated bootstrap, pending-outbox preservation and
   incremental-sync integration coverage.
7. Append the exact commands, outcomes, request IDs or sanitized excerpts, and
   remaining risks to the parent checkpoint.

## Rules

- Preserve backend-owned conflict resolution, ownership, transaction and sync
  semantics.
- Preserve offline-after-initial-auth behavior and pending local work.
- Use diagnostic identifiers/counts; keep credentials and personal payloads out
  of logs and evidence.
- Keep unrelated V2-19 UI tasks untouched.

## Acceptance criteria

- The parent reproduction matrix has an evidence-backed result for every case.
- Every reproduced defect has a focused regression test and smallest safe fix.
- Frontend, backend and root auth/sync checks pass.
- Disposable PostgreSQL HTTP coverage passes for account creation, sign-in,
  device registration, empty/populated bootstrap and incremental sync.
- Secret-redaction checks pass across frontend and backend diagnostics.
- The parent V2-19-05 acceptance criteria are satisfied or a precise external
  verification requirement remains documented without claiming Done.

## Evidence checkpoint — 2026-11-09

- Baseline revisions were root `07e3d01`, frontend `e7c58b1` and backend
  `58e65b4`. The pre-existing frontend `CMakeLists.txt.user` modification was
  left untouched and excluded from every commit.
- Focused baseline checks passed: 5/5 frontend auth/bootstrap/sync suites, 4/4
  backend auth/device/event suites and `./scripts/test-all.sh root`.
- The first disposable Linux build reproduced a Qt 6.4 compile failure in
  `DLDiagnostics::RequestTrace::complete`: the Qt 6.8-only `QHttpHeaders` API
  prevented production diagnostics from building in the deployment image.
  Backend commit `c191353` uses the Qt 6.4 response-header API while retaining
  the Qt 6.8 path. The rebuilt image compiled and passed all 12 configured
  Linux backend suites; local Qt 6.8 backend checks passed 14/14.
- The root integration build then reproduced an unresolved-symbol failure
  because `domain_matrix` compiled instrumented handlers without their new
  `DLDiagnostics.cpp` dependency. The root target now includes that production
  source and the complete integration gate passes.
- Frontend commit `f23af3f` adds malformed bootstrap JSON/state coverage and
  proves existing local state, its pending outbox row and cursor remain
  unchanged when restoration rejects the response.
- `python3 tests/authentication_http_regression.py --base-url
  http://127.0.0.1:18095` passed against an isolated PostgreSQL 16 container
  and the rebuilt backend image. It covered 14 HTTP operations, asserted a
  unique echoed request ID for each and verified success/rejection responses,
  empty/populated bootstrap, incremental pull and cursor acknowledgement.
- A `docker logs delearner-v21905c-backend` audit found exactly one
  `request_start` and `request_complete` for every test ID, all required
  auth/device/bootstrap/upload/pull/cursor result events, and none of 74
  credential, authorization, email, fixture-vocabulary or database-password
  markers. The disposable containers and network were removed afterward.
- Broader verification passed: frontend non-UI CTest 17/17, backend CTest
  14/14, `./scripts/test-all.sh root`, and
  `CMAKE_BUILD_PARALLEL_LEVEL=2 ./scripts/run-integration.sh`. The latter passed
  authentication/device lifecycle, bootstrap race/catch-up, automatic
  two-device reconnect, domain/tombstone convergence, Word/Group scenarios,
  review-statistics propagation and learning-setting convergence.
- Conclusion: every parent reproduction row has executable evidence, the two
  reproduced integration defects have narrow fixes, and no auth, sync,
  conflict, ownership or shared-contract semantics changed.
