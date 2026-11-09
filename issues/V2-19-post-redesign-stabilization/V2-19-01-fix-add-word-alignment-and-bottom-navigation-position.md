# V2-19-01 — Fix Add Word alignment and bottom-navigation position

**Parent epic:** V2-19 — Post-Redesign Stabilization  
**Status:** Done
**Workspace:** frontend  
**Size:** 2 story points  
**Dependencies:** completed V2-16-01, V2-16-03

## Objective

Correct the visible Add Word regressions without changing its approved data behavior.

## Scope

- Fix Group selector/dropdown text/indicator alignment.
- Review vertical spacing around the selector so it matches the approved Add Word reference.
- Lower/seat the shared bottom navigation closer to the safe-area/bottom edge, matching the approved V2-16 navigation references.
- Ensure the navigation adjustment does not break other screens using the shared shell.

## Current regression reference

See `references/V2-19-01/`.

## Existing target references

- `../V2-16-frontend-design-alignment/references/V2-16-01/`
- `../V2-16-frontend-design-alignment/references/V2-16-03/`

## Acceptance criteria

- Group selector label and chevron are visually centered and vertically aligned.
- Bottom navigation respects the platform safe area and visually matches the approved reference.
- No hard-coded iPhone-only offset is introduced.
- Add/Edit Word behavior and multi-group semantics remain unchanged.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.

## Implementation checkpoint — 2026-11-09

- Phase: frontend Add Word and shared-navigation regression fix.
- Behavior tested: the Group placeholder and chevron remain centered with the
  chevron reserved at the trailing edge; the shared navigation body sits closer
  to the bottom edge while retaining the full reported safe-area inset at phone
  and tablet widths; existing multi-group selection behavior remains intact.
- Frontend files changed: `qml/Components/DLWordEditor.qml`,
  `qml/Components/DLBottomNavigation.qml`, `tests/CMakeLists.txt`,
  `tests/TestResponsiveNavigationUi.cmake`,
  `tests/qml/tst_WordEditor.qml`, and
  `tests/qml/tst_BottomNavigation.qml`.
- Verification: `cmake --build build-tests -j4` passed;
  `ctest --test-dir build-tests -R
  'Test(ResponsiveNavigationUi|WordEditorUi|BottomNavigationUi)$'
  --output-on-failure` passed 3/3; `ctest --test-dir build-tests
  --output-on-failure` passed 28/28; `cmake --build build-ios --target
  delearner -j4` completed with `BUILD SUCCEEDED`.
- Diagnostic source/correlation ID: local QML geometry regression tests; no
  runtime request correlation applies to this frontend-only visual task.
- Conclusion: V2-19-01 acceptance criteria are satisfied. V2-19-02 is the next
  task in the documented V2-19 execution order; the parent epic remains In
  Progress.
