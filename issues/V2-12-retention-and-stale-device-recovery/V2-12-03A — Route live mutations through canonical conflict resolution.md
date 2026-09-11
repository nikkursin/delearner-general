# V2-12-03A — Route live mutations through canonical conflict resolution

**Parent epic:** V2-12 — Retention and Stale-Device Recovery

**Status:** Ready

**Workspace:** backend + root

**Size:** 2 story point(s)

**Dependencies:** V2-08-04,V2-10-03

## Objective

Repair the backend live mutation path so every accepted sync mutation is resolved through the existing canonical LWW conflict semantics before canonical state and incremental sync output are committed.

This issue is the prerequisite discovered by V2-12-04. It must make preserved stale-device replay safe without implementing stale-device replay itself.

## Scope

- Route the live backend mutation path through the existing `DLConflictResolver`.
- Ensure canonical persistence reflects the conflict-resolution result rather than blindly persisting the incoming mutation.
- Ensure the synchronization event exposed to incremental pull is consistent with the resulting canonical state/tombstone.
- Ensure the mutation acknowledgement returns the resulting canonical state/tombstone according to the existing contract.
- Preserve existing event idempotency behavior.
- Add focused automated coverage for older replay, winner/loser behavior, tombstones and idempotent retry where directly required.
- Promote the existing V2-12-04 older-replay regression into an enabled backend regression test once the repair is implemented.
- Update root issue/verification records only as needed to document the prerequisite completion.

## Out of Scope

- Do not implement client handling of HTTP `409 stale_cursor`.
- Do not implement bootstrap replay of preserved client outbox events.
- Do not change retention policy.
- Do not change timestamp sanity tolerances.
- Do not introduce new conflict-resolution semantics.
- Do not redesign the sync contract.
- Do not reopen or rewrite completed V2-08 tasks unless an actual regression requires a minimal corrective change.
- Do not introduce unrelated backend refactors.
- Do not change frontend code except if a contract regression is discovered and root approval is required first.

## Implementation Constraints

- Use the existing last-modification-wins conflict semantics.
- The backend remains the single owner of conflict resolution.
- Incoming client `updatedAt` values must retain their existing semantic meaning.
- Do not invent timestamp tolerance rules or other deferred constants.
- Domain mutation and accepted canonical synchronization output must remain transactionally consistent.
- A losing mutation must not overwrite newer canonical state.
- A losing mutation must not cause incremental pull to propagate state that contradicts canonical storage.
- Duplicate delivery of the same `eventId` must remain idempotent.
- Preserve repository ownership boundaries and existing shared-contract behavior.

## Required Behavior

The current incorrect path effectively behaves as:

```text
receive mutation
→ persist incoming sync event
→ directly persist incoming domain state
→ acknowledge
```

The repaired path must behave conceptually as:

```text
receive mutation
→ authenticate / authorize
→ validate
→ enforce eventId idempotency
→ load relevant canonical state/tombstone
→ resolve incoming mutation through DLConflictResolver
→ determine resulting canonical state/tombstone
→ persist canonical result
→ persist synchronization output consistent with that result
→ commit atomically
→ return acknowledgement + canonical result
```

Exact internal factoring may follow the current backend architecture. Do not introduce a parallel conflict engine.

## Acceptance Criteria

- [ ] `DLEventsCompatibilityHandler::applyCanonicalMutation` no longer bypasses the existing backend conflict-resolution semantics.
- [ ] An older update cannot overwrite a newer canonical update.
- [ ] A newer valid update still replaces an older canonical update according to existing LWW semantics.
- [ ] Delete tombstones participate in the same existing LWW rules.
- [ ] A losing update/delete does not produce incremental-pull state that contradicts canonical storage.
- [ ] Mutation acknowledgement contains the resulting canonical entity state or tombstone, not an assumed incoming result when the incoming mutation loses.
- [ ] Duplicate delivery of the same `eventId` remains idempotent.
- [ ] Canonical domain mutation and accepted synchronization output remain transactionally consistent.
- [ ] The V2-12-04 regression case passes:
  - Device A uploads `Newer server edit` at `2026-01-15T10:00:00Z`.
  - Device B later replays `Older offline edit` at `2026-01-15T09:00:00Z`.
  - Canonical storage remains `Newer server edit`.
- [ ] Relevant existing backend characterization/unit tests still pass.
- [ ] Relevant canonical root fixtures still pass.
- [ ] No unrelated frontend, product or UI behavior changes.

## Focused Regression Coverage

At minimum, cover these cases through the existing real backend handler/repository test path where feasible:

1. **Older replay loses**
   - canonical update at `10:00`
   - incoming replay at `09:00`
   - canonical value remains the `10:00` value

2. **Newer replay wins**
   - canonical update at `09:00`
   - incoming mutation at `10:00`
   - canonical value becomes the `10:00` value

3. **Incremental propagation consistency**
   - after conflict resolution, another device pulling changes must not receive a losing state as if it were canonical

4. **Tombstone conflict**
   - verify update/delete ordering follows the same existing LWW rule

5. **Idempotent retry**
   - resend the same accepted `eventId`
   - no duplicate domain mutation or contradictory sync event is created

Do not expand test coverage into unrelated sync behavior.

## Verification

1. Run the affected backend unit/characterization tests.
2. Run the promoted older-offline-replay regression.
3. Run relevant tombstone/idempotency conflict tests.
4. Verify incremental pull after both winning and losing mutations.
5. Run the complete affected backend test executable(s).
6. Run root canonical fixture validation.
7. Run `git diff --check` / equivalent repository hygiene checks.
8. Do not claim PostgreSQL end-to-end coverage unless it was actually executed.
9. Do not claim V2-12-04 stale-device recovery acceptance criteria pass; this issue only repairs its backend prerequisite.

## Canonical References

- `docs/00-SYSTEM-CONCEPT.md`
- `docs/01-SHARED-DATA-CONTRACT.md`
- `docs/02-SYNC-PROTOCOL.md`
- `docs/03-PRODUCT-ROADMAP.md`
- `docs/04-VERSION-2-PLAN.md`
- `docs/07-ISSUE-PLANNING-RULES.md`
- `AGENTS.md`
- `issues/V2-12-retention-and-stale-device-recovery/V2-12-04-*`
- `issues/V2-12-retention-and-stale-device-recovery/V2-12-04-older-replay-regression.patch`

The canonical sync protocol requires backend-owned conflict resolution, transactional mutation/event persistence and replay of preserved mutations using their original timestamps.

The shared contract likewise requires backend-owned LWW semantics, canonical mutation results and stable `eventId` idempotency.

## Figma Requirement

None.

Do not call Figma for this task.

## Stop / Escalate If

- Fixing the issue requires changing the current LWW conflict semantics.
- The existing `DLConflictResolver` cannot represent the canonical contract behavior without a shared-contract change.
- Correct transactional ordering requires a major repository/API architecture change.
- Incremental pull semantics are contradictory or undefined in the current canonical contract.
- Completing the task requires implementing `stale_cursor` recovery, preserved-outbox replay or other V2-12-04 client behavior.
- A PostgreSQL/schema change becomes necessary but is not already covered by the canonical contract.

## Unblocks

- V2-12-04 — Replay preserved mutations and verify convergence

After this issue passes, V2-12-04 may resume from its existing blocked state and implement:
- automatic HTTP `409 stale_cursor` handling;
- bootstrap recovery;
- preserved pending-outbox restoration;
- replay using original `eventId` / `updatedAt`;
- final two-device convergence verification.

## Blocker — 2026-09-08: durable conflict metadata requires schema authorization

Inspection at root-pinned backend revision
`83e935fb5b5c7f28599ff4ab7957f7e0ee91e9cb` found a prerequisite to preserving
the existing resolver semantics:

- `src/events/DLConflictResolver.cpp` resolves equal `occurredAt` values using
  the lexicographically greater event ID. An empty current event ID lets the
  incoming event win. `testConflictResolverEqualTimestampTieBreaker` verifies
  that the same incoming event wins against one current ID and loses against
  another at the same timestamp.
- `src/persistence/DLDatabaseMigrator.cpp` and `DLDomainRepository.h` provide
  modification timestamps on canonical entities/tombstones, but no winning
  event ID. The only persisted event IDs are in `accepted_sync_events`.
- `DLSyncTransactionRepository::pruneAcceptedEventsBefore` deletes those rows
  according to device cursors and the maximum history window. Therefore an
  event-history lookup cannot reliably recover the canonical winner's ID.

Two histories can leave identical canonical state and timestamps but different
winning event IDs. After retention deletes their events, the persisted state
cannot distinguish them, although the resolver requires different outcomes for
an incoming equal-timestamp event. Passing an empty ID would silently replace
this rule with arrival-order behavior. Keeping winning events indefinitely would
change retention behavior, which is explicitly out of scope.

### Required decision

Authorize an explicit backend schema migration to retain winning-event identity
with canonical entities/tombstones (or equivalent durable per-entity metadata),
including a defined policy for existing rows whose originating events have
already been pruned. This is backend persistence metadata; no new client field
is proposed. The exact migration and existing-row policy are not implemented
or approved by this record.

This triggers the task's stop condition: "A PostgreSQL/schema change becomes
necessary but is not already covered by the canonical contract." The canonical
docs require migration/versioning infrastructure but do not define this metadata
or its initialization policy. The task remains Blocked; V2-12-04 also remains
Blocked and no completed V2-08 task is reopened.

### Verification performed in this invocation

Used an isolated backend worktree at the root pin to exclude pre-existing child
commits and the untracked backend HTTP test. No implementation changes were made.

```sh
cmake -S /tmp/delearner-v2-12-03a-backend -B /tmp/delearner-v2-12-03a-build -DCMAKE_PREFIX_PATH=/opt/homebrew -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_BUILD_TYPE=Debug
cmake --build /tmp/delearner-v2-12-03a-build --target test_sync_domain test_sync_transaction_repository --parallel 4
ctest --test-dir /tmp/delearner-v2-12-03a-build -R '^(test_sync_domain|test_sync_transaction_repository)$' --output-on-failure
python3 contracts/validate_contract_fixtures.py --fixture-dir contracts/fixtures/v1
```

Configuration/build succeeded; both existing test executables passed, including
the resolver tie-break and retention tests. All 12 root contract fixtures passed.
These are baseline checks supporting the diagnosis, not verification of a repair.
The transaction tests use the existing SQLite adapter; PostgreSQL end-to-end,
live-handler repair, and stale-device convergence were not verified.

Only this task record is committed. Existing submodule checkouts/pins and the
untracked backend test are excluded. The parent epic remains non-Done.

## Authorized Backend Persistence Change — 2026-09-08

The backend is authorized to persist durable winning-mutation identity for
canonical syncable entities/tombstones.

### Decision

The current LWW resolver uses the originating `eventId` as the deterministic
tie-breaker when modification timestamps are equal. Because accepted sync-event
history is intentionally bounded and may be pruned, the winning event identity
required by conflict resolution must survive independently of retained event
history.

Add backend-only durable synchronization metadata equivalent to:

```text
winningEventId = UUID
```

for canonical syncable entity/tombstone state where required by the existing
persistence model.

The exact table placement may follow the existing backend schema structure.
Do not expose this as a new client-owned domain property and do not change the
shared API payload unless implementation proves that unavoidable.

### Semantics

After processing a mutation:

* if the incoming mutation wins, canonical `winningEventId` becomes the incoming
  mutation's `eventId`;
* if the incoming mutation loses, the existing canonical `winningEventId` remains
  unchanged;
* equal-timestamp decisions must continue using the existing
  `DLConflictResolver` event-ID tie-break semantics;
* pruning `accepted_sync_events` must not remove information required for future
  conflict decisions;
* canonical state, winning-event metadata and the synchronization result exposed
  to incremental pull must remain transactionally consistent.

### Existing Development Rows

This project is still pre-release and the canonical shared contract does not
require preservation of existing developer data across the UUID-based baseline.

No attempt is required to reconstruct winning event IDs from already-pruned
history.

Migration/bootstrap/test data may be reset or regenerated where necessary rather
than inventing conflict semantics for canonical rows whose originating winning
event is unknowable.

A nullable transitional database value is acceptable only where required to
perform migration/reset safely. Normal post-migration canonical sync state must
retain a valid winning event identity.

Do not define empty-string or arrival-order behavior as a replacement for the
existing resolver tie-break rule.

### Scope

This authorization covers only the backend persistence/schema change required to
make the existing conflict resolver durable.

It does not authorize:

* changes to LWW conflict semantics;
* permanent retention of accepted sync events;
* client contract fields for winning-event identity;
* V2-12-04 stale-cursor handling or preserved-outbox replay;
* unrelated schema redesign.

### Required Verification

In addition to the existing V2-12-03A acceptance criteria, verify:

1. Equal-timestamp conflict resolution remains deterministic after accepted-event
   history relevant to the original winner has been pruned.
2. Winning-event metadata survives canonical persistence/reload.
3. A losing mutation does not replace winning-event metadata.
4. A winning mutation updates canonical state and winning-event metadata
   atomically.
5. Tombstone winner identity follows the same rule.
6. Existing retention tests continue to pass without retaining event history
   indefinitely.
7. Relevant PostgreSQL migration/schema tests are updated where available.
8. Existing development fixtures may be rebuilt instead of preserving obsolete
   pre-migration state.

With this decision recorded, the schema-change stop condition is resolved and
V2-12-03A may proceed.
