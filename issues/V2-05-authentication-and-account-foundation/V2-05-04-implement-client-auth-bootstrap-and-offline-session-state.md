# V2-05-04 — Implement client auth bootstrap and offline session state

**Parent epic:** V2-05 — Authentication and Account Foundation  
**Status:** Planned  
**Workspace:** frontend  
**Size:** 2 story point(s)  
**Dependencies:** V2-05-01,V2-05-03  

## Objective

Implement the approved sign-in flow, persist the successful account/session context needed for startup, and allow free-core offline reopening after prior auth.

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

Design-first for new authentication/account flow. If this subtask exposes new behavior not already represented, stop and obtain/produce the required Figma definition before UI implementation.

## Acceptance Criteria

- [ ] Fresh unauthenticated install cannot enter the app offline; previously authenticated user can reopen free core offline without periodic re-auth lockout.
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
- A meaningful user-facing flow lacks a Figma definition.
- Completing the task would require future-version work.
