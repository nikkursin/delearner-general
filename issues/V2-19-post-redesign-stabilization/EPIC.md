# V2-19 — Post-Redesign Stabilization

**Status:** In Progress — V2-19-08 runtime sign-out regression planned
**Workspace:** frontend + backend + root
**Dependencies:** completed V2-16/V2-17 implementation

## Purpose

Restore a reliable authenticated startup and synchronization path, then fix the
remaining regressions discovered after the V2-16/V2-17 redesign/domain work.
Preserve the approved design, domain model and sync architecture; do not solve
these regressions by rolling back completed work.

## Current execution order

The task number is a stable identifier, not the execution priority.

| Priority | Task | Status | Why it is ordered here |
|---|---|---|---|
| 1 | V2-19-08 — Fix runtime sign-out route 404 | Planned | The physical-device backend runtime returns 404 for the checked-in route; verify and repair runtime/build parity before further Profile integration. |
| 2 | V2-19-07 — Add secure Sign out and Sign in again controls | Done | Presented-session revocation, safe local sign-out, same-account recovery and account isolation are covered. |
| 3 | V2-19-04 — Enable Group → Add Word with preselected group | Done | Canonical Add Word routing now preselects the originating group. |
| 4 | V2-19-06 — Fix multi-device authentication and sync regressions | Done | Bootstrap compatibility, rejected-session recovery and secure device/account transition regressions are fixed with automated coverage. |
| 5 | V2-19-05 — Stabilize auth-to-sync startup and add end-to-end diagnostics | Done | Preserved completed diagnostic baseline; do not reopen. |
| 6 | V2-19-01 — Fix Add Word alignment and bottom-navigation position | Done | Independent local UI regression. |
| 7 | V2-19-02 — Fix Words filter alignment and swipe delete | Done | Independent local UI regression. |
| 8 | V2-19-03 — Align Group Details and fix swipe actions | Done | Completed prerequisite for V2-19-04. |

V2-19-01 through V2-19-07 are complete. Completed regression history must not
be reopened or duplicated; V2-19-08 records the newly observed runtime failure.

## Scheduling decision — 2026-11-09

The user explicitly overrode the former gate that delayed V2-19 until V2-18-06
was Done. V2-19-05 may start immediately and has no dependency on V2-18 Quiz UI
work. The future visual redesign of authentication remains deferred; functional
authentication and synchronization reliability are active here.

## Scope

- Add safe, verbose development diagnostics across the complete auth-to-sync
  startup path.
- Fix existing-account sign-in, account creation, device registration,
  bootstrap and first synchronization regressions.
- Preserve unsynced local vocabulary during bootstrap and reconciliation.
- Fix Add Word alignment and shared bottom-navigation positioning.
- Fix Words filter alignment and the broken side-swipe delete affordance.
- Align Group Details and restore its side-swipe actions.
- Enable Group → Add Word routing with the originating group preselected.
- Add secure Settings controls for intentional sign out and same-account
  recovery after an online session is rejected or expires.
- Fix the observed runtime 404 for the sign-out route through a real served
  HTTP regression test and verified development backend path.
- Add focused frontend, backend and root regression coverage.

## Epic-wide evidence and logging rule

Every task must leave a reviewable evidence trail. After each investigation or
implementation phase, record in the task checkpoint:

- the date and phase;
- the exact behavior or hypothesis tested;
- the relevant files changed;
- commands/tests run and their result;
- the diagnostic source and correlation/request ID when applicable;
- the conclusion and next executable step.

For V2-19-05, runtime logging is part of the implementation, not a last-resort
request to the user. Log every meaningful auth-to-sync state transition and
every success/failure exit at the frontend and backend seams. Development logs
may be deliberately verbose and may include operational metadata such as
routes, HTTP status, request IDs, UUIDs, cursor values, event counts, timings,
Qt network errors and stable error codes.

Verbose does not mean secret-bearing. Never log or request:

- passwords, password hashes or salts;
- session tokens, bearer values or `Authorization` headers;
- raw authentication request/response bodies;
- database credentials;
- personal vocabulary or full sync payloads;
- full email addresses or other unnecessary personal data.

Log payload shape/counts and identifiers instead of payload values. Any log
shared outside the local development environment must still be reviewed for
personal or device-identifying metadata.

## Rules

- Existing V2-16 references remain the target design baseline where applicable.
- Fix the smallest underlying cause; do not broadly refactor unrelated QML,
  authentication or synchronization code.
- Keep user-facing errors separate from technical diagnostic messages.
- Diagnostic additions must not change auth, sync, conflict, ownership or
  bootstrap semantics.
- Do not add a third-party logging dependency unless the existing Qt logging
  facilities are proven insufficient.
- Do not redesign the login page in this epic; that remains deferred under
  V2-18 until a target reference is supplied.

## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes
  and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of
  introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive
  on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being
  implemented.

## Epic completion

V2-19 is complete only when:

- V2-19-01 through V2-19-08 are Done;
- the auth → device registration → bootstrap → first sync sequence is
  diagnosable end to end and passes its regression matrix;
- required frontend, backend and root tests pass;
- no secret-bearing logging has been introduced;
- no unrelated product, contract or sync behavior changed.
