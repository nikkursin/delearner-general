# V2-19-04 — Enable Group → Add Word with preselected group

**Parent epic:** V2-19 — Post-Redesign Stabilization  
**Status:** Done
**Workspace:** frontend  
**Size:** 2 story points  
**Dependencies:** V2-19-03, completed V2-16-03

## Objective

Replace the previously disabled Group Details `Add Word` action with the approved routing behavior.

## Scope

- Enable the Add Word action from the group context/action sheet.
- Navigate to the existing Add Word page.
- Preselect the originating group before the user enters/saves the word.
- The user may still add other groups up to the existing maximum of four total group memberships.
- Returning/cancelling must not create a word or mutate group membership.
- Do not create a second group-specific Add Word implementation.

## Current reference

See `references/V2-19-04/`.

## Acceptance criteria

- Tapping Add Word from a group opens the same canonical Add Word page used elsewhere.
- Originating group is selected when the page opens.
- Saving creates the normal Word entity with that membership through the existing repository/outbox flow.
- Maximum-four-group validation still applies.
- Back/cancel leaves persisted data unchanged.

## Completion evidence — 2026-11-10

- Enabled the existing Groups action sheet, Group Details header, and empty-state Add Word actions.
- Routed each action through the canonical Add/Edit Word screen with the originating group preselected; normal Add Word navigation clears stale group context.
- Kept save behavior on the existing `createWord` repository/outbox path and retained the existing four-group selector limit.
- Verified cancel returns without calling the persistence path.
- Changed frontend files: `DLAppStateManager`, `Main.qml`, `DLAddEditWordPage.qml`, `DLWordEditor.qml`, `DLGroupsList.qml`, `DLGroupDetails.qml`, and focused C++/QML tests.
- Verification: `cmake --build build-tests --target TestAppStateAuthBootstrap -j4`; focused `ctest` for app-state, Groups UI, and Word Editor UI; full `ctest --test-dir build-tests --output-on-failure` (28/28 passed); full `cmake --build build-tests -j4`.
- Diagnostic/correlation ID: not applicable to this local UI routing task.
- Conclusion: all acceptance criteria are locally verified; no external check remains.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
