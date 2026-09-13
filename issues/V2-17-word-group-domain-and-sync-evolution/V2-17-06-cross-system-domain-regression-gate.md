# V2-17-06 — Cross-system domain regression gate

**Parent epic:** V2-17 — Word/Group Domain and Sync Evolution  
**Status:** Blocked  
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
