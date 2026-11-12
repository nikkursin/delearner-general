# V2-21-03 — Implement split authentication pages and client validation

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
**Workspace:** frontend + root
**Size:** 5 story points
**Dependencies:** V2-21-01, V2-21-02
**Figma requirement:** None; do not access or modify Figma

## Objective

Replace the combined authentication form with separate Sign in and Create
account pages, matching the V2-21-01 local UX contract and shared validation
fixtures.

## Design source

Implement the completed V2-21-01 local UX contract with the frontend's existing
tokens, controls and responsive-shell patterns. The old combined QML form is a
functional reference only. Do not call Figma tools, wait for Figma nodes or
create a Figma layout as part of this task.

Codex has local design discretion to turn that contract into polished pages.
It should make the required visual choices itself, follow the existing
DELearner style, and add the required pages without waiting for another mockup
or reference asset.

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

- [ ] The checkpoint maps the implementation to the V2-21-01 local UX contract
      and confirms no Figma access occurred.
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
- [ ] Phone and tablet results satisfy the local responsive rules and focused
      geometry tests.

## Non-goals

- Provider SDKs, OAuth/web views or account linking.
- Email verification, password reset or profile editing.
- Changing bootstrap, sync, sign-out or account-isolation semantics.

## Stop / escalate if

- The implementation requires discarding pending local work or changing the
  authenticated identity model.

## Implementation checkpoint — 2026-11-12

### UX-contract mapping

- Kept Sign in as the default local route inside `DLAuthPage`, added a distinct
  Create account route and returned through a local Back to Sign in action.
- Split the forms into `DLSignInForm` and `DLCreateAccountForm`, with one shared
  `DLAuthProviderPlaceholders` component. Apple and Google remain disabled,
  explicitly unavailable controls with no authentication callback.
- Preserved the existing Sign in again path, prefilled account email,
  saved-local-work guidance and existing app-state/bootstrap transition. The
  recovery state forces the local route back to Sign in and hides account
  creation.
- Used a safe-area-aware scroll container, 24 px phone margins, a 480 px tablet
  maximum width and minimum 48 px controls. Focus/Return order and accessible
  labels follow the V2-21-01 local contract.
- No Figma tool, file or node was accessed or modified.

### Validation and request behavior

- Added one frontend validator matching all 31 root-owned Name, Email and
  Password fixtures, plus client-only Repeat password confirmation.
- Registration now forwards trimmed Name, Email and Password only. Repeat
  password has no C++ request, persistence or logging interface and a focused
  HTTP request test confirms it is absent from the payload.
- Stable backend field codes map to Name, Email and Password messages while
  unknown, network and bootstrap errors retain the safe page-level fallback.
- Persisted the optional account display name returned by registration/sign-in
  and use it on Home/Profile, with the existing email/signed-in fallback for
  legacy accounts.

### Files changed

- Frontend auth/session code: registration validator, auth service/session
  persistence and app-state registration/display-name API.
- Frontend QML: split auth page/forms/provider placeholders, safe-area wiring,
  and display-name fallback on Home/Profile.
- Frontend tests/build: shared-fixture validator/request test, auth/bootstrap
  coverage, auth QML interaction/accessibility/geometry coverage and adjusted
  Home/Profile expectations.
- Root coordination: this checkpoint, task/index status and parent task row.

### Verification

- `cmake -S . -B build-tests -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH=/opt/homebrew -DDELEARNER_BUILD_APP=OFF -DDELEARNER_BUILD_TESTS=ON` — passed.
- `cmake --build build-tests -j 4` — passed.
- `ctest --test-dir build-tests -R 'Test(HomeUi|AuthSyncPresentationUi|RegistrationValidator|AuthSessionStore|AppStateAuthBootstrap)$' --output-on-failure` — passed 5/5.
- `ctest --test-dir build-tests --output-on-failure` — passed 36/36.
- `python3 ../tests/registration_input_contract_smoke.py` from the frontend
  repository — passed 31/31 fixture cases.
- `git diff --check` for frontend changes — passed.

### Limitations

- Automated viewport rows cover narrow phone, phone landscape, tablet portrait
  and tablet landscape behavior; no physical-device visual check was required
  by this leaf task.
- Per the V2-21 epic guardrail, the root frontend submodule pointer remains
  unpinned until the compatible V2-21-08 integration gate.

### Next task

- V2-21-04A remains blocked until its target icon references are supplied.
  V2-21-08 remains blocked on V2-21-04A and stays last.
