# Domain relationship and tombstone matrix

Run `tests/domain_relationship_tombstone_matrix.sh` from the root workspace.
The matrix also runs through `scripts/run-integration.sh` and
`scripts/test-all.sh all`. It uses the same `DELEARNER_BUILD_ROOT`,
`BUILD_TYPE`, `CMAKE_BUILD_PARALLEL_LEVEL` and CMake platform environment as
other root builds. It requires Qt Core, Sql, Network, HttpServer and Test;
Felgo, credentials and Figma are unnecessary.

This root-owned test links the production backend authentication, mutation,
pull and bootstrap handlers to the production frontend reconciliation and
bootstrap library. Two registered devices have separate SQLite files and
independent cursors. A third, freshly initialized client restores the actual
backend export at every checkpoint. Payloads come from canonical root fixtures.

| Domain | Create/update | Older update/delete loses | Delete + retry | Older resurrection loses | Later resurrection | Pull equals fresh bootstrap |
|---|---|---|---|---|---|---|
| Group | Yes | Yes | Yes | Yes | Yes | Yes |
| Word | Yes | Yes | Yes | Yes | Yes | Yes |
| Review statistics | Yes | Yes | Yes | Yes | Yes | Yes |
| Account learning setting | Yes | Yes | Yes | Yes | Yes | Yes |

Each row checks canonical acknowledgement values, client-visible existence and
modification time, both client databases, repeated-page application, cursor
acknowledgement, no outbox feedback, and SQLite foreign-key integrity. Snapshot
comparisons exclude local surrogate integer IDs and retain UUID relationships.
Review-state comparisons run in the review row, which publishes canonical review
records; other rows create only unsynced default client review scaffolding.
The group row sends the existing companion word-unlink mutation before deleting
the group and explicitly reattaches the word after resurrection. It does not
assume resurrection recreates membership automatically. Review rows keep their
referenced word alive. Quiz-derived review updates, independent setting UUIDs
and device-local setting exclusion remain covered by the preceding V2-13
scenarios, which the integration command also runs.

The backend uses its existing deterministic QSQLITE migration/test adapter;
client storage is real SQLite. This matrix exercises production handler and
storage code in-process, not HTTP transport or PostgreSQL-specific concurrency.
Those boundaries remain the responsibility of backend and release integration
tests. The matrix introduces no conflict policy: every domain must follow the
canonical timestamp LWW/tombstone rules, including the established logical
account/key identity for settings.

## Authentication and device prerequisite (V2-15-02)

The runner first executes `authentication_device_lifecycle` and stops on failure
before accepting the domain matrix. Both root integration entry points run this
gate before the remaining compiled domain scenarios. For just the prerequisite:

```sh
./tests/domain_relationship_tombstone_matrix.sh --auth-only
```

The scenario registers three devices through the production authenticated device
handler and verifies repeat registration preserves their identities. It checks
missing/invalid bearer denial for registration, upload, pull, bootstrap and cursor
acknowledgement; rejects cross-account device claims, uploads and cursor changes;
rejects spoofed payload ownership; and verifies another account cannot read the
seeded account's pull/bootstrap state. Revocation rejects upload and cursor
advancement without changing canonical state or event history, while a remaining
active device can still upload. Revocation uses the existing backend repository
lifecycle operation; this does not claim a user-facing revocation endpoint exists.

The tests use the existing deterministic SQLite backend adapter and in-process
production handlers, with no external credentials. HTTP transport and PostgreSQL
concurrency are outside this focused scenario. The root orchestration smoke test
injects an authorization test failure and verifies the domain matrix never runs.

## Automatic two-device reconnect (V2-15-03)

The same runner also requires `automatic_two_device_reconnect` after the auth
prerequisite. This scenario connects the production `DLAppStateManager` and
`DLSyncCoordinator` over loopback HTTP to the production backend handlers.
Two persisted client databases take turns opening through the app state manager
because the frontend database manager is a process singleton.

It checks immediate offline group creation, durable outbox survival across client
restart, and automatic upload/pull/cursor acknowledgement on network restoration.
A test transport returns HTTP 503 after the first successful backend commit:
the next automatic attempt must resend the identical event and payload, clear
the outbox only after acknowledgement, and leave server history/sequence unchanged.
Device B then persists an older offline edit while A commits a newer edit;
reconnecting B must silently adopt A's canonical state. B's later deletion must
propagate its tombstone back to A on reconnect. No manual sync is invoked.
The existing four-domain matrix supplies the broader update/delete/resurrection
conflict coverage; the preceding child scenarios supply word relationships,
quiz-derived reviews and account settings coverage.

Conflict timestamps are fixed in the test's queued envelopes, and the retry is
made due through test database setup, so the test neither sleeps through backoff
nor fixes a production retry cadence. The app retains its existing scheduling
logic. This harness still uses the deterministic backend SQLite adapter; deployed
routing, PostgreSQL concurrency, and platform connectivity notification delivery
are outside this scenario. The root test build renames only the backend session
DTO to avoid colliding with the unrelated frontend DTO in one executable.

## Bootstrap and release gate (V2-15-04)

`bootstrap_race_catch_up` uses a real backend export of all four domains, inserts
an update and tombstone before installation, then verifies SQLite catch-up,
replay safety, cursor acknowledgement and equality with a third fresh client.
The runner requires this scenario alongside the existing matrix/reconnect tests.
Both root integration entry points also run
`tests/bootstrap_recovery_regression_gate.sh`, which requires the existing
bootstrap restore, automatic stale recovery, startup and backend protocol suites
individually with `--no-tests=error`. See
[the release checklist](../../docs/08-VERSION-2-RELEASE-CHECKLIST.md) for the full
coverage mapping, recorded pins and outstanding Figma/platform/deployment checks.

## Word/Group regression gate (V2-17-06)

After `./scripts/build-all.sh all`, run
`./tests/word_group_domain_regression_gate.sh`. Both root integration entry points
require this gate. It requires every named child suite individually, including
both repositories' contract-2 fixtures, repository membership validation,
serialization, transactional outbox and remote reconciliation. It then runs the
bootstrap/recovery gate (including existing-local-vocabulary sign-in tests in
`TestAppStateAuthBootstrap`) and the compiled cross-repository matrix.

`word_group_contract2_convergence` covers:

- zero, one and four memberships; removal retaining other UUIDs; moving membership;
- a fifth owned group rejected with `too_many_groups`, without changing the
  backend snapshot or either client's memberships;
- group deletion preserving words, idempotent event retries and no outbox feedback;
- singular noun/plural form, plural-only noun, all three verb forms, adjective
  comparisons, separate adverbs, phrase literal translation, memo/examples and icons;
- propagation to two independent client databases and backend bootstrap restore.

Membership transitions compare exact UUID sets on both incremental clients and
the bootstrap client. Child `TestWordRepository` checks the corresponding local
fifth-membership rejection and atomicity. Existing matrix, coordinator, outbox,
reconciliation and bootstrap suites retain retry, cursor and stale-recovery
coverage. The orchestration smoke test injects failure into each prerequisite to
verify the gate stops; missing CTest registrations also fail explicitly.
