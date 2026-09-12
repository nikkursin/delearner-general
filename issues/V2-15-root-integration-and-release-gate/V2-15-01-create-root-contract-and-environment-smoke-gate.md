# V2-15-01 — Create root contract and environment smoke gate

**Parent epic:** V2-15 — Root Integration and Release Gate  
**Status:** Done
**Workspace:** root  
**Size:** 2 story point(s)  
**Dependencies:** V2-02-04,V2-01-04  

## Objective

Run shared fixtures, schema/version diagnostics, backend health and child test entry points through one root command.

## Scope

- Implement only the change described by this task.
- Preserve existing working behavior outside the task.
- Follow the shared contract and repository ownership boundaries.
- Add/update tests directly required by the change.

## Implementation Constraints

- Do not perform unrelated refactors.
- Do not invent deferred architecture constants (retry cadence, retention duration, timestamp tolerance, batching, device limits). Keep such values configurable when the task needs them.
- Do not introduce payments, premium functionality, sharing, new quiz families or Version 3 redesign work.
- Shared-contract changes require root-level approval/update before child implementations diverge.

## Figma Requirement

None.

## Acceptance Criteria

- [x] Fresh integration environment fails fast on incompatible contract/schema/setup and reports actionable diagnostics.
- [x] Existing relevant tests still pass.
- [x] New behavior has focused automated coverage where feasible.
- [x] No unrelated product/UI behavior changed.

## Verification

1. Run the affected child repository tests.
2. Run relevant root contract/integration checks when the task crosses repository boundaries.
3. Verify canonical contract fixtures if serialization/API/schema behavior is touched.
4. For user-facing tasks, compare the implemented flow against the approved Figma nodes.

## Canonical References

- `docs/00-SYSTEM-CONCEPT.md`
- `docs/01-SHARED-DATA-CONTRACT.md`
- `docs/02-SYNC-PROTOCOL.md`
- `docs/03-PRODUCT-ROADMAP.md`
- `docs/04-VERSION-2-PLAN.md`
- `docs/07-ISSUE-PLANNING-RULES.md`
- `AGENTS.md`

## Stop / Escalate If

- A major architecture boundary must change.
- Shared schema/contract semantics are missing or contradictory.
- A required behavior is missing from the canonical contract or selected issue. Missing Figma alone is not a blocker unless this task explicitly marks Figma as Required.
- Completing the task would require future-version work.

## Completion Evidence — 2026-09-12

- Added `scripts/smoke-gate.sh` as the single root entry point for pinned
  schema/contract diagnostics, all shared fixture validation, deterministic
  Compose setup, live backend health/PostgreSQL schema verification, and both
  child CTest entry points.
- Added focused compatibility and health diagnostics with actionable mismatch
  output. Root coverage proves both success and deliberate SQLite/PostgreSQL
  mismatch failures, and `scripts/test-all.sh root` passed.
- `CMAKE_OSX_ARCHITECTURES=arm64 CMAKE_BUILD_PARALLEL_LEVEL=4
  ./scripts/smoke-gate.sh` passed: 3 fixture-set versions and 12 sync events
  validated, the backend container build passed 11/11 available tests, live
  `/health` reported PostgreSQL `1.2`, frontend passed 15/15 CTest entries, and
  backend passed 12/12 CTest entries.
- `CMAKE_OSX_ARCHITECTURES=arm64 CMAKE_BUILD_PARALLEL_LEVEL=4
  ./scripts/run-integration.sh` passed the existing word/group, review-statistics,
  learning-settings, and domain relationship/tombstone scenarios.
- The child worktrees and root submodule pins remain unchanged; no shared
  contract, schema, product, or UI behavior changed.
