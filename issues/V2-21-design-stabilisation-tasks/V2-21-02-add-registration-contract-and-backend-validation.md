# V2-21-02 — Add registration contract and backend validation

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
**Workspace:** root + backend
**Size:** 5 story points
**Dependencies:** V2-21-01
**Figma requirement:** None; do not access or modify Figma

## Objective

Freeze one executable registration-input contract and enforce it at the backend
so invalid input cannot bypass the Create account UI.

## UX dependency

Use the completed V2-21-01 local UX contract for field names and error-state
intent. Do not access Figma or wait for Figma nodes. The backend remains
authoritative for the security rules below.

## Validation contract

Add root-owned valid/invalid fixtures and apply the same rules in backend and
later frontend tests:

### Name

- Trim leading/trailing whitespace.
- The new client requires 2–80 Unicode characters after trimming.
- Reject control characters and an all-whitespace value.
- Store a supplied valid value as the backend account display name.
- Keep the request field optional at the API boundary for compatibility with
  existing clients/accounts; validate it whenever it is supplied.

### Email

- Trim and normalize consistently with the existing identity lookup.
- Accept 3–254 characters with one `@`, a non-empty local part, a non-empty
  dotted domain, no whitespace and valid non-empty domain labels.
- Validation is intentionally basic syntax validation, not proof of ownership.
- Duplicate normalized email behaviour remains deterministic.

### Password

- Accept 8–128 characters.
- A password of 12 or more characters may be a passphrase. An 8–11 character
  password must contain characters from at least two of: lowercase, uppercase,
  digit and non-alphanumeric.
- Reject an all-whitespace password.
- Do not trim or otherwise transform the password before hashing.

Repeat password is client-only and must not enter the HTTP payload, database or
logs.

## Scope

- Add a root fixture/table containing representative valid and invalid Name,
  Email and Password cases.
- Document the additive registration request/response behaviour and stable
  error codes without changing the sync contract version.
- Add a versioned PostgreSQL migration for the optional account display name.
- Extend registration to accept and persist a supplied valid display name.
- Return the display name through the existing safe account/session result when
  available so the client does not derive it from the email.
- Enforce email and password rules in the backend before hashing or persistence.
- Return field-specific, user-mappable error codes such as
  `invalid_display_name`, `invalid_email` and `weak_password` without echoing
  the supplied value.
- Keep old accounts and omitted-name requests functional.
- Add service, handler, migration, HTTP and secret-redaction tests.

## Acceptance criteria

- [x] The checkpoint confirms the V2-21-01 local UX contract was used without
      Figma access.
- [x] Root fixtures are the shared source for backend and frontend validation
      tests.
- [x] Direct HTTP registration rejects invalid email, weak password and invalid
      supplied name even when the frontend is bypassed.
- [x] A valid supplied display name is persisted and returned after registration
      and later sign-in.
- [x] Existing accounts and compatible clients without a display name continue
      to authenticate.
- [x] Duplicate normalized email handling and account isolation are unchanged.
- [x] Logs and errors contain no password, raw auth body, token or full email.
- [x] Backend focused tests and the relevant root auth regression pass.

## Non-goals

- Email ownership verification or verification-message delivery.
- Password breach-list/network checks, password reset or account recovery.
- Adding display name to learning-data sync events.
- Apple/Google provider implementation.

## Stop / escalate if

- The change cannot remain additive for existing accounts/clients.
- Implementing display name would require changing ownership, session or sync
  identity semantics.

## Implementation checkpoint — 2026-11-12

### Contract and compatibility

- Used the completed V2-21-01 local UX contract for the Name, Email and
  Password fields and stable field-error mapping. No Figma tool or file was
  accessed.
- Added the root-owned executable table
  `contracts/fixtures/v1/registration-input-contract.json` with 31 valid and
  invalid cases. Backend tests consume this file in the coordinated root
  workspace; V2-21-03 can consume the same cases for client validation.
- Documented optional `displayName`, optional response behavior and the stable
  `invalid_display_name`, `invalid_email`, `weak_password` and
  `email_already_registered` codes in
  `docs/09-REGISTRATION-INPUT-CONTRACT.md`.
- Kept sync/API contract `2.1` unchanged. Advanced only the independent
  PostgreSQL schema from `1.5` to additive `1.6` for nullable
  `auth_users.display_name`; the V2-20 target history remains `1.5`.

### Backend implementation

- Registration now validates the supplied optional display name, normalized
  email and unmodified password before hashing or persistence.
- A valid display name is trimmed, persisted transactionally with the account
  and returned by registration and later sign-in. Omitted-name registration
  and legacy null-name accounts continue to work and omit the response field.
- The `1.5` to `1.6` migration adds only the nullable display-name column and
  preserves existing account data.
- Handler and diagnostics retain safe generic errors/log metadata; requests,
  credentials, full emails, hashes, salts and tokens are never logged.

### Files changed

- Root contract/docs/tests: registration fixture and smoke test, registration
  contract doc, PostgreSQL baseline/docs, root test orchestration, served HTTP
  auth regression, health-version fixture and domain-matrix version assertion.
- Backend implementation: auth service/result, auth handler, auth-user
  repository, database migrator and PostgreSQL schema version.
- Backend tests: auth fixture/handler/service/redaction coverage, display-name
  persistence, `1.5` migration preservation and compatible existing suites.

### Verification

- `cmake --build delearner-backend/build-codex-arm64 -j 4` — passed.
- `ctest --test-dir delearner-backend/build-codex-arm64 --output-on-failure` —
  passed 15/15.
- `python3 tests/registration_input_contract_smoke.py` — passed 31/31 cases.
- `./tests/contract_versions_smoke.sh` — passed.
- `./tests/auth_behavior_contract_smoke.sh` — passed.
- `./tests/root_contract_environment_gate_smoke.sh` — passed.
- `./scripts/test-all.sh root` — passed all root smoke checks.
- `./tests/sign_out_http_runtime_regression.sh` — rebuilt the Docker runtime;
  standalone backend CTest passed 12/12 and the real served HTTP matrix passed
  37/37 correlated requests, including all invalid registration cases and
  display-name registration/sign-in.
- `git diff --check` for selected root/backend files — passed.

### Limitations

- A standalone backend-only Docker build cannot see root-owned fixtures, so
  the one fixture-consumption unit case explicitly skips there, matching the
  existing standalone contract-fixture behavior. The coordinated workspace
  runs that case, and the root served-HTTP regression drives the same fixture
  through the Dockerized backend.
- Per the epic guardrail, the root backend submodule pointer is not advanced
  until the compatible V2-21 integration gate.

### Next task

- V2-21-03 — Implement split authentication pages and client validation.
