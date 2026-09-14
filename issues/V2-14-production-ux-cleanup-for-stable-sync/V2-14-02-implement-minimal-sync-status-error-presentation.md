# V2-14-02 — Implement minimal sync status/error presentation

**Parent epic:** V2-14 — Production UX Cleanup for Stable Sync  
**Status:** Done
**Workspace:** frontend  
**Size:** 2 story point(s)  
**Dependencies:** V2-14-01,V2-11-01,V2-12-04  

## Objective

Bind the approved status/error states to the sync/auth services without embedding synchronization logic in QML.

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

Required only through the approved node IDs recorded by V2-14-01. Do not rediscover/traverse Figma unless the recorded references are insufficient.

## Acceptance Criteria

- [x] Normal successful sync is unobtrusive; actionable auth/device errors are visible; automatic stale recovery does not ask for manual DB reset.
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

## Completion — 2026-09-14

- Added a persistent inline synchronization status component in the existing
  Settings synchronization section. It consumes app-state properties backed by
  the existing coordinator: neutral idle, active/recovery activity, offline
  reassurance, and readable errors. A queued request never claims completion.
- Kept presentation errors separate from transport diagnostics and ordinary CRUD
  errors. Failed sync messages survive local reads, connectivity changes and
  retries until a successful cycle clears them. HTTP 401 prompts sign-in;
  revoked-device responses (403/409) and other access failures have distinct
  messages. Network/server failures do not imply expired authentication.
- Preserved automatic stale bootstrap/replay and free-core access. QML contains
  no sync orchestration or manual reset workflow.
- Clarified first-sign-in internet/offline behavior, translated auth failures to
  readable correction/retry messages, and hid static local progress steps during
  initial cloud bootstrap. Bootstrap failures return readable retry guidance.
- Compared against the existing canonical Figma handoff `2894:979` in file
  `7kCGSdFGQ79KpRqdaG5Pfp` using its screenshot directly; no traversal or design
  modification. The recorded auth references remain the source for the existing
  inline layout; no auth/Settings redesign was introduced.

### Verification

- `cmake -S delearner-frontend -B delearner-frontend/build-tests -DDELEARNER_BUILD_APP=OFF -DDELEARNER_BUILD_TESTS=ON`: passed.
- `cmake --build delearner-frontend/build-tests -j 4`: passed.
- `ctest --test-dir delearner-frontend/build-tests --output-on-failure`: final run
  passed all 21 tests, including C++ auth/sync/recovery coverage, both canonical
  fixture sets, and offscreen QML status/auth/bootstrap tests.
- Initial QML verification found a premature wrapping assertion and a native
  macOS offscreen-controls crash. The assertion now waits for layout; QML tests
  explicitly use Qt Basic style. The focused three-test QML rerun and subsequent
  full 21-test run passed.
- `./scripts/test-all.sh root`: passed.
- Root and frontend `git diff --check`: passed. Backend unchanged; no API,
  serialization, schema, sync semantics or canonical documentation changed.

### Remaining Platform Check

Physical iOS/Android and packaged Felgo presentation were not exercised here;
local verification used offscreen Qt Quick with Basic controls. Check the
existing Settings/auth/bootstrap surfaces on device during release validation.
