# V2-19-01 — Fix Add Word alignment and bottom-navigation position

**Parent epic:** V2-19 — Post-Redesign Stabilization  
**Status:** Ready  
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
