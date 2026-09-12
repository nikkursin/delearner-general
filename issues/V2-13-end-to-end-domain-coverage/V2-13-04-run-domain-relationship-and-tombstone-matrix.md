# V2-13-04 — Run domain relationship and tombstone matrix

**Parent epic:** V2-13 — End-to-End Domain Coverage  
**Status:** Done
**Workspace:** root  
**Size:** 2 story point(s)  
**Dependencies:** V2-13-01,V2-13-02,V2-13-03  

## Objective

Add an integration matrix for cross-device deletes, resurrection by later valid update, relationships and bootstrap consistency for all in-scope domains.

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

None. Do not call Figma for this task. If functional testing requires a visible state, implement the smallest functional presentation using existing project patterns and defer visual review to V2-14.

## Acceptance Criteria

- [x] Matrix passes normal LWW/tombstone rules and identifies no domain-specific conflict policy outside the canonical protocol.
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

- Added the root-owned executable matrix in `tests/domain_matrix/`, invoked by
  `tests/domain_relationship_tombstone_matrix.sh`, `scripts/test-all.sh all`,
  and `scripts/run-integration.sh`.
- Four domain rows connect production backend handlers to two independent
  frontend SQLite stores and a fresh third-client bootstrap at every checkpoint.
  They verify stale update/delete rejection by canonical LWW, winning deletes,
  duplicate delivery, later resurrection, group unlink/reattach, cursor progress,
  no feedback outbox, and bootstrap/pull convergence.
- Uses canonical fixture payloads and the backend's existing deterministic
  QSQLITE adapter. HTTP transport and PostgreSQL concurrency are outside this
  in-process matrix; no implementation or shared contract changes were needed.
- `CMAKE_OSX_ARCHITECTURES=arm64 CMAKE_BUILD_PARALLEL_LEVEL=4 scripts/test-all.sh all`
  passed: root smoke/contract checks, frontend 15/15 CTest entries, backend 12/12
  entries, existing three domain scenarios, and the new matrix (all four rows).
- Compared UUID-based state rather than local integer keys. The review row
  compares published review state; unsynced default review scaffolding created
  by word application is not treated as canonical review data in other rows.
- Both child worktrees and their root submodule pins remain unchanged.
