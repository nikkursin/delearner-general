# DE Vocab Learner Root Coordination Repository

This repository coordinates the Version 2 DE Vocab Learner work across the
frontend and backend Git submodules. It owns cross-repository documentation,
issues, integration scaffolding, and the pinned compatible child revisions.

Implementation ownership remains in the child repositories:

- `delearner-frontend/`: Qt/QML/Felgo client, local SQLite, client tests.
- `delearner-backend/`: Qt/C++ backend, PostgreSQL persistence, backend tests.

## Agent Entry Points

Start from these root files before changing cross-repository work:

1. `AGENTS.md` for repository ownership, reading order, scope, and commit rules.
2. `issues/00-VERSION-2-ISSUE-INDEX.md` for Version 2 epic order.
3. The selected epic and subtask under `issues/`.
4. Canonical docs referenced by the selected issue.

Canonical source-of-truth documents:

- `docs/00-SYSTEM-CONCEPT.md`
- `docs/01-SHARED-DATA-CONTRACT.md`
- `docs/02-SYNC-PROTOCOL.md`
- `docs/03-PRODUCT-ROADMAP.md`
- `docs/04-VERSION-2-PLAN.md`
- `docs/07-ISSUE-PLANNING-RULES.md`

## Submodules

Initialize child repositories after a fresh clone:

```sh
git submodule update --init --recursive
```

The root repository pins exact frontend/backend revisions. Do not casually
update submodule pointers; root commits should represent a compatible system
state.

## Shared Integration Environment

The root owns shared integration scaffolding only. Child repositories keep their
own build and test logic.

Initialize a fresh checkout:

```sh
./scripts/bootstrap.sh
```

Prepare local environment values:

```sh
cp .env.example .env
```

Then start the shared backend dependencies from the root:

```sh
docker compose up -d postgres
```

When backend-container testing is useful, run:

```sh
docker compose up --build backend
```

The Compose scaffold exposes PostgreSQL for Version 2 backend persistence work
and passes database connection variables to the backend container. Local secrets
belong in `.env`, which is ignored by Git.

## Root Orchestration Commands

Root commands are thin entry points. They initialize or invoke child repository
build/test systems without duplicating child CMake logic.

Build both child repositories:

```sh
./scripts/build-all.sh
```

Build a single child repository:

```sh
./scripts/build-all.sh frontend
./scripts/build-all.sh backend
```

Run root smoke checks and child CTest suites:

```sh
./scripts/test-all.sh
```

Run only root smoke checks when platform-specific child prerequisites are not
available:

```sh
./scripts/test-all.sh root
```

Run the current root integration smoke gate:

```sh
./scripts/run-integration.sh
```

Print the root-owned Version 2 schema and sync/API compatibility baselines:

```sh
./scripts/contract-diagnostics.sh
```

The scripts use `./build` for root-owned generated output by default. Set
`DELEARNER_BUILD_ROOT`, `BUILD_TYPE`, `CMAKE_GENERATOR`, or
`CMAKE_BUILD_PARALLEL_LEVEL` to override local build behavior.

## Current Scope

Version 2 adds authenticated, account-based, offline-capable multi-device sync
for the existing free product. It does not include payments, premium features,
sharing, new quiz families, or a broad Version 3 UI redesign.
