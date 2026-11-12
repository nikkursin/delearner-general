# V2-21-08 — Run the design-stabilisation regression gate

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Ready
**Workspace:** root + frontend + backend
**Size:** 3 story points
**Dependencies:** V2-21-02 through V2-21-07, V2-21-04A, V2-21-07A
**Figma requirement:** None; do not access or modify Figma

## Objective

Prove the V2-21 auth, responsive-shell, manual-sync and streak changes work
together without weakening authentication, offline use or synchronization.

## Verification matrix

### Authentication

- Valid Create account with Name, Email, Password and matching Repeat password.
- Invalid/empty name, malformed email, weak password and mismatch blocked in
  the client; backend rejection proven independently.
- Existing account Sign in and Sign in again recovery.
- Duplicate normalized email and mapped backend errors.
- Apple/Google placeholders visible and inert on both pages.
- Successful auth continues through device registration, bootstrap and first
  sync without losing pending local work.

### Home and responsive shell

- Manual refresh uses the existing coordinator with the approved transparent
  idle and error SVGs; only a user-triggered manual sync spins, and resolved
  idle/automatic-sync states remain static.
- Phone portrait/landscape, iPad portrait/landscape and wide viewport geometry.
- Rotation/resizing with Home, Quiz, Add Word, Words, Groups and Profile.
- Bottom navigation safe-area/content clearance.

### Streak

- Repository-backed 0, 1, 7, 8, 10, 11, 14, 15 and 30-day states.
- One face total, at most one tail total and no more than three dog rows,
  including tail-hidden overflow above 21 days.
- Ascending streak ordinals ending at the displayed count, including preview
  26 → `20 … 26`.
- Local completion, offline state, bootstrap and two-device reconciliation.
- Preview slider changes presentation only in development builds.
- Release build has no visible, focusable or accessible preview control.

## Required evidence

- Record root, frontend and backend revisions and pre-existing working-tree
  changes before verification.
- Run focused frontend QML/C++ tests, the complete relevant frontend suite,
  backend auth tests and root auth/integration regressions.
- Compare the auth implementation with the V2-21-01 local UX contract.
- Record a physical iPad landscape result when available; do not claim it from
  viewport tests alone.
- Inspect logs and requests for password, Repeat password, token, raw auth body
  and full-email leakage.
- Record release-build inspection of the temporary streak tooling.

## Acceptance criteria

- [ ] All verification-matrix cases have a pass/fail result and command or
      manual evidence.
- [ ] Frontend, backend and root regression suites relevant to V2-21 pass.
- [ ] Auth pages satisfy the V2-21-01 local UX contract and responsive matrix.
- [ ] No auth/bootstrap/offline/account-isolation regression is present.
- [ ] No duplicate sync coordinator or mutable streak counter was introduced.
- [ ] Sync rotation is manual-trigger-scoped and the correct SVG is shown for
      idle, error and recovered states at the approved scale.
- [ ] Dog end-cap/row limits and streak ordinal rules from V2-21-07A pass at
      phone and tablet widths.
- [ ] Production/release UI contains no temporary streak slider.
- [ ] Compatible frontend/backend commits are ready before root submodule
      pointers are updated.

## Completion rule

Do not mark V2-21 or this gate Done when a required environment check has merely
been skipped. Record the limitation and leave the task In Progress unless the
issue explicitly permits that check to remain manual follow-up.
