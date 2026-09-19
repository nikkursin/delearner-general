# V2-19-05 — Debug sign-in and account-creation regressions

**Parent epic:** V2-19 — Post-Redesign Stabilization  
**Status:** Ready  
**Workspace:** frontend + backend + root  
**Size:** 5 story points  
**Dependencies:** completed authentication/sync baseline, completed V2-17-05

## Objective

Identify and fix the functional regressions that prevent reliable sign-in to an existing account and reliable creation of a new account.

## Observed symptoms

- Existing-account sign-in can reach: `Could not prepare your vocabulary. Check your connection and sign in to try again.`
- Creating an account may report that the email/account cannot be created or fail with a generic account-creation error.

## Investigation order

1. Inspect the current frontend authentication state machine, session handling, bootstrap path and error mapping.
2. Inspect backend registration/sign-in handlers, database constraints, transaction boundaries and returned status/error bodies.
3. Inspect V2-17-05 and related regression tests to determine why the pre-existing-local-vocabulary/bootstrap path still fails.
4. Reproduce with automated/integration tests where possible:
   - successful new-account registration;
   - duplicate-email registration;
   - successful existing-account sign-in;
   - sign-in with existing local vocabulary;
   - bootstrap with empty local database;
   - invalid credentials;
   - network/backend failure after authentication.
5. Only if code/tests cannot isolate the problem, ask the user for runtime logs with exact capture instructions.

## Log-request rule if needed

Do not ask vaguely for "the logs." Specify:

- which frontend process/device;
- which backend process/container;
- the exact action to reproduce;
- the timestamp/window to capture;
- the expected endpoint/status information to include.

Never request passwords, session tokens, authorization headers or other secrets. If logging currently prints them, redact them before sharing.

## Fix requirements

- Distinguish authentication failure from post-auth bootstrap/sync failure.
- Existing-account sign-in must not fail merely because local vocabulary already exists.
- Duplicate account/email cases must return a specific, actionable result rather than a generic creation failure.
- Generic server/network failures must remain distinguishable from validation/duplicate-account errors.
- Preserve offline-after-initial-auth behavior.
- Do not redesign the login page in this task.

## Current reference

See `references/V2-19-05/`.

## Acceptance criteria

- New-account registration succeeds for a valid unused account.
- Duplicate registration has deterministic behavior and clear error mapping.
- Existing valid account can sign in and bootstrap/reconcile without losing pending/local vocabulary.
- Relevant frontend/backend automated tests cover the reproduced root cause.
- No credentials/secrets are added to logs.


## Interaction quality

- Keep page transitions, bottom sheets, swipe gestures, answer-state changes and progress updates smooth rather than abrupt.
- Reuse existing project animation/easing constants where available instead of introducing unrelated timing values.
- Animations must not block input or the UI thread and must remain responsive on supported iOS/Android phones and tablet-sized layouts.
- Do not add decorative animation unrelated to the interaction being implemented.
