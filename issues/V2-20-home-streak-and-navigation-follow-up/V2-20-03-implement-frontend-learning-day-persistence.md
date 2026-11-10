# V2-20-03 — Implement frontend learning-day persistence

**Parent epic:** V2-20 — Home, Streak and Navigation Follow-up
**Status:** Done
**Workspace:** frontend + root
**Size:** 5 story points
**Dependencies:** V2-20-01, V2-20-02
**Figma requirement:** None

## Objective

Record qualifying quiz completion locally, expose derived streak state, and
synchronize completed learning days through the durable outbox.

## Scope

- Add the explicit SQLite migration/version from V2-20-01.
- Add repository/service APIs for idempotent daily completion and streak
  derivation from completed dates.
- On completion of a Translation or Article quiz with at least one answered
  question, atomically insert the missing learning day and its outbox event.
- A second completion on the same local date creates no duplicate row/event.
- Preserve pending learning-day events during failed sync and re-bootstrap.
- Adopt the backend canonical UUID after same-date reconciliation.
- Restore learning days during fresh-device bootstrap and apply incremental
  learning-day events.
- Expose current streak and recent completed dates to QML without making QML
  responsible for date arithmetic or persistence.

## Acceptance criteria

- Qualifying completion updates local streak state immediately while offline.
- Zero-answer/cancelled sessions do not complete a learning day.
- Same-day repeated quizzes remain one day and one effective mutation.
- Consecutive dates, missed dates, month/year boundaries and daylight-saving
  transitions have deterministic tests with an injected clock/timezone.
- Clearing word review statistics does not delete learning days.
- Reauthentication, retry and re-bootstrap preserve pending learning days.
- A different account cannot inherit the former account's local streak.
- Frontend repository, app-state and bootstrap tests pass.
