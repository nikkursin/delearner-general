# V2-21-10 — Run calendar-dog and quiz-layout regression gate

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
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

- [x] Every verification-matrix case has a recorded pass/fail result and exact
      command or manual evidence.
- [x] The calendar uses fixed circles and one dog across all touched rows without
      changing canonical reset/history semantics.
- [x] Both quiz layouts satisfy the prompt, wide-option, bottom-placement and
      constrained-height requirements without behavior regressions.
- [x] Relevant focused, frontend-suite and root checks pass.
- [x] A compatible frontend commit exists before the root submodule pointer and
      epic/index status are updated.
- [x] V2-21 is marked Done only after all failures are resolved or explicitly
      returned to the owning implementation task.

## Completion rule

Keep this task Blocked until both dependencies are Done. Once started, keep it
In Progress if any required geometry, reset, quiz-behavior or suite check fails;
do not close the epic from a visual spot check alone.

## Regression-gate checkpoint — 2026-11-13

**Result:** Done. The compatible frontend revision is `8e2aba7`, containing
completed V2-21-07C (`3894f3f`) and V2-21-09. The root started at `eacf68e` and
the backend remained clean at `48cb5a7`. Before verification, the frontend had
one unrelated user change in `qml/Views/DLHomePage.qml` that reduces the manual
sync error mark from 24 to 18 logical pixels; it was preserved and excluded
from this task.

### Verification matrix

| Case | Result | Evidence |
|---|---|---|
| Fixed circles in 28-, 29-, 30- and 31-day months at phone/tablet widths | Pass | `TestHomeUi::test_calendarMonthLengthsAndResponsiveGeometry` and `test_fixedCircleAndDogGeometryAtSupportedWidths` cover 320/360/393 phone, 768 tablet portrait and 1024 tablet landscape geometry, fixed 30–34 px circles and bounded calendar width/height. |
| One-row and two-through-all-row streak tracks | Pass | `TestHomeUi::test_integratedDogTrackAcrossRequiredRows` covers zero, one, dates 9–12, two rows, three rows and all six rows, including connector counts. |
| One face, at most one tail and hidden off-month tail | Pass | The integrated-track rows assert endpoint counts; `test_streakBeginningBeforeMonthHidesTailAndKeepsOneFace` proves the off-month continuation case. |
| Date layering, wrapping and non-interactive decorative pieces | Pass | `test_fixedCircleAndDogGeometryAtSupportedWidths` asserts day z-order above the body and ignored endpoint accessibility; the integrated-track rows assert week connectors and represented date counts. |
| Zero, at-risk, reset, rollover, post-gap and preserved history | Pass | `test_truthfulStateVariants`, `test_atRiskStreakUsesYesterdayAndMonthBoundaryStaysTruthful`, `test_historicalCompletionDoesNotExtendCurrentDog`, `test_rolloverResetsMissedStreakWithoutRestartAndPreservesHistory` and the learning-day repository/contract tests passed. |
| Large framed Translation and Article prompts, including wrapped text | Pass | `TestTranslationQuizSessionUi` and `TestArticleQuizSessionUi` assert the prompt stages, flexible-space ordering, 104 px preferred stage, and absence of prompt/option elliding or line caps. |
| Full-width phone options and tablet width cap | Pass | `TestQuizSessionLayoutUi` exercises the shared answer-width equation at 320/360/393/768/1024 px, a landscape safe-area case, 44 px minimum targets and the 560 px tablet cap. |
| Bottom placement, constrained heights, safe areas and feedback stability | Pass | Both session checks assert bottom alignment, safe-area padding, reserved 104 px feedback/action space and the existing bounded Flickable fallback; shared ordering keeps the answer region below the prompt. |
| Back/progress/results/scoring/exactly-once statistics | Pass | The full suite passed `TestQuizService`, `TestQuizRepository`, `TestQuizResultsUi` and both session checks; service coverage includes duplicate-answer idempotence, progress, final results and exactly-once review-stat updates for Translation and Article. |
| Five supplied reference files | Pass | Local visual inspection compared all five files. The bad captures document stretched calendar tiles, detached dog and mid-page/narrow quiz answers; the Duolingo composition reference and exported quiz reference support the tested fixed-circle/continuous-track and prompt/wide-bottom-answer hierarchy without importing third-party branding or changing semantics. |

### Commands and results

- `cmake --build build-tests --parallel 2` — passed.
- `ctest --test-dir build-tests --output-on-failure -R '^(TestHomeUi|TestTranslationQuizSessionUi|TestArticleQuizSessionUi|TestQuizSessionLayoutUi)$'` — 4/4 passed.
- `ctest --test-dir build-tests --output-on-failure -j 4` — 37/37 passed.
- `bash tests/learning_day_v21_contract_fixtures_smoke.sh` from the root — passed.
- Local inspection of `current-bad-phone-calendar.jpeg`,
  `duolinguo-reference.jpeg`, `translation_quiz_bad_phone.jpeg`,
  `article_quiz_bad_phone.jpeg` and `quiz_reference_figma.png` — completed.

### Device evidence and limitation

Representative geometry is automated in the real Home QML harness for narrow
phone, phone, tablet portrait and tablet landscape. Quiz source/layout checks
cover phone, safe-area and tablet width equations plus constrained-height
fallbacks. No packaged iOS/Android build or physical-device screenshot was
available, so this gate does not claim physical-device visual proof.
