# V2-19-03 — Align Group Details and fix swipe actions

**Parent epic:** V2-19 — Post-Redesign Stabilization  
**Status:** Done
**Workspace:** frontend  
**Size:** 5 story points  
**Dependencies:** completed V2-16-05

## Objective

Bring Group Details back in line with the supplied design and restore the intended side-swipe word actions.

## Scope

- Restore the missing decorative/header shape treatment shown by the approved target.
- Correct the top action/add-word control styling and placement.
- Preserve group icon/color identity.
- Fix word-row side-swipe interaction so actions are visible and usable.
- Support the existing remove/delete/move semantics without reintroducing single-group assumptions.
- Keep layout responsive instead of hard-coding the Figma phone dimensions.

## References

See `references/V2-19-03/` for current regression and target comparison.

## Acceptance criteria

- Header/decorative shape is visibly consistent with the target reference.
- Word rows do not render partially off-screen.
- Horizontal swipe reveals the intended action area and coexists with vertical scrolling.
- Group membership operations preserve the multi-group domain model.
- No Word entity is deleted merely because one group membership is removed.

## Checkpoint — 2026-11-09

- **Phase:** implementation and verification complete.
- **Behavior/hypothesis tested:** Group Details had lost the approved
  accent-colored header silhouette and used an oversized text action; its
  two-button swipe strip also lacked a trailing anchor, so a left swipe could
  move the word card while leaving the actions partially off-screen.
- **Files changed:** `qml/Components/DLGroupDetails.qml`,
  `qml/Views/DLGroupDetailsPage.qml` and `tests/qml/tst_Groups.qml` in the
  frontend repository.
- **Verification:** the maintained Qt 6.8 `qmltestrunner` passed all 18 Groups
  cases; `ctest --test-dir build-tests -R
  'TestGroupsUi|TestWordRepository|TestGroupRepository' --output-on-failure`
  passed 3/3; `cmake --build build-tests --parallel` passed; the first 25
  frontend CTest cases passed before the command output window closed, and a
  follow-up run passed the remaining Groups, Words and BottomNavigation UI
  cases 3/3; `qmllint` reported no errors; `git diff --check` passed.
- **Diagnostic source:** the supplied current/target V2-19-03 screenshots and
  focused QML geometry, gesture-direction and membership assertions;
  correlation/request ID is not applicable to this local UI task.
- **Conclusion:** the responsive header again carries the group's stable accent
  color and compact plus treatment, word rows remain within tested
  phone/tablet widths, deliberate left swipe reveals both anchored actions,
  vertical drag leaves the swipe closed, and remove/move operations retain the
  Word entity plus unrelated group memberships. V2-19-04 is now dependency
  ready for a fresh invocation.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
