# V2-17-06 — Cross-system domain regression gate

**Parent epic:** V2-17 — Word/Group Domain and Sync Evolution  
**Status:** Done
**Workspace:** frontend + backend + root  
**Size:** 3 story points  
**Dependencies:** V2-17-04, V2-17-05

## Objective

Add the end-to-end acceptance coverage required before V2-16 relies on the expanded Word/Group model.

## Required scenarios

- Word with zero groups.
- Word with one group.
- Word with four groups.
- Attempted fifth group rejected consistently.
- Group deletion preserves words.
- Remove word from one group while retaining other memberships.
- Move membership from one group to another.
- Noun singular + plural form.
- Plural-only noun state.
- Verb with Präsens (3rd person), Präteritum, Partizip II.
- Adjective forms.
- Phrase literal translation.
- Group icon metadata.
- Memo/example fields.
- Two-device propagation.
- New-device bootstrap.
- Existing-local-data sign-in regression.

## Acceptance criteria

- Frontend/backend contract fixtures agree.
- Root integration tests exercise the cross-repository boundary where feasible.
- No regression to outbox atomicity, idempotent retries, cursor advancement or stale-device recovery.

## Completion evidence

- Added `tests/word_group_domain_regression_gate.sh` to both root integration
  entry points, requiring named frontend/backend fixture, repository, outbox,
  reconciliation, bootstrap, sign-in and recovery suites before accepting the
  cross-repository matrix.
- Extended `word_group_contract2_convergence` with exact membership transitions,
  fifth-owned-group rejection without state mutation, plural-only nouns and
  additional form/example assertions. Coverage mapping is in
  `tests/domain_matrix/README.md`.
- Added failure-injection orchestration coverage for every gate prerequisite.
- Verified `./scripts/test-all.sh all`: root smoke checks, 18 frontend suites,
  13 backend suites, five compiled matrix scenarios and the existing domain
  scenarios passed. `git diff --check` passed.
- Compatible child pins remain frontend `b8f75ff` and backend `6c8a124`; no child
  implementation or contract changes were required.
- Tests use the existing deterministic backend SQLite adapter and real client
  SQLite. No Felgo UI or PostgreSQL-specific concurrency claim is made.
