# V2-21-08A — Run Home calendar, reset and sync-animation gate

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
**Workspace:** root + frontend
**Size:** 2 story points
**Dependencies:** V2-21-04B, V2-21-07B
**Figma requirement:** None

## Objective

Verify the V2-21 post-completion corrections together before updating the root
frontend submodule pointer and closing the reopened epic.

## Verification matrix

### Manual sync control

- Fast success, slow success, early/late error, retry and recovery.
- 2500 ms minimum manual animation without delaying real sync completion.
- Static automatic-sync/idle state.
- Rotating arrows with zero-rotation exclamation overlay.
- Destruction/account transition leaves no timer or animation active.

### Streak and calendar

- Dog counts 0, 1, 7, 8, 14, 15 and 30 at phone/tablet widths.
- At most two rows, one face total and correct tail/overflow behavior.
- Current-month calendar for 28, 29, 30 and 31-day months with correct weekday
  alignment and compact phone height.
- Completed/today/missed/future visual and accessibility states.
- Yesterday-at-risk behavior, full missed-day reset to zero, rollover while
  active, resume after a missed day and new streak starting at one.
- Historical completed dates remain visible after reset.
- Month/year/leap-day/DST and account-isolation cases.

### Temporary tooling removal

- No preview slider, Loader, component, context/build flag, resource entry,
  preview-only test or V2-21-06 removal TODO remains.
- Release and Debug Home both use only the canonical streak value.

## Required evidence

- Record root/frontend revisions and pre-existing working-tree changes.
- Run focused Home QML, learning-day repository, lifecycle/resume and sync
  coordinator tests.
- Run the complete frontend suite and relevant root learning-day/integration
  checks.
- Inspect the built/source asset composition to prove the supplied
  `red-exclamation-mark.svg` remains stationary while only arrows rotate.
- Record any physical-device limitation separately from automated geometry and
  clock tests.

## Acceptance criteria

- [x] Every verification-matrix case has a recorded pass/fail result and exact
      command or manual evidence.
- [x] No UI-thread or network-operation delay was introduced for the animation.
- [x] The current streak visibly resets after one complete missed local day and
      historical learning days remain intact.
- [x] Dog and compact calendar satisfy their bounded geometry requirements.
- [x] Temporary preview tooling is completely absent.
- [x] Frontend and relevant root suites pass.
- [x] A compatible frontend commit is ready before the root submodule pointer
      and epic/index status are updated.

## Completion rule

Keep V2-21 and this gate In Progress if a required automated reset, rollover or
asset-layering check fails. Do not mark Done solely from a visual spot check.

## Implementation checkpoint — 2026-11-13

### Revisions and starting state

- Root started at `017f54b`; backend was clean at `48cb5a7`.
- Frontend started clean at `e1aed55`, containing the completed V2-21-04B and
  V2-21-07B commits. Root intentionally still pinned `4f7fcb9`, so its only
  pre-existing change was the deferred frontend submodule pointer.
- Gate coverage was committed in frontend as `870f853` —
  `test(frontend): V2-21-08A cover calendar month lengths`.

### Verification matrix results

| Area | Result | Automated/source evidence |
|---|---|---|
| Fast/slow manual success, early/late error, retry/recovery, refused request and automatic-sync idle | Pass | `TestHomeUi` covers each state, including a production-default assertion of 2500 ms. The real request is called before the independent QML timer starts; no sleep, network delay or UI-thread wait exists. |
| Stationary error mark and rotating arrows | Pass | `TestHomeUi` asserts separate tracked SVG sources and zero error-mark rotation during/after failures. Source inspection found the `RotationAnimator` only on `sync-refresh-idle.svg`, with `red-exclamation-mark.svg` as a sibling fixed at `rotation: 0`. |
| Destruction and account/session transition | Pass | `TestHomeUi::test_sessionTransitionAndTeardownCancelVisualCycle` verifies timer/animation cancellation. |
| Dog counts 0, 1, 7, 8, 14, 15 and 30 at responsive widths | Pass | `TestHomeUi` verifies zero state, exact headline, two-row/14-unit cap, one face, tail/overflow rules and bounds at 360, 393, 768 and 1024 logical pixels. |
| 28/29/30/31-day month geometry and alignment | Pass | Added data-driven phone/tablet coverage for all four month lengths; existing tests verify deterministic first-weekday blanks, full seven-column rows and height `<= 210`. |
| Completed/today/missed/future states and accessibility | Pass | `TestHomeUi` asserts each state plus full-date completion/today accessible names. |
| At-risk yesterday, full missed-day reset, live rollover, resume and new streak at one | Pass | `TestHomeUi` and `TestLearningDayRepository` verify retained history, rollover without restart, resume refresh and post-gap completion. |
| Month/year, leap day, DST and account isolation | Pass | `TestLearningDayRepository::streakDerivationHandlesCalendarAndDaylightSavingBoundaries`, `missedDateResetsOnlyCurrentStreak` and `accountIsolationAndReviewResetPreserveLearningDays`. |
| Temporary preview tooling removal and canonical-only streak | Pass | `rg -n 'DLStreakPreview|streakPreview|developerStreakPreview|DELEARNER_STREAK_PREVIEW_ENABLED|TODO: Remove after testing' . --glob '!build*' --glob '!\.git/**'` returned no matches. With the build/context flag absent, Debug and Release use the same repository-derived Home state. |

### Commands and results

- `cmake --build build-tests --parallel 2` — passed.
- `ctest --test-dir build-tests --output-on-failure -R '^(TestHomeUi|TestLearningDayRepository|TestAppStateAuthBootstrap|TestSyncCoordinator|TestRemoteChangeReconciler|TestBootstrapStateRestorer)$'`
  — 6/6 passed.
- `ctest --test-dir build-tests --output-on-failure` — 36/36 passed.
- `./tests/learning_day_v21_contract_fixtures_smoke.sh` — passed.
- `./tests/learning_day_backend_sync_scenario.sh` — passed static gate.
- `./tests/learning_day_backend_sync_scenario.sh --run` — passed frontend
  persistence/reset/account isolation, backend convergence/contract projection,
  pull reconciliation and bootstrap preservation.
- Fresh arm64 Release configuration and compilation in
  `build/v2-21-08a-release` — passed.
- `git diff --check` — passed before the frontend commit.

### Limitations

- No physical-device screenshot run was available; real QML components were
  exercised at phone, tablet portrait and tablet landscape dimensions.
- The fresh arm64 Release build compiled, but its standalone offscreen
  `qmltestrunner` process was killed/hung before test output in the root build
  path. The same Home QML suite passed in Debug, and Release/Debug parity for
  the canonical streak was verified by source/build-flag removal rather than
  counted as a second runtime pass.
