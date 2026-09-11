# DE Vocab Learner — Version 2 Issue Index

**Status:** In Progress  
**Epics:** 15  
**Loop-sized subtasks:** 61

## Version 2 Goal

Deliver an authenticated, account-based, offline-capable multi-device synchronization layer for the existing free product while preserving current learning behavior.

## Completed Foundation — Do Not Reopen

| Epic | Title | Status |
|---|---|---|
| [V2-01](./V2-01-root-coordination-repository-foundation/EPIC.md) | Root Coordination Repository Foundation | Done |
| [V2-02](./V2-02-contract-and-schema-baseline/EPIC.md) | Contract and Schema Baseline | Done |
| [V2-03](./V2-03-frontend-uuid-migration-baseline/EPIC.md) | Frontend UUID + Migration Baseline | Done |
| [V2-04](./V2-04-backend-postgresql-domain-baseline/EPIC.md) | Backend PostgreSQL Domain Baseline | Done |

Additionally completed: V2-07 and V2-11 are Done. These tasks stay Done and must not be reopened.

## Remaining Execution Strategy

The remaining work is intentionally backend-first. Ralph selects globally from dependency-ready tasks using the workspace priority below instead of mechanically finishing every earlier epic before considering later backend work.

1. **Backend authentication/account foundation** — V2-05-01 → V2-05-02 → V2-05-03.
2. **Backend device lifecycle** — V2-06-01 → V2-06-02 → V2-06-04.
3. **Backend mutation engine** — V2-08-01 → V2-08-02/V2-08-03 → V2-08-04.
4. **Backend pull/bootstrap/recovery primitives** — V2-09-01 → V2-09-02 → V2-10-01 → V2-12-01 → V2-12-02.
5. **Client identity + outbox completion** — V2-05-04 → V2-06-03 → V2-07-03 → V2-07-04.
6. **Client pull/bootstrap/scheduling/recovery wiring** — remaining V2-09, V2-10, V2-11 and V2-12 tasks.
7. **End-to-end domain convergence** — V2-13.
8. **Late production UX/Figma review** — V2-14. Figma MCP calls belong here unless a later explicit issue says otherwise.
9. **Release gate** — V2-15.

This order is a priority strategy, not permission to bypass dependencies.

## Epic Catalog

| Epic | Title | Primary Workspace | Figma Policy | High-level dependency |
|---|---|---|---|---|
| [V2-01](./V2-01-root-coordination-repository-foundation/EPIC.md) | Root Coordination Repository Foundation | root | None | Done |
| [V2-02](./V2-02-contract-and-schema-baseline/EPIC.md) | Contract and Schema Baseline | root + children | None | Done |
| [V2-03](./V2-03-frontend-uuid-migration-baseline/EPIC.md) | Frontend UUID + Migration Baseline | frontend | None | Done |
| [V2-04](./V2-04-backend-postgresql-domain-baseline/EPIC.md) | Backend PostgreSQL Domain Baseline | backend | None | Done |
| [V2-05](./V2-05-authentication-and-account-foundation/EPIC.md) | Authentication and Account Foundation | root + backend + frontend | Deferred; simple functional client state allowed | V2-04 |
| [V2-06](./V2-06-device-registration-and-lifecycle/EPIC.md) | Device Registration and Lifecycle | backend + frontend + root | None unless explicitly added later | backend auth |
| [V2-07](./V2-07-frontend-transactional-outbox/EPIC.md) | Frontend Transactional Outbox | frontend | None | Done |
| [V2-08](./V2-08-backend-mutation-processing/EPIC.md) | Backend Mutation Processing | backend + root | None | backend auth + device enforcement + contract |
| [V2-09](./V2-09-incremental-pull-and-cursor/EPIC.md) | Incremental Pull and Cursor | backend + frontend + root | None | backend mutation engine |
| [V2-10](./V2-10-new-device-bootstrap/EPIC.md) | New-Device Bootstrap | backend + frontend + root | None; functional startup state only | backend pull + auth/device |
| [V2-11](./V2-11-automatic-sync-scheduling/EPIC.md) | Automatic Sync Scheduling | frontend | No Figma; minimal functional status only | client outbox/pull/bootstrap |
| [V2-12](./V2-12-retention-and-stale-device-recovery/EPIC.md) | Retention and Stale-Device Recovery | backend + frontend + root | No Figma before V2-14 | pull/bootstrap; client recovery later |
| [V2-13](./V2-13-end-to-end-domain-coverage/EPIC.md) | End-to-End Domain Coverage | frontend + backend + root | None | sync paths complete |
| [V2-14](./V2-14-production-ux-cleanup-for-stable-sync/EPIC.md) | Production UX Cleanup for Stable Sync | Figma + frontend + root | **Required here, late** | functional V2 sync complete |
| [V2-15](./V2-15-root-integration-and-release-gate/EPIC.md) | Root Integration and Release Gate | root + frontend + backend | Verify recorded approved nodes only | V2-14 + functional system |

## Version 2 Non-Goals

- Figma-wide redesign of existing MVP1 screens.
- Payments/subscriptions/entitlements.
- Sharing, AI features, advanced spaced repetition or new quiz families.
- Permanent event sourcing.
- Preserving disposable pre-release integer-ID data.
