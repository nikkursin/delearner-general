# V2-10-01 — Implement consistent bootstrap state export

**Parent epic:** V2-10 — New-Device Bootstrap  
**Status:** Done  
**Workspace:** backend  
**Size:** 2 story point(s)  
**Dependencies:** V2-09-01,V2-04-03  

## Objective

Return authenticated current Version 2 user state from PostgreSQL together with the sequence representing that consistent view.

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

- [x] Export includes words, groups, review statistics, synced settings and required tombstones/state; excludes local-only data.
- [x] Existing relevant tests still pass.
- [x] New behavior has focused automated coverage where feasible.
- [x] No unrelated product/UI behavior changed.

## Verification

- `cmake --build build-codex-arm64 --target test_event_characterization test_sync_transaction_repository test_domain_repository`
- `ctest --test-dir build-codex-arm64 -R 'test_event_characterization|test_sync_transaction_repository|test_domain_repository' --output-on-failure`
- `cmake --build build-codex-arm64`
- `ctest --test-dir build-codex-arm64 --output-on-failure`

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
