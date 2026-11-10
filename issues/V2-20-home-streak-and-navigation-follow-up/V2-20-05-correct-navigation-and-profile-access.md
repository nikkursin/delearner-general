# V2-20-05 — Correct navigation and Profile access

**Parent epic:** V2-20 — Home, Streak and Navigation Follow-up
**Status:** Planned
**Workspace:** frontend + root
**Size:** 5 story points
**Dependencies:** V2-19-08, V2-20-04
**Figma requirement:** None; use supplied local references

## Objective

Make Home the primary entry point, remove Profile from the bottom bar, and
align the existing Profile page more closely with the supplied reference while
keeping current safety controls.

## Navigation behavior

- Authenticated startup lands on Home.
- Bottom navigation order is exactly **Home**, **Quiz**, center **+**,
  **Words**, **Groups**.
- Center `+` retains the canonical Add Word action.
- The top-left Home account/avatar affordance opens Profile.
- Back/navigation behavior from Profile returns to Home without creating
  duplicate page instances or losing tab state.
- Remove Profile only as a bottom-navigation destination. The Profile view
  remains a routed secondary screen; internal legacy `settings` identifiers may
  remain when renaming them would add risk without user-visible value.

## Profile alignment

Follow the second panel of
`Screenshot 2026-11-10 at 08.10.01.png` more closely:

- centered identity/avatar header;
- generous spacing and rounded grouped action rows;
- consistent icon containers, chevrons/toggles and typography;
- phone/tablet responsive scrolling.

Keep the reference rows requested by the user:

- Account Info;
- Sounds;
- Notifications;
- About Us;
- Share with Friends;
- Help & Support.

These are visual placeholders in this task. Mark them clearly unavailable or
coming soon and do not implement storage, permissions, sharing, support or
backend behavior. They must not pretend success when selected.

Preserve the already functional DE Vocab Learner controls:

- Sign in again;
- Manual sync;
- Sign out;
- Delete all vocabulary/groups.

Do not roll back existing behavior for Sign in again, Manual sync or Delete
all. **Sign out** uses the corrected V2-19-08 runtime path.

## Acceptance criteria

- Bottom navigation contains exactly the five approved destinations in the
  approved order and exposes correct accessibility names.
- Profile has no bottom-navigation item and opens from the Home top-left
  affordance.
- The existing Profile design is visibly closer to the supplied header/action
  row composition.
- All six requested reference rows are visible but clearly nonfunctional.
- All four existing real controls remain present; their current confirmation,
  recovery, error and safety behavior is preserved.
- Sign out completes after backend 200/approved 401 and a failed remote
  revocation retains local state.
- Navigation and Profile QML tests cover phone/tablet layouts and route cycles.

## Non-goals

- Implementing the six reference-row product features.
- Avatar upload or profile editing.
- Replacing the existing Add Word flow.
- Authentication-screen redesign.
