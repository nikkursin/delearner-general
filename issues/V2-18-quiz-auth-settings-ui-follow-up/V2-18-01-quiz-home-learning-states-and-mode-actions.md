# V2-18-01 — Quiz home, learning states and mode actions

**Parent epic:** V2-18 — Quiz, Authentication and Settings UI Follow-up  
**Status:** Done
**Workspace:** frontend + root  
**Size:** 5 story points  
**Dependencies:** completed V2-16/V2-17 baseline

## Objective

Replace the existing Quiz landing screen with the supplied target design and expose useful learning-state statistics without changing the current local quiz architecture.

## Scope

- Implement the target Quiz home layout.
- Show four quiz-family cards.
- Translation Quiz and Article Quiz are active.
- The other two quiz-family cards shown by the approved home reference remain visible placeholders and must not start a quiz.
- Show Hard / Learning / Mastered totals using the epic classification rules.
- Show the upcoming/review vocabulary list using existing review/statistics ordering where available.
- Do not introduce a new spaced-repetition algorithm merely to populate this list.
- Add side-swipe action on a word row to **Clear Score** / reset that word's review statistics.
- Clearing score must not delete the Word entity or group membership.
- Tapping the main body of Translation or Article starts that quiz using the application's existing/default configuration without opening custom setup.
- Tapping the three-dot action opens the mode action sheet.
- Action sheet:
  - `Custom` routes to the corresponding custom setup.
  - `Report a problem` is a visual placeholder only in this epic.
  - `Begin` starts the mode using default configuration.

## Design references

See `references/V2-18-01/`.

## Acceptance criteria

- Learning-state counts exactly follow the V2-18 epic rules.
- Multi-group words are counted once.
- Clearing one score returns that word to the unreviewed/Learning state and preserves vocabulary/group data.
- The reset uses the existing review-statistics persistence/sync path.
- Translation/Article direct launch does not require custom setup.
- Placeholder quiz cards cannot accidentally navigate into incomplete flows.
- Layout remains responsive across supported phone/tablet widths.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.

## Completion evidence

- Frontend commit `55d0896` replaces the Quiz landing page with the four-card
  responsive layout, exact Hard/Learning/Mastered totals, review-ordered word
  rows, Clear Score swipe action and the mode action sheet.
- Translation and Article card bodies and `Begin` launch the existing local quiz
  engine with a safe default count. `Custom` keeps using the existing setup
  route; Examples, Writing and `Report a problem` remain non-functional
  placeholders.
- Clear Score resets the existing synchronized review-statistics entity through
  its transactional outbox path. Tests verify that the Word and its multi-group
  memberships remain intact.
- Service tests cover classification boundaries, multi-group deduplication,
  review ordering and default launch with fewer than ten eligible questions.

### Verification

- `cmake -S . -B build-tests -DDELEARNER_BUILD_APP=OFF -DDELEARNER_BUILD_TESTS=ON`
  — passed.
- `cmake --build build-tests -j4` — passed.
- `ctest --test-dir build-tests --output-on-failure` — all 26 tests passed,
  including both contract fixture suites and the existing QML tests.
- `qmllint qml/Views/DLQuizHomePage.qml` — parsed successfully; only the
  established global `appStateManager` context-property warnings remain.
- Frontend staged diff whitespace check passed; the pre-existing Qt Creator
  `CMakeLists.txt.user` change was excluded from the commit.

### External check

Verify final sizing, safe areas, swipe feel and action-sheet presentation in a
full Felgo device build. Felgo is not installed in this execution environment,
so the full application target could not be generated locally.
