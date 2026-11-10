# V2-19-06 — Fix multi-device authentication and sync regressions

**Parent epic:** V2-19 — Post-Redesign Stabilization
**Status:** Done
**Workspace:** frontend + backend + root
**Dependencies:** completed V2-19-05, completed V2-17-04 through V2-17-06
**Figma requirement:** None

## Objective

Fix the runtime regressions captured after V2-19-05 without reopening its
completed diagnostics work:

1. migrate unambiguous legacy PostgreSQL Word part-of-speech values to contract
   2 wire values so fresh-device bootstrap restores successfully;
2. invalidate rejected online credentials after the first sync 401, preserve
   pending outbox work, and resume it after same-account reauthentication;
3. prevent a registered device UUID from being reused across accounts while
   preserving backend device-ownership enforcement;
4. keep authentication, device registration and post-auth bootstrap failures
   distinct in diagnostics and user-facing messages;
5. guard independently safe QML teardown bindings, without broad UI work.

## Confirmed runtime evidence

- Account sign-in and device resolution returned 200 twice.
- `/bootstrap` returned 200 with seven Words, five Groups, five review-statistic
  records, one tombstone and server sequence 49.
- PostgreSQL contained four `Nomen`, one `Verb` and two canonical `verb` Word
  values for the affected account. Retained and canonical event JSON contained
  the same legacy values.
- The frontend rejected those raw backend values with
  `Word part_of_speech is not a contract 2 value.`
- Three consecutive nine-event uploads used an invalid persisted session and
  returned 401 `invalid_session`, with no acknowledgement.
- After failed fresh bootstrap removed the session/database but retained the
  device UUID, a new account attempted to claim that UUID and correctly
  received 409 `device_claim_conflict`.
- No logout or supported cross-account local-data transition currently exists.

## Required behavior

- Keep contract 2 validation strict. Perform compatibility normalization in an
  explicit PostgreSQL schema migration, including canonical domain rows and
  retained/canonical event payloads used by pull/idempotent responses.
- Do not map ambiguous legacy `Andere` to `phrase`.
- On any sync-phase 401, clear only online session credentials, preserve offline
  access and pending outbox rows, and suppress automatic retries until fresh
  credentials are stored.
- Same-account reauthentication reuses the registered device and resumes the
  preserved outbox.
- A full fresh-bootstrap rollback clears both the uncommitted session and the
  orphan device identity. A legacy orphan conflict may rotate once and retry;
  backend authorization remains unchanged.
- Refuse replacement of a persisted local account by a different account until
  an explicit account-switch/data-isolation flow exists. Never upload one
  account's pending events under another account.
- Preserve the current UI structure. Use distinct existing error surfaces.

## Acceptance criteria

- A schema 1.3 fixture containing `Nomen`, `Verb`, `Adjektiv`, `Adverb`, and
  `Phrase` migrates without data loss to the exact contract 2 values; unknown
  values remain rejected.
- The affected populated bootstrap payload restores through the frontend
  contract validator after migration.
- A sync 401 causes one upload attempt, keeps the event pending, removes the
  rejected online credential, and prevents resume/network/manual retries.
- Same-account sign-in resumes and acknowledges the preserved event.
- Fresh-bootstrap failure cannot leave an account-A device UUID for an account-B
  registration attempt.
- A direct different-account sign-in cannot replace account-A local session or
  transfer its outbox.
- Focused frontend/backend tests and relevant root integration gates pass.
- No device test is claimed unless performed on a physical device.

## Evidence checkpoint

### 2026-11-10 — diagnosis and implementation

Confirmed root causes:

- Contract 2 validation was correct. PostgreSQL schema 1.3 still contained four
  `Nomen`, one `Verb` and two `verb` values for the affected seven Words, and
  bootstrap emitted those stored values without normalization. Retained and
  canonical Word event JSON contained the same legacy labels.
- A sync 401 was recorded only as an outbox send failure. It did not invalidate
  the rejected credential, so network/startup triggers retried the same pending
  batch with the same invalid session.
- Fresh-bootstrap rollback removed the provisional auth session and database
  but left the generated device identity. A later account therefore presented
  the previous account's UUID and correctly hit backend
  `device_claim_conflict`.
- The frontend had no supported logout/account-switch isolation flow and could
  replace a persisted local account after a different user's auth response.
- The QML null-reference warnings were teardown-time bindings. The
  CoreGraphics NaN warnings did not include a source backtrace and were not
  attributable safely from the available evidence.

Implemented changes:

- Advanced the PostgreSQL schema baseline to 1.4. The transactional migration
  normalizes only unambiguous legacy Word labels in `domain_words`, retained
  accepted/resolved payloads and canonical bootstrap payloads. `Andere` remains
  unmapped and strict contract validation remains unchanged.
- A 401 in upload, bootstrap, pull or cursor acknowledgement now emits one
  session-rejected transition. The app clears only online credentials, keeps
  offline access and the pending outbox, suppresses retries, and resumes after
  same-account reauthentication.
- Fresh-bootstrap rollback now clears the provisional device identity. A
  legacy orphan identity may rotate and retry registration once only when no
  local session exists; backend ownership checks remain unchanged.
- A successful auth response for a different user is rejected before device
  registration when a prior local account exists, preserving that account's
  session and pending data.
- Device-registration conflict, authentication failure and authenticated
  bootstrap failure retain distinct diagnostics and user-facing messages.
- Added null guards to `Main.qml` and `DLAuthPage.qml` without changing the UI.

Changed implementation/test surfaces:

- Backend: `DLDatabaseSchemaVersion`, `DLDatabaseMigrator`, and
  `test_database_migrator`; commit `ef48183`.
- Frontend: `DLClientAuthService`, `DLAppStateManager`, `DLSyncCoordinator`,
  `Main.qml`, `DLAuthPage.qml`, `TestAppStateAuthBootstrap`, and
  `TestDeviceIdentityAndSyncContext`; commit `12da3da`.
- Root: schema baseline/contract documentation, environment smoke expectation,
  and the compiled domain-matrix legacy bootstrap regression.

### Verification

- `ctest --test-dir delearner-backend/build-codex-arm64 --output-on-failure`:
  14/14 passed.
- `ctest --test-dir delearner-frontend/build-tests --output-on-failure -E
  'Ui$'`: 17/17 passed.
- Affected QML presentation tests: 2/2 passed.
- `ctest --test-dir build/domain-matrix --output-on-failure`: 6/6 passed,
  including schema-1.3 `Nomen` migration through real backend bootstrap and
  strict fresh-client SQLite restoration, plus automatic two-device reconnect.
- `./scripts/test-all.sh root`: passed.
- Final `CMAKE_BUILD_PARALLEL_LEVEL=2 ./scripts/run-integration.sh`: passed.
  One earlier run under build load exposed an existing request-read timing
  flake; `TestSyncCoordinator` then passed 10/10 consecutive stress repeats and
  the final canonical run passed.
- `docker compose build backend`: image built and its 12 registered container
  tests passed. Restarted local backend reports PostgreSQL schema 1.4 and a
  healthy status.
- Live development PostgreSQL verification after startup migration found zero
  localized legacy labels in domain Words, accepted payloads, resolved payloads
  or canonical payloads. Remaining values were only `noun` and `verb`.

### Remaining manual checks / deferred warning

- No physical iPad/device test was performed or claimed. On the affected flow,
  manually confirm existing-account sign-in restores all seven Words/five
  Groups/five review-statistics records and one tombstone, then confirm edits
  converge in both directions across two devices.
- Manually expire/revoke a session with pending work, confirm exactly one 401
  upload, reauthenticate the same account, and confirm the pending event is
  acknowledged.
- Confirm a failed fresh bootstrap followed by new-account registration uses a
  fresh device UUID; confirm a different account cannot replace a device that
  still contains the first account's local data.
- CoreGraphics NaN warnings remain deferred until reproduced with
  `CG_NUMERICS_SHOW_BACKTRACE=1`; no speculative geometry change was made.
