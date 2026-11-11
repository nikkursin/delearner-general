# V2-21-07 — Correct streak count and day ordering

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Ready
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

- [ ] The reported 11 → 10 → 9 → 8 backward representation is reproducible in
      a test before the fix and absent afterward.
- [ ] The recent date strip is oldest-to-newest with today in the expected
      trailing position for left-to-right layout.
- [ ] Current streak remains derived from consecutive completed dates and is
      not replaced by QML/test-slider state.
- [ ] Values above seven render in the intended row/continuation order without
      reversed growth or distorted dog end pieces.
- [ ] Missing today, completed today and broken-streak states remain truthful.
- [ ] Repository and Home QML regression suites pass.

## Non-goals

- Changing what qualifies as a learning day.
- Introducing a mutable synchronized streak counter.
- Persisting the temporary preview value.

## Stop / escalate if

- The user-observed sequence cannot be mapped to the current count, date strip
  or dog graphic after the documented viewport/state matrix is exercised.
