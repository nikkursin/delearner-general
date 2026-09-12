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

### Prerequisites

Install the local toolchain before running root build/test commands:

- Git with submodule support.
- CMake 3.16 or newer.
- Ninja, recommended. The scripts use Ninja automatically when available.
- A C++20-capable compiler.
- Qt 6 development packages required by the child projects. Current local
  builds use QtCore, QtSql, QtTest, QtNetwork, QtHttpServer and QtWebSockets.
- Docker with Compose for root integration environment validation and
  PostgreSQL-backed local integration work.
- Felgo only when building the full frontend application target. Without Felgo,
  the frontend CMake project intentionally disables the app target and still
  builds the frontend core library and CTest suite.

On Apple Silicon, ensure the CMake architecture matches the installed Qt build.
For Homebrew Qt under `/opt/homebrew`, use `CMAKE_OSX_ARCHITECTURES=arm64`.

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

Use a clean build root when you want a reproducible proof build:

```sh
DELEARNER_BUILD_ROOT=/private/tmp/delearner-build-proof CMAKE_OSX_ARCHITECTURES=arm64 ./scripts/build-all.sh
```

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

Run the same full test command against a clean proof build root:

```sh
DELEARNER_BUILD_ROOT=/private/tmp/delearner-build-proof CMAKE_OSX_ARCHITECTURES=arm64 ./scripts/test-all.sh
```

Run only root smoke checks when platform-specific child prerequisites are not
available:

```sh
./scripts/test-all.sh root
```

Run the current root integration smoke gate. Authentication/account isolation and
device lifecycle checks must pass before the compiled domain-sync scenarios:

```sh
./scripts/run-integration.sh
```

Run the fail-fast contract and fresh-environment smoke gate. This validates the
root fixtures and pinned child schema/contract versions, starts PostgreSQL and
the backend through Docker Compose, checks the live backend schema reported by
`/health`, and invokes both child CTest entry points:

```sh
./scripts/smoke-gate.sh
```

The gate leaves the Compose services running for subsequent integration work.
Use `docker compose down` when they are no longer needed. Set
`DELEARNER_BACKEND_HEALTH_URL` for an externally exposed backend or
`DELEARNER_SMOKE_SKIP_COMPOSE_START=true` when the compatible backend is already
managed outside this Compose project.

Print the root-owned Version 2 schema and sync/API compatibility baselines:

```sh
./scripts/contract-diagnostics.sh
```

The scripts use `./build` for root-owned generated output by default. Set
`DELEARNER_BUILD_ROOT`, `BUILD_TYPE`, `CMAKE_GENERATOR`, or
`CMAKE_BUILD_PARALLEL_LEVEL` to override local build behavior. Set
`CMAKE_OSX_ARCHITECTURES` on macOS when the active compiler architecture and Qt
framework architecture need to be made explicit.

### Current Build Proof

Verified on 2026-08-21 from this root checkout with pinned submodules:

```sh
DELEARNER_BUILD_ROOT=/private/tmp/delearner-build-proof CMAKE_OSX_ARCHITECTURES=arm64 ./scripts/build-all.sh
DELEARNER_BUILD_ROOT=/private/tmp/delearner-build-proof CMAKE_OSX_ARCHITECTURES=arm64 ./scripts/test-all.sh
./scripts/run-integration.sh
```

Results:

- Frontend configured and built successfully. Felgo was not installed in the
  verification environment, so CMake disabled the full app target and built the
  frontend core library plus tests.
- Backend configured and built successfully, including the `de_backend`
  executable and backend test targets.
- Full `./scripts/test-all.sh` passed: root smoke checks, 7/7 frontend CTest
  tests and 8/8 backend CTest tests.
- `./scripts/run-integration.sh` passed the root environment smoke gate and
  Docker Compose configuration validation.

## Current Scope

Version 2 adds authenticated, account-based, offline-capable multi-device sync
for the existing free product. It does not include payments, premium features,
sharing, new quiz families, or a broad Version 3 UI redesign.

## Current Completion Stage

The project is buildable and has executable root/frontend/backend smoke and
unit coverage for the completed baseline work. Version 2 is not product-complete
or release-ready yet.

Based on `issues/00-VERSION-2-ISSUE-INDEX.md` and the epic status files:

- Done: V2-01 root coordination repository foundation, V2-02 contract/schema
  baseline, V2-03 frontend UUID/migration baseline, and V2-04 backend
  PostgreSQL domain baseline.
- Partially started: V2-07 frontend transactional outbox has completed schema
  and serialization subtasks, but the atomic domain mutation plus outbox write
  subtask is blocked.
- Not yet complete: authentication/account foundation, device lifecycle,
  backend mutation processing, incremental pull, bootstrap/re-bootstrap,
  automatic scheduling, production sync UX, and end-to-end release gates.

In practical terms, the repository is at the Version 2 foundation and
persistence-baseline stage: the coordinated workspace, contracts, frontend UUID
storage baseline and backend PostgreSQL current-state baseline are in place and
buildable, while the authenticated multi-device sync product behavior still has
major planned work remaining.
