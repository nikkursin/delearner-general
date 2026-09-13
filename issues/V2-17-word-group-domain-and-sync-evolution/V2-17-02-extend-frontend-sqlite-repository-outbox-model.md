# V2-17-02 — Extend frontend SQLite/repository/outbox model

**Parent epic:** V2-17 — Word/Group Domain and Sync Evolution  
**Status:** Ready
**Workspace:** frontend  
**Size:** 5 story points  
**Dependencies:** V2-17-01

## Objective

Implement the finalized Word/Group contract semantics in the local SQLite/domain/repository layer while preserving atomic local-first mutations and outbox capture.

## Scope

- Replace single-group local semantics with multi-group membership suitable for `0..4` groups per word.
- Use a relational local representation where appropriate; do not encode membership in a way that makes normal local queries fragile.
- Extend Word persistence/repository mapping for the finalized morphology/memo/literal-translation fields.
- Extend Group persistence for stable icon metadata if not already supported.
- Update create/update/delete/group-removal operations and repository queries.
- Every syncable mutation must still commit domain state and its outbox event in one SQLite transaction.
- Update local contract serialization/deserialization.

## Acceptance criteria

- Local CRUD supports 0, 1 and 4 group memberships and rejects >4.
- Duplicate memberships are impossible/normalized.
- Deleting a group preserves words and removes only the deleted membership.
- New Word fields round-trip through SQLite without loss.
- Outbox payload contains the finalized full current entity state.
- Existing vocabulary remains queryable after the schema update according to the project's current migration policy.

## Tests

- Repository tests for membership cardinality and deletion semantics.
- Transactional outbox invariants for all new mutation paths.
- Serialization round-trip tests for new fields.
