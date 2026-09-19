# V2-19 — Post-Redesign Stabilization

**Status:** Ready  
**Workspace:** frontend + backend + root  
**Dependencies:** completed V2-16/V2-17 implementation

## Purpose

Fix regressions discovered after executing the V2-16/V2-17 redesign/domain work. Preserve the approved design and domain architecture; do not solve these regressions by rolling back the completed redesign.

## Scope

- Add Word alignment and bottom-navigation positioning.
- Words filter alignment and broken side-swipe delete affordance.
- Group Details visual alignment and broken side-swipe actions.
- Enable Group → Add Word routing with originating group preselected.
- Debug existing-account sign-in and account-creation failures.
- Add focused regression tests for corrected functional behavior.

## Rules

- Existing V2-16 references remain the target design baseline where applicable.
- Fix the smallest underlying cause; do not broadly refactor unrelated QML/auth/sync code.
- Authentication investigation must begin from code/tests and reproducible behavior. Ask the user for runtime logs only if the code/test investigation cannot isolate the failure, and then request exact safe logging steps without credentials/tokens.
- Do not redesign the login page in this epic; that remains deferred under V2-18 until a target reference is supplied.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
