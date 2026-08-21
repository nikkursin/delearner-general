# AGENTS.md — DE Vocab Learner Root Coordination Rules

## Purpose

This file defines how coding agents work in the root DE Vocab Learner coordination repository.

The root repository contains the frontend and backend as Git submodules and owns cross-repository coordination.

## Repository Responsibilities

### Root repository owns

- canonical system architecture;
- canonical shared data/sync contracts;
- canonical product/cross-repo roadmap;
- cross-repository issues;
- end-to-end acceptance criteria;
- integration/contract tests where feasible;
- shared development environment;
- root orchestration scripts;
- exact compatible frontend/backend submodule revisions;
- agent workflow rules.

### Frontend repository owns

- Qt/QML application implementation;
- SQLite/local storage;
- client-side auth/sync implementation;
- frontend unit/component tests;
- frontend-local technical documentation;
- purely frontend-local issues.

### Backend repository owns

- Qt/C++ backend implementation;
- PostgreSQL/backend storage;
- authentication/session/device handling;
- server-side sync/conflict logic;
- backend unit/component tests;
- backend-local technical documentation;
- purely backend-local issues.

## Mandatory Reading Order for Cross-Repo Work

Before changing code for a cross-repository/product issue, read only what is needed in this order:

1. Current root issue and acceptance criteria.
2. `docs/00-SYSTEM-CONCEPT.md`.
3. `docs/01-SHARED-DATA-CONTRACT.md` when shared entities/contracts are affected.
4. `docs/02-SYNC-PROTOCOL.md` when synchronization is affected.
5. Relevant child-repo `AGENTS.md` / repo-specific docs.
6. Relevant tests.
7. Relevant implementation files only.
8. Figma when UI/product behavior is affected.

Do not scan the entire codebase by default.

## Authority Precedence

When sources disagree, use this precedence:

1. Explicit current user/product decision.
2. Current root issue acceptance criteria, provided they do not contradict canonical product decisions.
3. Figma where product intent is clear.
4. Current working implementation.
5. Canonical architecture documents.
6. Historical/reference material.

Do not silently reinterpret a higher-authority source to fit a lower-authority one.

## Figma Rules

Figma is a strong source of product and UX truth where intent is clear.

For meaningful new user-facing screens/flows:

```text
product decision
→ Figma definition/review
→ implementation
```

Small local UI changes may be implemented directly when they do not alter product behavior.

If Figma and code disagree:

- identify the discrepancy explicitly;
- determine whether code is outdated or design is stale;
- make small/local alignment only when intent is clear;
- if alignment requires a strong structural/architectural code change, ask the user before implementing it.

## Agent Autonomy

Agents have moderate autonomy.

Allowed without additional approval:

- small local refactors required to complete an issue;
- local naming/structure cleanup that preserves behavior;
- additional tests;
- implementation details that stay inside existing boundaries.

Require approval before changing:

- major architecture boundaries;
- shared contract semantics;
- sync semantics;
- database schema strategy beyond the current issue;
- product behavior;
- large Figma/code realignment;
- cross-repo ownership/responsibility boundaries.

Do not perform speculative future-proofing.

## Scope Control

Work only on the current issue.

Do not:

- add unrelated features;
- rewrite working systems unnecessarily;
- introduce premium/sharing functionality into unrelated tasks;
- refactor both repos broadly because one local change is needed;
- change product rules merely because another implementation seems easier.

Prefer the smallest safe change that satisfies acceptance criteria.

## Root vs Child Workspace

Use the root workspace for:

- auth + sync work;
- contract changes;
- product behavior spanning both repos;
- shared data changes;
- integration issues;
- system-level bugs.

Use a child repo directly for:

- isolated frontend maintenance;
- isolated backend maintenance;
- local tests/refactors/bugs that do not alter shared behavior.

If a local issue begins affecting shared contracts/product behavior, escalate back to root context.

## Cross-Repo Issue Model

Cross-repository features use one canonical root issue with explicit frontend/backend subtasks.

Example:

```text
issues/001-auth-and-basic-sync/
├── ISSUE.md
├── frontend.md
└── backend.md
```

The root issue owns end-to-end acceptance criteria.

Child subtasks may add implementation-specific criteria but cannot weaken or reinterpret root behavior.

Purely local repo issues may exist independently when they do not change shared contracts or product semantics.

## Submodule Rules

The root repository pins exact compatible frontend/backend commits.

Do not casually update submodule pointers.

A cross-repo change should normally complete in this order:

1. Read root issue/contracts.
2. Implement/test required frontend changes.
3. Implement/test required backend changes.
4. Run contract/integration tests where feasible.
5. Commit child-repo changes.
6. Update root submodule pointers.
7. Commit root issue/integration result.

The root commit should represent a coherent compatible system state.

## Testing Rules

Tests are mandatory for behavior changes.

### Frontend

Keep frontend unit/component tests in the frontend repository.

### Backend

Keep backend unit/component tests in the backend repository.

### Root

Keep cross-repository contract and integration tests in the root repository where feasible.

Root-level integration tests should verify the end-to-end behavior defined by root acceptance criteria.

Do not mark an issue complete solely because one repository's tests pass when the feature spans both repositories.

## Root Environment and Scripts

The root repository should provide a reproducible shared development/integration environment.

Expected direction:

- `docker-compose.yml` for shared backend dependencies such as PostgreSQL;
- `.env.example`;
- bootstrap tooling;
- root orchestration scripts such as:
  - `scripts/bootstrap.sh`
  - `scripts/build-all.sh`
  - `scripts/test-all.sh`
  - `scripts/run-integration.sh`

Root scripts orchestrate child-repo commands. They must not duplicate child build logic unnecessarily.

## Current Product Constraints

Preserve these rules unless the current root issue explicitly and intentionally changes them:

- account required;
- first launch requires internet/authentication;
- free core works offline indefinitely after initial sign-in;
- current implemented/designed functionality is free;
- current quizzes remain local-only;
- review statistics synchronize;
- account-level learning settings synchronize;
- device/UI-specific state remains local;
- basic sync is free;
- sharing is not implemented now;
- ownership is modeled now for future sharing;
- UUIDs are canonical IDs for syncable entities;
- current development database may be discarded during the pre-release UUID/schema reset;
- future schema changes use explicit migration/versioning infrastructure;
- SQLite and PostgreSQL schemas evolve independently;
- each database schema uses `MAJOR.MINOR` versioning;
- sync/API contract uses independent `MAJOR.MINOR` versioning;
- same contract major versions remain backward-compatible across minor revisions;
- backend stays client-independent;
- create/update events carry full current entity state;
- delete events carry tombstone identity/timestamps;
- local mutations and outbox writes are one SQLite transaction;
- outbox events remain until backend acknowledgement;
- acknowledged events keep only short rolling local diagnostics;
- backend event history is bounded, not permanent event sourcing;
- backend canonical state is PostgreSQL current state;
- conflict resolution is backend-owned last-modification-wins for the current version;
- normal conflict reconciliation is automatic and silent;
- stale devices re-bootstrap automatically when incremental recovery is impossible;
- unsynced local work must be preserved across re-bootstrap;
- backend canonical mutation and accepted sync-event persistence are one backend transaction.

## Premium Rules

Do not implement premium features as part of unrelated issues.

Current direction only:

- backend is entitlement authority;
- RevenueCat is preferred provider-normalization direction;
- Apple/Google native store subscriptions are initial payment channels;
- premium belongs to user account;
- premium cached offline entitlement expires after 48 hours without valid backend confirmation;
- premium-only derived data retention after premium becomes inactive is 30 days;
- intentional account deletion deletes all user-related backend and local data.

## Import/Export

Manual database/package import/export is not a future user sync path.

Once backend sync is stable:

- hide/remove it from normal production UI;
- retain code-level capability only where useful for testing, migration verification or debugging.

## Deferred Decisions

When an issue touches a deferred detail, implement the smallest issue-specific solution and document it locally rather than promoting it to permanent architecture without approval.

Examples:

- retry timings;
- exact event-retention duration;
- exact timestamp sanity thresholds;
- exact device-count limits;
- exact auth library/provider implementation details;
- future sharing permissions;
- advanced premium behavior.

## Definition of Done for Cross-Repo Work

A cross-repository issue is complete only when:

- root acceptance criteria are satisfied;
- required frontend tests pass;
- required backend tests pass;
- integration/contract tests pass where feasible;
- canonical docs are updated if and only if architecture/contract decisions intentionally changed;
- frontend/backend submodule pointers reference compatible commits;
- no unrelated behavior was changed.

## Canonical Figma Design

The canonical DELearner product design is:

https://www.figma.com/design/7kCGSdFGQ79KpRqdaG5Pfp/DELearner?node-id=0-1

Figma file key:

`7kCGSdFGQ79KpRqdaG5Pfp`

Agents working on tasks marked "Figma required" must use this existing file.

Do not create a replacement Figma file.
Do not infer another DELearner file from the authenticated Figma account.
Do not redesign unrelated screens.
