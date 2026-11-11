# V2-21-02 — Add registration contract and backend validation

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Ready
**Workspace:** root + backend
**Size:** 5 story points
**Dependencies:** V2-21-01
**Figma requirement:** Use the approved V2-21-01 field/error states

## Objective

Freeze one executable registration-input contract and enforce it at the backend
so invalid input cannot bypass the Create account UI.

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

- [ ] Root fixtures are the shared source for backend and frontend validation
      tests.
- [ ] Direct HTTP registration rejects invalid email, weak password and invalid
      supplied name even when the frontend is bypassed.
- [ ] A valid supplied display name is persisted and returned after registration
      and later sign-in.
- [ ] Existing accounts and compatible clients without a display name continue
      to authenticate.
- [ ] Duplicate normalized email handling and account isolation are unchanged.
- [ ] Logs and errors contain no password, raw auth body, token or full email.
- [ ] Backend focused tests and the relevant root auth regression pass.

## Non-goals

- Email ownership verification or verification-message delivery.
- Password breach-list/network checks, password reset or account recovery.
- Adding display name to learning-data sync events.
- Apple/Google provider implementation.

## Stop / escalate if

- The change cannot remain additive for existing accounts/clients.
- Implementing display name would require changing ownership, session or sync
  identity semantics.
