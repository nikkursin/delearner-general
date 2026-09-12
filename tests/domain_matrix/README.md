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
