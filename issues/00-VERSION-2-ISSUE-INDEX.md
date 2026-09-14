# DE Vocab Learner — Version 2 Issue Index

**Status:** In Progress  
**Epics:** 18  
**Loop-sized subtasks:** 74

## Version 2 Goal

Deliver an authenticated, account-based, offline-capable multi-device synchronization layer for the existing free product while preserving current learning behavior.

After the functional synchronization baseline is stable, align the approved vocabulary/group/onboarding/navigation frontend surfaces with the supplied design references and evolve the synchronized Word/Group domain only where those approved designs require it.

Quiz, authentication/login and Settings/Profile redesign remain deferred until their target references are supplied.

## Completed Foundation — Do Not Reopen

| Epic | Title | Status |
|---|---|---|
| [V2-01](./V2-01-root-coordination-repository-foundation/EPIC.md) | Root Coordination Repository Foundation | Done |
| [V2-02](./V2-02-contract-and-schema-baseline/EPIC.md) | Contract and Schema Baseline | Done |
| [V2-03](./V2-03-frontend-uuid-migration-baseline/EPIC.md) | Frontend UUID + Migration Baseline | Done |
| [V2-04](./V2-04-backend-postgresql-domain-baseline/EPIC.md) | Backend PostgreSQL Domain Baseline | Done |

Additionally completed: V2-07 and V2-11 are Done. These tasks stay Done and must not be reopened.

## Remaining Execution Strategy

The remaining work stays dependency-driven and backend-first where cross-system behavior is involved. Ralph selects globally from dependency-ready tasks using the workspace priority below instead of mechanically finishing every earlier epic before considering later ready work.

1. **Backend authentication/account foundation** — V2-05-01 → V2-05-02 → V2-05-03.
2. **Backend device lifecycle** — V2-06-01 → V2-06-02 → V2-06-04.
3. **Backend mutation engine** — V2-08-01 → V2-08-02/V2-08-03 → V2-08-04.
4. **Backend pull/bootstrap/recovery primitives** — V2-09-01 → V2-09-02 → V2-10-01 → V2-12-01 → V2-12-02.
5. **Client identity + outbox completion** — V2-05-04 → V2-06-03 → V2-07-03 → V2-07-04.
6. **Client pull/bootstrap/scheduling/recovery wiring** — remaining V2-09, V2-10, V2-11 and V2-12 tasks.
7. **End-to-end domain convergence** — V2-13.
8. **Stable-sync production UX cleanup** — V2-14. Keep its existing scope; do not duplicate the newly approved screenshot-driven redesign owned by V2-16.
9. **Word/Group domain and sync evolution** — V2-17. Complete the shared-contract/frontend/backend changes required by the approved new Word/Group behavior.
10. **Frontend design alignment** — V2-16. V2-16-01 and V2-16-02 may proceed independently where ready; V2-16-03 through V2-16-07 wait for the required V2-17 synchronized domain support.
11. **Release gate** — V2-15 after the functional sync system plus active V2-16/V2-17 scope is integrated and verified.
12. **Deferred UI follow-up** — V2-18 remains non-blocking and undecomposed until Quiz, authentication/login and Settings/Profile target references are supplied.

This order is a priority strategy, not permission to bypass dependencies.

## Ownership Clarification

- **V2-14** retains its existing production UX cleanup responsibilities around stable synchronization.
- **V2-16** owns the newly approved screenshot-driven redesign for onboarding, bottom navigation, Add/Edit Word, Groups, Group Details, Words and Word Details/Edit.
- **V2-17** owns the cross-system data/contract changes required by that redesign. These changes must not be implemented as frontend-only shortcuts.
- **V2-18** reserves future Quiz, authentication/login and Settings/Profile design work. Existing behavior stays unchanged until that epic is explicitly activated and decomposed.

## Epic Catalog

| Epic | Title | Primary Workspace | Figma / Reference Policy | High-level dependency |
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
| [V2-11](./V2-11-automatic-sync-scheduling/EPIC.md) | Automatic Sync Scheduling | frontend | No Figma; minimal functional status only | Done |
| [V2-12](./V2-12-retention-and-stale-device-recovery/EPIC.md) | Retention and Stale-Device Recovery | backend + frontend + root | No Figma before V2-14 | pull/bootstrap; client recovery later |
| [V2-13](./V2-13-end-to-end-domain-coverage/EPIC.md) | End-to-End Domain Coverage | frontend + backend + root | None | sync paths complete |
| [V2-14](./V2-14-production-ux-cleanup-for-stable-sync/EPIC.md) | Production UX Cleanup for Stable Sync | Figma + frontend + root | Existing late stable-sync UX scope | functional V2 sync complete |
| [V2-15](./V2-15-root-integration-and-release-gate/EPIC.md) | Root Integration and Release Gate | root + frontend + backend | Verify approved references only | V2-14 + active V2-16/V2-17 scope + functional system |
| [V2-16](./V2-16-frontend-design-alignment/EPIC.md) | Frontend Design Alignment | frontend + root | Use supplied screenshots; avoid MCP unless material information is missing | functional frontend baseline; V2-17 for new Word/Group semantics |
| [V2-17](./V2-17-word-group-domain-and-sync-evolution/EPIC.md) | Word/Group Domain and Sync Evolution | frontend + backend + root | None | existing contract + UUID + outbox + mutation/pull/bootstrap baseline |
| [V2-18](./V2-18-quiz-auth-settings-ui-follow-up/EPIC.md) | Quiz, Authentication and Settings UI Follow-up | frontend + backend + root as later decomposed | Deferred until target references are supplied | V2-16/V2-17 completion; non-blocking until activated |

## V2-16 — Frontend Design Alignment Tasks

| Task | Status | Dependencies |
|---|---|---|
| [V2-16-01](./V2-16-frontend-design-alignment/V2-16-01-responsive-shell-and-modern-bottom-navigation.md) — Responsive shell and modern bottom navigation | Done | Existing navigation baseline |
| [V2-16-02](./V2-16-frontend-design-alignment/V2-16-02-first-run-onboarding-flow.md) — First-run onboarding flow | Done | Existing authentication entry point |
| [V2-16-03](./V2-16-frontend-design-alignment/V2-16-03-add-edit-word-redesign-and-group-selector.md) — Add/Edit Word redesign and group selector | Blocked | V2-17-04 |
| [V2-16-04](./V2-16-frontend-design-alignment/V2-16-04-groups-list-create-and-edit-redesign.md) — Groups list, create and edit redesign | Blocked | V2-17-04 |
| [V2-16-05](./V2-16-frontend-design-alignment/V2-16-05-group-details-and-word-actions-redesign.md) — Group Details and word actions redesign | Blocked | V2-17-04 |
| [V2-16-06](./V2-16-frontend-design-alignment/V2-16-06-words-list-search-filters-and-swipe-actions.md) — Words list, search, filters and swipe actions | Blocked | V2-17-04 |
| [V2-16-07](./V2-16-frontend-design-alignment/V2-16-07-word-details-and-edit-word-redesign.md) — Word Details and Edit Word redesign | Blocked | V2-17-04 |

### V2-16 implementation rules

- The supplied references are designed around iPhone 14/15 Pro proportions, but QML must use flexible/responsive containers, safe-area handling and scrolling so the same screens remain usable on supported iOS phones, Android phones and tablet-sized displays.
- Onboarding logo/illustration areas remain placeholders until final assets are supplied.
- A word may display/select up to four groups only after V2-17 establishes the synchronized domain behavior.
- Adjective and Adverb remain separate for now. Their potential future merge is not part of V2-16.
- The Group Details overflow action for **Add Word** is acknowledged, but its final target reference remains pending and must not be invented.

## V2-17 — Word/Group Domain and Sync Evolution Tasks

| Task | Status | Dependencies |
|---|---|---|
| [V2-17-01](./V2-17-word-group-domain-and-sync-evolution/V2-17-01-extend-shared-word-group-contract.md) — Extend shared Word/Group contract | Done | Existing V2 contract baseline |
| [V2-17-02](./V2-17-word-group-domain-and-sync-evolution/V2-17-02-extend-frontend-sqlite-repository-outbox-model.md) — Extend frontend SQLite/repository/outbox model | Done | V2-17-01 |
| [V2-17-03](./V2-17-word-group-domain-and-sync-evolution/V2-17-03-extend-backend-postgresql-domain-validation.md) — Extend backend PostgreSQL/domain validation | Done | V2-17-01 |
| [V2-17-04](./V2-17-word-group-domain-and-sync-evolution/V2-17-04-complete-sync-bootstrap-reconciliation-coverage.md) — Complete sync/bootstrap/reconciliation coverage | Done | V2-17-02, V2-17-03 |
| [V2-17-05](./V2-17-word-group-domain-and-sync-evolution/V2-17-05-fix-sign-in-sync-with-existing-local-vocabulary.md) — Fix sign-in sync with pre-existing local vocabulary | Done | Existing authentication + sync baseline |
| [V2-17-06](./V2-17-word-group-domain-and-sync-evolution/V2-17-06-cross-system-domain-regression-gate.md) — Cross-system domain regression gate | Done | V2-17-04, V2-17-05 |

### V2-17 approved product semantics

- A Word may belong to **0..4 Groups**.
- Group membership is synchronized account data.
- Noun article states include `der`, `die`, `das`, and `Plural`.
- Selecting `Plural` represents a plural-only word and hides the separate plural-form field in the UI.
- Verb data adds **Präsens (3rd person)** alongside **Präteritum** and **Partizip II**.
- Adjective comparison fields remain supported.
- Adverb remains a separate word type for now.
- Phrase is an explicit supported type and includes literal translation where applicable.
- Group create/edit includes synchronized/stable icon metadata required by the approved UI.
- Group deletion does not delete Word entities.
- Removing a Word from one Group does not delete the Word entity.
- The max-four-group rule must be enforced coherently across UI/domain validation, local persistence, contract/backend processing and synchronization.

## V2-18 — Deferred UI Follow-up

**Status:** Deferred / not decomposed.

Reserved for future target references covering:

- Quiz redesign;
- authentication/login redesign;
- Settings/Profile redesign;
- logout/profile UX;
- email validation/verification UX;
- password-strength UX;
- manual-sync control/icon treatment;
- any later dedicated Home-screen redesign.

Do not create detailed implementation tasks for V2-18 until those references and product decisions are supplied. Existing behavior remains unchanged unless a separate bug-fix issue explicitly requires otherwise.

## Version 2 Non-Goals / Deferred Scope

- Payments/subscriptions/entitlements.
- Sharing, AI features, advanced spaced repetition or new quiz families.
- Permanent event sourcing.
- Preserving disposable pre-release integer-ID data.
- Merging Adjective and Adverb in the current redesign.
- Inventing final onboarding illustrations/logo assets before approved assets are supplied.
- Redesigning Quiz, authentication/login or Settings/Profile as part of V2-16.
