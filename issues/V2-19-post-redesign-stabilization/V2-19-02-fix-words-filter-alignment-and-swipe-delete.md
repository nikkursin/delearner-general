# V2-19-02 — Fix Words filter alignment and swipe delete

**Parent epic:** V2-19 — Post-Redesign Stabilization  
**Status:** Ready  
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


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
