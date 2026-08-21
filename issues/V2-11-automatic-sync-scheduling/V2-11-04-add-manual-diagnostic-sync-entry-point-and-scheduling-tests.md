# V2-11-04 — Add manual diagnostic sync entry point and scheduling tests

**Parent epic:** V2-11 — Automatic Sync Scheduling  
**Status:** Planned  
**Workspace:** frontend  
**Size:** 1 story point(s)  
**Dependencies:** V2-11-02,V2-11-03  

## Objective

Expose a non-primary manual trigger for diagnostics/fallback and test offline→online, resume and repeated-trigger behavior.

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

- [ ] Manual trigger uses the same coordinator; automatic behavior remains the normal path.
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
- A required behavior is missing from the canonical contract or issue acceptance criteria.
- Completing the task would require future-version work.
