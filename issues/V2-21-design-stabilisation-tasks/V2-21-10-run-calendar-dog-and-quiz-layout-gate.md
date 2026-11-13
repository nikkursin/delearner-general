# V2-21-10 — Run calendar-dog and quiz-layout regression gate

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Blocked — waiting for V2-21-07C and V2-21-09
**Workspace:** root + frontend
**Size:** 2 story points
**Dependencies:** V2-21-07C, V2-21-09
**Figma requirement:** None

## Objective

Verify the integrated calendar dog, fixed date circles and both corrected quiz
layouts together before updating the root frontend submodule pointer and
returning V2-21 to Done.

## Verification matrix

### Calendar and dog

- Equal fixed-size circles for all real dates in 28-, 29-, 30- and 31-day
  months at phone/tablet widths.
- Current streaks contained in one row and crossing two through every available
  calendar row.
- Exactly one face and at most one tail across the whole calendar; hidden tail
  when the streak began before the visible month.
- Correct body/date layering, week-boundary wrapping and no intercepted date
  accessibility/pointer behavior.
- Zero, at-risk, missed-day reset, rollover and post-gap-new-streak cases with
  historical completion circles preserved.

### Translation and Article quiz layouts

- Large framed prompt stage for short and wrapped prompts.
- Full-width phone answer controls and bounded readable tablet width.
- Lower-page answer placement, safe-area spacing and no overlap or unreachable
  content on short/landscape screens.
- Correct/incorrect feedback and continuation action without a large geometry
  jump.
- Existing back, progress, result, scoring and exactly-once review-statistics
  behavior.

### Reference comparison

- Compare representative phone renders to all five supplied follow-up files:
  `current-bad-phone-calendar.jpeg`, `duolinguo-reference.jpeg`,
  `translation_quiz_bad_phone.jpeg`, `article_quiz_bad_phone.jpeg` and
  `quiz_reference_figma.png`.
- Treat the screenshots as hierarchy/composition evidence, not permission to
  copy third-party branding or change quiz/streak product semantics.

## Required evidence

- Record root/frontend revisions and pre-existing working-tree changes before
  editing; preserve unrelated user changes.
- Run focused Home/calendar, learning-day, Translation Quiz and Article Quiz
  geometry/behavior tests.
- Run the complete relevant frontend suite and root learning-day contract checks.
- Record representative geometry or screenshots for phone, tablet portrait and
  tablet landscape; distinguish automated coverage from physical-device proof.
- Confirm the root pointer references a compatible frontend commit only after
  both implementation tasks are complete and verified.

## Acceptance criteria

- [ ] Every verification-matrix case has a recorded pass/fail result and exact
      command or manual evidence.
- [ ] The calendar uses fixed circles and one dog across all touched rows without
      changing canonical reset/history semantics.
- [ ] Both quiz layouts satisfy the prompt, wide-option, bottom-placement and
      constrained-height requirements without behavior regressions.
- [ ] Relevant focused, frontend-suite and root checks pass.
- [ ] A compatible frontend commit exists before the root submodule pointer and
      epic/index status are updated.
- [ ] V2-21 is marked Done only after all failures are resolved or explicitly
      returned to the owning implementation task.

## Completion rule

Keep this task Blocked until both dependencies are Done. Once started, keep it
In Progress if any required geometry, reset, quiz-behavior or suite check fails;
do not close the epic from a visual spot check alone.
