# V2-16-01 — Responsive shell and modern bottom navigation

**Parent epic:** V2-16 — Frontend Design Alignment  
**Status:** Done
**Workspace:** frontend  
**Size:** 3 story points  
**Dependencies:** existing navigation baseline

## Objective

Replace the visually heavy five-equal-tab bottom bar with the supplied modern shell treatment while preserving working navigation behavior and keeping the layout responsive.

## Scope

- Implement the curved/raised center-action visual treatment shown in the target reference.
- Keep the central Add action visually prominent.
- Preserve existing navigation ownership and route behavior in this task; do not create a new Home/Profile/Settings screen solely because a mockup contains that label.
- Respect bottom safe area/home indicator on iOS and corresponding Android insets.
- Make width distribution responsive rather than tied to one device width.
- Provide selected/unselected icon/text states consistent with the reference direction.

## Design references

See `references/V2-16-01/`:

- `bottom-navigation-current.jpg`
- `bottom-navigation-target-states.png`

## Acceptance criteria

- Navigation remains functional for all routes that worked before this task.
- Central Add action opens the existing Add Word flow.
- The bar does not overlap scroll content or system gesture areas.
- Layout remains usable on narrower/wider phones and tablet widths.
- No Quiz, Settings/Profile or Home content redesign is introduced.

## Tests

- QML/component tests where already used for navigation.
- Manual navigation check on at least one iOS-size and one Android-size viewport.
- Verify active-state switching and center Add action.
