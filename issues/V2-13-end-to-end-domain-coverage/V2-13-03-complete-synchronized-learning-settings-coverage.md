# V2-13-03 — Complete synchronized learning-settings coverage

**Parent epic:** V2-13 — End-to-End Domain Coverage  
**Status:** Done
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

- [x] Native language/quiz defaults/learning preferences converge; theme/navigation/transient UI state stays device-local.
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

## Approved Blocker Resolution — 2026-09-12

For synchronized account-level learning settings, the logical identity of a setting is the pair:

`(ownerUserId, settingKey)`

The setting UUID is not the logical identity for deciding whether two learning-setting mutations refer to the same setting key. It remains a technical/entity identifier used by the persistence and synchronization implementation.

Therefore:

* There must be at most one canonical synchronized learning setting for a given `(ownerUserId, settingKey)`.
* PostgreSQL must continue to enforce `UNIQUE(owner_user_id, setting_key)`.
* If two devices independently create the same synchronized setting key with different UUIDs, the backend must treat them as competing mutations of the same logical setting rather than as two independent settings.
* Backend reconciliation must resolve the mutation against the existing canonical row identified by `(ownerUserId, settingKey)`.
* Once the canonical setting has been identified, the existing `updatedAt` last-modification-wins rule applies.
* The backend response must return the canonical entity state and canonical UUID so that the client can reconcile its local row and pending synchronization state.
* Clients must accept canonical UUID reconciliation returned by the backend and must not create a second logical setting for the same synchronized key.
* Deletes/tombstones for learning settings must resolve the target setting using the same `(ownerUserId, settingKey)` logical identity semantics.
* Random client-generated UUIDs remain permitted for offline first creation; deterministic account/key UUID generation is not required.
* This rule applies specifically to synchronized keyed learning settings and does not change UUID identity semantics for words, groups, review statistics, or other syncable entities.

The shared data contract and sync protocol must be updated to record this learning-setting identity exception before or together with the child-repository implementation.

With this decision approved, the identity blocker recorded above is considered resolved and implementation may continue.


## Completion — 2026-09-12

Implemented the approved account/key identity exception in the shared contract
and live backend mutation path. Responses, replay results and pull envelopes use
the canonical UUID, while stored submitted events retain their original identity
for idempotency. Learning-setting tombstones resolve by the same account/key.
Backend uploads reject device-local keys/scopes.

The frontend now stores account learning settings in SQLite schema 1.3, records
local mutations with their outbox events atomically, applies canonical settings
and tombstones on push acknowledgement/pull/bootstrap, and preserves pending
payloads during canonical UUID reconciliation and re-bootstrap. Device/UI state
is excluded. No presentation changes were required.

The task-related files from the pre-existing partial frontend commit `77e7bf5`
were isolated onto `ralph/v2-13-03-learning-settings`, based on the previously
pinned `793b13c`. The original `version_2_new_implementation` branch remains at
`77e7bf5`, preserving its unrelated iOS export edit without including it here.

Verification:

- `cmake --build delearner-backend/build-codex-arm64 -j 4` — passed.
- `cmake -S delearner-frontend -B delearner-frontend/build-tests` and
  `cmake --build delearner-frontend/build-tests -j 4` — passed.
- `ctest --test-dir delearner-backend/build-codex-arm64 --output-on-failure`
  — 12/12 passed.
- `ctest --test-dir delearner-frontend/build-tests --output-on-failure`
  — 15/15 passed.
- `scripts/test-all.sh root` — passed, including fixture compatibility probes.
- `DELEARNER_BUILD_ROOT=/tmp/delearner-v2-13-03-build tests/learning_settings_sync_scenario.sh --run`
  — passed against links to the above build directories. Runs real backend
  handler tests and frontend SQLite repository/reconciliation tests; no deployed
  server or UI test is claimed.
- Root and child `git diff --check` — passed.

Focused coverage includes native-language/quiz-default/learning-preference keys,
competing offline UUIDs, older/newer winners, retry replay, canonical pull IDs,
tombstones/resurrection, account isolation, rejected UI settings, local mutation
rollback, atomic canonical acknowledgement rollback, pending envelope preservation,
bootstrap recovery and database cleanup.
