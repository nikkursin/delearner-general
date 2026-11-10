# DE Vocab Learner — Shared Data Contract

## Status

Canonical cross-boundary data contract for frontend/backend coordination.

This document defines semantic ownership and compatibility rules. It does not require SQLite and PostgreSQL to use identical schemas.

## Contract Version

The sync/API contract uses independent `MAJOR.MINOR` versioning.

Example:

```text
contract: 1.2
```

Rules:

- same major version is expected to interoperate;
- minor versions must remain backward-compatible;
- optional additive fields may be introduced in minor versions;
- unknown optional fields are ignored by older compatible clients;
- unknown required semantics must not be silently ignored;
- a major version change represents a breaking protocol change requiring explicit compatibility handling or upgrade.

HTTP/API routes may expose only the major version, for example `/api/v1/...`, while the full contract version remains `1.2`, `1.3`, etc.

The backend stays client-independent. It exposes the canonical contract rather than tailoring payloads to every specific client implementation.

## Version 2 Current Baselines

Root-owned machine-readable baselines live in `contracts/version-baseline.env`.
They are surfaced through root diagnostics and tests so frontend and backend
work can depend on the same compatibility source.

Current Version 2 values:

```text
SQLite schema:     1.4
PostgreSQL schema: 1.4
Sync/API contract: 2.0
API route major:   /api/v2
```

V2-20-01 freezes the next additive targets without claiming that the pinned
children already implement them:

```text
SQLite schema target:     1.5
PostgreSQL schema target: 1.5
Sync/API contract target: 2.1
API route major:          /api/v2
```

The active runtime remains SQLite `1.4`, PostgreSQL `1.4`, and sync/API `2.0`
until V2-20-02 and V2-20-03 implement the target. The machine-readable target
values live beside the active values in `contracts/version-baseline.env` with
the `DELEARNER_V2_20_TARGET_` prefix.

V2-17 defines and implements the current Word/Group contract as sync/API `2.0`
on `/api/v2`. The prior `1.0` fixture sets remain available as compatibility
references; the active runtime compatibility baseline is `2.0`.

These values are independent version families. SQLite advanced to `1.1` for
the additive local outbox schema and `1.2` for the additive local pull-cursor
state needed to persist successful remote consumption. SQLite `1.3` adds
account learning settings with local tombstones (V2-13-03). PostgreSQL advanced to
`1.1` for the additive registered-device schema and `1.2` for backend-only
durable winning-event metadata and resolved pull output (V2-12-03A). The
pre-release `1.2` migration resets legacy canonical sync data and device cursors
whose winning identities cannot be recovered after retention; account/auth/device
identity remains intact. PostgreSQL `1.3` adds portable Group icon metadata,
Word morphology/literal-translation fields, and relational multi-Group Word
membership while migrating the former single membership without data loss.
PostgreSQL `1.4` normalizes the unambiguous legacy Word type labels retained in
canonical domain rows and sync-event payloads (`Nomen`, `Verb`, `Adjektiv`,
`Adverb`, and `Phrase`) to the strict contract 2 wire values. It deliberately
does not treat ambiguous legacy `Andere` as `phrase`. These changes do not
advance the active sync/API version. SQLite `1.4` adds
portable Group icon metadata, Word morphology/literal-translation fields, and
relational multi-Group Word membership while migrating the former single
membership without data loss.

The approved `1.5` schema targets are additive. SQLite `1.5` adds an
account-isolated `learning_days` store with a unique `(owner_user_id,
activity_date)` key and reuses the transactional outbox. PostgreSQL `1.5` adds
the canonical account-owned `learning_days` relation with the same logical
unique key. Exact child migration SQL belongs to V2-20-02 and V2-20-03; neither
schema is required to mirror the other beyond the contract fields and
constraints.

## Database Schema Versioning

Frontend SQLite and backend PostgreSQL schemas evolve independently.

Both use explicit `MAJOR.MINOR` schema versions.

```text
SQLite schema:     MAJOR.MINOR
PostgreSQL schema: MAJOR.MINOR
Sync/API contract: MAJOR.MINOR
```

These version numbers are independent and are not expected to match.

Recommended semantics:

- `MAJOR`: incompatible structural change requiring deliberate migration/compatibility handling;
- `MINOR`: backward-compatible/additive schema evolution.

The new UUID-based pre-release schema becomes the first durable baseline. Existing developer data does not need migration preservation.

## Identity

Syncable entities use UUIDs as canonical IDs across client and backend.

Examples:

```text
word.id  = UUID
group.id = UUID
```

Legacy integer IDs are not part of the target model and do not need preservation because there are no production users/data requiring compatibility.

Client devices may generate canonical UUIDs before contacting the backend. This allows offline creation without server-assigned identity.

### Keyed learning-setting identity

Synchronized learning settings have logical identity `(ownerUserId, setting_key)`.
Their UUID is a technical entity identifier; random offline UUIDs are permitted.
PostgreSQL retains `UNIQUE(owner_user_id, setting_key)`. The backend resolves
create/update/delete mutations against the existing account/key, including its
tombstone, before applying the existing `updatedAt` last-modification-wins rule.
Responses, pull events and bootstrap state carry the canonical UUID. Clients
reconcile the local row by key without creating duplicate logical settings.
Words, groups and review statistics retain their existing UUID identity semantics.

### Keyed learning-day identity

Completed learning days have logical identity `(ownerUserId, activity_date)`.
Their UUID is a technical identifier generated offline by a client. PostgreSQL
`1.5` must enforce `UNIQUE(owner_user_id, activity_date)` and resolve that key
before inserting. The first accepted row for a key retains its UUID and full
payload. A later create for the same key, including one with a different
offline UUID, is an idempotent no-op that acknowledges and returns the existing
canonical row. Clients reconcile local rows by owner/date and adopt the
canonical UUID after acknowledgement or bootstrap.

There is no learning-day update or user-facing delete. Account deletion still
removes all learning days owned by the deleted account.

## Ownership

Every personal syncable entity belongs to exactly one backend user account.

Conceptual field:

```text
ownerUserId = UUID
```

Ownership must be enforced by backend authorization.

Ownership is modeled now even though sharing is not implemented yet.

## Current Syncable Domain Scope

The first backend-connected MVP synchronizes the important current personal data:

- words;
- groups;
- review statistics;
- synchronized learning settings;
- completed learning days (contract `2.1` target);
- deletes/tombstones for those entities.

Current quiz execution and raw quiz-session history are not part of the synchronization contract.

Device-specific UI state is not part of the synchronization contract.

## Entity Representation

Create/update sync mutations carry full current entity state, not patches.

Conceptually:

```json
{
  "entityType": "word",
  "entityId": "uuid",
  "updatedAt": "client modification timestamp",
  "data": {
    "...": "full current entity state"
  }
}
```

The exact shape of each entity is defined by the evolving contract and may differ from either database's internal table structure.

The contract is the mapping boundary between the local operational model and backend operational model.

## Contract Fixtures

Root-owned contract fixtures live under `contracts/fixtures/`.

The initial word/group create and update fixtures are in
`contracts/fixtures/v1/word-and-group-events.json`. They define UUID-based
event envelopes, authenticated ownership context, device context and full-state
word/group payloads for frontend and backend compatibility tests.

Review statistics, synchronized learning settings and delete tombstone fixtures
are in `contracts/fixtures/v1/review-settings-and-tombstone-events.json`.
Review-statistics fixtures use the reviewed word UUID as the sync entity ID.
Learning-setting fixtures cover account-level learning preferences only. Delete
fixtures carry tombstone identity and timestamps instead of dead full payloads.

The approved multi-group Word/Group target fixtures are in
`contracts/fixtures/v2/word-and-group-events.json`. Frontend and backend tests
validate this same root-owned target before their persistence implementations
adopt it. Moving from `group_id` to authoritative `group_ids` full state, and
removing legacy `Andere` as a phrase alias, are breaking semantics; therefore
this shape is contract `2.0`, not a compatible `1.x` addition.

The learning-day target fixtures are in
`contracts/fixtures/v2.1/learning-day-events.json`. They define two-device
same-date convergence, strict invalid cases, acknowledgement-driven canonical
UUID adoption, bootstrap state, incremental events, and the legacy `2.0` read
projection. Existing `1.0` and `2.0` fixture sets remain unchanged and valid.

## Contract 2.0 Word and Group Payloads

Wire payload names continue the existing snake-case convention except for the
established `ownerUserId` ownership field. Database table or join-table shapes
are not part of this contract.

### Word

Every Word create/update payload is full current state and contains:

```text
id, ownerUserId
german_word, normalized_german_word
part_of_speech, article
native_translation, normalized_native_translation
example_phrase_de, example_phrase_native
group_ids
notes, literal_translation
plural_form
praesens_third_person_form, praeteritum_form, partizip_ii_form
positive_form, comparative_form, superlative_form
created_at, updated_at
```

Rules:

- `group_ids` is the authoritative, semantically unordered membership set. It
  contains zero through four unique UUIDs owned by the authenticated user.
  Array order has no persistence or conflict meaning.
- `part_of_speech` is exactly one of `noun`, `verb`, `adjective`, `adverb`, or
  `phrase`. These stable wire values are independent of translated UI labels.
  Legacy `Andere` is not accepted as `phrase` in contract 2.
- `article` is `der`, `die`, `das`, or `plural_only` for a noun and is `null`
  for every other part of speech.
- `plural_form` is nullable for an ordinary noun, must be `null` for a
  `plural_only` noun, and is `null` for non-nouns. The word text itself holds
  the plural-only lexical form.
- `praesens_third_person_form`, `praeteritum_form`, and `partizip_ii_form` are
  nullable verb fields and are `null` for non-verbs.
- `positive_form`, `comparative_form`, and `superlative_form` are nullable
  adjective fields and are `null` for non-adjectives.
- `literal_translation` is nullable for a phrase and is `null` otherwise.
- `notes` is the synchronized memo value. It remains nullable.
- `example_phrase_de` and `example_phrase_native` retain their existing
  nullable example/example-translation meanings for every word type.

### Group

Every Group create/update payload contains the existing identity, ownership,
name, `color_hex`, and timestamps plus `icon_key`. `icon_key` is a non-empty,
lowercase portable catalog key made from letters, digits, `.`, `_`, or `-`
(for example `travel` or `train`). It is not an iOS symbol name, Android
resource ID, filesystem path, or other platform-specific asset identifier.
Clients map known keys to bundled cross-platform visuals and render a generic
fallback for an unknown key, allowing later compatible catalog additions.

Deleting a Group preserves every Word. The backend removes the deleted UUID
from affected membership sets and makes those resulting full Word states
available through normal mutation/pull reconciliation; the Group delete remains
a normal tombstone. Removing one membership likewise updates the Word's full
`group_ids` state and never implies Word deletion.

## Contract 2.1 Learning-Day Payload

`learning_day` is an additive, immutable entity on `/api/v2`. A create carries
full state:

```text
id, ownerUserId
activity_date
completed_at, timezone_offset_minutes
created_at, updated_at
```

Rules:

- `id` is a client-generated UUID and initially equals the event `entityId`.
- `ownerUserId` must equal the authenticated user UUID. The backend never
  accepts a client-supplied owner for another account.
- `activity_date` is a real Gregorian calendar date in exact `YYYY-MM-DD`
  form. It must equal the local date obtained by applying
  `timezone_offset_minutes` to `completed_at`.
- `completed_at` is an ISO-8601 UTC timestamp captured when the qualifying quiz
  completes.
- `timezone_offset_minutes` is an integer from `-840` through `840`, inclusive.
- Creation is the only operation. `created_at` and `updated_at` equal
  `completed_at`; no mutable streak counter or later last-modification-wins
  update exists for this entity.
- `(ownerUserId, activity_date)` is the logical key. The first accepted create
  remains canonical; later same-key creates return that canonical UUID and
  state without inserting another domain row. The later accepted sync event
  carries the resolved canonical UUID/state, preserving ordinary event
  idempotency and allowing every client to upsert the same logical row.
- Bootstrap uses `state.learningDays`, an array of these payloads.
- Incremental pull uses the ordinary event envelope with
  `entityType: "learning_day"`, `operation: "create"`, a `serverSequence`, and
  the full payload.

The current streak is a client-side derivation over consecutive
`activity_date` values. It is not synchronized state.

### Why this is contract 2.1

The entity is additive and optional for contract `2.0` product behavior, so it
does not require a new route major. Safe coexistence is nevertheless explicit:

- sync reads accept `X-DELearner-Sync-Contract` with `2.0` or `2.1`;
- an omitted header means `2.0`, preserving existing clients;
- the `2.0` bootstrap projection omits `state.learningDays`;
- the `2.0` incremental projection omits `learning_day` events but advances
  `nextSequence` through scanned optional events so legacy clients do not loop;
- `2.1` responses include learning days and echo `contractVersion: "2.1"`;
- a client upgrading from `2.0` to `2.1` performs one bootstrap before resuming
  incremental sync, restoring any learning days skipped by its former cursor;
- a `learning_day` mutation under `2.0`, or any unknown required entity
  semantic, is rejected rather than silently accepted.

This negotiation is by declared contract version, not by client product or
platform, so the backend remains client-independent. The fixture compatibility
scenario proves the legacy projection and upgrade rule.

## Delete Representation

Deletes use tombstones.

Delete mutations contain identity and delete/modification metadata rather than the last full entity payload.

Conceptually:

```json
{
  "entityType": "word",
  "entityId": "uuid",
  "updatedAt": "...",
  "deletedAt": "..."
}
```

A tombstone participates in the same last-modification-wins comparison as ordinary updates.

A later valid modification may resurrect an entity if its modification timestamp wins.

## Time Fields

Client mutations include the actual client-side modification timestamp:

```text
updatedAt
```

The backend separately records receipt time:

```text
serverReceivedAt
```

Conflict resolution normally uses the client modification timestamp.

The backend must sanity-check clearly invalid/broken client timestamps. Exact tolerance thresholds are deferred implementation details and must not be invented ad hoc by agents.

## Conflict Semantics

Current v1 conflict philosophy is last-modification-wins.

The backend owns conflict resolution.

Clients must not independently implement competing conflict policies.

Normal resolved conflicts are reconciled automatically without showing a conflict dialog.

If the backend determines a different canonical result from the optimistic local state, the client updates local SQLite/UI to the returned canonical result.

## Mutation Result

After processing a mutation, the backend returns:

- acknowledgement;
- resulting canonical entity state for create/update; or
- canonical tombstone metadata for delete.

This allows immediate client reconciliation without waiting for the next pull cycle.

## Event Identity and Idempotency

Every client-generated sync mutation has a stable unique event identifier:

```text
eventId = UUID
```

Retries reuse the same `eventId`.

The backend must process duplicate delivery idempotently.

## User and Device Context

Authentication identifies the backend user.

Registered devices have backend-tracked device identity.

Exact device-count limits are product/policy configuration and are deferred. Multiple simultaneous registered devices are supported. Users can revoke old devices.

A revoked device must not be allowed to continue uploading as a valid registered device without reauthorization.

## Authentication Identities

The backend user identity is separate from authentication provider identities.

A user may link:

- email/password identity;
- Apple identity;
- Google identity.

Provider identities map to one backend user record.

No automatic account merge occurs solely because verified email strings match.

## Subscription/Entitlement Data

The backend stores one effective entitlement state per user, while purchase/store/provider facts remain transaction metadata/history.

RevenueCat is the preferred normalization layer, but entitlement ownership and product authorization remain backend responsibilities.

## Schema Independence

The frontend SQLite schema and backend PostgreSQL schema must not be mechanically mirrored table-for-table.

### SQLite

Optimized for:

- offline operation;
- local UI/query needs;
- local transactional outbox;
- efficient client behavior.

### PostgreSQL

Optimized for:

- canonical current state;
- users/devices/auth;
- authorization;
- sync processing;
- subscriptions/entitlements;
- future shared/cross-user behavior;
- server-side query needs.

Important/queryable domain data should generally be relational. Natural aggregate or low-query-value structured fields may remain JSON where that is simpler and appropriate.

## Sharing Direction

Sharing is not part of the active contract now.

Future direction:

- share word or group explicitly between users;
- create an independent recipient-owned copy;
- no automatic future propagation between source and copy.

Do not add sharing endpoints/tables merely for speculative future-proofing. Model ownership now; add actual sharing infrastructure only when the feature enters scope.
