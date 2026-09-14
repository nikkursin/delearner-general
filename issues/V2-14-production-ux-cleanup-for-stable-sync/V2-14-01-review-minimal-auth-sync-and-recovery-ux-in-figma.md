# V2-14-01 — Review minimal auth, sync and recovery UX in Figma

**Parent epic:** V2-14 — Production UX Cleanup for Stable Sync  
**Status:** Done
**Workspace:** Figma + root  
**Size:** 1 story point(s)  
**Dependencies:** V2-05-04,V2-11-04,V2-12-04,V2-13-04  

## Objective

Only after the functional Version 2 system is working, inspect the existing DELearner Figma file once and review/define the minimal production presentation for authentication, sync status, recoverable errors and automatic stale-device recovery.

## Scope

- Reuse the existing DELearner Figma file and recorded node IDs when available.
- Review the simple functional states implemented earlier rather than redesigning the application.
- Batch inspection/update work where possible to minimize MCP calls.
- Record approved node IDs in the root issue for implementation/verification.

## Figma Requirement

Required. This is the intended late Version 2 Figma checkpoint. If the existing DELearner Figma file cannot be identified safely, stop with `BLOCKED_FIGMA` rather than creating a substitute file.

## Acceptance Criteria

- [x] Authentication entry/error/offline-reopen presentation is reviewed.
- [x] Sync status and meaningful recoverable error presentation is reviewed.
- [x] Automatic stale-device recovery does not become a manual reset workflow.
- [x] Approved/relevant node IDs are recorded for V2-14-02 and final release verification.
- [x] No unrelated MVP1 screen redesign is introduced.

## Verification

1. Use recorded Figma file/node references directly where available.
2. Batch required inspection rather than repeatedly traversing the file.
3. Record final node IDs and concise decisions in this issue/root coordination state.

## Canonical References

- `docs/00-SYSTEM-CONCEPT.md`
- `docs/02-SYNC-PROTOCOL.md`
- `docs/07-ISSUE-PLANNING-RULES.md`

## Stop / Escalate If

- Existing DELearner Figma file identity is unavailable.
- Review implies a major product/architecture change rather than presentation cleanup.

## Review Outcome — 2026-09-14

Reviewed the existing canonical file `7kCGSdFGQ79KpRqdaG5Pfp`, Design page
`0:1`, against the current functional client and canonical auth/sync rules.
The handoff is recorded in the same file at
[V2-14-01 presentation review](https://www.figma.com/design/7kCGSdFGQ79KpRqdaG5Pfp/DELearner?node-id=2894-979).
This is a presentation definition for V2-14-02, not an implementation or a
new authentication/Settings redesign approval. Existing screens are preserved.

### Relevant Figma Nodes

All IDs belong to the canonical file above. The existing auth reference section
is `2813:860`; its five frames and the local-save toast were visually inspected.

| Node ID | Reference | Application / limits |
|---|---|---|
| `2813:863` | First launch requires sign-in | Account and internet required; Apple/Google controls are placeholders, not supported production actions. |
| `2813:882` | Email/password | Keep existing sign-in and Create account actions. |
| `2813:899` | Successful sign-in / bootstrap | Show preparation until actual completion; use indeterminate activity instead of a fabricated progress percentage. |
| `2813:914` | Offline reopening | Reuse the offline reassurance, not a new mandatory Continue offline screen. |
| `2813:929` | Auth failure | Reuse readable inline error presentation with correction/retry; no guest fallback. |
| `2835:1596` | Changes saved toast | Local-save reference only; does not prove server acknowledgement. |
| `2894:979` | V2-14-01 review handoff | Minimal auth/sync/error/recovery presentation and explicit limits for V2-14-02. |

No separately named sync/recovery frame was found on the recorded Design page.
The review note defines the missing presentation using existing inline card
patterns; it introduces no new screen, manual recovery flow or product rule.

### Presentation Decisions

| Functional state | Minimal presentation / action |
|---|---|
| First sign-in | Existing email/password form; explain account and internet requirement. Keep fields/actions disabled while an auth request is active. |
| Auth or initial bootstrap failure | Readable inline error and existing retry/correction path. Never claim initial cloud loading completed when it failed. |
| Previously authenticated offline reopen | Open local free core automatically. Optional inline reassurance: “Offline — sync resumes when connected.” No expiry or new gate. |
| Idle sync | Neutral “Sync runs automatically.” Idle alone does not mean all data is acknowledged. |
| Active sync | Unobtrusive “Syncing…” in the existing synchronization/status surface. Keep ordinary local editing available. |
| Recoverable sync failure | “Could not sync. Your changes remain on this device.” Preserve work and existing automatic triggers; manual sync remains diagnostic fallback. |
| Authentication required for sync | Explain sign-in is needed only when the actual failure warrants it; preserve local work and free-core access. Do not classify every network error as expired authentication. |
| Stale-device recovery | Same normal “Syncing…” presentation while automatic bootstrap/replay proceeds. No reset, erase, import/export or conflict-choice dialog. Failure uses the recoverable error presentation. |
| Recovery/sync success | Clear stale error state. No repeated success toast and no “Synced” claim based only on a request being queued. |

Errors must remain readable until recovery and use user-facing language rather
than raw transport/protocol diagnostics. No retry timings or retention constants
are defined here. Existing reference colors/layout are guidance for local status
presentation, not authorization to restyle unrelated screens.

### Implementation Comparison and Handoff

- `qml/Views/DLAuthPage.qml` already provides email/password, Create account,
  busy disabling and inline `lastError`. Preserve this flow; add only necessary
  explanatory/error presentation in V2-14-02.
- `DLAppStateManager::enterFreeCoreAfterAuthenticatedStartup` opens the existing
  free core directly. The Figma Continue offline button is a reference discrepancy;
  implementing a new gate would change working behavior and is not part of this review.
- `qml/Views/DLSettingsPage.qml` currently reports “Sync requested.” from a
  diagnostic action. V2-14-02 should expose actual coordinator activity/failure
  without treating request acceptance as synchronization completion.
- `DLSyncCoordinator` already supplies activity and error signals and owns
  automatic stale recovery. Presentation should consume this existing behavior.
- `DLStartupLoadingPage.qml` has static local-loading steps; do not reuse those
  steps or the Figma progress bar as measured cloud-bootstrap progress.
- Authentication/login, Settings/Profile, provider buttons and unrelated screen
  redesign remain deferred under V2-18. V2-14-02 remains Planned; this invocation
  does not implement it. Parent V2-14 remains In Progress.

### Verification Evidence

- Figma: one metadata inspection of `0:1`, batched screenshots of the six
  referenced existing nodes, and a targeted sync/recovery name query. Added only
  review node `2894:979` and its nine text children (`2894:980`–`2894:988`).
  Final screenshot inspected after correcting overlapping review paragraphs;
  the complete note is readable at 708 × 1400.
- `./scripts/test-all.sh root`: passed.
- `ctest --test-dir delearner-frontend/build-tests --output-on-failure -R
  '^(TestAppStateAuthBootstrap|TestSyncCoordinator|TestProductionSettingsUi)$'`:
  sync coordinator and production settings checks passed. Auth suite initially
  failed in unrelated `internalExportReplaceRestoresDatabaseState` snapshot
  comparison, while its auth/offline/bootstrap cases passed.
- `ctest --test-dir delearner-frontend/build-tests --output-on-failure -R
  '^TestAppStateAuthBootstrap$'`: passed on rerun (no source changes). The initial
  intermittent failure is recorded here rather than presented as a clean first run.
  These checks used the existing local build; no child implementation was changed.
- `git diff --check`: passed. Both child worktrees and pinned revisions unchanged.
- No external check remains for this review task. Implementation/platform
  verification belongs to V2-14-02 and the release gate.
