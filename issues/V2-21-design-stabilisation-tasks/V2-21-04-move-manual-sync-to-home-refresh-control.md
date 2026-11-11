# V2-21-04 — Move manual sync to a Home refresh control

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
**Workspace:** frontend
**Size:** 2 story points
**Dependencies:** completed V2-20-05
**Figma requirement:** None; this is an explicit local Home adjustment

## Objective

Expose the existing manual diagnostic sync action as a refresh icon in the
top-right of Home while keeping automatic synchronization primary.

## Reference

- `references/500px-Refresh_icon.png`

Copy the runtime asset into the frontend-owned asset catalog. Do not load the
issue reference path at runtime.

## Scope

- Add a top-right refresh control to the existing Home header opposite the
  Profile/account affordance.
- Use the supplied icon without distorting it and adapt tint/contrast to the
  existing Home design if required.
- Invoke the same manual-sync coordinator entry point already used by Profile;
  do not create another scheduler or network path.
- Disable or debounce the control while sync is running.
- Represent idle, syncing, success and failure truthfully through existing sync
  state/error presentation; a subtle non-blocking rotation while syncing is
  acceptable.
- Add an accessible label such as **Synchronize now** and retain a usable touch
  target on phone and tablet.
- Keep or remove the Profile manual-sync row only according to the approved
  current product behaviour; do not accidentally create divergent actions.

## Acceptance criteria

- [x] The supplied refresh graphic is copied into and loaded from the frontend
      asset system.
- [x] The control is aligned to the top-right of Home at phone and tablet widths.
- [x] One activation triggers the existing coordinator once; repeated taps
      cannot create overlapping sync runs.
- [x] Offline/failure state is actionable and does not imply local-data loss.
- [x] Automatic sync-on-active/resume/connectivity behaviour is unchanged.
- [x] QML/component tests cover geometry, accessibility and busy/error state.

## Non-goals

- Changing sync cadence, retry rules, conflict resolution or API semantics.
- Making manual refresh the normal synchronization mechanism.

## Implementation checkpoint — 2026-11-11

### Files changed

- `delearner-frontend/assets/images/refresh_icon.png` — copied the supplied
  runtime graphic into the frontend asset catalog without modification.
- `delearner-frontend/qml/Views/DLHomePage.qml` — added the accessible
  top-right manual-sync control, truthful sync/error description, busy disable
  state and subtle in-progress rotation.
- `delearner-frontend/tests/qml/tst_Home.qml` — covered phone/tablet geometry,
  asset loading, accessibility, single activation, busy debounce and safe
  failure presentation.

### Verification

- `ctest --test-dir build-tests -R 'TestHomeUi|TestProfileUi' --output-on-failure`
  — passed 2/2.
- `ctest --test-dir build-tests --output-on-failure` — passed 34/34.
- SHA-256 comparison of the issue reference and runtime asset — identical.
- Final selected-file diff review — automatic sync code and the existing
  Profile manual-sync action are unchanged.

### Limitations

- No physical-device visual pass was required; phone and tablet geometry is
  exercised by the QML component test.

### Next task

- V2-21-05 — Fix iPad landscape and bottom-navigation geometry.
