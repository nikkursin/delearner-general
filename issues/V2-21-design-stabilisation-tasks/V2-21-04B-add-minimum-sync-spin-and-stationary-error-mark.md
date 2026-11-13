# V2-21-04B — Add minimum sync spin and stationary error mark

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Ready
**Workspace:** frontend
**Size:** 2 story points
**Dependencies:** completed V2-21-04A
**Figma requirement:** None; follow the explicit current product correction

## Objective

Make every accepted Home manual-sync action visibly rotate for a short minimum
duration, while keeping the error exclamation stationary at the centre of the
rotating arrows.

## Existing approved assets

- `delearner-frontend/assets/icons/sync-refresh-idle.svg` — rotating arrow
  layer and normal idle icon.
- `delearner-frontend/assets/icons/red-exclamation-mark.svg` — user-supplied
  stationary error overlay.

The exclamation asset already exists as an uncommitted user file. Preserve it,
inspect it before use and include it only in the selected frontend task commit.
Do not regenerate, redraw or overwrite it. The combined
`sync-refresh-error.svg` may remain in the asset catalog for compatibility, but
Home must not rotate that combined SVG.

## Approved timing and state model

### Normal idle

- Show the static normal refresh arrows without an exclamation.
- Automatic/background sync does not start the Home manual-sync animation.
- A previous successful or failed attempt must not leave an animation running.

### Accepted manual sync

- Start the arrow rotation immediately after the Home button accepts the manual
  request.
- Use a minimum visible rotation duration of 2.5 seconds (within the requested
  2–3 second range).
- Start the real sync immediately. The minimum animation duration is visual
  feedback only; it must not delay network work, acknowledgement, persistence,
  callbacks or the UI thread.
- If sync remains active after 2.5 seconds, continue rotating until its terminal
  result.
- If sync succeeds sooner, finish the remaining visual minimum and then return
  to the static normal icon.
- Prevent a second manual request while the real or minimum-visual cycle is
  still active.

### Error

- Show `red-exclamation-mark.svg` as a separate centred, stationary overlay.
- Rotate only `sync-refresh-idle.svg` behind/around the exclamation.
- If an error arrives before the 2.5-second minimum ends, reveal the stationary
  exclamation immediately and continue rotating only the arrows for the
  remaining minimum duration.
- After the minimum duration and terminal failure, stop the arrows and retain
  the static arrows-plus-exclamation error state.
- Retrying starts a new manual visual cycle. Clearing/resolving the error removes
  the exclamation and restores static normal arrows.

## Implementation constraints

- Use non-blocking QML animation/timer state; never use a sleep or busy wait.
- Separate real coordinator busy state, terminal result and minimum visual
  duration so signal ordering cannot strand the icon.
- Reset timers/rotation on page destruction and account/session transition.
- Keep the visible arrow and exclamation layers optically centred at the
  V2-21-04A approved 20–24 logical-pixel scale inside the existing touch target.
- Add a deterministic timing seam for QML tests so the suite does not sleep for
  2.5 real seconds per case. Production duration remains 2500 ms.
- Preserve the existing coordinator, automatic sync triggers, error text and
  accessible retry action.

## Acceptance criteria

- [ ] An accepted fast successful manual sync visibly rotates for at least the
      configured 2500 ms production minimum, then becomes static idle.
- [ ] A slow manual sync rotates until terminal completion even when longer than
      the minimum.
- [ ] Automatic sync, page creation and a refused manual request do not start
      rotation.
- [ ] During an error visual cycle, the arrows rotate and the exclamation's
      rotation remains exactly zero.
- [ ] After terminal failure/minimum duration, arrows stop while the stationary
      exclamation remains visible and retryable.
- [ ] Resolving the error restores static normal arrows without starting another
      animation.
- [ ] The animation introduces no artificial delay into sync/network completion
      and does not block input or the UI thread.
- [ ] Focused Home QML tests cover fast success, slow success, early error,
      late error, retry, automatic sync, refused trigger and teardown.
- [ ] The complete frontend suite passes.

## Non-goals

- Changing sync scheduling, retry policy, API semantics or conflict handling.
- Adding an artificial delay to the real synchronization operation.
- Rotating the exclamation mark.
- Replacing the supplied user asset.
