# V2-05 — Authentication and Account Foundation

**Status:** Planned  
**Version:** 2  
**Workspace:** root + backend + frontend  
**Figma:** Deferred to V2-14; no MCP call required here  
**Depends on:** V2-01,V2-04  

## Goal

Establish backend-owned account/session identity first, then add the smallest functional client authentication bootstrap required for testing and offline reopening.

## In Scope

- Freeze minimal auth behavior from canonical docs without designing UI.
- Create backend user/provider-identity/session foundation.
- Implement email/password as the minimum executable path.
- Implement client session bootstrap/offline state with simple functional presentation only where unavoidable.

## Out of Scope

- Figma-driven visual authentication design in this epic
- Guest mode
- Payment entitlements
- Polished Apple/Google production sign-in
- Automatic identity merge based only on matching email

## Epic Acceptance Criteria

- [ ] Initial use requires successful online authentication.
- [ ] Authenticated identity comes from session credentials rather than payload userId.
- [ ] Previously authenticated client can reopen offline and use free core.
- [ ] Backend account isolation tests prevent cross-user access.
- [ ] Any temporary auth UI is intentionally minimal and left for V2-14 visual review.

## Subtasks

| ID | Title | Workspace | Size | Dependencies |
|---|---|---|---:|---|
| [V2-05-01](./V2-05-01-freeze-minimal-version-2-auth-behavior-contract.md) | Freeze minimal Version 2 authentication behavior contract | root | 1 | V2-01-02,V2-04-04 |
| [V2-05-02](./V2-05-02-implement-backend-user-and-auth-identity-model.md) | Implement backend user and auth-identity model | backend | 2 | V2-04-01,V2-05-01 |
| [V2-05-03](./V2-05-03-implement-email-password-sessions-and-auth-middleware.md) | Implement email/password sessions and auth middleware | backend | 2 | V2-05-02 |
| [V2-05-04](./V2-05-04-implement-client-auth-bootstrap-and-offline-session-state.md) | Implement client auth bootstrap and offline session state | frontend | 2 | V2-05-03 |

## Canonical References

- `docs/00-SYSTEM-CONCEPT.md`
- `docs/01-SHARED-DATA-CONTRACT.md`
- `docs/02-SYNC-PROTOCOL.md`
- `docs/07-ISSUE-PLANNING-RULES.md`
- `AGENTS.md`

## Stop / Escalate If

- Work requires a new authentication product rule not already approved.
- Shared schema/contract semantics are missing or contradictory.
- The task begins pulling payments, sharing or Version 3 redesign into Version 2.

Missing Figma is not a blocker for this epic.
