# V2-13-03 — Complete synchronized learning-settings coverage

**Parent epic:** V2-13 — End-to-End Domain Coverage  
**Status:** Blocked
**Workspace:** frontend + backend + root  
**Size:** 2 story point(s)  
**Dependencies:** V2-12-04,V2-02-03  

## Objective

Implement approved account-level learning settings sync and explicitly exclude device/UI-local preferences.

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

- [ ] Native language/quiz defaults/learning preferences converge; theme/navigation/transient UI state stays device-local.
- [ ] Existing relevant tests still pass.
- [ ] New behavior has focused automated coverage where feasible.
- [ ] No unrelated product/UI behavior changed.

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

## Blocker — 2026-09-12

Account learning-setting identity for concurrent first writes is undefined.
Two devices can independently create `learning.native_language` while offline,
with different UUIDs. The partial frontend implementation at `77e7bf5` generates
random UUIDs for new keys. PostgreSQL enforces `UNIQUE(owner_user_id, setting_key)`,
but `DLEventsCompatibilityHandler` reads canonical state and chooses create/update
by entity UUID. Consequently, a second UUID for the same account/key takes the
insert path and conflicts with that uniqueness constraint rather than converging
through the existing per-entity LWW path.

The canonical contract and fixtures specify UUID identities and setting keys but
provide no identity rule for this case. A root decision is required before choosing
between a shared deterministic account/key UUID rule and backend-owned identity
reconciliation (including retries, tombstones and pending outbox references).
This is shared identity/sync semantics, covered by this task's stop conditions.

Inspection only: no implementation or runtime tests were performed in this run.
The pre-existing frontend commit remains untouched and unpinned; it also includes
an unrelated iOS export edit that must be isolated from eventual task completion.
Resume this task after the identity rule is approved and recorded in the contract.
