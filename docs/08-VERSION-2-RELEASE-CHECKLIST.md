# Version 2 release checklist

Gate implementation: V2-15-04. Verification recorded 2026-09-13 on macOS arm64,
Qt 6.9.0, with Docker Desktop and the root Compose backend/PostgreSQL environment.

**Automated gate passed; Version 2 release remains pending.** V2-14-01 and
V2-14-02 still require their own completion. Completing the V2-15 gate tooling
and evidence does not approve the product release or mark Version 2 complete.

## Compatible revisions

- Frontend: `e1b1e4b140a1ec578b081421c518b429f7aa9e47`
- Backend: `f20e9bba077a9aff7090bc386431fec8b369e0f7`
- SQLite `1.4`, PostgreSQL `1.3`, sync/API `1.0` (`/api/v1`).

These are the unchanged root Git submodule pins. Re-run the gate if either pin
changes. No child implementation, schema, protocol or UI changed for this task.

## Reproduce the automated gate

From an initialized checkout with child Qt prerequisites and Docker running:

```sh
./scripts/smoke-gate.sh
./scripts/test-all.sh all
```

The smoke gate builds/starts the Compose backend, checks live PostgreSQL health
and schema compatibility, validates fixtures and invokes both child suites.
`test-all.sh all` adds root checks, mandatory bootstrap/recovery suites and the
compiled cross-repository scenarios. Each command must exit zero. For integration
alone after setup, use `./scripts/run-integration.sh`. Build configuration remains
owned by each child; root build outputs use `DELEARNER_BUILD_ROOT` when supplied.

## Completion criteria and evidence

| Required outcome | Automated evidence run successfully |
|---|---|
| Account required; initial online sign-in; offline free-core reopening | `TestAuthSessionStore`, `TestAppStateAuthBootstrap`, `test_auth_service` |
| Registered devices, revocation and account isolation | `TestDeviceIdentityAndSyncContext`, backend auth/device suites, root `authentication_device_lifecycle` |
| UUID canonical domain state, ownership and explicit migrations | `TestDatabaseManager`, frontend domain repositories, `test_database_migrator`, `test_domain_repository`, shared fixture/version checks; live PostgreSQL schema health |
| Immediate local mutations plus durable atomic outbox; stable retries and acknowledgement | `TestTransactionalOutbox`, `TestSyncEventSerializer`, `TestSyncCoordinator`, root `automatic_two_device_reconnect` |
| Authenticated, idempotent, transactional backend processing | `test_event_characterization`, `test_sync_transaction_repository`, `test_sync_domain` |
| New-device restore and concurrent bootstrap catch-up | `TestBootstrapStateRestorer`, `TestAppStateAuthBootstrap`, root `bootstrap_race_catch_up` |
| Incremental cursor advancement and two-device convergence | `TestRemoteChangeReconciler`, root domain matrix and compiled word/group, review and learning-setting scenarios |
| Tombstones, conflict winners, relationships and resurrection | Root four-domain `domain_relationship_tombstone_matrix`, backend characterization and frontend reconciliation suites |
| Bounded history; automatic stale recovery without losing pending work | `test_sync_transaction_repository`, `test_event_characterization`, `TestBootstrapStateRestorer`, `TestSyncCoordinator::staleDeviceRebootstrapsReplaysOriginalEventAndConverges` |
| Automatic active/resume/reconnect sync, offline changes and lost acknowledgement retry | `TestAppStateAuthBootstrap`, `TestSyncCoordinator`, root `automatic_two_device_reconnect` |
| Existing vocabulary, groups, quiz and review free core; learning settings vs local state | All 16 frontend CTest registrations, including `TestQuizRepository`, plus root review/settings scenarios |
| Production import/export hidden; internal capability preserved | `TestProductionSettingsUi`, internal export/replace/merge/error cases in `TestAppStateAuthBootstrap` |
| Missing/failed required suites cannot silently pass | Root authentication and bootstrap/recovery orchestration failure-injection tests; required CTest selections use `--no-tests=error` |

Recorded results: all 16 frontend and 12 backend CTest registrations passed;
root smoke/fixture checks passed; all four root matrix CTest scenarios passed;
compiled word/group, review and learning-setting scenarios passed. The Compose
backend build/start and live health check passed with PostgreSQL schema `1.2`.

The new race scenario captures a real backend export containing all four domains,
commits a word update and setting tombstone before client installation, restores
SQLite at the export sequence, and catches up from that sequence. It verifies
replay safety, absence of outbox feedback, foreign-key integrity, acknowledged
cursor, and equality with a fresh third-client export.

## Outstanding release checks

- [ ] Complete V2-14-01 review and V2-14-02 implementation in their own tasks.
  Record approved nodes from the existing canonical Figma file
  `7kCGSdFGQ79KpRqdaG5Pfp` and verify minimal auth/status/recovery presentation.
  This task has Figma Requirement `None` and makes no design-approval claim.
- [ ] On supported shipping platforms, verify packaged first sign-in, restart
  offline, quiz completion, suspend/resume, network restoration and recovery
  presentation against recorded approved nodes. Automated manager tests do not
  verify OS connectivity notification delivery or packaged QML rendering.
- [ ] Exercise deployed HTTP routing and simultaneous clients against PostgreSQL,
  including bootstrap racing a mutation and stale recovery with offline work.
  The root domain matrix uses the backend's deterministic SQLite test adapter;
  loopback tests use production handlers. Live PostgreSQL health/migrations pass,
  but these do not demonstrate PostgreSQL concurrency or deployed sync routing.

Do not declare Version 2 complete until these checks and all canonical root
acceptance criteria pass against the release pins. Record failures and new
verification evidence here without weakening criteria.
