# V2-21-07B — Add compact month calendar and enforce streak reset

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
**Workspace:** frontend
**Size:** 5 story points
**Dependencies:** completed V2-21-06, completed V2-21-07A
**Figma requirement:** None; follow the explicit current product correction

## Objective

Reduce the dog to at most two rows, remove all temporary preview-slider code,
replace the ordinal strip with a compact current-month calendar, and ensure the
Home streak visibly resets after one complete local calendar day is missed.

## Approved dog rules

- Keep the single-dog model from V2-21-07A: exactly one face and at most one
  tail in total.
- Reduce visible capacity from three rows/21 units to two rows/14 units.
- Streaks 1–14 show at most two rows, one tail at the beginning and one face at
  the final visible end.
- Streaks above 14 show exactly two rows, hide the tail to communicate earlier
  off-screen length, retain exactly one face at the end, and keep the headline's
  exact uncapped count.
- Intermediate/wrapped rows never duplicate a tail or face.

## Remove temporary preview tooling

Remove the V2-21-06 test slider completely, including:

- `DLStreakPreview` and its Home Loader;
- preview properties/bindings and `streakPreviewEnabled` build/context flag;
- preview-specific CMake/resource registration;
- preview-only tests and every `// TODO: Remove after testing` integration
  marker introduced by V2-21-06.

After removal, Home has one streak value only: the repository-derived canonical
current streak. Do not replace the slider with another developer mutation
control.

## Compact current-month calendar

- Replace the seven-cell ordinal strip with a compact, read-only calendar for
  the complete current local month.
- Show a concise localized month/year heading, weekday headers and every day
  number in a seven-column grid. Use blank leading/trailing cells rather than
  displaying adjacent-month dates.
- Use the current locale's first day of week where practical; keep tests
  deterministic through injected locale/calendar inputs.
- Distinguish at least:
  - completed learning day;
  - today completed;
  - today not yet completed;
  - past day without completion;
  - future day.
- Keep historical completed-day marks visible after the current streak resets;
  reset means the consecutive counter returns to zero, not that learning-day
  history is deleted.
- Keep the calendar non-interactive in this scope: no month navigation, date
  editing or manual completion.
- Target no more than roughly 210 logical pixels of calendar height on a
  phone-sized Home card, including heading and weekday labels. Use compact
  24–28 logical-pixel day cells and preserve accessible touch-independent text.
- Provide accessible names containing the full date and completion/today state.

## Streak reset semantics

Preserve and make visible the canonical rule:

- The streak counts consecutive completed local dates ending today, or ending
  yesterday while today is still in progress.
- If the most recent completion is older than yesterday, at least one complete
  local calendar day was missed and the current streak is `0`.
- Completing a quiz after such a gap starts a new streak at `1`; it does not
  reconnect the older historical run.
- Missing today is not declared until the local date advances. A completion
  yesterday therefore remains an at-risk streak throughout today.
- Historical learning-day records remain stored and visible in the calendar.

The Home presentation must recompute this rule:

- when Home is created;
- after qualifying quiz completion;
- after bootstrap/pull reconciliation;
- when the application resumes/becomes active;
- at local-date rollover while Home remains visible.

Use an injected clock/timezone and a non-blocking rollover mechanism. Do not
poll aggressively and do not perform date arithmetic independently in multiple
QML locations.

## Required regression matrix

- Completed May 1 and May 3; clock May 5 before another completion → current
  streak `0`, zero-state dog/headline, May 1/3 still marked in calendar.
- Completed May 3; clock May 4 without completion → streak remains `1` and is
  shown as at risk because no full day has yet been missed.
- Same state after rollover to May 5 → streak resets to `0` without requiring a
  restart, quiz or sync event.
- Completing May 5 after the gap → new streak `1`; older dates remain history.
- Cover month/year boundaries, leap February and a daylight-saving transition
  using the local date supplied by the injected clock/timezone.

## Acceptance criteria

- [x] Dog row count never exceeds two; capacity is 14, with one face total and
      tail hidden only above capacity.
- [x] All temporary slider/component/build-flag/TODO integration code is
      removed and Home cannot override the canonical streak.
- [x] The compact calendar shows the whole current month within the stated
      phone height target and remains readable on phone/tablet widths.
- [x] Calendar states truthfully represent completed, missed, today and future
      dates without changing persisted learning days.
- [x] A complete missed local day resets the visible headline and dog to zero on
      rollover/resume; a subsequent completion starts at one.
- [x] Yesterday-completed/today-incomplete remains at risk rather than resetting
      early.
- [x] Reset behavior is account-isolated and deterministic across month, year,
      leap-day and DST boundaries.
- [x] Repository, Home QML, lifecycle/resume and release tests pass.

## Non-goals

- Deleting historical learning days when a streak resets.
- A calendar editor, month picker, history browser or manual streak control.
- Changing learning-day sync/API semantics.
- Reintroducing a mutable synchronized streak counter.

## Stop / escalate if

- Correct rollover behavior would require changing the approved local-date
  learning-day contract rather than fixing derivation/refresh presentation.
- Removing the preview tooling would discard any non-test product capability.

## Implementation checkpoint — 2026-11-13

**Frontend commit:** `e1aed55` — `feat(frontend): V2-21-07B add calendar and streak reset`

### Changes

- capped the single-dog composition at two seven-unit rows, retained one face,
  and hid the single tail only when the exact headline count exceeds 14;
- removed `DLStreakPreview`, its Home/Main bindings, build/context flag,
  preview-only tests and every removal marker;
- replaced the ordinal strip with a localized, read-only full-month calendar
  that uses compact cells, locale-injectable weekday ordering, distinct
  completed/today/missed/future states and full-date accessibility names;
- refreshed canonical repository-derived streak state after quiz, sync,
  authentication and application-resume events, plus a non-blocking one-shot
  timer scheduled for the next local-date rollover through an injectable clock;
- extended repository and Home regressions for retained history, missed-day
  reset, fresh completion after a gap, rollover without restart, resume,
  account isolation and month/year/leap-day/DST boundaries.

### Verification

- `cmake --build build-tests --parallel 2` — succeeded (Felgo unavailable, so
  the configured environment built tests/core only).
- `ctest --test-dir build-tests --output-on-failure -R '^(TestHomeUi|TestLearningDayRepository|TestAppStateAuthBootstrap)$'`
  — 3/3 passed.
- `ctest --test-dir build-tests --output-on-failure` — 36/36 passed.
- `rg -n "DLStreakPreview|streakPreview|developerStreakPreview|DELEARNER_STREAK_PREVIEW_ENABLED|TODO: Remove after testing" . --glob '!build*'`
  — no matches.
- `git diff --check` — passed before the frontend commit.

### Limitations and next task

- No packaged Felgo application or physical-device screenshot was available;
  the real QML components were exercised through the project test harness at
  phone, tablet portrait and tablet landscape widths.
- Per the epic guardrail, the root frontend submodule pointer remains deferred
  until the V2-21-08A integration gate. V2-21 stays In Progress; the next task
  is V2-21-08A.
