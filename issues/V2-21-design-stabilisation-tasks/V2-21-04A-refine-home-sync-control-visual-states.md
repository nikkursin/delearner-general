# V2-21-04A — Refine Home sync-control visual states

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
**Workspace:** frontend
**Size:** 2 story points
**Dependencies:** completed V2-21-04
**Figma requirement:** None; this is an explicit visual correction to one control

## Objective

Replace the visually poor white-background refresh bitmap introduced by
V2-21-04 with a transparent, correctly scaled and stateful Home sync control.

## Current problem

- `references/500px-Refresh_icon.png` has a baked white background and is no
  longer an approved runtime asset.
- Scaling the 500 × 500 bitmap into the current control produces an icon that
  does not match the established 24 × 24 SVG icon language.
- Syncing and failure need distinct, understandable visual states rather than
  only a generic button background or text elsewhere on the page.

V2-21-04 remains Done as implementation history. This follow-up supersedes only
its visual-asset and state-presentation decisions.

## Required references

The required references are now present in `references/V2-21-04A/`:

1. `sync-refresh-idle.svg` — transparent refresh/sync glyph.
2. `sync-refresh-error.svg` — matching refresh glyph with an exclamation state.
3. `current-bad-phone.png` — observed oversized always-spinning control and the
   related Home/streak presentation regressions.

Both SVGs must use the same view box, optical centre, stroke family and
orientation. Copy them into the frontend-owned runtime asset catalog; do not
redraw, replace or load them from the issue folder at runtime.

## Approved interaction states

### Idle

- Show only the transparent refresh glyph; do not draw a permanent white tile
  or opaque image background.
- Keep a minimum 44 × 44 logical-pixel touch target while rendering the glyph
  at 20–24 logical pixels.
- The control background is transparent by default. A subtle pressed/focus
  treatment may appear only during interaction.

### Synchronizing

- Rotate the idle refresh glyph clockwise around its true visual centre.
- Use a smooth linear loop near 800–1000 ms per revolution.
- Start rotation only after the user activates this Home control and that
  activation actually starts/joins the requested manual sync operation.
- Do not rotate merely because the page loaded, automatic synchronization is
  running, a stale busy flag exists, or a previous operation once ran.
- Track the Home control's manual-trigger visual lifecycle separately from the
  coordinator's general busy state. Stop on every terminal success/failure,
  refused trigger, teardown or cancellation path; do not start a second sync.
- Respect the application's reduced-motion/platform-animation policy when one
  exists. A static busy state is acceptable when motion is disabled.

### Failure/offline

- Stop rotation and show the supplied error/exclamation state.
- Use `sync-refresh-error.svg` exactly as the error-state source; do not build a
  second improvised badge on top of the idle glyph.
- Keep the control actionable as **Retry synchronization** when retry is valid.
- Preserve truthful supporting text that local learning data remains safe.
- Clear the error icon only when sync state actually recovers, not after an
  arbitrary timer.

### Success

- Return to the normal idle refresh glyph after successful completion and keep
  it completely static until the user triggers the control again.
- Do not add an unapproved persistent success badge. A brief existing-state
  transition is acceptable if it is non-blocking and testable.

## Scale and asset rules

- Use the supplied SVGs as frontend-owned assets and render them consistently
  with the existing `assets/icons/*.svg` icon system.
- Preserve aspect ratio and centre the glyph by its SVG view box/optical bounds.
- Render the visible glyph at 20–24 logical pixels inside a centred content
  item. The 44–48 logical-pixel touch target must not stretch the SVG to fill
  its bounds.
- Do not compensate for whitespace inside an asset with arbitrary negative
  margins or per-device scale factors.
- Do not use an opaque rectangle to conceal a non-transparent asset.
- Verify phone, iPad portrait and iPad landscape at normal and high-density
  scaling.
- Copy approved runtime assets into the frontend asset catalog; issue-reference
  paths are never loaded at runtime.

## Acceptance criteria

- [ ] The rejected white-background PNG is no longer loaded by Home at runtime.
- [ ] Idle and error assets have transparent backgrounds and share consistent
      bounds, stroke weight and optical scale.
- [ ] The glyph is 20–24 logical pixels inside a touch target of
      at least 44 × 44 logical pixels.
- [ ] The idle glyph is static on page load and during automatic/background
      sync; a user-triggered manual sync rotates smoothly around the visual
      centre and stops on success, failure, refused start and teardown.
- [ ] Failure/offline shows `sync-refresh-error.svg` and exposes an
      accessible retry action without hiding the existing error explanation.
- [ ] Resolving the error restores the static idle SVG and does not restart
      rotation until another user activation.
- [ ] Focus, pressed, disabled, busy and error states remain distinguishable
      without a permanent white tile.
- [ ] Phone and iPad geometry tests cover scale, centring and state transitions.
- [ ] Existing coordinator debounce, automatic sync and Profile manual-sync
      behaviour are unchanged.
- [ ] The relevant QML tests and complete frontend suite pass.

## Non-goals

- Changing synchronization cadence, retry policy, API or conflict semantics.
- Creating a second sync coordinator.
- Redesigning the complete Home header.
- Replacing the supplied approved SVGs with generated or guessed icons.

## Reference readiness checkpoint — 2026-11-12

- `sync-refresh-idle.svg`, `sync-refresh-error.svg` and
  `current-bad-phone.png` are present and readable.
- The task is dependency-ready for Ralph/AFK execution.

## Implementation checkpoint — 2026-11-12

### Files changed

- `delearner-frontend/assets/icons/sync-refresh-idle.svg` and
  `sync-refresh-error.svg` — copied the approved transparent runtime assets
  into the frontend icon catalog.
- `delearner-frontend/qml/Views/DLHomePage.qml` — replaced the rejected bitmap
  and permanent tile with a centred 24-pixel SVG control, added distinct
  idle/error/accessibility states, and isolated rotation to the accepted Home
  manual-sync lifecycle.
- `delearner-frontend/tests/qml/tst_Home.qml` — added regression coverage for
  phone, iPad portrait and iPad landscape geometry; static automatic sync;
  accepted, refused and completed manual sync; error/retry state; and recovery.

### Verification

- `ctest --test-dir build-tests -R '^TestHomeUi$' --output-on-failure` — passed
  1/1 after first reproducing the old PNG, automatic-spin and accessibility
  failures.
- `ctest --test-dir build-tests --output-on-failure` — passed 36/36.
- Newline-normalized SHA-256 comparisons against both issue references —
  matched; the runtime copies only add the repository-standard trailing
  newline.
- SVG structure checks — both assets use `viewBox="0 0 800 800"`, contain no
  background rectangle/image, and Home has no `refresh_icon.png` reference.

### Limitations

- No physical-device visual pass was run. Resolution-independent SVGs and
  logical-pixel geometry are covered by the QML component test at phone and
  both iPad orientations.

### Next task

- V2-21-07A — Fix single-dog and streak-number presentation.

## Superseding animation follow-up — V2-21-04B

Later physical-device review found that normal successful sync completes too
quickly to communicate activity and that the combined error icon can rotate the
exclamation with the arrows. V2-21-04A remains Done as implementation history.
V2-21-04B adds a non-blocking 2.5-second minimum manual animation and uses the
user-supplied `assets/icons/red-exclamation-mark.svg` as a stationary overlay.
