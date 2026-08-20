# DE Vocab Learner — Version 2 Loop Issue Pack

This package expands the canonical Version 2 plan into Loop-sized executable epics and subtasks.

## Source of truth

Do not treat this ZIP as a replacement for the canonical root documentation. Before execution, read:

- `docs/00-SYSTEM-CONCEPT.md`
- `docs/01-SHARED-DATA-CONTRACT.md`
- `docs/02-SYNC-PROTOCOL.md`
- `docs/03-PRODUCT-ROADMAP.md`
- `docs/04-VERSION-2-PLAN.md`
- `docs/07-ISSUE-PLANNING-RULES.md`
- `AGENTS.md`

## Scope discipline

- Version 2 = authenticated account + complete basic multi-device synchronization for the current free core.
- Existing quiz execution remains local; resulting review statistics sync.
- Current Figma-defined full free-product redesign belongs to Version 3.
- Payments/entitlements belong to Version 4.
- Sharing/premium expansion is later.
- Figma is required before implementing meaningful **new** user-facing Version 2 flows (auth/sync/recovery), but this issue pack must not redesign unrelated MVP1 screens.
- Deferred constants/implementation choices remain configurable and must not be promoted to canonical architecture by an agent without approval.

## Execution hierarchy

`Version 2 → Epic → Loop-sized subtask → child tests → root acceptance`

Cross-repo subtasks should be executed from the root workspace. Purely local subtasks may start in the relevant child repository.
