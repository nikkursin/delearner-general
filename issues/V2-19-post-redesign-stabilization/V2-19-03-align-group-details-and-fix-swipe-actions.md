# V2-19-03 — Align Group Details and fix swipe actions

**Parent epic:** V2-19 — Post-Redesign Stabilization  
**Status:** Ready  
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


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
