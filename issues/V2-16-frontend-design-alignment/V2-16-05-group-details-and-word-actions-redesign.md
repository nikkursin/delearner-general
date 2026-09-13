# V2-16-05 — Group Details and word actions redesign

**Parent epic:** V2-16 — Frontend Design Alignment  
**Status:** Blocked  
**Workspace:** frontend  
**Size:** 5 story points  
**Dependencies:** V2-17-04, V2-16-04

## Objective

Implement the supplied Group Details states and Telegram-like side-swipe word actions on top of the multi-group domain model.

## Scope

- Empty group details state.
- Populated group details state.
- Group name/icon/color header treatment.
- Word rows within the group.
- Side-swipe action reveal similar to Telegram chat actions.
- Delete-from-group action with confirmation bottom sheet.
- Recently deleted/removed feedback with Undo action.
- Move-to-group bottom sheet.
- Move must update memberships rather than delete/recreate the word.
- Under the multi-group model, moving from the current group means removing the current group membership and adding the chosen destination membership atomically from the user's perspective.
- Add Word action is visible as a required group action, but its final destination/reference is explicitly pending.

## Design references

See `references/V2-16-05/`.

## Important distinction

Deleting/removing a word **from a group** is not the same operation as deleting the word entity from the vocabulary. Preserve the word unless the user explicitly performs the global Word delete flow.

## Acceptance criteria

- Empty/populated states switch from actual group membership data.
- Side-swipe reveal is gesture-safe and does not break vertical scrolling.
- Delete confirmation clearly refers to group removal where that is the intended operation.
- Undo restores the removed membership when still valid.
- Move does not violate the four-group limit and does not create duplicate memberships.
- Missing Add Word design is documented and not fabricated.
