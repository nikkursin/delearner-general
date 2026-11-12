# V2-21-01 — Freeze local split-authentication UX contract

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
**Workspace:** root
**Size:** 2 story points
**Dependencies:** existing authentication and reauthentication behaviour
**Figma requirement:** None; explicit current user decision forbids Figma work

## Objective

Freeze an implementation-ready local UX contract for separate Sign in and
Create account pages without accessing or modifying Figma.

## Explicit design-source decision

There is no canonical auth layout in Figma, and the user explicitly directed
that this auth flow must not perform any Figma work. This issue and the current
product decision are the source of truth for the flow. Codex must not call
Figma tools, create Figma frames or block waiting for Figma references.

Use the current frontend design tokens, reusable controls and responsive-shell
patterns as the visual baseline. The existing combined auth page is a
functional starting point, not a layout that must be preserved.

## Codex design authority

Codex should come up with the auth-page design itself. It may choose the local
composition, spacing, grouping, dividers, provider-button treatment and
responsive form width needed to produce a coherent result, provided it:

- visibly belongs to the existing DELearner application;
- reuses established components/tokens instead of inventing a parallel style;
- includes every required page, field, state and navigation action below;
- remains responsive and accessible on phone and tablet;
- does not change authentication, bootstrap or sync behaviour.

No external mockup or additional design approval is required for these local
visual decisions. Record the decisions in the checkpoint so V2-21-03 can
implement them consistently.

## Local UX contract

### Sign in

- Sign in is the default first-use page.
- Show Email and Password fields with one primary **Sign in** action.
- Show a clear **Create account** navigation action for users without an
  account.
- Show disabled or **Coming soon** Apple and Google provider controls.
- Preserve busy, invalid-credentials, network and bootstrap error presentation.
- Preserve the **Sign in again** recovery variant, prefilled account email and
  saved-local-work guidance. Recovery mode does not offer account creation.

### Create account

- Use a separate page with Name, Email, Password and Repeat password fields.
- Show field-local validation guidance from the V2-21 registration contract.
- Provide a primary **Create account** action and a clear route back to Sign in.
- Show the same disabled or **Coming soon** Apple and Google controls.
- Repeat password is client-only and never enters requests, persistence or
  logs.

### Responsive presentation

- Use a scrollable content column that remains usable with the software
  keyboard and safe areas.
- Centre and constrain the form to a readable maximum width on tablets while
  allowing the page background to fill the viewport.
- Do not stretch phone controls across the full iPad landscape width.
- Use existing spacing, typography, colour and control primitives; do not add a
  parallel auth-only design system.
- Preserve logical focus order, Return/Next keyboard behaviour and accessible
  field/action labels.

### State presentation

- Define empty, invalid-email, weak-password, password-mismatch, busy,
  backend-validation, network and bootstrap-failure states.
- Client feedback is immediate, but backend validation remains authoritative.
- Provider placeholders never fabricate progress, success, tokens or linked
  identities.

## Work

- Inspect only the current auth page, shared controls/tokens, auth tests and
  responsive-shell patterns needed to confirm reusable implementation seams.
- Record the chosen component/page split, navigation ownership, width/spacing
  rules and state mapping in the implementation checkpoint.
- Identify any discrepancy between this contract and current code for
  V2-21-03; do not implement frontend code in this task.

## Acceptance criteria

- [x] The checkpoint records an implementation-ready page/component and
      navigation structure.
- [x] Sign in, Create account and Sign in again states are unambiguous.
- [x] Phone, keyboard, tablet portrait and tablet landscape rules are explicit.
- [x] Validation and provider-placeholder states are mapped without inventing
      provider functionality.
- [x] The contract reuses the current design system and identifies focused test
      seams.
- [x] No Figma tool was accessed and no Figma file/node was created or modified.

## Non-goals

- Any Figma read or write action.
- Production Apple/Google authentication or account linking.
- Email ownership verification, password reset or account deletion.
- Frontend/backend implementation.

## Stop / escalate if

- A required product behaviour is still ambiguous after applying the explicit
  V2-21 decisions and current functional auth semantics.
- Completing the local contract would require changing authentication,
  bootstrap, offline or account-isolation semantics.

## Implementation checkpoint — 2026-11-12

### Page and component structure

- Keep `DLAuthPage.qml` as the single app-level auth screen loaded by
  `Main.qml`. It owns the safe-area-aware scroll viewport, shared visual
  values, page-level error summary and a local `signIn` / `createAccount`
  route. No new `DLScreen` value or application-level navigation state is
  needed.
- Add focused `DLSignInForm.qml` and `DLCreateAccountForm.qml` child
  components. They own only their fields, field-local feedback, focus chain
  and submit/navigation signals; `DLAuthPage` calls `appStateManager.signIn`
  or the V2-21-03 registration API.
- Add one shared `DLAuthProviderPlaceholders.qml` component used by both
  forms. It renders Apple and Google as visibly unavailable **Coming soon**
  controls, removes them from the active focus/submit path and has no provider
  callback.
- Do not introduce an auth-only theme. Reuse the current `DLAppPage` /
  `DLAuthPage` palette (`#f6f7fb` background, dark primary text, muted text,
  blue primary action and red errors), Qt Quick Controls, 28 px bold page
  heading and the established rounded-card/control treatment. The current
  project has no centralized token or input-control component to extend.

### Navigation and modes

- Normal auth entry always starts on Sign in. **Create account** changes only
  the local `DLAuthPage` route; **Back to Sign in** returns without changing
  `appStateManager.currentScreen` or authentication state.
- `authState === "reauthentication_required"` forces the Sign in form into
  recovery mode, pre-fills `accountEmail`, changes the heading/action to
  **Sign in again**, shows the saved-local-work guidance verbatim and hides
  all Create account navigation. A later auth-state change back to recovery
  also resets any local create-account route.
- Recovery submission continues through the existing `signIn` method so the
  current same-account check, pending-outbox preservation, bootstrap and
  account-isolation behavior remain authoritative.
- Successful authentication continues to leave the auth screen only through
  the existing app-state/bootstrap transition. The local route must never
  infer success or navigate into the app itself.

### Responsive and keyboard rules

- Fill the viewport background and place the forms in a vertical `Flickable`
  or equivalent scroll container. Apply real top, bottom, left and right safe
  area insets plus 24 px phone margins; pass the insets from `Main.qml` as is
  already done for onboarding.
- Centre a form column with width
  `min(480, viewport width - safe areas - 48)`. On a fitting viewport, centre
  the column vertically; when content or the software keyboard reduces the
  available height, top-align and scroll it so the focused field and its
  message remain reachable. Never scale the form to fill tablet width.
- Use 16 px between primary field/action groups, 8 px between a field and its
  local message, and at least 24 px between the credential form, divider and
  provider placeholders. Interactive controls are at least 48 px high.
- Phone portrait, phone landscape, tablet portrait and tablet landscape use
  the same width rule and reflow on resize. No platform/device-name branch or
  fixed iPad offset is permitted.
- Sign in focus order is Email → Password → Sign in → Create account. Create
  account focus order is Name → Email → Password → Repeat password → Create
  account → Back to Sign in. Return advances to the next field; Return on the
  last field submits only when locally valid and not busy. Disabled provider
  placeholders are skipped. Every field, action, error and provider
  placeholder has an accessible name; local errors are associated with their
  field and the summary is announced when it changes.

### State and error mapping

| State | Sign in | Create account | Presentation/behavior |
|---|---|---|---|
| Empty | Email/password required after touch or submit | All four fields required after touch or submit | Field-local plain-language message; no request |
| Invalid email | Email field | Email field | Use the shared V2-21-02 fixture rule; keep backend authoritative |
| Weak password | Not pre-validated beyond non-empty | Password field | Use the shared V2-21-02 fixture rule; no password value in messages/logs |
| Password mismatch | Not applicable | Repeat password field | Block submit locally; Repeat password is never passed to the manager |
| Busy | Existing `authBusy` state | Existing `authBusy` state | Disable fields, route links and submit; show **Signing in…** or **Creating account…**; prevent duplicate requests |
| Invalid credentials | Page summary | Not applicable | Preserve the safe backend message and keep both fields available after completion |
| Backend field validation | Page summary unless a stable V2-21-02 field code maps it | Map `invalid_display_name`, `invalid_email` and `weak_password` to their fields | Never echo supplied values; unknown safe errors stay in the page summary |
| Network failure | Page summary | Page summary | Keep entered values except passwords may follow existing Qt control lifetime; remain on the current route |
| Bootstrap failure | Page summary on the forced Sign in/recovery state | Page summary after the existing app-state transition | Do not claim account/app readiness; preserve current cleanup and local-work rules |

Client validation becomes visible after a field is touched and updates while
the user edits it; submitting marks all required fields as touched. Backend
results can replace the relevant local message and remain authoritative.
Provider placeholders never enter a busy state and never emit authentication,
registration, token or navigation events.

### Current-code discrepancies for V2-21-03

- `DLAuthPage.qml` currently combines Sign in and registration in one
  non-scrollable, vertically centred column and submits registration with the
  Sign in Email/Password fields.
- There is no Name or Repeat password input, local validation, field-local
  error, provider placeholder, safe-area input or tablet maximum width.
- `DLAppStateManager::registerAccount` currently accepts only Email and
  Password; V2-21-02/V2-21-03 must add the compatible display-name path while
  keeping Repeat password out of that API.
- The existing `lastError` is one page-level string. V2-21-03 may map the
  stable field codes introduced by V2-21-02 in QML, but must retain the summary
  fallback for invalid credentials, network, bootstrap and unknown safe
  errors.
- Existing recovery behavior and tests already provide the required prefilled
  email, saved-work guidance, hidden Create account action and same-account
  submission seam; they are preserved rather than redesigned.

### Focused test seams

- Extend `tests/qml/tst_AuthSyncPresentation.qml` to cover initial/local route
  changes, recovery route lock, busy debounce, error mapping, provider
  inertness, field focus/Return order and accessible labels.
- Add phone portrait, phone landscape, tablet portrait and tablet landscape
  rows that assert the 480 px maximum form width, safe-area margins,
  scrollability and resize reflow without device-specific branches.
- Drive Create account validation from the root fixtures introduced by
  V2-21-02 and assert no submission on empty/invalid/mismatch cases.
- Extend the focused C++ auth tests around the registration method to assert
  Name/Email/Password forwarding and that Repeat password cannot enter the
  request interface, persistence or diagnostic output.

### Files changed

- `issues/00-VERSION-2-ISSUE-INDEX.md` — marked V2-21-01 Done.
- `issues/V2-21-design-stabilisation-tasks/EPIC.md` — marked only V2-21-01
  Done; V2-21 remains In Progress.
- This task file — replaced the superseded Figma task definition with the
  approved local contract and recorded the implementation checkpoint.

### Verification

- Inspected the current auth page, app loader, responsive shell, reusable
  visual patterns, app-state auth API and focused auth/UI tests.
- `ctest --test-dir build-tests -R TestAuthSyncPresentation --output-on-failure`
  — passed 1/1 (`TestAuthSyncPresentationUi`).
- Verified the contract does not require a new application screen, auth-state
  transition, backend identity rule, bootstrap rule or sync semantic.
- No Figma tool was accessed and no Figma file or node was created or changed.

### Limitations

- This task intentionally changes no frontend/backend implementation. The
  executable validation fixture and backend error codes belong to V2-21-02;
  the QML/C++ implementation and geometry tests belong to V2-21-03.

### Next task

- V2-21-02 — Add registration contract and backend validation.
