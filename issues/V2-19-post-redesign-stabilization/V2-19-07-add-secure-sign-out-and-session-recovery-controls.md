# V2-19-07 — Add secure Sign out and Sign in again controls

**Parent epic:** V2-19 — Post-Redesign Stabilization
**Status:** Done
**Workspace:** frontend + backend + root
**Size:** 8 story points
**Dependencies:** completed V2-19-06
**Figma requirement:** None; preserve the current Settings and authentication UI

## Objective

Add the account controls required for reliable manual multi-account and
long-running synchronization testing without risking local pending work or
cross-account data leakage.

Use these user-facing names consistently:

- **Sign out** — intentionally remove the current account and its local cached
  data from this device after it is safe to do so.
- **Sign in again** — recover an expired/rejected online session for the same
  account while preserving local vocabulary and pending synchronization work.

Do not call the recovery action `Refresh login`, `Reconnect database`, or
`Log in back`. The observed state is loss of an authenticated backend session,
not evidence that the local SQLite database disconnected.

## Confirmed baseline

- The backend currently creates bearer sessions with a default 30-day TTL.
- A synchronization 401 now moves the frontend to
  `reauthentication_required`, clears only the rejected online credential, and
  preserves the local database and pending outbox.
- Settings shows `Sign in to sync. Your changes remain on this device.` but has
  no action that opens same-account reauthentication.
- The application has no sign-out API, no client sign-out action, and no
  supported account-switch/data-isolation flow.
- Existing account-mismatch protection must continue to prevent account B from
  inheriting account A's database or outbox.

The report that sync stops after long usage is not sufficient to assume a
database failure. Correlate the frontend 401/backend error/session expiry before
changing session lifetime or database behavior.

## Required behavior

### Session recovery — `Sign in again`

- When `authState == reauthentication_required`, show a prominent
  **Sign in again** action in the Settings Synchronization section.
- Present the current authentication form in recovery mode. The stored account
  email may be prefilled, but the password and bearer token must never be
  logged or displayed.
- Use this message or an equivalent concise localization-ready form:
  `Your sign-in expired. Your changes are saved on this device. Sign in again to sync.`
- Only the same user ID may recover the local account. A different valid
  account remains rejected by the existing account-mismatch protection.
- Successful recovery re-registers/resolves the device if necessary, resumes
  synchronization automatically, and uploads the preserved outbox exactly
  once.
- Failed recovery leaves the database and outbox untouched and keeps the
  recovery action available.
- Do not add a refresh-token protocol or silently store passwords in this task.

### Intentional account exit — `Sign out`

- Add an Account section to Settings with a **Sign out** action and a clear
  confirmation dialog.
- Sign out is a device-local account removal, not account deletion. It must not
  delete backend vocabulary, the backend user, or data on other devices.
- Do not permit ordinary sign out while pending outbox events exist. Explain:
  `Sign in again and sync your saved changes before signing out.`
- When the current session is valid, revoke the presented backend session
  before local teardown. Revoking one session must not revoke other devices.
- If the session has already been rejected and there is no pending outbox work,
  local teardown may proceed without pretending the rejected token was
  remotely revoked.
- After safe sign out, close and remove the account's local SQLite database,
  clear its auth session and device identity, clear account-specific in-memory
  state, and return to the existing authentication screen.
- A later account sign-in starts from an empty isolated local state and must
  bootstrap only that account's backend data.
- Do not weaken backend device ownership or transfer a device/outbox between
  accounts. Any stale backend device record remains an independent lifecycle
  concern unless the smallest secure implementation already has an authorized
  release/revoke path.

## Diagnostics

Extend the existing safe V2-19 logging rather than adding a new framework.
Record start/result/failure for:

- recovery action selected;
- same-account validation;
- backend session revocation;
- pending-outbox sign-out refusal;
- local database/session/device cleanup;
- automatic sync resume after recovery.

Log stable phases, safe IDs, counts, status codes and request IDs. Never log
passwords, bearer/session values, authorization headers, raw auth bodies, full
email addresses, vocabulary, or outbox payloads.

## Acceptance criteria

- Backend tests prove sign out revokes only the presented session and that the
  revoked token immediately fails authentication while another device session
  remains valid.
- A sync 401 exposes **Sign in again**, performs no automatic unauthorized
  retry, and preserves every pending event.
- Same-account recovery resumes and acknowledges the preserved outbox without
  duplication.
- Different-account recovery is refused before device registration or sync.
- Sign out with pending events is refused without deleting local state.
- Safe sign out removes the local account database/session/device identity,
  returns to authentication, and leaves backend account data intact.
- Signing into another account after safe sign out cannot see or upload the
  former account's local data.
- Settings/QML tests cover visibility, naming, confirmation, recovery and error
  states while preserving the current responsive layout.
- Root integration coverage exercises two independent sessions, session
  revocation, recovery, pending-event preservation and account isolation.
- Physical-device verification is recorded separately and is not claimed from
  automated tests.

## Non-goals

- Account deletion.
- Broad Settings/Profile or authentication visual redesign.
- Password reset, email verification, new identity providers or refresh tokens.
- Cross-account transfer of local vocabulary or pending events.
- Changing the 30-day session TTL without correlated evidence that the TTL is
  itself incorrect.

## Completion checkpoint — 2026-11-10

- Implemented presented-session revocation in the backend and verified that a
  second session for the same account remains valid.
- Added Settings **Sign out** confirmation/refusal behavior and **Sign in
  again** recovery mode while preserving the existing responsive UI.
- Verified same-account recovery, different-account rejection before device
  registration, preserved-outbox acknowledgement without duplication, safe
  local teardown, and isolated bootstrap for a later account.
- Added the root `session_account_controls_regression_gate.sh` and extended the
  live HTTP authentication scenario with two-session revocation coverage.
- `./scripts/build-all.sh all`: passed (Felgo application target unavailable;
  tests/core built).
- Frontend CTest excluding the host-blocked `qmltestrunner` suites: 20/20
  passed, including `TestAppStateAuthBootstrap` and
  `TestProductionSettingsUi`.
- Backend CTest: 14/14 passed, including `test_auth_service`.
- `./scripts/test-all.sh root`: passed.
- `qmllint` accepted the changed QML and QML test; it reported only the
  project's existing unqualified-context warnings.
- `TestAuthSyncPresentationUi` could not execute on this macOS host because
  `qmltestrunner -platform offscreen` is killed/hangs before test output; the
  same failure reproduces with the unrelated existing `TestSyncStatusUi`.
- Physical-device verification remains a separate human check and is not
  claimed here.
