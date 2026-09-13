# V2-16-07 — Word Details and Edit Word redesign

**Parent epic:** V2-16 — Frontend Design Alignment  
**Status:** Blocked  
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
