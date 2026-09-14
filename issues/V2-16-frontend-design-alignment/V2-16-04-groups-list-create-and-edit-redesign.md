# V2-16-04 — Groups list, create and edit redesign

**Parent epic:** V2-16 — Frontend Design Alignment  
**Status:** Done
**Workspace:** frontend  
**Size:** 5 story points  
**Dependencies:** V2-17-04

## Objective

Replace the current modal-only Groups management experience with the supplied responsive list/create/edit flow.

## Scope

- Groups skeleton/loading state.
- Empty Groups state with Add Group action.
- Populated Groups list with search field, count and per-group overflow action.
- Create Group page.
- Edit Group page.
- Group name, color and icon/logo selection.
- Use a stable cross-platform group-icon value from V2-17; render using platform-appropriate glyph/emoji/icon treatment rather than persisting platform-specific asset IDs.
- Preserve group deletion behavior: deleting a group must not delete the underlying words.
- Group edit screen exposes Save Changes and Delete Group actions as in the target reference.
- Overflow sheet exposes the supplied management actions without inventing missing downstream screens.

## Design references

See `references/V2-16-04/` for current dialogs and target loading/empty/create/list/action/edit states.

## Acceptance criteria

- Loading state does not flash an incorrect empty state while data is unresolved.
- Empty state appears only after successful load with zero groups.
- Create/edit persists name/color/icon through the existing domain flow backed by V2-17.
- List cards remain stable with long names and different device widths.
- Deleting a group preserves words and only removes the deleted membership as defined by V2-17.
- No Add Word subflow is invented; that reference is still pending.

## Completion — 2026-09-14

- Replaced modal-only group management with a responsive searchable folder-card list and full-page create/edit form using the supplied screenshots. Existing page/navigation ownership and safe-area/scrolling shell remain in use.
- Added explicit loading, successful-empty, failed-load/retry and no-search-results states. Database read failures now propagate through the group service to the UI.
- Passed stable icon keys through the QML-facing manager into the existing transactional group/outbox flow. Local glyphs render known keys; editing preserves unknown keys and existing colors.
- Added the management sheet with Edit. Add Word is shown disabled because its destination reference is still pending; no downstream flow was introduced.
- Delete confirmation preserves words and other memberships; failures keep the editor and confirmation available.

### Verification

- `cmake --build delearner-frontend/build-tests --parallel 4` — passed.
- `ctest --test-dir delearner-frontend/build-tests --output-on-failure` — final run passed all 23 tests, including canonical v1/v2 fixtures, QML Groups tests, transactional outbox and manager integration tests.
- New manager tests verify name/color/icon persistence, icon outbox payload, create/edit navigation identity, deletion preserving a word's other membership, and failed group reads followed by recovery.
- New QML tests exercise loading/empty/error/retry, search, management actions, create validation/save failure, unknown-icon preservation, missing groups, deletion failure, long names, and scrolling at 280/353/640 content widths.
- `cmake --build delearner-frontend/build-android --target delearner --parallel 4` — passed, including new QML cache compilation and ARM64 native linking.
- Offscreen component renders of the populated list and edit form were inspected against the supplied references. Standalone Qt Quick Test cannot load the Felgo page shell (`DateFormatter` resource missing in that runner); the Android application target compiled successfully.
- An intermediate full run hit an existing import/export snapshot mismatch; the final full run passed unchanged. No import/export fix was included.
- Frontend and root `git diff --check` — passed.

### Human check

- Physical iOS/Android rendering, platform glyphs and keyboard/safe-area behavior remain to be checked on devices. Responsive component behavior is covered locally.
- Pre-existing IDE configuration and an unrelated iOS export edit observed during execution were excluded from this task's commits.
