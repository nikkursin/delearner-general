# V2-05 — Authentication and Account Foundation

**Status:** Planned  
**Version:** 2  
**Workspace:** root + Figma + backend + frontend  
**Figma:** Design-first for new authentication/account flow  
**Depends on:** V2-01,V2-04  

## Goal

Require a real backend account for initial use while preserving indefinite offline access to the free core after successful authentication.

## In Scope

- Define minimal Version 2 authentication flow in Figma before client implementation.
- Create backend user/provider-identity/session foundation.
- Implement email/password as the minimum executable path.
- Bootstrap and persist client session state suitable for offline free-core reopening.

## Out of Scope

- Guest mode
- Payment entitlements
- Polished Apple/Google production sign-in unless separately prioritized
- Automatic identity merge based only on matching email

## Epic Acceptance Criteria

- [ ] Initial use requires successful online authentication.
- [ ] Authenticated identity comes from session credentials rather than payload userId.
- [ ] Previously authenticated client can reopen offline and use free core.
- [ ] Backend account isolation tests prevent cross-user access.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-05-01](./V2-05-01-define-version-2-authentication-flow-in-figma.md) | Define Version 2 authentication flow in Figma | Figma + root | 1 | V2-01-02 |
| [V2-05-02](./V2-05-02-implement-backend-user-and-auth-identity-model.md) | Implement backend user and auth-identity model | backend | 2 | V2-04-01,V2-05-01 |
| [V2-05-03](./V2-05-03-implement-email-password-sessions-and-auth-middleware.md) | Implement email/password sessions and auth middleware | backend | 2 | V2-05-02 |
| [V2-05-04](./V2-05-04-implement-client-auth-bootstrap-and-offline-session-state.md) | Implement client auth bootstrap and offline session state | frontend | 2 | V2-05-01,V2-05-03 |

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
