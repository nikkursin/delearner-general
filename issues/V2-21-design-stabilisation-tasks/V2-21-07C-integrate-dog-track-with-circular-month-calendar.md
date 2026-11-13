# V2-21-07C — Integrate the dog track with the circular month calendar

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
**Workspace:** frontend
**Size:** 5 story points
**Dependencies:** completed V2-21-07B
**Figma requirement:** None; use the supplied exported references and explicit
current product correction

## Objective

Replace the separate bounded dog graphic and variable date tiles with one
compact calendar composition: every current-month date uses the same fixed-size
circle, while the current consecutive streak is represented by one dachshund
track running behind those date circles and wrapping through every calendar row
that the streak touches.

This task supersedes only V2-21-07B's two-row/14-unit visual cap. It must not
change the completed learning-day data, missed-day reset rule or canonical
streak derivation.

## Visual references

Use both supplied files:

- `references/V2-21-04A/current-bad-phone-calendar.jpeg` shows the current
  problems: stretched date tiles and a dog detached from the calendar.
- `references/V2-21-04A/duolinguo-reference.jpeg` shows the intended spatial
  idea around dates 9–12: dates sit above a continuous progress character/track.

The second file is a composition reference only. Do not copy Duolingo branding,
badges, typography, colors, premium elements or product behavior.

## Approved composition

### Fixed date circles

- Render every real date in the current month inside an equal-diameter circle.
  Grid columns may flex, but the circle itself must not stretch into a square or
  rounded rectangle as the viewport changes.
- Target a compact 30–34 logical-pixel outer diameter on phones, with consistent
  diameter for completed, today, missed and future states. Text and border/fill
  may change by state; geometry must not.
- Keep leading and trailing non-date grid positions blank. Do not draw fake
  circles for adjacent-month dates.
- Preserve legible contrast when a date circle is drawn over the dog body.
  Date circles and labels are always above the body in z-order.
- Keep the current-month card compact. Integrating the dog must not add a second
  dog panel or materially increase the completed V2-21-07B phone height.

### One wrapping dachshund

- Draw the dog only for dates belonging to the canonical **current consecutive
  streak**. Historical completed dates outside the current streak remain marked
  by their normal completed-day circle but do not receive dog body.
- The body is a rounded continuous track behind the applicable date circles,
  similar in spatial concept to dates 9–12 in the supplied reference.
- The dog may run through **all calendar week rows touched by the visible current
  streak**. There is no two-row or three-row cap in this integrated design.
- When a streak crosses a week boundary, finish the row segment cleanly at the
  outer grid edge and continue on the next row. Use a subtle curved/vertical
  connector where it remains clear and compact; otherwise aligned wrapped
  segments are acceptable, but the result must read as one dog rather than a
  separate dog per row.
- Render no more than one tail and one face for the entire calendar:
  - tail at the earliest visible current-streak date when that date is the real
    beginning of the streak;
  - hide the tail when the streak began before the visible month, indicating an
    off-screen continuation;
  - face at the latest visible current-streak date/end;
  - intermediate rows contain body/connector only, never another face or tail.
- A zero streak renders no dog. The yesterday-completed/today-incomplete
  at-risk streak still renders according to the canonical value. A missed-day
  reset removes the dog track while retaining historical completion circles.
- Keep the result polished but restrained: rounded joins, consistent existing
  orange/dark DELearner palette, clear layering and optional short non-blocking
  geometry transitions. Do not add unrelated decorative motion.

## Responsive and accessibility rules

- Derive geometry from the calendar grid, available width and shared spacing
  tokens; do not add phone-model checks or per-device offsets.
- Verify phone, tablet portrait and tablet landscape. Wider viewports may add
  breathing room, but date circles retain equal size and the calendar remains a
  coherent seven-column unit rather than stretching across the whole tablet.
- Preserve full-date/state accessible names from V2-21-07B. The decorative dog
  pieces must not create duplicate focus targets or replace the date semantics.
- Decorative body layers must not intercept pointer or accessibility events.

## Required regression matrix

- Current streak of 0 and 1.
- Streak contained within one row, including a dates-9-through-12-style case.
- Streak crossing two, three and every available week row in 28-, 29-, 30- and
  31-day month layouts.
- Streak beginning before the visible month: tail hidden, one face, all visible
  current-streak dates connected.
- Streak beginning inside the visible month: exactly one tail and one face.
- Week-boundary, month-boundary, leap-February and locale-first-weekday cases.
- Missed-day reset: no dog, historical completed circles retained.
- Equal circle diameter and bounded calendar height at representative phone,
  tablet portrait and tablet landscape sizes.

## Acceptance criteria

- [x] Every current-month date uses the same fixed circular geometry; no state
      produces the stretched rounded squares shown in the bad screenshot.
- [x] The current streak is rendered behind its date circles as one wrapping
      dachshund track across every calendar row it touches.
- [x] The complete calendar contains at most one face and one tail; intermediate
      rows never duplicate either endpoint.
- [x] A streak that began before the visible month hides the tail, while the
      visible body still communicates continuation.
- [x] Historical completions outside the current streak remain distinguishable
      without incorrectly extending the dog through them.
- [x] Reset, at-risk, rollover and post-gap-new-streak semantics from V2-21-07B
      remain unchanged and covered by focused tests.
- [x] The calendar remains compact, responsive, readable and accessible at the
      required phone/tablet sizes.
- [x] Frontend focused tests and the relevant suite pass, with a checkpoint
      recording commands, results, files changed and visual-test limitations.

## Non-goals

- Month navigation, editing dates or manually changing a streak.
- Changing learning-day persistence, synchronization or reset semantics.
- Showing the dog behind unrelated historical completed runs.
- Copying Duolingo assets, badges or product behavior.
- Reopening or rewriting the completed V2-21-07B implementation record.

## Stop / escalate if

- The current-streak dates cannot be identified without changing shared
  learning-day or sync semantics.
- A proposed implementation needs new licensed character artwork instead of
  composing the existing dog assets and calendar primitives.

## Implementation checkpoint — 2026-11-13

**Frontend commit:** `3894f3f` — `feat(frontend): V2-21-07C integrate streak dog calendar`

### Changes

- moved the canonical current-streak visualization into the month calendar and
  removed the detached, two-row `DLStreakDog` component;
- rendered every real day as a fixed 30-logical-pixel circle over one dark
  track that spans every touched calendar row with alternating edge connectors;
- retained one face and at most one tail from the existing dog assets, hiding
  the tail when the real streak begins before the visible month;
- kept historical completed dates outside the canonical current streak marked
  without extending the dog through them;
- added focused geometry, row-wrap, endpoint, rollover, month-boundary,
  leap-month, locale, accessibility and responsive-width coverage.

### Verification

- `cmake --build build-tests --parallel 2` — succeeded; the configured build
  contains the frontend core and test targets because Felgo is unavailable.
- `ctest --test-dir build-tests --output-on-failure -R '^TestHomeUi$'` — 1/1
  passed.
- `ctest --test-dir build-tests --output-on-failure` — 36/36 passed.
- `git diff --check` — passed before the frontend commit.
- `rg -n "DLStreakDog|streakDog" . --glob '!build*'` — no remaining source or
  test integration matches.

### Limitations and next task

- No packaged Felgo application or physical-device screenshot was available;
  the real QML components were exercised by the project harness at 320/393
  phone, tablet portrait and tablet landscape sizes.
- V2-21 remains In Progress. V2-21-09 is the next dependency-ready task;
  V2-21-10 remains blocked on V2-21-09.
