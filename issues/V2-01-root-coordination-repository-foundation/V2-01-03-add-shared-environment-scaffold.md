# V2-01-03 — Add shared environment scaffold

**Parent epic:** V2-01 — Root Coordination Repository Foundation  
**Status:** Planned  
**Workspace:** root  
**Size:** 2 story point(s)  
**Dependencies:** V2-01-01  

## Objective

Add .env.example and shared integration-environment scaffolding, including PostgreSQL/backend dependencies where appropriate; keep secrets out of Git.

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

- [ ] A documented local integration environment can be prepared from the root without embedding secrets or replacing child setup.
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
