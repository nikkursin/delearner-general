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

## Version 2 Initial Baselines

Root-owned machine-readable baselines live in `contracts/version-baseline.env`.
They are surfaced through root diagnostics and tests so frontend and backend
work can depend on the same compatibility source.

Initial Version 2 values:

```text
SQLite schema:     1.0
PostgreSQL schema: 1.0
Sync/API contract: 1.0
API route major:   /api/v1
```

These values are independent version families. Their initial numeric equality
does not create a requirement that future SQLite, PostgreSQL and sync/API
versions advance together.

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
