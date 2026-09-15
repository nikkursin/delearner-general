# V2-16-07 — Word Details and Edit Word redesign

**Parent epic:** V2-16 — Frontend Design Alignment  
**Status:** Done
**Workspace:** frontend  
**Size:** 5 story points  
**Dependencies:** V2-17-04, V2-16-03, V2-16-06

## Objective

Implement the supplied compact Word Details and Edit Word designs with conditional information by part of speech, while preserving review/statistics data even where the new visual design no longer shows the old statistics card.

## Scope

### Shared details

- German word + translation header.
- Part-of-speech indicator.
- Up to four group memberships from V2-17.
- Examples and translated example where available.
- Memo where available.
- Last reviewed information.
- Edit action.

### Conditional details

- Noun: article and plural information.
- Verb: Präsens (3rd person), Präteritum and Partizip II.
- Adjective: comparative and superlative.
- Adverb: remain a separate part of speech; render only finalized V2-17 fields.
- Phrase: literal translation.

### Edit flow

- Reuse the Add/Edit field model from V2-16-03.
- Save Changes action.
- Delete Word action remains destructive and separate from group-membership removal.
- Show the supplied lightweight `Changes saved` notification/snackbar after successful persistence.

## Design references

See `references/V2-16-07/` for current Word Details/Edit states and target Noun, Verb, Adjective, Adverb, Phrase, editor and saved-notification states.

## Data-preservation rule

The absence of the old large Statistics panel from the target references is a presentation change only. Do not remove review-statistics storage, synchronization or learning behavior.

## Acceptance criteria

- Details render the correct fields for each finalized part of speech.
- Missing optional data does not leave broken/empty structural rows.
- Edit round-trip does not lose fields that are not currently visible.
- Successful save shows the reference notification and refreshed details.
- Global delete remains distinct from removing a word from one group.


## Completion evidence

- Frontend commit `41ce1fd` implements the compact responsive details view, all
  canonical part-of-speech fields, up to four group badges, examples, memo and
  last-reviewed information. Empty optional sections are omitted.
- The existing Add/Edit field model is reused. Successful edits return to fresh
  details with a dismissible, automatically expiring `Changes saved.` notice;
  failed saves remain in the editor. Global deletion requires confirmation and
  stays separate from removing group membership.
- Review statistics are retained. A database test verifies that editing leaves
  the complete review-statistics rows unchanged; editor tests cover hidden-field
  preservation, failed saves, cancellation and destructive confirmation.
- The Adverb screenshot's comparison rows are intentionally omitted: contract
  2.0 defines comparison fields only for adjectives. This follows the task's
  explicit finalized-V2-17-fields constraint; no contract semantics changed.

### Verification

- `cmake --build delearner-frontend/build-tests --parallel 4` — passed.
- `ctest --test-dir delearner-frontend/build-tests --output-on-failure` — all
  25 tests passed, including both canonical fixture suites.
- After the final focused additions, `ctest --test-dir
  delearner-frontend/build-tests -R 'TestWordDetailsUi|TestAppStateAuthBootstrap'
  --output-on-failure` and `ctest --test-dir delearner-frontend/build-tests
  -R 'TestWord(Editor|Details)Ui' --output-on-failure` — passed.
- Offscreen QML rendering of the noun details component was visually inspected
  against the supplied reference; phone/tablet widths are also exercised by tests.
- Frontend staged diff whitespace check passed. Pre-existing Qt Creator settings
  and iOS export-service edits were excluded from the commit.

### External check

Check the complete Felgo shell, safe areas and keyboard interaction on iOS and
Android. The standalone QML runner could render/test the standard Qt components
but could not load the full Felgo page because its `DateFormatter.qml` runtime
resource was unavailable. No physical-device run is claimed.
