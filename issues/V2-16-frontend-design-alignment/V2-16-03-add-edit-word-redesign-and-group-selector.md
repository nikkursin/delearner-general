# V2-16-03 — Add/Edit Word redesign and group selector

**Parent epic:** V2-16 — Frontend Design Alignment  
**Status:** Blocked  
**Workspace:** frontend  
**Size:** 5 story points  
**Dependencies:** V2-17-04

## Objective

Replace the current Add/Edit Word presentation with the supplied responsive design and consume the finalized V2-17 Word/Group semantics.

## Scope

### Base fields

- German word (required).
- Translation (required).
- Part of speech.
- Group memberships.
- German example.
- Translation of the example.
- Memo.
- Save/Save Changes state.

### Part-of-speech behavior

**Noun**
- Article choices: `der`, `die`, `das`, `Plural`.
- Standard singular noun: show plural-form input.
- When `Plural` is selected as the article/state, hide the separate plural-form input because the word itself is plural-only.

**Verb**
- Präsens (3rd person).
- Präteritum.
- Partizip II.

**Adjective**
- Comparative.
- Superlative.

**Adverb**
- Keep Adverb as a separate part of speech for now.
- Follow the supplied Add/Edit reference; do not merge Adjective and Adverb in this task.

**Phrase**
- Literal translation field.

### Group selector component

Implement a reusable group-selection popup/bottom-sheet component:

- supports zero to four selected groups;
- maximum is exactly four for the current product rule;
- existing selections are visible when reopening the selector;
- Apply commits the selected membership set to the editor state;
- UI must not be the only enforcement layer: V2-17 owns canonical validation;
- selected groups must display in the Add/Edit screen without assuming only one group.

## Design references

See `references/V2-16-03/` for current and target states, including Noun, Verb, Adjective, Adverb, Phrase and group multi-selection.

## Acceptance criteria

- Conditional fields switch correctly when part of speech changes.
- Editing an existing word loads and saves all finalized V2-17 fields.
- Group selection cannot exceed four memberships.
- Switching to plural-only noun state hides the plural-form input without leaving stale contradictory UI state.
- Add/Edit layout scrolls correctly on smaller phones and remains usable on tablets.
- No bottom-navigation redesign is implemented here; use the shell from V2-16-01 where applicable.

## Tests

- Component test for max-four group selection.
- Tests for conditional field visibility by part of speech.
- Repository/view-model integration tests for load/save of new fields.
- Regression test for editing an existing word without data loss.
