# V2-21-08 — Run the design-stabilisation regression gate

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
**Workspace:** root + frontend + backend
**Size:** 3 story points
**Dependencies:** V2-21-02 through V2-21-07, V2-21-04A, V2-21-07A
**Figma requirement:** None; do not access or modify Figma

## Objective

Prove the V2-21 auth, responsive-shell, manual-sync and streak changes work
together without weakening authentication, offline use or synchronization.

## Verification matrix

### Authentication

- Valid Create account with Name, Email, Password and matching Repeat password.
- Invalid/empty name, malformed email, weak password and mismatch blocked in
  the client; backend rejection proven independently.
- Existing account Sign in and Sign in again recovery.
- Duplicate normalized email and mapped backend errors.
- Apple/Google placeholders visible and inert on both pages.
- Successful auth continues through device registration, bootstrap and first
  sync without losing pending local work.

### Home and responsive shell

- Manual refresh uses the existing coordinator with the approved transparent
  idle and error SVGs; only a user-triggered manual sync spins, and resolved
  idle/automatic-sync states remain static.
- Phone portrait/landscape, iPad portrait/landscape and wide viewport geometry.
- Rotation/resizing with Home, Quiz, Add Word, Words, Groups and Profile.
- Bottom navigation safe-area/content clearance.

### Streak

- Repository-backed 0, 1, 7, 8, 10, 11, 14, 15 and 30-day states.
- One face total, at most one tail total and no more than three dog rows,
  including tail-hidden overflow above 21 days.
- Ascending streak ordinals ending at the displayed count, including preview
  26 → `20 … 26`.
- Local completion, offline state, bootstrap and two-device reconciliation.
- Preview slider changes presentation only in development builds.
- Release build has no visible, focusable or accessible preview control.

## Required evidence

- Record root, frontend and backend revisions and pre-existing working-tree
  changes before verification.
- Run focused frontend QML/C++ tests, the complete relevant frontend suite,
  backend auth tests and root auth/integration regressions.
- Compare the auth implementation with the V2-21-01 local UX contract.
- Record a physical iPad landscape result when available; do not claim it from
  viewport tests alone.
- Inspect logs and requests for password, Repeat password, token, raw auth body
  and full-email leakage.
- Record release-build inspection of the temporary streak tooling.

## Acceptance criteria

- [x] All verification-matrix cases have a pass/fail result and command or
      manual evidence.
- [x] Frontend, backend and root regression suites relevant to V2-21 pass.
- [x] Auth pages satisfy the V2-21-01 local UX contract and responsive matrix.
- [x] No auth/bootstrap/offline/account-isolation regression is present.
- [x] No duplicate sync coordinator or mutable streak counter was introduced.
- [x] Sync rotation is manual-trigger-scoped and the correct SVG is shown for
      idle, error and recovered states at the approved scale.
- [x] Dog end-cap/row limits and streak ordinal rules from V2-21-07A pass at
      phone and tablet widths.
- [x] Production/release UI contains no temporary streak slider.
- [x] Compatible frontend/backend commits are ready before root submodule
      pointers are updated.

## Completion rule

Do not mark V2-21 or this gate Done when a required environment check has merely
been skipped. Record the limitation and leave the task In Progress unless the
issue explicitly permits that check to remain manual follow-up.

## Regression-gate checkpoint — 2026-11-13

### Revisions and pre-existing working-tree state

- Root verification started from `a450c5d`, with recorded submodule pointers
  `delearner-frontend@94d61a4` and `delearner-backend@fdff398`.
- Compatible child checkouts were `delearner-frontend@1d2b109` and
  `delearner-backend@48cb5a7`. The child commits were already committed by the
  completed V2-21 implementation tasks and remained unchanged during this
  gate.
- The root already showed both deferred submodule-pointer updates, untracked
  V2-19 diagnostic logs and `tests/__pycache__`. The frontend already had
  unrelated local changes in `CMakeLists.txt.user`,
  `src/Auth/DLClientAuthService.cpp` and
  `src/Services/DLDatabaseExportService_ios.mm`; the backend was clean.
- The unrelated root/frontend changes were neither edited nor staged. The
  local frontend API-address override was isolated from verification by unit,
  component and compiled integration harnesses with injected endpoints, while
  the served HTTP matrix targeted `127.0.0.1:8080` explicitly.

### Verification matrix results

| Area | Result | Evidence |
|---|---|---|
| Create account and client validation | Pass | `TestRegistrationValidator`, `TestAuthSyncPresentationUi` and all 31 shared registration fixture cases passed; empty/invalid name, malformed email, weak password and mismatch remained client-blocked. |
| Backend validation and duplicate email | Pass | `test_auth_service` passed and the served HTTP matrix rejected every invalid fixture, returned stable errors, accepted a valid named account and returned HTTP 409 for the normalized duplicate. |
| Sign in, Sign in again and pending work | Pass | `TestAuthSessionStore`, `TestDeviceIdentityAndSyncContext`, `TestAppStateAuthBootstrap` and the session/account regression gate passed, including same-account recovery, offline access, pending-outbox preservation and account isolation. |
| Provider placeholders and UX contract | Pass | Source comparison with V2-21-01 plus `TestAuthSyncPresentationUi` confirmed separate responsive pages, the 480-pixel form bound, safe-area/scroll behavior, accessible fields/actions and inert Apple/Google Coming-soon controls. |
| Auth to device/bootstrap/first sync | Pass | `authentication_device_lifecycle`, bootstrap/recovery scenarios and the served HTTP registration → sign-in → device registration → bootstrap → upload/pull/cursor matrix passed. |
| Manual sync presentation | Pass | `TestHomeUi`, `TestSyncCoordinator` and `TestAppStateAuthBootstrap` passed static idle/automatic states, accepted/refused manual starts, scoped rotation, error SVG/retry and recovered idle behavior through the existing coordinator. |
| Responsive shell and navigation | Pass | `TestResponsiveNavigationUi`, `TestResponsiveShellUi`, Home/auth geometry rows and the complete QML suite passed phone portrait/landscape, iPad portrait/landscape, wide viewport, resize and safe-area/content-clearance cases. |
| iPad landscape runtime | Pass | The V2-21-05 iPad iOS 18.4 simulator check remains the recorded non-viewport runtime evidence: portrait → landscape → portrait filled the viewport with no black frame or stale navigation overlay. No physical iPad was available, so no physical-device result is claimed. |
| Streak persistence and convergence | Pass | `TestLearningDayRepository` and `learning_day_backend_sync_scenario.sh` passed the required 0/1/7/8/10/11/14/15/30 derivations, same-day idempotence, offline capture, bootstrap, two-device convergence and account isolation. |
| Dog composition and ordinals | Pass | `TestHomeUi` passed narrow-phone, phone and tablet rows for one face, at most one tail, at most three rows, hidden overflow tail and ascending ordinals including preview 26 → `20 … 26`. |
| Development preview isolation | Pass | `TestHomeUi` proved preview changes make zero repository/outbox/network mutations and restore canonical presentation. Every integration point retains the exact removal marker. |
| Release preview absence | Pass | A Release reconfiguration/build plus `TestHomeUi` passed with zero `DELEARNER_STREAK_PREVIEW_ENABLED` occurrences in the generated build rules; the release/default Loader was neither visible, focusable nor accessible. |
| Secret/request inspection | Pass | Repeat password appears only in frontend validation and is absent from the manager registration/request interface. The served backend log scan found zero full test emails, Repeat-password, session-token, Authorization/Bearer-value, raw-auth-body or password-value patterns. |

No duplicate coordinator or mutable streak counter was found: Home still calls
the existing manager/coordinator path and the displayed streak remains derived
from immutable account-owned learning dates.

### Commands and results

- Focused frontend CTest selection for registration, auth/session/bootstrap,
  Home, responsive shell and learning days — 9/9 passed.
- Focused backend CTest selection for auth, devices, diagnostics and event
  characterization — 4/4 passed.
- `CMAKE_BUILD_PARALLEL_LEVEL=4 ./scripts/test-all.sh all` — passed after
  correcting the root build cache from the incompatible Homebrew Qt 6.9 QML
  runner to the project-compatible Felgo Qt 6.8.3 runner: frontend 36/36,
  backend 15/15 and all compiled/root scenarios passed. The initial toolchain-
  mismatched run is not counted as a product pass.
- `./tests/sign_out_http_runtime_regression.sh` — Docker Release build passed
  12/12 backend tests; checkout and running revisions both matched `48cb5a7`;
  the real served HTTP matrix passed 37/37 uniquely correlated requests.
- `./scripts/run-integration.sh` — passed root environment, Compose validation,
  auth/device lifecycle, bootstrap/recovery, two-device domain, learning
  settings/review statistics and learning-day integration scenarios.
- Release frontend reconfiguration/build and focused
  `TestHomeUi|TestAuthSyncPresentationUi|TestResponsiveShellUi|TestResponsiveNavigationUi`
  selection — 4/4 passed; generated Release preview-definition count was zero.
- Final secret-pattern scan of the served backend logs — zero matches.

### Limitations

- No physical iPad was available. The required iPad landscape result is backed
  by the recorded iOS 18.4 iPad simulator rotation check, separately from the
  deterministic viewport tests, and no physical-device claim is made.
