# DE Vocab Learner — Registration Input Contract

## Status

Canonical additive registration-input contract for V2-21. The executable case
table is `contracts/fixtures/v1/registration-input-contract.json`.

This authentication contract is independent of the learning-data sync/API
contract. It does not change sync/API version `2.1`.

## HTTP request

`POST /api/v1/auth/register` accepts a JSON object with:

- required string `email`;
- required string `password`;
- optional string `displayName`.

`repeatPassword` is client-only. It must not be sent, persisted or logged.
Unknown optional request fields retain the existing compatibility behavior.

### Display name

When `displayName` is supplied, the backend trims leading and trailing
whitespace, requires 2–80 Unicode code points, rejects Unicode control
characters and persists the trimmed value on the account. The field remains
optional for compatible existing clients and accounts.

### Email

The backend trims and Unicode-case-folds the email before identity lookup. The
normalized value must contain 3–254 Unicode code points, exactly one `@`, a
non-empty local part and a dotted domain. Domain labels must be non-empty,
contain only letters, numbers or interior hyphens, and cannot start or end with
a hyphen. Whitespace and control characters are rejected. This is basic syntax
validation only; it does not prove email ownership.

### Password

Passwords contain 8–128 Unicode code points and cannot be all whitespace. A
password of at least 12 characters may be a passphrase without character-class
mixing. An 8–11 character password must use at least two of lowercase,
uppercase, digit and non-alphanumeric characters.

The backend never trims or otherwise transforms a password before hashing.

## HTTP response

A successful registration returns the existing `userId`, `sessionToken` and
`tokenType` fields. It also returns `displayName` when the account has one.
Later successful sign-in returns the same optional `displayName`. Existing
accounts without a display name omit it.

Stable field errors use HTTP 400 and do not echo submitted values:

- `invalid_display_name` — a supplied display name is invalid;
- `invalid_email` — email syntax is invalid;
- `weak_password` — password length, whitespace or class rules fail.

The existing deterministic duplicate result remains HTTP 409 with
`email_already_registered`. Existing sign-in failures remain HTTP 401 with
`invalid_credentials`.

## Persistence and compatibility

PostgreSQL schema `1.6` additively introduces nullable
`auth_users.display_name`. Migration from `1.5` preserves all existing users,
identities, credentials, sessions and learning data. An omitted display name is
stored as SQL `NULL`.
