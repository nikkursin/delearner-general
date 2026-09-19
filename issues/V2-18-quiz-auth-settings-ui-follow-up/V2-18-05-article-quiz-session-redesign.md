# V2-18-05 — Article Quiz session redesign

**Parent epic:** V2-18 — Quiz, Authentication and Settings UI Follow-up  
**Status:** Blocked  
**Workspace:** frontend  
**Size:** 3 story points  
**Dependencies:** V2-18-04

## Objective

Align the Article Quiz session with the target design and current noun/article domain semantics.

## Scope

- Header/back navigation.
- Progress bar and current-question count.
- Show the German noun prompt.
- Show article choices supported by the current model:
  - `der`;
  - `die`;
  - `das`;
  - `Plural` where eligible.
- Correct and incorrect answer feedback follows the same success/error interaction model as Translation Quiz.
- Record review statistics exactly once per answered question.
- Final question routes to the shared result flow.

## Design references

See `references/V2-18-05/`.

## Acceptance criteria

- A noun's actual article is the only correct choice.
- Plural-only nouns can be quizzed without forcing a fake singular article.
- Unanswered questions do not alter statistics.
- Progress and answer feedback remain responsive and visually stable.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
