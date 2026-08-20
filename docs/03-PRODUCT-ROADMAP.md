# DE Vocab Learner — Product Roadmap

## Status

Canonical planning document for product/version scope after MVP1.

This roadmap must stay aligned with:

- `00-SYSTEM-CONCEPT.md`
- `01-SHARED-DATA-CONTRACT.md`
- `02-SYNC-PROTOCOL.md`
- `AGENTS.md`

If this roadmap conflicts with those canonical architecture documents, the architecture documents win until the product decision is explicitly changed.

## Current State — Version 1 / MVP1

MVP1 is considered functionally complete on the previous UI design.

Current free core includes the implemented vocabulary-management, groups, quiz flows, review statistics, settings, import/export and related local functionality.

Known pre-Version-2 technical debt may be fixed only when required to safely enable Version 2 or when it is isolated low-risk maintenance. Version 2 must not become a general refactor of MVP1.

## Version Sequence

### Version 2 — Account + Basic Multi-Device Sync

Goal: convert the existing local application into an authenticated, account-based, multi-device free product without changing the core learning experience.

Primary outcome:

```text
sign in
→ registered device
→ bootstrap personal data
→ local CRUD remains immediate/offline-capable
→ changes synchronize automatically
→ second device converges to the same canonical user state
```

Scope:

- root coordination repository and submodule workflow;
- UUID-first local schema baseline;
- real SQLite schema versioning/migrations;
- PostgreSQL canonical domain model;
- account/authentication foundation;
- registered devices;
- synchronized words;
- synchronized groups;
- synchronized review statistics;
- synchronized learning settings;
- tombstones/deletes;
- durable transactional local outbox;
- idempotent backend mutation processing;
- incremental pull/cursor;
- new-device bootstrap;
- automatic conservative sync triggers;
- stale-device recovery/re-bootstrap;
- cross-repository contract/integration tests;
- hide manual import/export from normal production UI after sync is stable, while retaining internal test capability.

Explicitly out of scope:

- redesigning all current screens;
- payments/subscriptions;
- premium features;
- user-to-user sharing;
- cloud quiz execution;
- raw quiz-session history sync;
- collaborative editing;
- speculative new learning features.

Exit condition: two authenticated devices can independently edit the supported personal domain data, work offline, reconnect, and automatically converge through the backend without data loss in normal supported scenarios.

### Version 3 — Current Figma Product Alignment + Free-Core Stabilization

Goal: move the completed free functionality from the old UI design to the current approved Figma product design and stabilize it as the first coherent production-quality free experience.

Scope:

- audit current code against current Figma screens and flows;
- implement meaningful screen/flow changes defined in Figma;
- preserve working Version-2 auth/sync behavior;
- add/complete authentication/account-facing UI required by the product;
- repair known UI/navigation inconsistencies that conflict with the intended design;
- normalize loading, empty, error and offline states across the product;
- remove user-facing manual sync/import-export flows that are no longer part of normal product behavior;
- validate mobile layouts and the existing supported platform targets;
- strengthen UI/component/integration tests around the stabilized flows;
- perform free-core regression testing end-to-end.

Explicitly out of scope:

- payments/subscriptions;
- premium feature development;
- sharing;
- major new learning modes unless they are already part of the approved current Figma free-core design.

Exit condition: the free account-based synchronized product matches the approved Figma intent for all current core flows and is stable enough to serve as the base for monetization.

### Version 4 — Payments, Subscriptions and Entitlements

Goal: introduce commercial account state without destabilizing the free core.

Scope direction:

- Apple in-app subscription flow;
- Google Play subscription flow;
- RevenueCat integration as preferred normalization layer;
- backend-canonical entitlement state;
- account-level premium entitlement across devices;
- 48-hour cached premium entitlement grace behavior;
- subscription cancellation/expiry behavior;
- prevention of duplicate subscriptions where practical;
- premium-only data retention rules;
- account management screens/flows required by payment state;
- entitlement tests across backend/client boundaries.

Version 4 should establish the monetization foundation. It should not automatically include every future premium feature.

### Version 5 — First Premium Learning Features

Goal: add the first genuinely premium learning value on top of the Version-4 entitlement system.

Candidate scope, to be prioritized before implementation:

- advanced statistics;
- advanced spaced repetition;
- advanced quiz modes;
- AI-generated examples/explanations/content;
- grammar/media-related premium capabilities;
- higher configurable limits where product value justifies them.

Only features explicitly selected for Version 5 should be implemented. The list above is a direction pool, not an automatic commitment.

### Version 6+ — Cross-User and Expanded Learning Features

Future direction may include:

- explicit user-to-user word sharing;
- explicit user-to-user group sharing;
- copy-on-share recipient-owned copies;
- further grammar learning functionality;
- richer media/attachment support;
- additional premium learning systems;
- live collaborative ownership only if separately approved later.

No public publishing/community space is assumed by default.

## Planning Rules

1. Versions describe product outcomes, not arbitrary technical batches.
2. Each version should be broken into root-level epics/issues with explicit acceptance criteria.
3. Cross-repository work starts from the root coordination repository.
4. Frontend/backend sub-tasks may add implementation detail but cannot weaken root acceptance criteria.
5. Small repo-local maintenance issues may remain local if they do not change shared contracts or product behavior.
6. Do not pull future-version features forward merely because adjacent code is being touched.
7. Deferred technical constants remain deferred until a concrete issue requires them.

## Immediate Next Action

Create the Version 2 root issue set and execute it top-to-bottom, starting with repository/workspace foundation and data identity/schema baseline before implementing full sync behavior.
