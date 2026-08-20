# DE Vocab Learner — System Concept

## Status

Canonical system document for the current project direction.

This document supersedes earlier architectural assumptions when they conflict with the decisions recorded here. Historical documents are not part of the active canonical set.

## Product State

- MVP1 is implemented on the previous UI design.
- The current implemented vocabulary, group, quiz, review-statistics, settings, import/export and related free functionality is considered the free core product.
- The next major technical milestone is authenticated multi-device synchronization of the current personal learning data.
- After the authenticated/synced free product is stable and aligned with the current Figma design, payments/subscriptions are introduced.
- Sharing and other cross-user functionality are future features and are not part of the current implementation scope.

## System Shape

DE Vocab Learner is an account-based, offline-capable vocabulary-learning application.

The system consists of:

1. A Qt/QML client application.
2. A local SQLite database used as the immediate working store.
3. A Qt/C++ backend.
4. PostgreSQL as the backend canonical current-state database.
5. A versioned sync/API contract connecting client and backend.
6. A root coordination repository that contains frontend and backend repositories as Git submodules and owns cross-repository documentation, issues, integration tooling and agent instructions.

```text
Qt/QML Client
    |
    | local-first operations
    v
SQLite
    |
    | versioned synchronization contract
    v
Qt/C++ Backend
    |
    v
PostgreSQL
```

## Authority Model

The system uses hybrid authority.

### Personal learning data

Personal learning data is:

- editable locally;
- immediately visible locally;
- usable offline after initial authentication;
- synchronized through the backend;
- represented as canonical current state in PostgreSQL.

The backend is authoritative when devices disagree, but normal personal-data editing does not wait for backend confirmation.

### Backend-authoritative areas

The backend is authoritative for:

- user accounts;
- authentication and sessions;
- registered devices;
- synchronization conflict resolution;
- canonical cloud state;
- subscriptions and entitlements;
- future cross-user/shared functionality;
- future server-dependent premium functionality.

## Authentication Model

An account is required to use the application.

Initial use requires internet access and successful authentication. There is no guest mode.

Supported product direction:

- email/password;
- Sign in with Apple;
- Google sign-in.

Multiple identities may be linked to one backend user account.

Matching verified email addresses may suggest an existing account, but identities must never be merged automatically from email equality alone. Linking requires explicit authentication/verification and confirmation.

After the initial successful sign-in, the free core remains usable offline indefinitely. Free functionality must not be disabled merely because the backend has not been contacted recently.

## Free and Premium Scope

### Free core

Everything currently implemented/designed belongs to the free core unless explicitly changed later, including:

- vocabulary CRUD;
- groups;
- current quiz flows;
- review statistics;
- current settings;
- basic vocabulary synchronization;
- offline use after initial authentication.

### Future premium direction

Potential premium functionality includes:

- advanced statistics;
- advanced spaced repetition;
- AI-generated examples/explanations/content;
- grammar/media features;
- advanced quiz modes;
- cloud-heavy functionality;
- plan-based higher limits;
- sharing/cross-user features.

These are future directions, not current implementation requirements.

## Premium Entitlement Rules

Backend entitlement state is canonical.

The client may cache entitlement state for offline use. If there has been no valid backend payment confirmation for more than 48 hours, premium functionality is disabled until entitlement can be confirmed again.

This 48-hour rule applies to premium entitlement validation, not to free-core authentication availability.

When premium becomes inactive:

- free-compatible user-owned data remains;
- premium-only derived data is retained for 30 days;
- after 30 days, premium-only derived data may be deleted.

Subscription cancellation stops renewal but premium remains active until the already-paid store entitlement expires.

Direct account deletion is different: intentional account deletion removes the account and all related backend and local user data and returns the application to sign-in.

## Payment Direction

Initial payment platform scope:

- iOS: Apple native in-app subscriptions;
- Android: Google Play native subscriptions;
- RevenueCat is the preferred normalization/integration layer;
- backend remains the canonical entitlement authority;
- direct web payments are out of scope initially.

Premium belongs to the backend user account, not to a device. A purchase made through one supported store unlocks the same account on other supported devices.

The product should prevent duplicate active subscriptions where possible and expose one effective entitlement state even if provider/store transaction history contains multiple records.

## Offline Behavior

After initial authentication, normal free personal-data operations are optimistic and local-first:

```text
user action
→ SQLite transaction
→ UI updates immediately
→ durable sync outbox event created
→ backend synchronization later
→ automatic reconciliation if backend canonical state differs
```

The application should synchronize conservatively and automatically when:

- the app is active and network is available;
- the app resumes;
- connectivity returns.

Manual sync may exist as a fallback or diagnostic tool, but continuous aggressive background polling is not required.

## Quizzes and Learning Progress

Current quizzes are local-only.

The backend is not required to generate or run existing quizzes.

Quiz outcomes update local review statistics, and review statistics synchronize across devices.

Raw/full quiz session history is not synchronized in the current scope. Server-side quiz-history storage may be introduced later for advanced analytics or premium features.

## Settings

### Synchronized settings

Account-level learning preferences synchronize, including examples such as:

- native language;
- quiz defaults;
- learning preferences;
- other account-level learning settings.

### Local-only settings

Device/UI-specific state remains local, including:

- theme;
- navigation state;
- transient filters/search;
- layout/window state;
- device-specific UI preferences.

## Sharing Direction

There is no sharing functionality in the current scope.

The backend should nevertheless model explicit ownership of personal entities from the beginning.

Future direction:

- both individual words and groups may be shared;
- copy-on-share is the initial model;
- the recipient receives an independent copy;
- later edits are independent;
- live collaborative ownership may be considered later but is not part of the current architecture.

No public publishing/community space is assumed.

## Figma and Product Truth

Figma is a strong source of product and UX truth where intent is clear.

It may define:

- navigation flow;
- required fields;
- available user actions;
- quiz flow;
- user-facing state transitions;
- free/premium gating;
- relationships implied by screens.

Authority precedence:

1. Explicit current product decisions.
2. Figma where product intent is clear.
3. Current working implementation.
4. Canonical architecture documents.
5. Historical/reference material.

When Figma and implementation disagree, the discrepancy must be inspected explicitly. Small/local alignment is allowed when intent is clear. A change with strong architectural or structural impact requires user approval before implementation.

New meaningful user-facing flows/screens should be defined in Figma before implementation. Small local UI changes may be implemented directly if they do not change product behavior.

## Current Major Delivery Sequence

1. Authenticated multi-device sync of current personal data.
2. Stabilize and align the current free product with the current Figma design.
3. Add payments/subscriptions and entitlement handling.
4. Add future premium and cross-user functionality incrementally.

## Repository Model

The project should use a root coordination repository containing the frontend and backend as Git submodules.

```text
DELearner/
├── AGENTS.md
├── CLAUDE.md
├── docs/
├── issues/
├── scripts/
├── frontend/   # Git submodule
└── backend/    # Git submodule
```

The root repository owns:

- canonical roadmap;
- canonical system/product/shared-contract documentation;
- cross-repository issues;
- end-to-end acceptance criteria;
- integration and contract tests where feasible;
- shared development environment;
- orchestration scripts;
- exact compatible frontend/backend submodule revisions;
- agent workflow rules.

Child repositories own:

- implementation;
- local unit/component tests;
- repo-specific technical documentation;
- truly local maintenance issues.

Cross-system tasks start from the root workspace. Purely local tasks may start directly inside the relevant child repository.
