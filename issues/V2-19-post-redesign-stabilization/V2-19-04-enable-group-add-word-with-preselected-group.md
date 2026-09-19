# V2-19-04 — Enable Group → Add Word with preselected group

**Parent epic:** V2-19 — Post-Redesign Stabilization  
**Status:** Blocked  
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


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
