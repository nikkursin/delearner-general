# V2-12-04 — Replay preserved mutations and verify convergence

**Parent epic:** V2-12 — Retention and Stale-Device Recovery  
**Status:** Planned
**Workspace:** frontend + backend + root  
**Size:** 2 story point(s)  
**Dependencies:** V2-12-03,V2-12-03A,V2-08-04,V2-10-03

## Objective

Replay preserved pending events after fresh bootstrap using original eventId/updatedAt semantics, then resume incremental sync.

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

- [ ] Two-device stale-recovery test converges without manual reset and without silently losing local offline edits.
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

## Blocker — 2026-09-08

Safe replay is blocked by the live backend mutation path bypassing the existing
LWW resolver. The selected task requires preserved events to retain their original
modification times and pass through normal backend conflict handling. On the pinned
backend revision `83e935fb5b5c7f28599ff4ab7957f7e0ee91e9cb`, an older offline group
update instead overwrites a newer canonical group after bootstrap.

### Verified reproduction

The adjacent `V2-12-04-older-replay-regression.patch` adds one backend handler test:

1. Register two devices for one user.
2. Upload Device A's group value `Newer server edit`, modified at
   `2026-01-15T10:00:00Z`.
3. Fetch bootstrap successfully.
4. Replay Device B's original `Older offline edit`, modified at
   `2026-01-15T09:00:00Z`, with its original event ID and timestamp.
5. Assert the stored canonical group still contains Device A's newer value.

Both uploads return HTTP 200. The assertion fails: canonical storage contains
`Older offline edit`. This uses the real backend handlers, auth, registered-device
repositories and transaction repository with their existing SQLite test adapter;
it is not a PostgreSQL end-to-end test.

Reproduce in an isolated backend checkout at the revision above (adjust the Qt
prefix and architecture to the host):

```sh
git apply --unidiff-zero /path/to/V2-12-04-older-replay-regression.patch
cmake -S . -B /tmp/v2-12-04-backend-build -DCMAKE_PREFIX_PATH=/opt/homebrew -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_BUILD_TYPE=Debug
cmake --build /tmp/v2-12-04-backend-build --target test_event_characterization --parallel 4
/tmp/v2-12-04-backend-build/tests/test_event_characterization testOlderOfflineReplayPreservesNewerCanonicalState
```

### Verification performed

- Configured and built `test_event_characterization` with Qt 6.9.0 and an explicit
  `arm64` target (the default host architecture did not match the installed Qt).
- Ran the focused regression: expected newer value, observed older value; failed.
- Ran the complete characterization executable with the regression: 20 passed
  (including initialization/cleanup), 1 failed, 0 skipped. The sole failure is
  the new older-replay regression.
- Ran the root fixture validator: all 12 canonical fixtures passed.
- No frontend, PostgreSQL or full-system recovery acceptance run was claimed.

### Required prerequisite repair

`DLEventsCompatibilityHandler::applyCanonicalMutation` calls direct persistence
without invoking `DLConflictResolver`. In addition,
`DLSyncTransactionRepository::commitDomainMutationWithAcceptedEvent` persists the
incoming event before the mutation callback, so repairing only the stored value
would still require checking what other devices receive through incremental pull.
Safe conflict handling must be verified across canonical storage, acknowledgement,
incremental propagation, tombstones and idempotent replay before this task can
rely on it. This is a mutation-engine prerequisite repair, beyond simply wiring
preserved-outbox replay. V2-08 tasks remain Done and were not reopened.

The client also still needs automatic handling of the backend's HTTP 409
`stale_cursor` response and upload of preserved events after bootstrap. Those
V2-12-04 changes have not been made or marked complete.

No product code or child submodule pins changed. Pre-existing child commits and
the backend's untracked `tests/test_http_server.cpp` were excluded by using
isolated worktrees at the root-pinned revisions. The regression patch is evidence,
not an enabled passing test or a claim that recovery acceptance criteria pass.

## Blocker Resolution — 2026-09-11

V2-12-03A completed the backend prerequisite in backend commit `b7e894c`. The
older replay now loses through canonical LWW resolution, and acknowledgements
and incremental pull expose the resulting canonical state. This task is Planned
again; its client stale-cursor recovery and preserved-outbox replay remain
unimplemented.
