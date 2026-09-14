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
PostgreSQL schema: 1.3
Sync/API contract: 1.0
API route major:   /api/v1
```

V2-17 defines the next Word/Group contract as sync/API `2.0` on `/api/v2`.
It is intentionally a separate target fixture set until both clients and the
backend implement it. The active compatibility baseline above remains `1.0`;
contract definition alone does not claim runtime support.

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
These changes do not advance the active sync/API version. SQLite `1.4` adds
portable Group icon metadata, Word morphology/literal-translation fields, and
relational multi-Group Word membership while migrating the former single
membership without data loss.

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
