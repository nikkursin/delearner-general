# V2-15-02 — Add authentication isolation and device lifecycle scenarios

**Parent epic:** V2-15 — Root Integration and Release Gate  
**Status:** Done
**Workspace:** root  
**Size:** 2 story point(s)  
**Dependencies:** V2-06-04,V2-13-04  

## Objective

Create root scenarios for unauthenticated denial, two-user isolation, multi-device registration and revoked-device rejection.

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

- [x] Tests prove account boundaries and device authorization before data-sync scenarios are accepted.
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

Implemented root-owned `authentication_device_lifecycle` in the existing compiled
integration harness. It exercises production registration/auth/sync handlers with
three registered devices and a second account: missing/invalid sessions, repeat
registration, cross-account claims/uploads/cursor changes, spoofed ownership,
pull/bootstrap isolation, revoked upload/cursor rejection, unchanged state after
denial, and continued upload from an active device. The canonical group fixture
provides the mutation payload. Child implementation and submodule pins are unchanged.

Both root integration entry points run the authorization prerequisite before the
domain scenarios. The runner fails on failed or missing tests and supports
`--auth-only`. A root smoke test injects failure to verify later scenarios do not
run. V2-15 remains In Progress; no other subtask is completed by this change.

Verification:

- `./scripts/test-all.sh all`: passed root checks, frontend CTest 16/16, backend
  CTest 12/12, auth/device scenario, domain matrix and existing compiled word/group,
  quiz-review and learning-setting scenarios.
- `./tests/domain_relationship_tombstone_matrix.sh`: passed both compiled scenarios.
- `./scripts/test-all.sh root`: passed, including the new failure-injection test.
- `bash -n` on changed shell scripts and `git diff --check`: passed.

These deterministic scenarios use the backend's existing QSQLITE test adapter
and in-process production handlers. HTTP transport/PostgreSQL concurrency and
Felgo application execution are not claimed by this task; the available frontend
core/test build passed. No new external human check is required for this subtask.
