# V2-13 — End-to-End Domain Coverage

**Status:** Done
**Version:** 2  
**Workspace:** frontend + backend + root  
**Figma:** No redesign; preserve existing MVP1 behavior  
**Depends on:** V2-08,V2-09,V2-10,V2-12  

## Goal

Prove every domain type approved for Version 2 behaves correctly through the complete synchronization path.

## In Scope

- Complete/verify words and groups.
- Complete/verify review statistics.
- Complete/verify synchronized learning settings while local settings remain local.
- Verify tombstones, relationships and local-quiz-to-review propagation across devices.

## Out of Scope

- Raw quiz history sync
- New quiz modes
- Version 3 Figma redesign

## Epic Acceptance Criteria

- [x] Create/update/delete converges across two devices for all Version 2 entities.
- [x] Word/group relationships remain valid.
- [x] Local quiz results propagate only through review statistics.
- [x] Theme/navigation/transient filters and other device-local settings do not sync.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-13-01](./V2-13-01-complete-words-and-groups-two-device-sync-coverage.md) | Complete words and groups two-device sync coverage | frontend + backend + root | 2 | V2-12-04,V2-02-02 |
| [V2-13-02](./V2-13-02-complete-review-statistics-sync-coverage.md) | Complete review-statistics sync coverage | frontend + backend + root | 2 | V2-12-04,V2-02-03 |
| [V2-13-03](./V2-13-03-complete-synchronized-learning-settings-coverage.md) | Complete synchronized learning-settings coverage | frontend + backend + root | 2 | V2-12-04,V2-02-03 |
| [V2-13-04](./V2-13-04-run-domain-relationship-and-tombstone-matrix.md) | Run domain relationship and tombstone matrix | root | 2 | V2-13-01,V2-13-02,V2-13-03 |

## Canonical References

- `docs/00-SYSTEM-CONCEPT.md`
- `docs/01-SHARED-DATA-CONTRACT.md`
- `docs/02-SYNC-PROTOCOL.md`
- `docs/03-PRODUCT-ROADMAP.md`
- `docs/04-VERSION-2-PLAN.md`
- `docs/07-ISSUE-PLANNING-RULES.md`
- `AGENTS.md`

## Stop / Escalate If

- The work requires a new product behavior not already approved.
- The work requires changing shared contract/schema semantics beyond this epic.
- A Figma/code discrepancy would require a large structural change.
- The task begins pulling Version 3+ scope into Version 2.

## Completion Evidence

All four subtasks are Done. V2-13-04 verifies the domain relationship/tombstone
matrix against the pinned children and passes both child suites, root contract
checks, and all V2-13 domain scenarios. See its completion evidence and
`tests/domain_matrix/README.md` for coverage and test boundaries.
