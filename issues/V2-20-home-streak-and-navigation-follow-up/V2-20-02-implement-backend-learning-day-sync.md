# V2-20-02 — Implement backend learning-day persistence and sync

**Parent epic:** V2-20 — Home, Streak and Navigation Follow-up
**Status:** Done
**Workspace:** backend + root
**Size:** 5 story points
**Dependencies:** V2-20-01
**Figma requirement:** None

## Objective

Persist account-owned completed learning days in PostgreSQL and support them
through authenticated event ingestion, pull and bootstrap.

## Scope

- Add the explicit PostgreSQL migration/version from V2-20-01.
- Enforce one row per `(owner_user_id, activity_date)`.
- Resolve concurrent random client UUIDs to one canonical identity.
- Validate payload/date/timestamp shape and derive ownership only from the
  authenticated session.
- Commit canonical creation and accepted sync-event/sequence atomically.
- Return the canonical UUID/state in acknowledgement and pull results.
- Include completed learning days in consistent bootstrap state.
- Preserve idempotent event-ID retry and account isolation.

## Acceptance criteria

- Two devices creating the same date produce one canonical learning day.
- Different dates from offline devices are both retained.
- Cross-account reads and writes are rejected.
- Duplicate event delivery is idempotent.
- Bootstrap and incremental pull expose the same canonical records and matching
  server sequence.
- Invalid/future-out-of-policy dates and malformed timezone offsets are
  rejected with stable codes without partial writes.
- Backend and root contract tests cover migration, ingestion, pull and
  bootstrap.
