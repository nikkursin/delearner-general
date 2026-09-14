# V2-16-02 — First-run onboarding flow

**Parent epic:** V2-16 — Frontend Design Alignment  
**Status:** Done
**Workspace:** frontend  
**Size:** 3 story points  
**Dependencies:** existing authentication entry point

## Objective

Implement the supplied loading + three-stage onboarding flow before the user's first registration/authentication entry, without redesigning authentication itself.

## Scope

- Initial loading/splash state.
- Three onboarding pages/stages.
- `Skip` on the first two onboarding stages.
- `Continue` on stages one and two.
- `Get started` on the final stage.
- Progress indicators across the three stages.
- Completion/skip state stored as device-local UI state.
- Completed/skipped onboarding is not shown again during normal future launches on that local installation.
- `Get started`/`Skip` transitions into the existing authentication entry point.
- Keep logo and illustration areas as replaceable placeholders.

## Design references

See `references/V2-16-02/`:

- `onboarding-target-flow-annotated.png`
- `onboarding-target-flow-clean.png`

## Constraints

- Do not create production mascot/logo artwork.
- Do not change authentication/session semantics.
- Do not synchronize onboarding completion as account-level data.

## Acceptance criteria

- Fresh local install/state shows loading then onboarding.
- Skip and completion both suppress onboarding on later ordinary launches.
- Final action reaches the existing auth flow.
- Layout adapts to supported phone/tablet widths without fixed-frame clipping.

## Completion evidence — 2026-09-14

- Added the reference-based splash and three-stage responsive onboarding page, with replaceable logo/illustration placeholders, progress indicators, Skip on stages one/two and Get started on stage three.
- Both exit actions use the app-state manager to persist `onboarding/completed` in the installation-local `<databasePath>.ui.ini` before opening the existing authentication page. This neither opens SQLite nor creates auth credentials/outbox events. A failed settings write stays recoverable on onboarding.
- Unfinished onboarding appears again; completed/skipped onboarding stays dismissed on ordinary launches. Previously authenticated installations retain their existing startup path.
- `cmake --build delearner-frontend/build-tests --parallel 4` passed.
- Configured the working QML runner with `cmake -S delearner-frontend -B delearner-frontend/build-tests -DDELEARNER_QMLTESTRUNNER=/Users/nkursin/Felgo/Felgo/macos/bin/qmltestrunner`. The initially discovered Homebrew runner was killed at startup; the installed Felgo Qt 6.8.3 runner executed successfully.
- `ctest --test-dir delearner-frontend/build-tests --output-on-failure` passed all 19 checks, including auth/bootstrap regressions, both canonical fixture checks and the new onboarding QML tests.
- `/Users/nkursin/Felgo/Felgo/macos/bin/qmltestrunner -input delearner-frontend/tests/qml -platform offscreen` passed all 9 checks, covering splash, stage progression, both skip actions and 320×568, 393×852, 852×393 and 1024×1100 layouts with safe-area insets and reachable scroll actions.
- Inspected offscreen phone and landscape renders against the supplied reference.
- `cmake --build delearner-frontend/build-android --target delearner --parallel 4` passed, including QML compilation and Android native linking. APK packaging and physical iOS/Android launch were not exercised in this task.
- Final diffs and whitespace checks passed. V2-16 remains In Progress / partially blocked; no other task was advanced.
