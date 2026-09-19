# V2-18-02 — Translation Quiz custom setup

**Parent epic:** V2-18 — Quiz, Authentication and Settings UI Follow-up  
**Status:** Blocked  
**Workspace:** frontend  
**Size:** 5 story points  
**Dependencies:** V2-18-01

## Objective

Implement the custom Translation Quiz configuration screen shown in the supplied reference while reusing the existing Translation Quiz engine.

## Scope

- Translation direction:
  - German → native language.
  - Native language → German.
- Multi-select part-of-speech filters using currently supported word types.
- Multi-select saved groups.
- Selecting no specific group means all eligible words.
- Deduplicate words that belong to more than one selected group.
- Number-of-questions slider:
  - minimum 1 when at least one eligible word exists;
  - maximum is the number of distinct eligible words after all filters;
  - update the visible availability/selection counts as filters change.
- Multi-select learning-state content:
  - Hard;
  - Learning;
  - Mastered.
- `Repeat Correct Answers` is shown only as far as the current quiz mechanics support it. Do not invent written-answer correction behavior for a choice-only Translation session.
- `Save as preset` may be present to match the reference, but preset persistence/application is deferred until a preset-consumption flow is defined.
- `Begin` starts Translation Quiz using exactly the selected configuration.

## Design references

See `references/V2-18-02/`.

## Acceptance criteria

- Changing filters recomputes eligible distinct words and clamps question count safely.
- Words appearing in multiple selected groups are not duplicated.
- An impossible setup cannot start a quiz and gives a clear local explanation.
- Existing default/direct-start behavior from V2-18-01 remains unchanged.
- No backend-dependent quiz-generation behavior is introduced.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
