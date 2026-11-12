# V2-21 — Design Stabilisation Tasks

**Status:** Done
**Workspace:** root + frontend + backend
**Dependencies:** completed V2-19 and V2-20 baselines

## Purpose

Stabilise the newly introduced authentication, Home, responsive-shell and
learning-streak experiences without changing the established offline, sync or
account-isolation semantics.

This epic activates the authentication-screen and registration-validation work
that was explicitly deferred when V2-18 closed. It also records the later Home
and iPad regressions without reopening completed V2-19/V2-20 history.

## Approved product behaviour

### Authentication entry

- No canonical authentication layout currently exists in Figma. By explicit
  current user decision, V2-21 auth work must not access or modify Figma;
  Codex designs the required pages itself from the existing DELearner visual
  language and V2-21-01 local UX contract.
- **Sign in** and **Create account** are separate pages.
- Sign in remains the default first-use and recovery entry page.
- A user without an account can navigate from Sign in to Create account, and a
  user on Create account can return to Sign in.
- Both pages show Apple and Google authentication controls as clearly disabled
  or **Coming soon** placeholders. They must not start a fake provider flow.
- Create account contains Name, Email, Password and Repeat password fields.
- The new frontend requires Name during account creation. The backend stores a
  supplied display name, while remaining compatible with already released
  clients/accounts that do not have one.
- Registration performs the same basic email and password validation in the
  client and backend. Repeat password is a client-only confirmation and is
  never sent to or stored by the backend.
- This epic adds syntax/strength validation only. Email ownership verification,
  password reset and production Apple/Google authentication remain out of
  scope.

### Home and responsive shell

- Manual sync remains a secondary fallback using the existing sync coordinator
  in the top-right of Home. The original white-background
  `references/500px-Refresh_icon.png` treatment is rejected by V2-21-04A and is
  replaced by transparent, properly scaled idle/error states. Rotation occurs
  only during a sync triggered by that Home control.
- Phone, tablet and desktop-sized layouts use responsive width/safe-area rules.
  iPad landscape must use the available viewport rather than centring a
  portrait-sized surface between black side bars.
- The shared bottom navigation sits visually near the bottom while still
  respecting the real platform gesture/safe-area inset.

### Learning streak

- The canonical streak remains derived from account-owned completed learning
  dates. No mutable streak counter is introduced.
- The displayed count and streak-day ordinal sequence must progress in the
  expected ascending direction and remain correct for values above seven.
- The dog is one bounded composition: at most three rows, one face total and at
  most one tail total. Above 21 days the tail is hidden to show that the body
  continues beyond the visible range.
- Home shows ascending streak-day ordinals ending at the displayed count rather
  than unrelated calendar day-of-month labels.
- A temporary developer-only Home slider may override only the displayed
  streak value for visual testing. It must not create, persist, upload or
  acknowledge learning-day data.
- Every temporary slider integration point is marked exactly
  `// TODO: Remove after testing` and is isolated for one-step removal.

## Execution order for Ralph/AFK

Task identifiers are stable; use this priority order:

| Priority | Task | Status | Dependency |
|---|---|---|---|
| 1 | V2-21-01 — Freeze local split-authentication UX contract | Done | none |
| 2 | V2-21-02 — Add registration contract and backend validation | Done | V2-21-01 |
| 3 | V2-21-03 — Implement split authentication pages and client validation | Done | V2-21-01, V2-21-02 |
| 4 | V2-21-04 — Move manual sync to a Home refresh control | Done | completed V2-20-05 |
| 5 | V2-21-04A — Refine Home sync-control visual states | Done | V2-21-04 |
| 6 | V2-21-05 — Fix iPad landscape and bottom-navigation geometry | Done | completed V2-16-01, V2-20-05 |
| 7 | V2-21-06 — Add a removable streak preview slider | Done | completed V2-20-04 |
| 8 | V2-21-07 — Correct streak count and day ordering | Done | V2-21-06 |
| 9 | V2-21-07A — Fix single-dog and streak-number presentation | Done | V2-21-06, V2-21-07 |
| 10 | V2-21-08 — Run the design-stabilisation regression gate | Done | V2-21-02 through V2-21-07, V2-21-04A, V2-21-07A |

V2-21-04A and V2-21-07A were independently dependency-ready and are now Done.
V2-21-08 completed the epic after all implementation tasks.

For each task, Ralph/AFK must:

1. inspect the root and affected child working trees before editing and preserve
   unrelated user changes;
2. read the task, named dependencies, affected child `AGENTS.md`, focused tests
   and implementation files only;
3. implement the smallest change satisfying the acceptance criteria;
4. run focused tests and the relevant child suite;
5. append an implementation checkpoint with files changed, commands, results,
   limitations and the next task;
6. leave the task `In Progress` when required verification is missing and mark
   it `Done` only when every acceptance criterion is evidenced.

## Guardrails

- Preserve initial-online-authentication and offline-after-sign-in behaviour.
- Preserve V2-19-07 sign-out, reauthentication, pending-outbox and account
  isolation rules.
- Provider placeholders never fabricate success, tokens or linked identities.
- Auth-flow agents must use the V2-21-01 local UX contract and must not call
  Figma tools or modify the canonical Figma file for this flow.
- Client validation improves feedback; backend validation remains authoritative.
- Never log passwords, password strength inputs, tokens, full emails or raw
  authentication bodies.
- Do not replace automatic sync with the manual refresh control.
- Do not fix tablet layout with device-name checks or one iPad-only pixel offset.
- Do not mutate learning-day history to make the streak graphic look correct.
- Do not update root submodule pointers until compatible child commits and the
  V2-21-08 gate are ready.

## Completion

V2-21 is Done only when V2-21-01 through V2-21-08, V2-21-04A and V2-21-07A are
Done, frontend/backend/root tests pass where applicable, an iPad landscape
check is recorded, and a release build contains no visible or accessible streak
preview control.
