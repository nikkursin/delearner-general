# V2-18-03 — Translation Quiz session redesign

**Parent epic:** V2-18 — Quiz, Authentication and Settings UI Follow-up  
**Status:** Done
**Workspace:** frontend  
**Size:** 5 story points  
**Dependencies:** V2-18-02, V2-19-07

## Scheduling note — 2026-11-10

The former `Blocked` status had no remaining recorded blocker: V2-18-02 is
Done and the current/target session references are present. Execute this task
after the higher-priority V2-19-07 account/session controls so manual testing
can switch accounts and recover expired sync sessions safely.

## Objective

Align the existing Translation Quiz session with the supplied target flow while preserving scoring and review-statistics behavior.

## Scope

- Header/back navigation matching the target reference.
- Progress bar and `QUESTION X OF Y` state.
- Prompt card using the configured translation direction.
- Four answer choices.
- Before selection, all choices use the neutral state.
- Correct selection:
  - selected/correct answer uses success treatment;
  - show positive feedback;
  - enable `Next Question`.
- Incorrect selection:
  - selected wrong answer uses error treatment;
  - actual correct answer uses success treatment;
  - show the correct-answer feedback;
  - enable `Next Question`.
- Advance progress only when moving to the next question.
- Final question routes to the shared result flow.
- Persist correct/wrong review statistics exactly once per answered question.

## Design references

See `references/V2-18-03/`.

## Acceptance criteria

- Answer options cannot double-submit statistics.
- Back/route handling does not silently record unanswered questions.
- Correct/wrong styling is readable and matches the target state semantics.
- Progress remains correct after every answer.
- Existing quiz result/statistics data flow remains intact.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
