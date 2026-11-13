# V2-21-06 — Add a removable streak preview slider

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
**Workspace:** frontend
**Size:** 2 story points
**Dependencies:** completed V2-20-04
**Figma requirement:** None; temporary developer tooling

## Objective

Add the simplest removable Home control for previewing different streak lengths
without changing canonical learning-day data.

## Scope

- Add a compact developer/test-only slider on Home with a useful range such as
  0–30 and a visible numeric preview label.
- Initialise the preview from the real current streak.
- While enabled, override only the streak presentation value used by the Home
  count and dog graphic.
- Keep the real recent dates and canonical streak available so the preview is
  clearly distinguishable from persisted state.
- Isolate the UI in one small component or one contiguous block and gate it
  behind one existing or new development-only flag.
- Mark the component, flag/property, loader/integration point and tests with the
  exact comment `// TODO: Remove after testing`.
- Add a focused test proving slider changes update presentation and do not call
  repository, quiz-completion, outbox or sync mutation APIs.
- Ensure production/release builds have no visible, focusable or accessible
  slider control.

## Acceptance criteria

- [x] A developer build can preview 0, 1, 7, 8, 10, 11, 14, 15 and 30-day
      presentations without completing quizzes.
- [x] Moving the slider creates no learning-day row, outbox event, network
      request or persisted setting.
- [x] Returning preview to the real value restores the unmodified presentation.
- [x] All insertion points carry `// TODO: Remove after testing`.
- [x] Removing the isolated component/block and its one flag leaves no runtime
      dependency or production behaviour change.
- [x] A release-mode test or inspection proves the control is absent.

## Non-goals

- Editing historical learning days or providing a user-facing streak editor.
- Sending preview state to the backend.
- Using the slider to hide a repository or date-ordering bug.

## Removal rule

Do not remove the slider as part of V2-21 unless the user explicitly asks. Keep
it development-only and trivially removable in the meantime.

## Implementation checkpoint — 2026-11-11

**Frontend commit:** `9825c7d` — `feat(frontend): V2-21-06 add streak preview slider`

### Changes

- added an isolated `DLStreakPreview` component with a 0–30 slider, numeric
  preview and the real canonical streak shown alongside it;
- gated the Home Loader behind a Debug-only CMake definition exposed as one
  read-only QML context flag, leaving release/default instances unloaded;
- routed only the displayed Home streak count and dog length through the
  in-memory preview while leaving canonical dates, repositories, quiz
  completion, outbox and synchronization paths unchanged;
- marked the flag, component, Home properties/Loader, Main binding and focused
  tests with `// TODO: Remove after testing`.

### Verification

- `ctest --test-dir build-tests --output-on-failure -R '^TestHomeUi$'` — 1/1
  passed, covering 0, 1, 7, 8, 10, 11, 14, 15 and 30-day previews, reset to the
  real value, zero mutation/sync calls and an unloaded release/default Loader.
- `cmake --build build-tests --parallel 2` — succeeded after regenerating for
  the new QML component; the configured environment builds tests/core only
  because Felgo is unavailable.
- `ctest --test-dir build-tests --output-on-failure` — 35/35 passed.
- `git diff --check` — passed for every selected-task file.
- release inspection confirmed `DELEARNER_STREAK_PREVIEW_ENABLED` is generated
  only for CMake `Debug`; without it the context flag is false and the Loader
  creates no visible, focusable or accessible slider.

### Limitations and next task

- The Felgo application target was not available locally, so the developer
  control was exercised through the real Home QML component rather than a
  packaged app binary.
- Per the V2-21 guardrail, the root frontend submodule pointer remains deferred
  until V2-21-08. V2-21 stays In Progress; the next task remains subject to the
  Ralph selector.

## Removal decision — V2-21-07B

The user has completed visual testing and explicitly requested removal of the
temporary slider. V2-21-06 remains Done as history; V2-21-07B owns complete
removal of the component, flag, Loader, preview state, tests and marked
integration points.
