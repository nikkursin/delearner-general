# V2-19-02 — Fix Words filter alignment and swipe delete

**Parent epic:** V2-19 — Post-Redesign Stabilization  
**Status:** Done
**Workspace:** frontend  
**Size:** 3 story points  
**Dependencies:** completed V2-16-06

## Objective

Correct Words-list filter alignment and restore the intended Telegram-like side-swipe delete interaction.

## Scope

- Center part-of-speech filter labels/toggles within their pills/containers.
- Fix horizontal positioning so the filter row does not drift left.
- Keep horizontal scrolling responsive where the full filter set exceeds available width.
- Fix word-row swipe so the destructive action is actually revealed.
- Preserve vertical list scrolling while detecting horizontal swipe.
- Keep deletion confirmation/undo behavior consistent with the already-approved Words/Group interaction pattern.

## Current regression reference

See `references/V2-19-02/`.

## Existing target reference

`../V2-16-frontend-design-alignment/references/V2-16-06/`

## Acceptance criteria

- Filter text remains centered across supported widths.
- Horizontal filter scrolling does not clip the first/last item incorrectly.
- A deliberate horizontal swipe reveals the delete action.
- Normal vertical scrolling does not accidentally trigger delete.
- Deleting a word still follows the existing vocabulary/domain deletion path.

## Checkpoint — 2026-11-09

- **Phase:** implementation and verification complete.
- **Behavior/hypothesis tested:** the filter label/checkmark row was laid out at
  the leading edge of each chip instead of being centered; the Words delete
  action had no trailing anchor, so a left swipe moved the word card without
  exposing the action at the right edge.
- **Files changed:** `qml/Components/DLWordsList.qml` and
  `tests/qml/tst_Words.qml` in the frontend repository.
- **Verification:** `ctest --test-dir delearner-frontend/build-tests -R
  '^TestWordsUi$' --output-on-failure` passed; `cmake --build
  delearner-frontend/build-tests --parallel` passed; `ctest --test-dir
  delearner-frontend/build-tests --output-on-failure` passed all 28 tests.
- **Diagnostic source:** the local V2-19-02 regression screenshot, the approved
  V2-16-06 reference screenshots and focused QML geometry/gesture assertions;
  correlation/request ID is not applicable to this local UI task.
- **Conclusion:** filter content remains centered across tested phone/tablet
  widths, both horizontal filter-scroll boundaries remain reachable, deliberate
  left swipe exposes the anchored delete action, vertical drag leaves swipe
  position closed, and confirmation still uses the existing word deletion path.
  The next executable stabilization task is V2-19-03 in a fresh invocation.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
