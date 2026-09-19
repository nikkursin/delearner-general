# V2-18-04 — Article Quiz custom setup

**Parent epic:** V2-18 — Quiz, Authentication and Settings UI Follow-up  
**Status:** Done
**Workspace:** frontend  
**Size:** 3 story points  
**Dependencies:** V2-18-01

## Objective

Implement the target custom setup for Article Quiz using only eligible saved nouns and the existing review-statistics model.

## Scope

- Multi-select saved groups.
- Selecting no specific group means all eligible nouns.
- Deduplicate nouns that belong to multiple selected groups.
- Include only noun entries with an article state supported by the current domain.
- Keep compatibility with `der`, `die`, `das`, and the approved plural-only `Plural` article state.
- Number-of-questions slider is limited by the distinct eligible nouns after filtering.
- Multi-select Hard / Learning / Mastered content filters.
- `Repeat Correct Answers` must not invent written-answer behavior for the current choice-based Article session.
- `Save as preset` may match the supplied reference visually, but persistence/application remains deferred without a defined preset-consumption flow.
- `Begin` starts Article Quiz with the selected configuration.

## Design references

See `references/V2-18-04/`.

## Acceptance criteria

- Eligibility/count text updates when groups or learning-state filters change.
- No duplicated noun questions from multi-group membership.
- Plural-only noun entries remain representable where allowed by the current Word model.
- The quiz cannot start with zero eligible nouns.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
