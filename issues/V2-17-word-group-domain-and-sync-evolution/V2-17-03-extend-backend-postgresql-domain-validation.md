# V2-17-03 — Extend backend PostgreSQL/domain validation

**Parent epic:** V2-17 — Word/Group Domain and Sync Evolution  
**Status:** Ready
**Workspace:** backend  
**Size:** 5 story points  
**Dependencies:** V2-17-01

## Objective

Implement the finalized Word/Group semantics in canonical PostgreSQL state and backend validation without coupling PostgreSQL schema shape to SQLite.

## Scope

- Canonical multi-group membership for words.
- Enforce ownership on every referenced group.
- Enforce at most four unique memberships.
- Persist finalized Word morphology/memo/literal-translation fields.
- Persist Group icon metadata.
- Deleting a group must preserve words and remove the deleted membership.
- Mutation validation must reject references to groups outside the authenticated user's ownership.
- Preserve existing idempotency and conflict-resolution processing.

## Acceptance criteria

- Canonical state can represent 0..4 groups per word.
- Invalid fifth membership is rejected deterministically.
- Cross-user group IDs are rejected.
- Group deletion cannot cascade-delete vocabulary words.
- New fields are returned through canonical mutation results/bootstrap mappings.
- Backend unit/integration tests cover these cases.
