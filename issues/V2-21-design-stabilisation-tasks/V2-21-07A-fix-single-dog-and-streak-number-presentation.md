# V2-21-07A — Fix single-dog and streak-number presentation

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
**Workspace:** frontend
**Size:** 3 story points
**Dependencies:** completed V2-21-06, completed V2-21-07
**Figma requirement:** None; follow the explicit current product correction

## Objective

Render one continuous dachshund with only one tail and one face, cap it at three
visual rows, and replace the odd calendar/countdown labels with ascending streak
day numbers that agree with the headline and preview state.

## Observed evidence

Use `references/V2-21-04A/current-bad-phone.png` as the physical-phone
regression reference. It shows:

- four separate full dogs for a 26-day preview;
- a duplicated tail and face on every row;
- excessive card height;
- labels `6 … 12` that look unrelated to the displayed `26 day streak`;
- preview/header/dog/number-strip state that does not read as one system.

## Approved dog-composition rules

- The visual represents one dog, even when its body wraps across rows.
- A non-zero dog has exactly one visible face in total, placed at the end of the
  final visible row.
- For streaks within visible capacity, show exactly one tail in total, placed at
  the beginning of the first row.
- Intermediate rows contain tiled middle-body content only: no tail and no
  face.
- Use at most three rows. With the current seven-day row model, visible capacity
  is 21 day units.
- For streaks greater than 21, render three full visible rows, hide the tail to
  communicate that the dog continues beyond the left/earlier boundary, and
  keep exactly one face at the end of the third row.
- Never duplicate a face or tail to make an individual row look complete.
- The exact headline count remains uncapped; a 26-day streak still says
  `26 day streak` even though the dog shows only the bounded visible portion.
- Keep the complete dog within the streak card and avoid horizontal overflow,
  clipped face geometry or non-uniform scaling of the end assets.

## Approved streak-number rules

The row below the dog represents streak-day ordinals, not calendar
day-of-month values:

- For a displayed streak `N > 0`, show at most seven ascending ordinals ending
  at `N`: `max(1, N - 6) … N`.
- Examples: streak 3 shows `1, 2, 3`; streak 8 shows `2 … 8`; streak 26 shows
  `20 … 26`.
- For streak zero, hide the ordinal/check row and retain the existing first-day
  guidance.
- The temporary V2-21-06 preview uses the preview count for the headline, dog
  and ordinal row together. It must not show preview 26 with unrelated real
  calendar labels.
- Outside preview mode, use only the canonical repository-derived streak count.
- Ordinal presentation must not create, delete or rewrite learning-day rows,
  outbox events or synchronized history.

## Scope

- Refactor `DLStreakDog` into one bounded composition rather than one complete
  dog per row.
- Expose testable row, visible-capacity, overflow, tail-count and face-count
  properties without moving canonical date arithmetic into QML.
- Replace the Home calendar-date label strip with the approved ordinal model.
- Keep real completed dates available in the repository/service for streak
  derivation and sync; this task changes only Home presentation.
- Keep the temporary preview clearly labelled and presentation-only.
- Add focused QML regressions for phone and tablet widths.

## Acceptance criteria

- [x] Streaks 1, 7, 8, 14, 15 and 21 show one tail and one face total across no
      more than three rows.
- [x] Streaks 22, 26 and 30 show no tail, exactly one face, exactly three rows
      and an uncapped truthful headline.
- [x] No intermediate row contains a tail or face.
- [x] Dog body, final face and card bounds remain valid at narrow-phone, phone
      and tablet widths.
- [x] Ordinals are ascending and end at the displayed streak: 3 → `1…3`,
      8 → `2…8`, 26 → `20…26`.
- [x] Streak zero hides the ordinal/check row and retains first-day guidance.
- [x] Preview changes update headline, dog and ordinals together while leaving
      SQLite, outbox and network mutation counters at zero.
- [x] Canonical current-streak derivation, offline capture, sync and account
      isolation remain unchanged.
- [x] Focused Home QML tests and the complete frontend suite pass.

## Non-goals

- Changing what completes a learning day or how consecutive dates are derived.
- Increasing the dog beyond three visible rows.
- Persisting preview or ordinal UI state.
- Reopening V2-21-07 history.

## Stop / escalate if

- Implementing the presentation requires mutating canonical learning-day data
  or changing sync semantics.
- The supplied dog assets cannot form one bounded composition without changing
  their visual content rather than their layout.

## Implementation checkpoint — 2026-11-12

**Frontend commit:** `1d2b109` — `fix(frontend): V2-21-07A fix streak presentation`

### Changes

- bounded `DLStreakDog` at three seven-unit rows and exposed visible-capacity,
  overflow, row-count, tail-count and face-count properties for focused tests;
- composed one continuous dog with a single face, a single tail through day 21
  and no tail above visible capacity, while retaining fixed-size end assets;
- replaced calendar day-of-month labels with up to seven ascending streak-day
  ordinals ending at the real or previewed headline count;
- kept the zero-streak ordinal row hidden and preserved existing first-day
  guidance, canonical repository streak derivation and preview-only mutation
  isolation;
- added phone/tablet regressions for required counts, overflow, intermediate
  rows, asset/card bounds, ordinals and synchronized preview presentation.

### Verification

- pre-fix `ctest --test-dir build-tests --output-on-failure -R '^TestHomeUi$'`
  failed on the new bounded-composition and ordinal assertions as expected;
- post-fix `ctest --test-dir build-tests --output-on-failure -R '^TestHomeUi$'`
  passed 1/1;
- `cmake --build build-tests --parallel 2` succeeded;
- `ctest --test-dir build-tests --output-on-failure` passed 36/36;
- `git diff --check -- qml/Components/DLStreakDog.qml qml/Views/DLHomePage.qml tests/qml/tst_Home.qml`
  passed.

### Limitations and next task

- The configured local environment verifies the Home component through its
  real QML test harness; no packaged physical-device screenshot was captured.
- Per the epic guardrail, the root frontend submodule pointer remains deferred
  until V2-21-08. V2-21 stays In Progress; the next task is V2-21-08.
