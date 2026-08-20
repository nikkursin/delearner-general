# DE Vocab Learner — Version 2 Plan

## Version Goal

Deliver an authenticated, account-based, offline-capable multi-device synchronization layer for the existing free product.

Version 2 is primarily an architecture/data-flow milestone. It must preserve the existing learning behavior unless a change is required for authentication, UUID migration, synchronization, or correctness.

## Version 2 Completion Definition

Version 2 is complete when:

- an account is required and initial sign-in works online;
- a device is registered to the authenticated user;
- the free core remains usable offline after initial authentication;
- words, groups, review statistics and synchronized learning settings exist in canonical PostgreSQL state;
- those entities use canonical UUID identities across client/backend;
- local changes commit immediately and create durable outbox events atomically;
- backend processing is authenticated, idempotent and transactional;
- two devices can bootstrap, push, pull and converge;
- deletes synchronize through tombstones;
- stale devices can recover automatically without silently losing unsynced local work;
- cross-repository integration tests cover the critical flows.

## Recommended Epic / Issue Order

### V2-01 — Root Coordination Repository Foundation

**Scope**

- create the root `DELearner` coordination repository;
- add frontend and backend as Git submodules;
- add canonical docs at root;
- add root `AGENTS.md` / agent workflow;
- add `issues/`, `scripts/` and test-orchestration structure;
- add shared `.env.example` and integration environment scaffolding;
- provide root commands for bootstrap/build/test/integration where feasible.

**Acceptance criteria**

- fresh clone + submodule initialization is documented and reproducible;
- root pins exact compatible frontend/backend revisions;
- root can invoke child test/build commands without duplicating child build logic;
- agents can identify root-vs-local task ownership unambiguously.

**Out of scope**: feature implementation.

---

### V2-02 — Contract and Schema Baseline

**Scope**

- establish initial `MAJOR.MINOR` versions for SQLite schema, PostgreSQL schema and sync/API contract;
- define the concrete v1 entity payloads for words, groups, review statistics and synced learning settings;
- define create/update full-state payloads and delete tombstones;
- define canonical timestamps and transport encodings;
- define validation/compatibility tests for the contract.

**Acceptance criteria**

- frontend/backend use the same semantic contract fixtures;
- optional additive fields are demonstrably forward-tolerant within one major version;
- breaking changes cannot silently pass as compatible minor changes.

---

### V2-03 — Frontend UUID + Migration Baseline

**Scope**

- replace syncable entity integer identity with canonical UUID identity;
- establish the new disposable pre-release SQLite baseline;
- implement real `MAJOR.MINOR` schema-version tracking;
- retain migration infrastructure for all future schema evolution;
- update repositories/services/QML-facing identifiers and tests;
- implement soft-delete/tombstone semantics for syncable entities.

**Acceptance criteria**

- no legacy integer identity is required for syncable entities;
- a clean database is created with the new baseline schema;
- UUID-created data survives normal CRUD and relationships;
- delete paths no longer rely on immediate hard delete where sync requires tombstones;
- tests are enabled and green.

---

### V2-04 — Backend PostgreSQL Domain Baseline

**Scope**

- add PostgreSQL persistence and schema-version migration system;
- model users/ownership-ready domain entities;
- add relational current-state storage for the Version-2 sync domain;
- keep PostgreSQL independent from SQLite table-for-table shape;
- prepare atomic transaction boundary for domain mutation + server sync event.

**Acceptance criteria**

- backend can create/read/update/tombstone canonical user-owned entities;
- ownership is enforced at the persistence/service boundary;
- PostgreSQL schema version is explicit and migration-tested;
- current state does not depend on replaying the whole event history.

---

### V2-05 — Authentication and Account Foundation

**Scope**

- backend user model;
- authenticated sessions/tokens;
- email/password path as the minimum executable auth path unless a concrete issue selects another implementation order;
- provider-identity abstraction that can later support Apple/Google linking;
- initial client sign-in/session bootstrap;
- no guest mode;
- free core remains available offline after initial successful authentication.

**Acceptance criteria**

- unauthenticated users cannot access user sync state;
- authenticated user identity is derived from the session, not trusted from arbitrary payload fields;
- client can reopen offline after prior successful authentication and use free core;
- account boundaries prevent cross-user data access.

**Deferred within this epic unless separately selected**: polished Apple/Google production provider UI.

---

### V2-06 — Device Registration and Lifecycle

**Scope**

- stable backend device identity;
- register/resolve device on authenticated client;
- track device cursor/state;
- support multiple registered devices;
- device revocation behavior;
- reject uploads from revoked device authorization.

**Acceptance criteria**

- one account can register multiple devices;
- device-specific sync cursor is persisted;
- revoked device cannot continue uploading as valid without reauthorization;
- exact plan-based device count remains configurable/deferred.

---

### V2-07 — Frontend Transactional Outbox

**Scope**

- durable SQLite outbox;
- atomic domain mutation + outbox event transaction;
- full-state create/update events;
- tombstone delete events;
- stable `eventId` UUID;
- retry state;
- short rolling acknowledged-event diagnostic history.

**Acceptance criteria**

- every committed syncable local change has a durable event;
- failures cannot commit one side of the invariant without the other;
- retry reuses the same event ID;
- acknowledged events leave the active outbox only after backend acknowledgement.

---

### V2-08 — Backend Mutation Processing

**Scope**

- authenticated event ingestion;
- validation;
- idempotent `eventId` handling;
- LWW conflict resolution based primarily on client `updatedAt`;
- server receipt time tracking;
- atomic PostgreSQL current-state mutation + accepted sync event/server sequence;
- canonical mutation result response.

**Acceptance criteria**

- duplicate delivery is safe;
- accepted mutation and server event cannot diverge transactionally;
- backend returns canonical entity/tombstone result;
- client can reconcile when backend canonical result differs from optimistic local state.

---

### V2-09 — Incremental Pull and Cursor

**Scope**

- monotonically increasing server sequence;
- ordered changes-after-cursor retrieval;
- safe client application and cursor advancement;
- automatic reconciliation of remote changes;
- do not advance cursor past unsuccessfully applied events.

**Acceptance criteria**

- Device B receives Device A changes after its last cursor;
- replay from the same cursor is safe;
- client convergence does not require full bootstrap in normal operation.

---

### V2-10 — New-Device Bootstrap

**Scope**

- authenticated consistent current-state export from PostgreSQL;
- matching server sequence/cursor;
- local SQLite initialization/restore;
- fetch changes after bootstrap sequence;
- transition into incremental sync.

**Acceptance criteria**

- a newly signed-in device reconstructs the user’s supported current personal state;
- changes created during bootstrap are not missed;
- bootstrap does not require permanent server snapshot files.

---

### V2-11 — Automatic Sync Scheduling

**Scope**

- sync when active and connected;
- sync on app resume;
- sync on connectivity restoration;
- process queued local work conservatively;
- manual diagnostic/fallback trigger if useful;
- no aggressive constant polling.

**Acceptance criteria**

- ordinary users do not need to manually synchronize;
- offline edits remain immediate;
- reconnect eventually pushes pending changes and pulls remote changes.

---

### V2-12 — Retention and Stale-Device Recovery

**Scope**

- device cursor-aware server retention;
- configurable maximum event-retention window;
- stale cursor detection;
- incremental recovery attempt first;
- automatic fresh re-bootstrap when required;
- preserve and replay unsynced local outbox during re-bootstrap.

**Acceptance criteria**

- abandoned devices do not force infinite server event retention;
- stale device can recover without manual database reset;
- unsynced local work is not silently discarded during re-bootstrap.

---

### V2-13 — End-to-End Domain Coverage

**Scope**

Verify full Version-2 sync behavior for:

- words;
- groups;
- review statistics;
- synchronized learning settings;
- deletes/tombstones.

**Acceptance criteria**

- create/update/delete propagates across two devices for all in-scope entities;
- group/word relationships remain valid;
- review results created by local quizzes propagate through review statistics;
- device-local settings remain local;
- raw quiz history remains unsynchronized.

---

### V2-14 — Production UX Cleanup for Stable Sync

**Scope**

- expose only necessary auth/sync status/error handling in the current UI;
- hide/remove manual `.devocab` import/export from normal production UI after stable backend sync is proven;
- retain internal import/export capability for tests/debugging/migration verification;
- avoid full UI redesign before Version 3.

**Acceptance criteria**

- user no longer treats file import/export as the normal sync path;
- diagnostic/internal capability remains testable;
- changes are minimal and do not redesign unrelated MVP1 screens.

---

### V2-15 — Root Integration and Release Gate

**Scope**

- root contract tests;
- backend + frontend integration environment;
- two-device scenario harness where feasible;
- auth isolation tests;
- offline/reconnect scenarios;
- conflict/idempotency scenarios;
- bootstrap/re-bootstrap scenarios;
- regression run of existing free-core tests.

**Release gate**

Version 2 cannot be declared complete until the root acceptance criteria pass against pinned frontend/backend submodule revisions.

## Suggested Delivery Slices

To keep Loop issues small, each epic above should be decomposed into independently testable 1–2 point implementation issues when execution begins. Do not create one giant "implement sync" issue.

Recommended slices:

1. workspace/contract foundations;
2. identity/schema foundations;
3. auth/device foundations;
4. push/outbox path;
5. pull/bootstrap path;
6. recovery/retention;
7. domain completion + release gate.

## Version 2 Non-Goals

- Figma-wide redesign;
- premium gating;
- payment integration;
- sharing;
- AI features;
- advanced spaced repetition;
- new quiz families not already part of current free behavior;
- permanent event sourcing.
