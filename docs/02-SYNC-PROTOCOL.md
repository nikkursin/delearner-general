# DE Vocab Learner — Sync Protocol

## Status

Canonical synchronization behavior for the current project direction.

The protocol is not permanent event sourcing. PostgreSQL stores canonical current state. Events exist to synchronize devices, support recovery and provide limited diagnostics.

## Core Goals

The sync system must provide:

- immediate local/offline editing;
- durable capture of every syncable local mutation;
- idempotent retry;
- deterministic backend conflict resolution;
- multi-device propagation;
- safe new-device bootstrap;
- recovery when a device has been offline longer than retained server history;
- bounded event-history storage.

## Local Mutation Flow

Every syncable local mutation is atomic with creation of its durable outbox event.

```text
BEGIN SQLite transaction
→ apply domain mutation
→ write corresponding outbox event
COMMIT
```

Required invariant:

```text
local change committed
⇔
corresponding durable sync event committed
```

A local state change must never exist without its synchronization record.

## Optimistic Local Behavior

Normal personal-data editing is local-first.

```text
user edits
→ SQLite commits immediately
→ UI updates immediately
→ sync runs later
```

When the backend returns a different canonical result due to conflict resolution, the client automatically reconciles local SQLite/UI to that canonical state.

## Outbox Event Shape

A mutation event conceptually contains:

- `eventId` — globally unique UUID;
- `deviceId` — registered device identity;
- authenticated user context derived from the session;
- `entityType`;
- `entityId` — canonical UUID;
- operation type;
- `updatedAt` — client modification time;
- full current entity state for create/update;
- tombstone metadata for delete;
- contract version as required by the transport/API.

Exact transport field names may evolve through the versioned shared data contract.

## Push Processing

Backend processing for one mutation occurs atomically.

```text
receive event
→ authenticate/authorize
→ validate
→ enforce idempotent eventId
→ sanity-check timestamp
→ resolve conflict
→ update canonical PostgreSQL state/tombstone
→ persist sync event/server sequence
→ commit once
→ return acknowledgement + canonical result
```

Canonical domain mutation and accepted server sync-event persistence must be part of the same backend transaction.

If the transaction fails, the mutation is not acknowledged as committed.

### Learning-setting reconciliation

For `app_setting`, resolve `(authenticated ownerUserId, setting_key)` before
conflict comparison, including deletes and tombstones. Return the canonical UUID
and state/tombstone even when the submitted UUID differs. Retries retain the
original event ID and payload; pending events may still carry an older UUID and
resolve by the same logical key. Clients adopt the canonical UUID for subsequent
local edits and preserve pending local work across acknowledgement and bootstrap.

### Learning-day reconciliation

For `learning_day`, resolve `(authenticated ownerUserId, activity_date)` before
insert. The first accepted create establishes the canonical UUID and immutable
payload. A later same-key create with the same or a different UUID is an
idempotent no-op: acknowledge the submitted event and return the existing
canonical UUID/state without creating a second domain row. Persist its accepted
sync event with that resolved canonical state so retry and pull behavior retains
the normal transaction/idempotency guarantees. Clients match by owner/date and
adopt the canonical UUID after acknowledgement or bootstrap. Only create is
valid; ordinary update/delete and last-modification-wins resurrection do not
apply. Account deletion remains the sole deletion path.

## Outbox Acknowledgement

The client does not remove an event merely because it was sent.

```text
send event
→ backend commits/processes
→ backend acknowledges
→ client marks event acknowledged
```

If the request times out before acknowledgement, the client retries the same `eventId`.

Backend idempotency must make repeated delivery safe.

## Local Diagnostic History

Acknowledged outbox events are not retained permanently.

The client keeps a short rolling diagnostic history and purges old acknowledged events automatically.

The exact retention rule (for example last N events or X days) is deferred implementation detail.

## Pull / Server Sequence

The backend assigns a monotonically increasing server sequence to accepted synchronization changes.

Each registered device tracks the latest successfully consumed server sequence/cursor.

Incremental pull concept:

```text
client cursor = N
→ request changes after N
→ receive ordered changes
→ apply/reconcile
→ advance cursor only after successful application
```

The exact endpoint shape is part of the versioned contract.

### Contract 2.1 optional-entity projection

Bootstrap and incremental reads negotiate the minor contract through
`X-DELearner-Sync-Contract`. Missing means `2.0`. Contract `2.0` reads omit
`learning_day` state/events; when such an event is scanned, `nextSequence`
still advances through its server sequence. Contract `2.1` reads include the
event and add `contractVersion: "2.1"` to the response.

A client that changes its declared read contract from `2.0` to `2.1` must
bootstrap once before using its stored incremental cursor. This recovers the
canonical learning-day state that the safe legacy projection intentionally
skipped. Unknown required entity semantics are never silently acknowledged.

## New-Device Bootstrap

After sign-in on a new device:

```text
authenticate
→ register/resolve device
→ fetch a consistent current user state from PostgreSQL
→ obtain the server sequence corresponding to that state
→ create/restore local SQLite
→ fetch/apply changes after that sequence
→ begin normal incremental sync
```

For contract `2.1`, the consistent state includes `state.learningDays` and the
matching sequence. Contract `2.0` omits that optional key. Pending local
learning-day creates survive re-bootstrap and reconcile by owner/date when
replayed.

The implementation does not require a complex pre-generated snapshot system. A consistent backend state export plus matching sequence is sufficient for the first version.

## Automatic Sync Triggers

Synchronization is automatic but conservative.

Trigger sync when practical on:

- app active with network available;
- app resume;
- network reconnection;
- queued local work while connectivity exists.

Do not implement aggressive constant polling without a product requirement.

Manual sync may exist as fallback/diagnostics.

## Conflict Resolution

Current rule: last modification wins.

Comparison normally uses `updatedAt` from the client mutation.

The backend stores `serverReceivedAt` separately and may use defined sanity handling when client timestamps are obviously invalid.

Delete tombstones participate in the same rule.

A later valid update may resurrect an entity if its modification timestamp wins.

Normal conflict outcomes are applied silently on the client.

## Server Retention

Backend sync events are retained only while operationally needed.

PostgreSQL canonical current state is the long-lived source of user data, not the event stream.

Retention uses a hybrid strategy:

1. Active-device cursors indicate which events are still needed for ordinary incremental sync.
2. A maximum event-retention window prevents abandoned/stale devices from blocking cleanup forever.
3. A device whose cursor is older than retained history must recover through fresh bootstrap.

Exact maximum retention duration is deferred and must be configurable rather than embedded into the fundamental architecture.

## Stale Device Recovery

When a device reconnects:

```text
attempt incremental recovery from stored cursor
→ if required events still exist: continue normally
→ if cursor is too old: automatically re-bootstrap
```

The user should not normally be required to manually reset synchronization.

## Unsynced Local Changes During Re-bootstrap

A stale device may still contain legitimate offline work that has never reached the backend.

Those pending local outbox events must be preserved.

Recovery concept:

```text
preserve pending local outbox
→ fetch fresh canonical server state
→ rebuild/reconcile SQLite
→ restore/replay still-valid pending local events
→ let normal backend conflict rules decide outcomes
→ continue incremental sync
```

A stale cursor must not silently erase unsynced user work.

## Backend Independence from Client Implementations

The backend exposes the canonical API/contract and does not need to know the exact client implementation it is serving.

Within one major contract version:

- minor evolution must remain backward-compatible;
- unknown optional fields may be ignored by older clients;
- semantically required unknown operations/behavior must not be treated as successfully understood.

The backend may expose its current contract version but should not require per-client response tailoring as the default model.

## Synced Data Scope — First Backend-Connected MVP

End-to-end synchronization must cover:

- words;
- groups;
- review statistics;
- synced learning settings;
- completed learning days in contract `2.1`;
- deletes/tombstones;
- new-device bootstrap;
- incremental multi-device propagation.

Current quiz generation/execution remains local.

## Import/Export

Manual `.devocab`-style import/export is not a supported user synchronization mechanism once backend sync is stable.

The capability may remain internally for:

- tests;
- migration verification;
- debugging/recovery scenarios.

It should be hidden/removed from normal production UI once stable backend sync replaces it.

## Deferred Implementation Details

The following are intentionally not fixed by this document yet:

- timestamp sanity tolerance;
- retry/backoff constants;
- exact server event-retention duration;
- exact client diagnostic-history retention;
- batching sizes;
- endpoint naming beyond major API versioning;
- exact device limits by plan;
- exact auth provider/library implementation.

Agents must not invent these as permanent architecture decisions unless required by a concrete issue.
