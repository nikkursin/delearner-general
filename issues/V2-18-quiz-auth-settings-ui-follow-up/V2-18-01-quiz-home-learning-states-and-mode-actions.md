# V2-18-01 — Quiz home, learning states and mode actions

**Parent epic:** V2-18 — Quiz, Authentication and Settings UI Follow-up  
**Status:** Ready  
**Workspace:** frontend + root  
**Size:** 5 story points  
**Dependencies:** completed V2-16/V2-17 baseline

## Objective

Replace the existing Quiz landing screen with the supplied target design and expose useful learning-state statistics without changing the current local quiz architecture.

## Scope

- Implement the target Quiz home layout.
- Show four quiz-family cards.
- Translation Quiz and Article Quiz are active.
- The other two quiz-family cards shown by the approved home reference remain visible placeholders and must not start a quiz.
- Show Hard / Learning / Mastered totals using the epic classification rules.
- Show the upcoming/review vocabulary list using existing review/statistics ordering where available.
- Do not introduce a new spaced-repetition algorithm merely to populate this list.
- Add side-swipe action on a word row to **Clear Score** / reset that word's review statistics.
- Clearing score must not delete the Word entity or group membership.
- Tapping the main body of Translation or Article starts that quiz using the application's existing/default configuration without opening custom setup.
- Tapping the three-dot action opens the mode action sheet.
- Action sheet:
  - `Custom` routes to the corresponding custom setup.
  - `Report a problem` is a visual placeholder only in this epic.
  - `Begin` starts the mode using default configuration.

## Design references

See `references/V2-18-01/`.

## Acceptance criteria

- Learning-state counts exactly follow the V2-18 epic rules.
- Multi-group words are counted once.
- Clearing one score returns that word to the unreviewed/Learning state and preserves vocabulary/group data.
- The reset uses the existing review-statistics persistence/sync path.
- Translation/Article direct launch does not require custom setup.
- Placeholder quiz cards cannot accidentally navigate into incomplete flows.
- Layout remains responsive across supported phone/tablet widths.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
