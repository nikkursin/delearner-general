# V2-03-04 — Implement tombstone delete baseline and regression tests

**Parent epic:** V2-03 — Frontend UUID + Migration Baseline  
**Status:** Done  
**Workspace:** frontend  
**Size:** 2 story point(s)  
**Dependencies:** V2-03-02,V2-03-03  

## Objective

Replace immediate hard-delete behavior for syncable entities with tombstone-compatible persistence and expand/enable regression tests.

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

Review only if ID assumptions leak into UI; no redesign. If this subtask exposes new behavior not already represented, stop and obtain/produce the required Figma definition before UI implementation.

## Acceptance Criteria

- [x] Deleted syncable records can be represented for sync; normal UI no longer displays deleted items; existing free-core tests remain green.
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
- A meaningful user-facing flow lacks a Figma definition.
- Completing the task would require future-version work.
