# V2-05-01 — Freeze minimal Version 2 authentication behavior contract

**Parent epic:** V2-05 — Authentication and Account Foundation  
**Status:** Planned  
**Workspace:** root  
**Size:** 1 story point(s)  
**Dependencies:** V2-01-02,V2-04-04  

## Objective

Turn the already-approved canonical authentication decisions into a small executable behavior checklist/contract that backend and frontend tasks can test against without requiring Figma.

## Scope

- Record the required Version 2 states: first-use online sign-in, authenticated session, invalid/expired session behavior, previously authenticated offline reopening, and account isolation.
- Define only behavior/API expectations already supported by canonical docs.
- Add root fixtures or acceptance-test inputs where useful.
- Do not design screens.

## Implementation Constraints

- Do not invent provider-specific production UX.
- Email/password is the minimum executable authentication path.
- Apple/Google may remain provider-direction placeholders unless another issue explicitly implements them.
- Do not make free-core offline use depend on periodic backend contact after initial successful authentication.

## Figma Requirement

None. Do not call Figma for this task. If functional testing requires a visible state, implement the smallest functional presentation using existing project patterns and defer visual review to V2-14.

## Acceptance Criteria

- [ ] Root documentation/fixtures describe the minimum authentication state transitions needed by V2 backend/client tests.
- [ ] The contract distinguishes online first authentication from offline reopening after prior successful authentication.
- [ ] Authenticated user identity is derived from session credentials, never trusted from mutation payload `userId`.
- [ ] No screen layout or visual styling decision is promoted to architecture.

## Verification

1. Validate the behavior checklist against canonical system/shared-contract documents.
2. Run any root contract checks added by this task.
3. Inspect final diff for product decisions not already approved.

## Canonical References

- `docs/00-SYSTEM-CONCEPT.md`
- `docs/01-SHARED-DATA-CONTRACT.md`
- `docs/02-SYNC-PROTOCOL.md`
- `docs/07-ISSUE-PLANNING-RULES.md`
- `AGENTS.md`

## Stop / Escalate If

- A new authentication product rule is required that is not present in canonical docs.
- Shared contract semantics must change.
