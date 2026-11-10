# V2-18-07 — Rename Settings to Profile and redesign the page

**Parent epic:** V2-18 — Quiz, Authentication and Settings UI Follow-up
**Status:** Done
**Workspace:** frontend + root
**Size:** 5 story points
**Dependencies:** completed V2-19-07
**Figma requirement:** None; use the supplied local screenshots only

## Objective

Rename the user-facing **Settings** destination to **Profile** and redesign that
page using the supplied V2-19-06 screenshots as visual references. Preserve the
current account, synchronization, statistics and data-safety behavior.

The screenshots are inspiration rather than a literal product specification.
Adopt their useful layout language while keeping DE Vocab Learner's real data,
navigation and controls.

## Design references

Use:

- `../V2-19-post-redesign-stabilization/references/V2-19-06/Screenshot 2026-11-10 at 08.10.01.png`
- `../V2-19-post-redesign-stabilization/references/V2-19-06/Screenshot 2026-11-10 at 08.11.37.png`

The first screenshot supplies the primary Profile direction: a clear account
header, generous spacing, rounded grouped rows/cards, simple icons and strong
action hierarchy. Its account-details example may inform presentation of data
that DE Vocab Learner already owns.

The streak sequence is secondary visual inspiration only. Do not invent daily
streak persistence, calendar rules or reward semantics merely to reproduce it.
If the current model has no reliable streak value, omit the streak component.

Do not copy reference-app branding, names, photographs, bottom navigation,
quiz-specific content or unrelated product features.

## Required scope

### User-facing rename

- Change the page heading and bottom-navigation label from **Settings** to
  **Profile**.
- Update accessibility labels, automated UI expectations and other visible
  copy that names this destination.
- Internal route keys and class/file names may remain `settings` where changing
  them would create unnecessary navigation churn. This task is a product-facing
  rename, not a broad mechanical refactor.

### Profile presentation

- Introduce a Profile header/account summary using information already safely
  available to the client, such as a non-sensitive account label and signed-in
  state.
- A local initials/avatar placeholder is acceptable. Do not implement photo
  selection, upload or backend avatar storage.
- Reorganize the existing statistics, synchronization, account and danger-zone
  content into a coherent responsive hierarchy inspired by the reference.
- Reuse current design tokens, reusable controls and icon assets where
  practical. Avoid a parallel styling system.
- Keep the page scrollable and usable with safe areas on supported iOS and
  Android phones and tablet-sized layouts.

### Preserve and restyle every existing control

The redesign must retain all currently functional Settings actions and present
their buttons/rows in one consistent Profile-page style:

- **Sign in again**, visible when reauthentication is required;
- **Manual sync**;
- **Sign out**, including its confirmation and pending-outbox safety behavior;
- **Delete all vocabulary/groups**, including its destructive confirmation.

Also retain the existing words, groups and local database-size statistics and
the synchronization status/error presentation. Controls may move into more
appropriate Profile sections, but none may disappear, become a dead row or lose
its current state-dependent visibility, enablement, confirmation or error
feedback.

Primary, secondary and destructive actions should share the same rounded visual
language from the updated page while remaining distinguishable through label,
icon, color and confirmation behavior. Do not mix the old button treatment with
the new row/card treatment.

### Useful reference elements only

Useful additions are limited to presentation backed by current capabilities:

- account/session summary;
- compact vocabulary/group statistics;
- clear synchronization health and recovery state;
- grouped Account, Synchronization and Data sections;
- concise supporting text explaining destructive or recovery actions.

Do not add inactive rows or invent backend/product behavior for Sounds,
Notifications, Share with Friends, Help & Support, profile editing, public
usernames, social features, account deletion or streak tracking. A reference
element belongs in the page only when an existing DE Vocab Learner capability
can make it truthful and functional.

## Security and behavior guardrails

- Preserve the completed V2-19-07 **Sign out** and **Sign in again** semantics.
- Never display or log passwords, bearer/session values, full authorization
  data or other secrets.
- Do not expose a different account's identity or transfer local data/outbox
  events across accounts.
- Sign out with pending events remains refused; same-account recovery continues
  to preserve local work and resume synchronization.
- This task does not change auth, sync or database contracts.

## Acceptance criteria

- All user-visible page/navigation naming says **Profile** rather than
  **Settings** where it refers to this destination.
- The Profile layout visibly follows the supplied reference's account header,
  spacing, rounded groups and action hierarchy without copying unrelated
  features.
- Sign in again, Manual sync, Sign out and Delete all vocabulary/groups remain
  present, functional and consistently styled in the redesigned page.
- Existing statistics and sync status/error states remain available and
  readable.
- Reauthentication-required, syncing, sync-failure, signed-in and destructive
  confirmation states have focused QML regression coverage.
- Tests verify the user-facing rename and the continued presence/behavior of
  all four existing actions.
- Existing V2-19-07 frontend auth/account-isolation tests still pass.
- The page remains responsive and scrollable on phone and tablet dimensions;
  physical-device verification is recorded separately and is not inferred from
  automated tests.
- No placeholder control suggests unsupported functionality.

## Non-goals

- Authentication/login screen redesign.
- New profile fields or backend profile schema.
- Avatar upload, sounds, notifications, sharing or support workflows.
- Daily streak persistence or reward logic.
- Account deletion, password reset or email change.
- Auth/session/sync protocol changes.

## Completion checkpoint — 2026-11-10

- Renamed the user-facing destination and page heading to **Profile** while
  retaining the internal `settings` route.
- Added a responsive account summary, rounded grouped sections, compact local
  statistics, persistent synchronization state and consistently styled action
  rows based on the supplied local references.
- Preserved **Sign in again**, **Manual sync**, **Sign out** and **Delete all
  vocabulary/groups**, including their state-dependent availability,
  confirmations and error feedback.
- Added Profile QML coverage for signed-in, reauthentication, syncing,
  sync-failure, destructive confirmation, phone and tablet states.
- Verified the complete frontend suite: 31/31 tests passed.
- Physical-device verification remains a separate human check and is not
  claimed from automated tests.
