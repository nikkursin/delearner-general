# DE Vocab Learner — Version 2 Issue Index

**Status:** Planned  
**Epics:** 15  
**Loop-sized subtasks:** 60  

## Version 2 Goal

Deliver an authenticated, account-based, offline-capable multi-device synchronization layer for the existing free product while preserving current learning behavior.

## Epic Order

| Epic | Title | Workspace | Figma | Depends on |
|---|---|---|---|---|
| [V2-01](./V2-01-root-coordination-repository-foundation/EPIC.md) | Root Coordination Repository Foundation | root | None | MVP1 complete; canonical documentation set available |
| [V2-02](./V2-02-contract-and-schema-baseline/EPIC.md) | Contract and Schema Baseline | root + frontend + backend | None | V2-01 |
| [V2-03](./V2-03-frontend-uuid-migration-baseline/EPIC.md) | Frontend UUID + Migration Baseline | frontend | Review only if ID assumptions leak into UI; no redesign | V2-02 |
| [V2-04](./V2-04-backend-postgresql-domain-baseline/EPIC.md) | Backend PostgreSQL Domain Baseline | backend | None | V2-02,V2-01-03 |
| [V2-05](./V2-05-authentication-and-account-foundation/EPIC.md) | Authentication and Account Foundation | root + Figma + backend + frontend | Design-first for new authentication/account flow | V2-01,V2-04 |
| [V2-06](./V2-06-device-registration-and-lifecycle/EPIC.md) | Device Registration and Lifecycle | backend + frontend + root | Review only if user-facing revoke/manage-device UI is introduced | V2-05 |
| [V2-07](./V2-07-frontend-transactional-outbox/EPIC.md) | Frontend Transactional Outbox | frontend | None | V2-02,V2-03,V2-06 |
| [V2-08](./V2-08-backend-mutation-processing/EPIC.md) | Backend Mutation Processing | backend + root | None | V2-04,V2-05,V2-06,V2-07 |
| [V2-09](./V2-09-incremental-pull-and-cursor/EPIC.md) | Incremental Pull and Cursor | backend + frontend + root | None | V2-08,V2-06 |
| [V2-10](./V2-10-new-device-bootstrap/EPIC.md) | New-Device Bootstrap | backend + frontend + root | Reuse approved auth/startup flow; no new product redesign | V2-05,V2-06,V2-09 |
| [V2-11](./V2-11-automatic-sync-scheduling/EPIC.md) | Automatic Sync Scheduling | frontend | Minimal status states only; detailed UX handled in V2-14 | V2-07,V2-09,V2-10 |
| [V2-12](./V2-12-retention-and-stale-device-recovery/EPIC.md) | Retention and Stale-Device Recovery | backend + frontend + root | Recovery status reviewed in V2-14; no manual reset flow by default | V2-09,V2-10,V2-11 |
| [V2-13](./V2-13-end-to-end-domain-coverage/EPIC.md) | End-to-End Domain Coverage | frontend + backend + root | No redesign; preserve existing MVP1 behavior | V2-08,V2-09,V2-10,V2-12 |
| [V2-14](./V2-14-production-ux-cleanup-for-stable-sync/EPIC.md) | Production UX Cleanup for Stable Sync | Figma + frontend + root | Design/review required for meaningful new auth/sync/recovery states | V2-05,V2-11,V2-12,V2-13 |
| [V2-15](./V2-15-root-integration-and-release-gate/EPIC.md) | Root Integration and Release Gate | root + frontend + backend | Verification only against approved Version 2 Figma flows | V2-01 through V2-14 |

## Delivery Slices

1. **Workspace + contract:** V2-01 → V2-02
2. **Identity + persistence:** V2-03 + V2-04
3. **Account + device:** V2-05 → V2-06
4. **Push path:** V2-07 → V2-08
5. **Pull + bootstrap:** V2-09 → V2-10 → V2-11
6. **Recovery + domain completion:** V2-12 → V2-13
7. **Production cleanup + release:** V2-14 → V2-15

## Version 2 Non-Goals

- Figma-wide redesign of existing MVP1 screens (Version 3).
- Payments/subscriptions/entitlements (Version 4).
- Sharing, AI features, advanced spaced repetition or new quiz families.
- Permanent event sourcing.
- Preserving the disposable pre-release integer-ID database.
