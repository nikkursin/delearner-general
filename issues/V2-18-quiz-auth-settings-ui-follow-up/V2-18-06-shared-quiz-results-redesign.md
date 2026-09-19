# V2-18-06 — Shared Quiz results redesign

**Parent epic:** V2-18 — Quiz, Authentication and Settings UI Follow-up  
**Status:** Blocked  
**Workspace:** frontend  
**Size:** 3 story points  
**Dependencies:** V2-18-03, V2-18-05

## Objective

Replace the current Translation/Article result pages with one shared result presentation based on the supplied score-state reference.

## Scope

- Shared result screen for Translation and Article quizzes.
- Show score percentage plus correct/wrong totals.
- Provide three visually distinct result states matching the supplied low / middle / high score reference:
  - `Keep Practicing`;
  - `Good Job!`;
  - `Excellent!`.
- Use a vivid but project-consistent accent treatment for the score ring/state.
- Preserve the actual numeric score rather than substituting a tier label for it.
- `Retry` starts another session of the same quiz/configuration when that action is available in the target state.
- `Continue` / Quiz Home returns to Quiz home.
- Keep result copy/layout responsive.

## Score-tier rule

Use non-overlapping boundaries so every score maps to exactly one state:

- `0–40%` → Keep Practicing.
- `41–80%` → Good Job!
- `81–100%` → Excellent!

If the existing scoring code already centralizes equivalent tier boundaries, reuse that implementation rather than creating a second conflicting rule.

## Design references

See `references/V2-18-06/`.

## Acceptance criteria

- Correct + wrong equals the number of answered questions.
- Percentage is derived consistently from those results.
- Every possible score maps to exactly one visual state.
- Retry does not corrupt/duplicate the completed session's statistics.
- The result screen is shared rather than duplicated per quiz family.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
