# V2-21-03 — Implement split authentication pages and client validation

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Ready
**Workspace:** frontend + root
**Size:** 5 story points
**Dependencies:** V2-21-01, V2-21-02
**Figma requirement:** Required; implement the approved V2-21-01 nodes

## Objective

Replace the combined authentication form with separate Sign in and Create
account pages, matching the approved Figma flow and shared validation fixtures.

## Scope

- Keep Sign in as the initial auth route and preserve its Email, Password,
  progress, error and submit behaviour.
- Replace the current same-form Create account submission with navigation to a
  separate Create account page.
- Add Name, Email, Password and Repeat password fields to Create account.
- Pass Name, Email and Password to registration; never send Repeat password.
- Apply the V2-21-02 rules locally for immediate feedback while treating
  backend validation as authoritative.
- Show field-local, accessible messages for invalid email, weak password and
  mismatched password confirmation.
- Disable duplicate submissions while auth/bootstrap is busy and keep mapped
  backend errors visible without exposing technical secrets.
- Add Apple and Google controls to both pages as disabled or **Coming soon**
  placeholders with accessible labels that state they are unavailable.
- Preserve the Sign in again recovery variant, prefilled account email, saved
  local-work guidance and existing bootstrap/session transition.
- Use the returned account display name where available; retain a safe fallback
  for existing accounts without one.
- Cover narrow phone, phone landscape and tablet dimensions without fixed
  device-specific widths.

## Acceptance criteria

- [ ] Sign in and Create account are distinct pages/routes with working forward
      and back navigation.
- [ ] A valid new account completes auth, device registration, bootstrap and
      entry into the offline-capable app.
- [ ] Invalid fields are explained before submission and the same invalid cases
      are still rejected by the backend.
- [ ] Repeat password mismatch blocks submission and Repeat password is absent
      from requests, persistence and logs.
- [ ] Apple/Google controls are visible but cannot invoke registration, sign-in
      or success state.
- [ ] Sign in again still preserves local data/outbox work and cannot navigate
      into account creation.
- [ ] Focus order, keyboard/return behaviour and accessibility names are tested.
- [ ] Focused QML/C++ auth tests, root validation fixtures and the frontend suite
      pass.

## Non-goals

- Provider SDKs, OAuth/web views or account linking.
- Email verification, password reset or profile editing.
- Changing bootstrap, sync, sign-out or account-isolation semantics.

## Stop / escalate if

- The approved Figma nodes are missing or materially conflict with V2-21.
- The implementation requires discarding pending local work or changing the
  authenticated identity model.
