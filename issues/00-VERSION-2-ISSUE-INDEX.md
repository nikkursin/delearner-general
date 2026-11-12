# DE Vocab Learner — Version 2 Issue Index

**Status:** In Progress  
**Epics:** 20
**Loop-sized subtasks:** 95

## Version 2 Goal

Deliver an authenticated, account-based, offline-capable multi-device synchronization layer for the existing free product while preserving current learning behavior.

After the functional synchronization baseline is stable, align the approved vocabulary/group/onboarding/navigation frontend surfaces with the supplied design references, evolve the synchronized Word/Group domain only where those approved designs require it, stabilize post-redesign regressions, and align the currently implemented Quiz flows with the approved Quiz references.

Profile redesign is complete in V2-18 from the supplied V2-19-06 local references. V2-20 owns the later product correction that introduces Home, synchronized learning streaks and Profile access from the Home header. Authentication/login visual redesign remains deferred until its target references are supplied. Functional authentication regressions are not deferred and are handled by V2-19.

## Completed Foundation — Do Not Reopen

| Epic | Title | Status |
|---|---|---|
| [V2-01](./V2-01-root-coordination-repository-foundation/EPIC.md) | Root Coordination Repository Foundation | Done |
| [V2-02](./V2-02-contract-and-schema-baseline/EPIC.md) | Contract and Schema Baseline | Done |
| [V2-03](./V2-03-frontend-uuid-migration-baseline/EPIC.md) | Frontend UUID + Migration Baseline | Done |
| [V2-04](./V2-04-backend-postgresql-domain-baseline/EPIC.md) | Backend PostgreSQL Domain Baseline | Done |

Additionally completed: V2-07 and V2-11 are Done. These tasks stay Done and must not be reopened.

V2-16 and V2-17 are also completed implementation baselines. Regressions discovered after their execution must be fixed through V2-19 rather than reopening historical tasks.

## Remaining Execution Strategy

The remaining work stays dependency-driven and backend-first where cross-system behavior is involved. Ralph selects globally from dependency-ready tasks using the workspace priority below instead of mechanically finishing every earlier epic before considering later ready work.

1. **Backend authentication/account foundation** — V2-05-01 → V2-05-02 → V2-05-03.
2. **Backend device lifecycle** — V2-06-01 → V2-06-02 → V2-06-04.
3. **Backend mutation engine** — V2-08-01 → V2-08-02/V2-08-03 → V2-08-04.
4. **Backend pull/bootstrap/recovery primitives** — V2-09-01 → V2-09-02 → V2-10-01 → V2-12-01 → V2-12-02.
5. **Client identity + outbox completion** — V2-05-04 → V2-06-03 → V2-07-03 → V2-07-04.
6. **Client pull/bootstrap/scheduling/recovery wiring** — remaining V2-09, V2-10, V2-11 and V2-12 tasks.
7. **End-to-end domain convergence** — V2-13.
8. **Stable-sync production UX cleanup** — V2-14. Keep its existing scope; do not duplicate the screenshot-driven redesign already completed in V2-16.
9. **Post-redesign stabilization** — V2-19. Done, including the served-runtime sign-out-route regression.
10. **Quiz and Profile UI baseline** — completed in V2-18. Preserve its Done history; later navigation corrections belong to V2-20.
11. **Home, streak and navigation follow-up** — V2-20 after the sign-out regression. Freeze the streak contract, implement backend then frontend persistence, build Home, correct navigation/Profile access, and run the integration gate.
12. **Release gate** — V2-15 after the functional sync system, completed V2-16/V2-17/V2-18 UI baseline, V2-19 stabilization and V2-20 are integrated and verified.
13. **Deferred visual follow-up** — Authentication/login visual redesign remains outside the completed V2-18 leaf scope until target references are supplied.

This order is a priority strategy, not permission to bypass dependencies.

## Ownership Clarification

- **V2-14** retains its existing production UX cleanup responsibilities around stable synchronization.
- **V2-16** owns the completed screenshot-driven redesign for onboarding, bottom navigation, Add/Edit Word, Groups, Group Details, Words and Word Details/Edit.
- **V2-17** owns the completed cross-system data/contract changes required by that redesign.
- **V2-18** owns the completed Quiz and Settings-to-Profile baseline. Authentication/login visual redesign remains deferred.
- **V2-19** owns regressions discovered after completed work, including the runtime sign-out-route 404. Done tasks stay Done; new regressions receive new task IDs.
- **V2-20** owns Home, synchronized learning-day/streak data, corrected bottom navigation and Home-to-Profile access.
- Functional authentication bugs belong to V2-19 even though future authentication visual redesign remains deferred in V2-18.

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
| [V2-15](./V2-15-root-integration-and-release-gate/EPIC.md) | Root Integration and Release Gate | root + frontend + backend | Verify approved references only | V2-14 + completed V2-16/V2-17/V2-18 + V2-19 + functional system |
| [V2-16](./V2-16-frontend-design-alignment/EPIC.md) | Frontend Design Alignment | frontend + root | Use supplied screenshots; avoid MCP unless material information is missing | Done |
| [V2-17](./V2-17-word-group-domain-and-sync-evolution/EPIC.md) | Word/Group Domain and Sync Evolution | frontend + backend + root | None | Done |
| [V2-18](./V2-18-quiz-auth-settings-ui-follow-up/EPIC.md) | Quiz, Authentication and Settings UI Follow-up | frontend + root; backend only where existing synchronized review statistics must be verified | Use supplied local screenshots; avoid MCP unless material information is missing | Done |
| [V2-19](./V2-19-post-redesign-stabilization/EPIC.md) | Post-Redesign Stabilization | frontend + backend + root | Use current regression screenshots plus approved V2-16 references | completed V2-16/V2-17 baseline |
| [V2-20](./V2-20-home-streak-and-navigation-follow-up/EPIC.md) | Home, Streak and Navigation Follow-up | root + backend + frontend | Use supplied V2-19-06 Home/Profile screenshots and dog assets; no MCP required | completed V2-18 baseline; V2-19-08 before final Profile integration |

## V2-16 — Frontend Design Alignment Tasks

| Task | Status | Dependencies |
|---|---|---|
| [V2-16-01](./V2-16-frontend-design-alignment/V2-16-01-responsive-shell-and-modern-bottom-navigation.md) — Responsive shell and modern bottom navigation | Done | Existing navigation baseline |
| [V2-16-02](./V2-16-frontend-design-alignment/V2-16-02-first-run-onboarding-flow.md) — First-run onboarding flow | Done | Existing authentication entry point |
| [V2-16-03](./V2-16-frontend-design-alignment/V2-16-03-add-edit-word-redesign-and-group-selector.md) — Add/Edit Word redesign and group selector | Done | V2-17-04 |
| [V2-16-04](./V2-16-frontend-design-alignment/V2-16-04-groups-list-create-and-edit-redesign.md) — Groups list, create and edit redesign | Done | V2-17-04 |
| [V2-16-05](./V2-16-frontend-design-alignment/V2-16-05-group-details-and-word-actions-redesign.md) — Group Details and word actions redesign | Done | V2-17-04 |
| [V2-16-06](./V2-16-frontend-design-alignment/V2-16-06-words-list-search-filters-and-swipe-actions.md) — Words list, search, filters and swipe actions | Done | V2-17-04 |
| [V2-16-07](./V2-16-frontend-design-alignment/V2-16-07-word-details-and-edit-word-redesign.md) — Word Details and Edit Word redesign | Done | V2-17-04 |

### V2-16 implementation rules

- The supplied references are designed around iPhone 14/15 Pro proportions, but QML must use flexible/responsive containers, safe-area handling and scrolling so the same screens remain usable on supported iOS phones, Android phones and tablet-sized displays.
- Onboarding logo/illustration areas remain placeholders until final assets are supplied.
- A word may display/select up to four groups only after V2-17 establishes the synchronized domain behavior.
- Adjective and Adverb remain separate for now. Their potential future merge is not part of V2-16.
- The originally disabled Group Details **Add Word** action is superseded by V2-19-04: it must route to the canonical Add Word page with the originating group preselected.

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

## V2-18 — Quiz, Authentication and Settings UI Follow-up Tasks

**Status:** Done. Quiz and Profile scope complete; Authentication/login visual redesign remains deferred.

| Task | Status | Dependencies |
|---|---|---|
| [V2-18-01](./V2-18-quiz-auth-settings-ui-follow-up/V2-18-01-quiz-home-learning-states-and-mode-actions.md) — Quiz home, learning states and mode actions | Done | completed V2-16/V2-17 baseline |
| [V2-18-02](./V2-18-quiz-auth-settings-ui-follow-up/V2-18-02-translation-quiz-custom-setup.md) — Translation Quiz custom setup | Done | V2-18-01 |
| [V2-18-03](./V2-18-quiz-auth-settings-ui-follow-up/V2-18-03-translation-quiz-session-redesign.md) — Translation Quiz session redesign | Done | V2-18-02, V2-19-07 |
| [V2-18-04](./V2-18-quiz-auth-settings-ui-follow-up/V2-18-04-article-quiz-custom-setup.md) — Article Quiz custom setup | Done | V2-18-01 |
| [V2-18-05](./V2-18-quiz-auth-settings-ui-follow-up/V2-18-05-article-quiz-session-redesign.md) — Article Quiz session redesign | Done | V2-18-04 |
| [V2-18-06](./V2-18-quiz-auth-settings-ui-follow-up/V2-18-06-shared-quiz-results-redesign.md) — Shared Quiz results redesign | Done | V2-18-03, V2-18-05 |
| [V2-18-07](./V2-18-quiz-auth-settings-ui-follow-up/V2-18-07-rename-settings-to-profile-and-redesign-page.md) — Rename Settings to Profile and redesign the page | Done | completed V2-19-07 |

### V2-18 approved Quiz semantics

- Existing Quiz execution remains local; do not move current quiz generation/execution to the backend.
- Translation Quiz and Article Quiz are the only functional quiz families in this scope.
- The two additional quiz-family cards shown in the approved Quiz Home reference are placeholders only.
- Quiz Home learning states use existing review statistics:
  - **Mastered:** success rate `>= 90%` and more than 5 recorded attempts.
  - **Hard:** success rate `< 40%` after at least one recorded attempt.
  - **Learning:** all other words, including words without enough history to qualify as Hard or Mastered.
- Multi-group words are deduplicated before counting or generating quiz questions.
- Clearing a word score resets only that word's review/learning statistics; it does not delete the Word entity or any Group membership.
- Translation custom setup supports translation direction, part-of-speech filters, group filters, learning-state filters and question-count selection.
- Article custom setup uses eligible noun/article data and remains compatible with `der`, `die`, `das`, and plural-only `Plural`.
- `Report a problem` remains a placeholder.
- Preset persistence/application remains deferred until a preset-consumption flow is explicitly defined.
- Result presentation uses three non-overlapping score states:
  - `0–40%` — Keep Practicing.
  - `41–80%` — Good Job!
  - `81–100%` — Excellent!
- All Quiz transitions, bottom sheets, answer feedback, progress changes and swipe interactions should be smooth, responsive and non-blocking.

### V2-18 still deferred

- Authentication/login visual redesign.
- Profile fields and product features beyond the visual reorganization and
  preserved functional controls authorized by V2-18-07.
- Email validation/verification UX redesign.
- Password-strength UX redesign.

The formerly deferred Home-screen redesign is now explicitly activated in
V2-20. V2-18 remains Done and is not reopened.

The authentication/login and registration-validation deferrals listed above
are later activated by V2-21. This records a new follow-up decision and does not
reopen V2-18.

## V2-19 — Post-Redesign Stabilization Tasks

**Status:** Done. Runtime sign-out-route regression complete; completed history
remains closed.

Task numbers remain stable identifiers; the priority column defines execution
order.

| Priority | Task | Status | Dependencies |
|---|---|---|---|
| 1 | [V2-19-08](./V2-19-post-redesign-stabilization/V2-19-08-fix-runtime-sign-out-route-404.md) — Fix runtime sign-out route 404 | Done | completed V2-19-07 |
| 2 | [V2-19-07](./V2-19-post-redesign-stabilization/V2-19-07-add-secure-sign-out-and-session-recovery-controls.md) — Add secure Sign out and Sign in again controls | Done | completed V2-19-06 |
| 3 | [V2-19-04](./V2-19-post-redesign-stabilization/V2-19-04-enable-group-add-word-with-preselected-group.md) — Enable Group → Add Word with preselected group | Done | V2-19-03, completed V2-16-03 |
| 4 | [V2-19-06](./V2-19-post-redesign-stabilization/V2-19-06-fix-multi-device-auth-sync-regressions.md) — Fix multi-device authentication and sync regressions | Done | completed V2-19-05, completed V2-17-04 through V2-17-06 |
| 5 | [V2-19-05](./V2-19-post-redesign-stabilization/V2-19-05-debug-auth-sign-in-and-account-creation-regressions.md) — Stabilize auth-to-sync startup and add end-to-end diagnostics | Done | completed authentication/sync baseline, completed V2-17-05; no V2-18 dependency |
| 6 | [V2-19-01](./V2-19-post-redesign-stabilization/V2-19-01-fix-add-word-alignment-and-bottom-navigation-position.md) — Fix Add Word alignment and bottom-navigation position | Done | completed V2-16-01, V2-16-03 |
| 7 | [V2-19-02](./V2-19-post-redesign-stabilization/V2-19-02-fix-words-filter-alignment-and-swipe-delete.md) — Fix Words filter alignment and swipe delete | Done | completed V2-16-06 |
| 8 | [V2-19-03](./V2-19-post-redesign-stabilization/V2-19-03-align-group-details-and-fix-swipe-actions.md) — Align Group Details and fix swipe actions | Done | completed V2-16-05 |

### V2-19 stabilization rules

- Use the existing V2-16 references as the design baseline where applicable; fix regressions instead of redesigning those screens again.
- Add Word group-selector alignment and shared bottom-navigation placement must be corrected responsively, not with device-specific offsets.
- Words and Group Details swipe gestures must reveal the intended actions while coexisting with normal vertical scrolling.
- Group Details must restore missing visual/decorative treatment from the approved reference.
- Group → Add Word now routes to the canonical Add Word page with the originating group preselected; this supersedes the earlier disabled-action decision.
- Auth-to-sync stabilization starts immediately; the former V2-18-06 scheduling gate was explicitly overridden on 2026-11-09.
- Completed V2-19-07 remains the behavioral baseline for the V2-18-07 Profile controls.
- V2-19-08 must test the real HTTP route through the served backend application; direct handler tests are insufficient for a runtime 404.
- Safe verbose diagnostics are an implementation prerequisite, not a last-resort request. Every auth, device-registration, bootstrap and synchronization phase must emit correlated start/result/failure events.
- Existing-account sign-in, account creation, bootstrap, sign-in with existing local vocabulary and pending-outbox preservation must be covered by focused regression tests.
- Logs may contain development-only operational metadata, but never passwords, hashes, salts, session/bearer values, authorization headers, raw auth bodies, database credentials or personal vocabulary.
- All UI fixes should preserve smooth, responsive animations and interactions without adding unrelated decorative motion.

## V2-20 — Home, Streak and Navigation Follow-up Tasks

**Status:** Done. V2-20-01 through V2-20-06 are complete.

| Task | Status | Dependencies |
|---|---|---|
| [V2-20-01](./V2-20-home-streak-and-navigation-follow-up/V2-20-01-freeze-learning-day-contract-and-fixtures.md) — Freeze learning-day contract and fixtures | Done | completed V2-18 Quiz baseline |
| [V2-20-02](./V2-20-home-streak-and-navigation-follow-up/V2-20-02-implement-backend-learning-day-sync.md) — Implement backend learning-day persistence and sync | Done | V2-20-01 |
| [V2-20-03](./V2-20-home-streak-and-navigation-follow-up/V2-20-03-implement-frontend-learning-day-persistence.md) — Implement frontend learning-day persistence | Done | V2-20-01, V2-20-02 |
| [V2-20-04](./V2-20-home-streak-and-navigation-follow-up/V2-20-04-build-home-streak-page.md) — Build Home streak page | Done | V2-20-03 |
| [V2-20-05](./V2-20-home-streak-and-navigation-follow-up/V2-20-05-correct-navigation-and-profile-access.md) — Correct navigation and Profile access | Done | V2-19-08, V2-20-04 |
| [V2-20-06](./V2-20-home-streak-and-navigation-follow-up/V2-20-06-run-streak-navigation-integration-gate.md) — Run streak and navigation integration gate | Done | V2-20-02 through V2-20-05 |

### V2-20 approved semantics

- Bottom navigation is `Home | Quiz | + | Words | Groups`.
- Profile opens from the top-left Home account/avatar affordance and is not a
  bottom-navigation destination.
- Completing an implemented quiz with at least one answered question completes
  one account-owned local calendar learning day.
- Same-day completion is idempotent; consecutive completed dates define the
  current streak; completed days synchronize and bootstrap across devices.
- The dog uses the supplied tail, repeatable middle and face assets.
- Requested reference Profile rows remain visible placeholders; existing real
  Profile actions retain their implemented behavior.

## V2-21 — Design Stabilisation Tasks

**Status:** In Progress. Execute V2-21-01 through V2-21-08 in the priority order in
the epic.

| Task | Status | Dependencies |
|---|---|---|
| [V2-21-01](./V2-21-design-stabilisation-tasks/V2-21-01-freeze-local-split-authentication-ux-contract.md) — Freeze local split-authentication UX contract | Done | none |
| [V2-21-02](./V2-21-design-stabilisation-tasks/V2-21-02-add-registration-contract-and-backend-validation.md) — Add registration contract and backend validation | Ready | V2-21-01 |
| [V2-21-03](./V2-21-design-stabilisation-tasks/V2-21-03-implement-split-authentication-pages-and-client-validation.md) — Implement split authentication pages and client validation | Ready | V2-21-01, V2-21-02 |
| [V2-21-04](./V2-21-design-stabilisation-tasks/V2-21-04-move-manual-sync-to-home-refresh-control.md) — Move manual sync to a Home refresh control | Done | completed V2-20-05 |
| [V2-21-05](./V2-21-design-stabilisation-tasks/V2-21-05-fix-ipad-landscape-and-bottom-navigation-geometry.md) — Fix iPad landscape and bottom-navigation geometry | Done | completed V2-16-01, V2-20-05 |
| [V2-21-06](./V2-21-design-stabilisation-tasks/V2-21-06-add-removable-streak-preview-slider.md) — Add a removable streak preview slider | Done | completed V2-20-04 |
| [V2-21-07](./V2-21-design-stabilisation-tasks/V2-21-07-correct-streak-count-and-day-ordering.md) — Correct streak count and day ordering | Done | V2-21-06 |
| [V2-21-08](./V2-21-design-stabilisation-tasks/V2-21-08-run-design-stabilisation-regression-gate.md) — Run the design-stabilisation regression gate | Ready | V2-21-02 through V2-21-07 |

### V2-21 approved semantics

- No auth layout currently exists in Figma. By explicit current user decision,
  V2-21 auth work must not access or modify Figma. Codex designs the required
  pages itself using the existing DELearner style and the V2-21-01 local UX
  contract.
- Apple and Google controls are visible placeholders only; provider integration
  remains deferred.
- Create account uses Name, Email, Password and Repeat password with shared
  client/backend validation; Repeat password never leaves the client.
- Manual sync is a top-right Home refresh affordance backed by the existing
  coordinator.
- Responsive-shell fixes must cover iPad landscape and safe-area-correct bottom
  navigation without device-specific offsets.
- Streak presentation is fixed without changing immutable learning-day data.
- The temporary streak slider is development-only, presentation-only and marked
  `// TODO: Remove after testing` at every integration point.

## Version 2 Non-Goals / Deferred Scope

- Payments/subscriptions/entitlements.
- Sharing, AI features or advanced spaced repetition.
- Implementing the two placeholder Quiz families introduced visually in V2-18.
- Permanent event sourcing.
- Preserving disposable pre-release integer-ID data.
- Merging Adjective and Adverb in the current redesign.
- Inventing final onboarding illustrations/logo assets before approved assets are supplied.
- Production Apple/Google authentication, email ownership verification and
  password-reset flows.
- Implementing `Report a problem` or preset-management infrastructure without an explicit future task.
