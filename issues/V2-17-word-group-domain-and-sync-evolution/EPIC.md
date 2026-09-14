# V2-17 — Word/Group Domain and Sync Evolution

**Status:** Done
**Workspace:** frontend + backend + root  
**Dependencies:** existing shared contract, UUID baseline, outbox, mutation processing, pull/bootstrap and domain coverage

## Objective

Implement the smallest cross-system data-model changes required by the approved V2-16 vocabulary/group UI behavior without changing the project's local-first sync architecture.

## Product semantics introduced

- A word may belong to **0..4 groups**.
- Group membership is synchronized account data.
- Group create/edit includes stable icon/logo metadata in addition to existing visual properties.
- Word forms required by the supplied UI are persisted and synchronized.
- Phrase becomes an explicit supported word type where the current model uses a generic `Other/Andere` concept.
- Group removal does not delete words.
- Removing a word from one group does not delete the word entity.

## Architecture constraints

- Keep local mutation + outbox creation atomic.
- Keep backend canonical conflict resolution.
- Keep full-current-state create/update mutation semantics.
- Do not mirror SQLite and PostgreSQL mechanically.
- Do not introduce event sourcing or a second conflict policy.
- Do not invent new retry/retention/timestamp constants.

## Recommended contract representation

Represent a Word's synchronized membership set as an ordered-or-unordered `groupIds` collection of unique group UUIDs with a maximum cardinality of four. Internal databases may use relational membership tables. The wire contract must not expose platform-specific database structure.

Exact field spelling/version bump must follow the existing contract/versioning rules discovered in V2-17-01.
