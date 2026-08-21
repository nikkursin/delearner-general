# V2-05-01 — Define Version 2 authentication flow in Figma

**Parent epic:** V2-05 — Authentication and Account Foundation  
**Status:** Blocked  
**Workspace:** Figma + root  
**Size:** 1 story point(s)  
**Dependencies:** V2-01-02  

## Objective

Define/review the minimal sign-in/account-entry states needed by Version 2: first-launch auth requirement, email/password path, provider placeholders/direction, offline reopening and errors. Do not redesign existing vocabulary/quiz screens.

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

Required before implementation. Use the existing DELearner Figma file and add/review only the user-facing flow named by this task; do not redesign unrelated MVP1 screens.

## Blocker

2026-08-21: Figma MCP authentication is available, but the repository does not record the existing DELearner Figma file URL/key. The authenticated account has multiple Figma plans, so the agent cannot safely infer the correct file or create a substitute design without violating the task requirement to use the existing DELearner Figma file.

## Acceptance Criteria

- [ ] The Figma flow clearly establishes entry, success, offline-after-login and failure states; root issue references the approved nodes before implementation.
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
