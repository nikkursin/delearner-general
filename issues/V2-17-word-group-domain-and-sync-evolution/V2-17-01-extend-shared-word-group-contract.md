# V2-17-01 — Extend shared Word/Group contract

**Parent epic:** V2-17 — Word/Group Domain and Sync Evolution  
**Status:** Ready  
**Workspace:** root + frontend + backend  
**Size:** 3 story points  
**Dependencies:** existing V2 shared-contract baseline

## Objective

Define one canonical cross-boundary representation for the approved Word/Group changes before frontend/backend implementations diverge.

## Required semantics

### Word group membership

- Replace single-group semantics with `0..4` unique group UUID memberships.
- A word may exist with no group.
- Maximum four must be a shared validation rule, not UI-only.
- Removing/deleting a group removes that membership from affected words but preserves the words.

### Word fields required by the UI

- part of speech supports Noun, Verb, Adjective, Adverb and Phrase semantics;
- noun article state supports `der`, `die`, `das`, and plural-only;
- plural form is optional and not applicable for a plural-only noun state;
- verb adds Präsens (3rd person) alongside Präteritum and Partizip II;
- adjective supports comparative and superlative;
- phrase supports literal translation;
- memo is preserved/synchronized where it is not already part of the contract;
- existing example + example-translation semantics remain supported.

### Group fields

- group name;
- existing color representation;
- stable icon/logo representation that can render across iOS/Android without persisting platform-specific asset IDs.

## Contract compatibility

Inspect the current wire values before deciding the version bump. If `Other/Andere -> Phrase` changes an existing required enum semantic, treat it according to the contract's breaking-change rules rather than silently reusing an incompatible value.

## Acceptance criteria

- Shared documentation/contract fixtures define all fields and validation semantics.
- Frontend and backend tests consume the same agreed semantics.
- No database-specific table shape leaks into the wire contract.
- Max-four membership behavior and plural-only noun behavior are unambiguous.
