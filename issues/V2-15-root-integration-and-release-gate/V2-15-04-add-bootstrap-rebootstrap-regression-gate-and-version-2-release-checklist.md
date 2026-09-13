# V2-15-04 — Add bootstrap/rebootstrap regression gate and Version 2 release checklist

**Parent epic:** V2-15 — Root Integration and Release Gate  
**Status:** Done
**Workspace:** root  
**Size:** 2 story point(s)  
**Dependencies:** V2-12-04,V2-14-04,V2-15-01,V2-15-02,V2-15-03  

## Objective

Exercise new-device bootstrap, bootstrap race catch-up, stale-history rebootstrap with pending outbox preservation, then run existing free-core regressions and record the release gate.

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

- [x] All Version 2 completion criteria are machine-tested where feasible; remaining manual Figma/platform checks are explicit; root pins the compatible child commits.
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

- Added a production-handler bootstrap race/catch-up scenario and a mandatory
  bootstrap/rebootstrap regression suite gate to both root integration paths.
- Failure-injection checks verify required recovery suite failures stop the gate.
- `./scripts/test-all.sh all`: passed (16 frontend and 12 backend CTest
  registrations, root checks, four matrix scenarios and compiled domain scenarios).
- `./scripts/test-all.sh root`: passed after adding gate failure-injection checks.
- `./scripts/run-integration.sh`: passed.
- `./scripts/smoke-gate.sh`: passed, including Docker backend build/start and live
  PostgreSQL health/schema 1.2 validation.
- `git diff --check`: passed. Child worktrees and exact root pins remain unchanged.
- [Release checklist](../../docs/08-VERSION-2-RELEASE-CHECKLIST.md) records coverage,
  compatible revisions and outstanding Figma/platform/deployed-concurrency checks.
  Version 2 release remains pending; V2-14-01 and V2-14-02 remain Planned.
