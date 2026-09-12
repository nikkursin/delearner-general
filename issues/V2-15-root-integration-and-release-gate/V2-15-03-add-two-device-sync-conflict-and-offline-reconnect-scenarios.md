# V2-15-03 — Add two-device sync, conflict and offline/reconnect scenarios

**Parent epic:** V2-15 — Root Integration and Release Gate  
**Status:** Done
**Workspace:** root  
**Size:** 2 story point(s)  
**Dependencies:** V2-13-04,V2-11-04  

## Objective

Exercise bidirectional domain changes, idempotent retry, LWW/tombstone conflict behavior and offline→online automatic convergence.

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

- [x] Pinned frontend/backend revisions converge deterministically and no manual sync is required in normal scenarios.
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

## Completion Evidence

- Added `automatic_two_device_reconnect` to the root domain harness and required
  it after the authentication prerequisite in the shared integration runner.
- Production app state manager/coordinator connects to backend handlers over
  loopback HTTP, with two durable client SQLite databases. Covers offline local
  edits, reconnect-triggered push/pull, acknowledgement failure after server
  commit, identical retry across restart without duplicate server history,
  newer canonical update reconciliation, reverse-direction tombstone propagation,
  empty acknowledged outboxes and matching persisted device cursors.
- Existing four-domain LWW/tombstone matrix and compiled word/group, review and
  learning-setting scenarios continue to pass. No manual sync is used by the
  new scenario; no child implementation, contract or submodule pin changed.
- Verified with `./tests/domain_relationship_tombstone_matrix.sh`,
  `./scripts/test-all.sh root`, and `./scripts/test-all.sh all`: root smoke and
  contract checks, frontend CTest 16/16, backend CTest 12/12, all three root matrix
  scenarios and the existing compiled domain scenarios passed.
- Verified pins: frontend `e1b1e4b140a1ec578b081421c518b429f7aa9e47`, backend
  `f20e9bba077a9aff7090bc386431fec8b369e0f7`.
- Test boundary: deterministic backend SQLite adapter and loopback routes;
  deployed routing, PostgreSQL concurrency and platform connectivity notification
  delivery are not asserted by this focused scenario.
