# V2-16-06 — Words list, search, filters and swipe actions

**Parent epic:** V2-16 — Frontend Design Alignment  
**Status:** Blocked  
**Workspace:** frontend  
**Size:** 5 story points  
**Dependencies:** V2-17-04, V2-16-01

## Objective

Replace the current Words list presentation with the supplied responsive loading/empty/list design and add word-type filtering plus side-swipe actions.

## Scope

- Words skeleton/loading state.
- Empty Words state.
- Populated Words list.
- Search German word or translation.
- Sort control.
- New Word action.
- Part-of-speech filters directly below search.
- Filters support the finalized types from V2-17 and may be combined where the supplied toggle treatment indicates multi-selection.
- Compact word rows/cards with translation, part of speech and group membership indicators.
- Do not assume a word has only one group; the row must remain layout-safe for multi-group data.
- Side-swipe delete action matching the interaction direction used in Group Details.

## Design references

See `references/V2-16-06/`.

## Acceptance criteria

- Skeleton is shown while data is unresolved; empty state only after a completed zero-result load.
- Search and filters compose correctly rather than replacing each other's criteria.
- Clearing filters/search restores the full local result set.
- Side-swipe remains compatible with list scrolling.
- Layout works across supported phone/tablet widths.
- Existing vocabulary CRUD behavior remains intact.
