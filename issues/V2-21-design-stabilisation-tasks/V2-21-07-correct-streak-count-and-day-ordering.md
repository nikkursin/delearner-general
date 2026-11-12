# V2-21-07 — Correct streak count and day ordering

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
**Workspace:** frontend
**Size:** 3 story points
**Dependencies:** V2-21-06
**Figma requirement:** None; fix the explicit observed regression

## Objective

Reproduce and fix the streak presentation that appears to start at 11 and then
count backward through 10, 9, 8 instead of progressing predictably.

## Required diagnosis

Use injected clocks/completed-date fixtures and the V2-21-06 preview control to
separate these possible sources before changing behaviour:

- the repository's derived `currentStreak` value;
- descending storage query order leaking into presentation;
- the recent calendar-date strip being laid out newest-to-oldest;
- multi-row dog segment/day-span calculations above seven;
- right-to-left or reversed layout direction;
- stale QML state after a quiz, sync or preview change.

Record which layer first produces the wrong sequence. Do not rewrite canonical
learning-day history to compensate for a presentation bug.

## Scope

- Keep C++ repository/service code responsible for current-streak date
  arithmetic and QML responsible only for presentation.
- Display the recent calendar strip in chronological left-to-right order, with
  today at the trailing end in left-to-right locales.
- Keep the headline as one truthful current-streak value rather than a
  decreasing sequence of historical counts.
- Ensure dog rows/segments represent increasing streak length correctly for
  values above seven without reversing, clipping or distorting end caps.
- Refresh the presentation deterministically after local quiz completion,
  bootstrap/pull reconciliation and preview-slider changes.
- Add regressions for 0, 1, 2, 7, 8, 10, 11, 14, 15 and 30 days plus month,
  year and daylight-saving boundaries.
- Verify both a real repository-backed streak and a preview-only streak.

## Acceptance criteria

- [x] The reported 11 → 10 → 9 → 8 backward representation is reproducible in
      a test before the fix and absent afterward.
- [x] The recent date strip is oldest-to-newest with today in the expected
      trailing position for left-to-right layout.
- [x] Current streak remains derived from consecutive completed dates and is
      not replaced by QML/test-slider state.
- [x] Values above seven render in the intended row/continuation order without
      reversed growth or distorted dog end pieces.
- [x] Missing today, completed today and broken-streak states remain truthful.
- [x] Repository and Home QML regression suites pass.

## Non-goals

- Changing what qualifies as a learning day.
- Introducing a mutable synchronized streak counter.
- Persisting the temporary preview value.

## Stop / escalate if

- The user-observed sequence cannot be mapped to the current count, date strip
  or dog graphic after the documented viewport/state matrix is exercised.

## Implementation checkpoint — 2026-11-11

**Frontend commit:** `57541de` — `fix(frontend): V2-21-07 correct streak row progression`

### Diagnosis and changes

- injected-clock repository coverage proved canonical streak arithmetic was
  correct for 0, 1, 2, 7, 8, 10, 11, 14, 15 and 30 days, including ordinary
  month, year and daylight-saving boundaries;
- mapped Home label positions proved the recent strip is chronological in the
  left-to-right test locale, with 11 at the trailing edge rather than the
  observed 11 → 10 → 9 → 8 backward order;
- quiz and sync notifications refreshed the canonical headline deterministically,
  and preview changes remained presentation-only;
- the first wrong layer was `DLStreakDog`: it capped output at two rows and used
  a modulo continuation, so 14 represented days rolled backward to 8 represented
  days when the streak reached 15;
- the dog now allocates one row per seven-day span, gives every row its correct
  increasing day span and preserves fixed tail/face end-cap geometry.

### Verification

- pre-fix `ctest --test-dir build-tests --output-on-failure -R '^TestHomeUi$'`
  failed deterministically for 15 and 30 days (actual row count 2; expected 3
  and 5), while the date-order and 1–14-day cases passed;
- `cmake --build build-tests --parallel 2 --target TestLearningDayRepository`
  succeeded;
- `ctest --test-dir build-tests --output-on-failure -R '^TestHomeUi$|^TestLearningDayRepository$'`
  passed 2/2;
- `cmake --build build-tests --parallel 2` succeeded;
- `ctest --test-dir build-tests --output-on-failure` passed 35/35;
- `git diff --check` passed for all selected frontend task files.

### Limitations and next task

- The configured environment builds the frontend core/tests without the Felgo
  application target; repository-backed and real Home QML component tests cover
  the task behavior without a packaged-device visual check.
- Per the V2-21 guardrail, the root frontend submodule pointer remains deferred
  until V2-21-08. V2-21 remains In Progress; the next globally eligible task is
  subject to the Ralph selector.

## Superseding visual follow-up — V2-21-07A

The later physical-phone screenshot
`references/V2-21-04A/current-bad-phone.png` proves that the row-per-seven fix
still duplicates a complete tail and face on every row, permits more than three
rows and leaves the number strip visually inconsistent with the displayed
streak. V2-21-07 remains Done as implementation history. V2-21-07A supersedes
only its dog composition and number-strip presentation decisions.
