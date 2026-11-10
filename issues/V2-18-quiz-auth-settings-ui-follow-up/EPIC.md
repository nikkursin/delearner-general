# V2-18 — Quiz, Authentication and Settings UI Follow-up

**Status:** Done — active Quiz scope complete; Authentication/Settings redesign deferred
**Workspace:** frontend + root; backend only where an existing synchronized review-statistics path must be verified  
**Dependencies:** completed V2-16/V2-17 baseline

## Purpose

Align the existing Quiz experience with the supplied target references while preserving the already-working quiz/domain behavior. Authentication/login and Settings/Profile redesign remain deferred until their target references are supplied.

## Active Quiz scope

- Redesign Quiz home.
- Classify vocabulary into Hard / Learning / Mastered from existing review statistics.
- Add the quiz-mode action sheet.
- Keep Translation Quiz and Article Quiz as the only functional quiz families in this epic.
- Show the two additional quiz families from the approved home reference as placeholders only.
- Add custom setup flows for Translation and Article quizzes.
- Redesign Translation and Article quiz sessions.
- Redesign quiz result states.
- Allow per-word review statistics to be cleared from the Quiz home without deleting the Word entity.
- Preserve local quiz execution; do not move current quiz generation/execution to the backend.

## Current execution order — 2026-11-10

1. Complete priority task V2-19-07 for secure Sign out and Sign in again
   controls used by manual testing.
2. Execute V2-18-03 Translation Quiz session redesign; its references and
   completed dependency are available.
3. Execute V2-18-06 shared Quiz results only after V2-18-03 is Done.
4. Run the V2-18 integration/regression pass and close only the active Quiz
   scope. Broader Authentication/Settings visual redesign remains deferred.

## Learning-state classification

Use the existing per-word review statistics; do not invent a new spaced-repetition system.

- **Mastered:** success rate `>= 90%` and the word has more than 5 recorded quiz/review attempts.
- **Hard:** success rate `< 40%` after at least one recorded attempt.
- **Learning:** every other word, including words without enough history to qualify as Hard or Mastered.

The attempt count should come from the review statistics already maintained by the application. Do not introduce a separate session counter unless the current model genuinely lacks the needed information.

## Deferred / placeholder scope

- Authentication/login redesign — deferred beyond the functional V2-19-07
  same-account recovery entry point.
- Settings/Profile redesign — deferred beyond the functional V2-19-07 account
  controls added to the existing Settings layout.
- Report-a-problem backend/workflow — placeholder only.
- The two non-implemented quiz families — placeholder cards only; no session/setup logic.
- Preset management/application flow — not defined. A `Save as preset` control may match the supplied setup reference but must not invent persistence or a preset browser in this epic.
- Written-answer-only repeat/correction behavior must not be invented for the current choice-based Translation/Article sessions.

## Cross-system guardrails

- Clearing a word score resets only that word's review/learning statistics to an unreviewed state; it must not delete the vocabulary item or group membership.
- Use the existing synchronized review-statistics path if review statistics are already synchronized. Do not add a parallel sync mechanism.
- A word belonging to multiple selected groups must be deduplicated before quiz generation.
- Article Quiz must remain compatible with the approved noun article states, including plural-only nouns where the current domain represents `Plural`.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
