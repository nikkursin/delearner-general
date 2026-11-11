# V2-21-05 — Fix iPad landscape and bottom-navigation geometry

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Ready
**Workspace:** frontend
**Size:** 5 story points
**Dependencies:** completed V2-16-01, completed V2-20-05
**Figma requirement:** None; preserve existing screen designs

## Objective

Fix the shared responsive shell so iPad landscape uses the real viewport and
the bottom navigation sits correctly across supported form factors.

## Observed regressions

- On iPad landscape, the application appears to retain portrait sizing with
  black framing on the left and right.
- The bottom navigation appears too high on some phone layouts even though its
  iPad position looks acceptable.

## Required investigation

Before editing, record geometry evidence for at least:

- a narrow phone portrait viewport;
- a phone landscape viewport;
- an iPad portrait viewport;
- an iPad landscape viewport;
- one wider desktop/test viewport when supported.

Trace the effective window/content dimensions, orientation, safe-area insets,
maximum content widths and bottom-navigation bounds. Determine whether the
black side bars originate in application/window configuration, a fixed root
surface, safe-area handling or a child page constraint. Fix the first incorrect
owner rather than masking it on individual pages.

## Scope

- Make the app window/root shell react to orientation and available viewport
  changes.
- Keep readable content max-widths where appropriate while allowing page
  backgrounds/shell chrome to fill the full viewport.
- Remove portrait-only width/height assumptions from the shared shell and
  navigation geometry.
- Seat the bottom navigation closer to the visual bottom while preserving the
  full reported gesture/home-indicator safe area.
- Keep scrollable content clear of the navigation and system gesture regions.
- Verify Home, Quiz, Words, Groups, Add Word and Profile through the shared
  shell; make local changes only when a screen itself violates the shared rule.
- Add deterministic geometry tests using injected viewport and safe-area
  values. Do not identify a device by model name.

## Acceptance criteria

- [ ] iPad landscape has no app-created black side frames and responds to the
      full available viewport.
- [ ] Rotating between portrait and landscape recomputes layout without stale
      width, clipped content or displaced overlays.
- [ ] Bottom navigation respects the actual safe-area inset and is not raised by
      a duplicated or hard-coded phone padding.
- [ ] The bar never overlaps page content or the platform gesture region.
- [ ] Phone portrait/landscape, iPad portrait/landscape and wide viewport tests
      pass.
- [ ] A physical iPad landscape verification is recorded separately from
      automated geometry tests when the device/simulator is available.

## Non-goals

- Redesigning individual feature screens.
- One-off iPad model checks or hard-coded device offsets.
- Ignoring the safe area merely to move the bar downward.

## Stop / escalate if

- The side bars are imposed by an external deployment/platform policy that
  cannot be changed safely inside the frontend repository.
- Correcting the shell requires a large Figma/code realignment rather than a
  responsive-layout fix.
