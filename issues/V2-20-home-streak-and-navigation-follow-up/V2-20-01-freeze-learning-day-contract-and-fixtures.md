# V2-20-01 — Freeze learning-day contract and fixtures

**Parent epic:** V2-20 — Home, Streak and Navigation Follow-up
**Status:** Planned
**Workspace:** root + backend + frontend
**Size:** 5 story points
**Dependencies:** completed V2-18 Quiz baseline
**Figma requirement:** None

## Objective

Define the smallest safe synchronized representation for completed learning
days before either child repository implements streak persistence.

## Required semantic model

Model one immutable account-owned record per completed calendar date. The
logical identity is `(ownerUserId, activity_date)`, using the established
keyed-identity pattern so concurrent devices completing the same day converge
to one canonical record.

The contract must define at least:

- canonical UUID;
- authenticated owner UUID;
- `activity_date` as an ISO `YYYY-MM-DD` local calendar date;
- completion timestamp in UTC;
- timezone offset captured at completion for diagnostics/interpretation;
- creation/update metadata required by the current sync envelope.

Creation is monotonic for this scope: there is no user-facing edit/delete of a
completed learning day. Account deletion still removes all account-owned data.

## Work

- Decide and document whether this is a backward-compatible contract minor or
  requires a major advance. Do not claim minor compatibility unless fixtures
  prove older compatible clients can safely coexist with the new optional
  entity.
- Update the shared data contract, sync protocol and schema baselines only for
  the approved decision.
- Add root-owned valid/invalid fixtures, including two devices creating the
  same logical date with different UUIDs.
- Define canonical UUID reconciliation by logical key.
- Define bootstrap and incremental event shapes.
- Define strict date, timestamp, owner and timezone-offset validation.
- Record the exact SQLite/PostgreSQL migration targets for V2-20-02/03.

## Acceptance criteria

- The chosen versioning strategy is explicit and compatibility-tested.
- Fixtures cover create, duplicate same-date convergence, invalid dates,
  ownership mismatch and bootstrap representation.
- Same-date creation is idempotent by logical key and cannot produce duplicate
  canonical days.
- The contract supports offline client-generated UUIDs and canonical UUID
  adoption after acknowledgement/bootstrap.
- Current Word, Group, review-statistics and learning-setting fixtures remain
  valid.
- No mutable streak counter is introduced as the canonical model.
