# V2-20 — Home, Streak and Navigation Follow-up

**Status:** Done
**Workspace:** root + backend + frontend
**Dependencies:** completed V2-18 UI baseline; V2-19-08 before final Profile integration

## Purpose

Correct the primary navigation model, introduce a real synchronized learning
streak, and move the completed Profile design out of the bottom navigation into
the Home header.

V2-18 remains Done. This epic records the later product correction rather than
rewriting completed task history.

## Approved product behavior

### Primary navigation

The bottom navigation order is exactly:

```text
Home | Quiz | + | Words | Groups
```

- `+` keeps the existing Add Word behavior.
- Home becomes the authenticated landing destination.
- Profile is not a bottom-navigation destination.
- The top-left account/avatar control on Home opens the existing Profile view,
  following the first panel of the supplied
  `Screenshot 2026-11-10 at 08.10.01.png` reference.
- Removing the Profile tab does not delete the Profile screen or its safety
  controls.

### Learning streak

- A learning day is completed when the user finishes an implemented quiz
  session with at least one answered question.
- Multiple qualifying completions on the same local calendar date count once.
- Consecutive completed local dates form the current streak.
- Missing a calendar date resets the displayed current streak; historical
  completed days remain canonical data.
- A completion is recorded offline immediately and synchronizes later.
- Learning days are account-owned and must converge across devices without
  transferring between accounts.
- Clearing review statistics does not erase completed learning days.

The exact versioning and wire representation are frozen by V2-20-01 before
implementation. Prefer a keyed daily record over one mutable counter so two
devices cannot overwrite each other's completed days.

### Visual direction

- Home and Profile use the supplied V2-19-06 screenshots as references, not as
  source-app specifications.
- The dog is assembled from `streak_dog_tail.png`,
  `streak_dog_middle_component.png` and `streak_dog_face.png` without
  distorting the end pieces.
- Profile follows the centered identity header and rounded action-row rhythm
  more closely than V2-18-07 while preserving DE Vocab Learner behavior.
- Reference-only Profile rows may be present as clearly nonfunctional
  placeholders. Do not invent their backend/product behavior.

## Execution order

1. Complete priority regression V2-19-08.
2. V2-20-01 freezes streak semantics, versioning and fixtures.
3. V2-20-02 implements backend persistence and sync support.
4. V2-20-03 implements frontend local persistence and quiz completion capture.
5. V2-20-04 builds the Home streak presentation from real local state.
6. V2-20-05 corrects bottom navigation and Profile access/alignment.
7. V2-20-06 runs the cross-system and responsive regression gate.

## Guardrails

- Existing quiz execution remains local.
- Learning-day creation and its outbox event are one local transaction.
- Backend canonical mutation and accepted sync-event persistence remain one
  backend transaction.
- No account may read or mutate another account's learning days.
- Do not use a device-local counter as the remote source of truth.
- Do not implement notifications, sounds, social sharing, support workflows,
  avatar upload or account editing in this epic.
- Preserve V2-19-07 Sign in again, pending-outbox and account-isolation rules.

## Diagnostics

Extend the existing safe structured logging for learning-day creation,
same-date deduplication, upload acknowledgement, pull/bootstrap application and
streak derivation. Log phases, request/event IDs and counts; never log bearer
values, credentials, full emails, vocabulary or raw event payloads.

## Completion

V2-20 is Done only when V2-20-01 through V2-20-06 are Done and the root gate
proves offline capture, bootstrap, two-device convergence, account isolation,
navigation order and responsive Home/Profile behavior.
