# V2-16-04 — Groups list, create and edit redesign

**Parent epic:** V2-16 — Frontend Design Alignment  
**Status:** Blocked  
**Workspace:** frontend  
**Size:** 5 story points  
**Dependencies:** V2-17-04

## Objective

Replace the current modal-only Groups management experience with the supplied responsive list/create/edit flow.

## Scope

- Groups skeleton/loading state.
- Empty Groups state with Add Group action.
- Populated Groups list with search field, count and per-group overflow action.
- Create Group page.
- Edit Group page.
- Group name, color and icon/logo selection.
- Use a stable cross-platform group-icon value from V2-17; render using platform-appropriate glyph/emoji/icon treatment rather than persisting platform-specific asset IDs.
- Preserve group deletion behavior: deleting a group must not delete the underlying words.
- Group edit screen exposes Save Changes and Delete Group actions as in the target reference.
- Overflow sheet exposes the supplied management actions without inventing missing downstream screens.

## Design references

See `references/V2-16-04/` for current dialogs and target loading/empty/create/list/action/edit states.

## Acceptance criteria

- Loading state does not flash an incorrect empty state while data is unresolved.
- Empty state appears only after successful load with zero groups.
- Create/edit persists name/color/icon through the existing domain flow backed by V2-17.
- List cards remain stable with long names and different device widths.
- Deleting a group preserves words and only removes the deleted membership as defined by V2-17.
- No Add Word subflow is invented; that reference is still pending.
