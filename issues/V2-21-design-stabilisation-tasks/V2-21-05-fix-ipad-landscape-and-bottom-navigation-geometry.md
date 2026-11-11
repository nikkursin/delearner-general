# V2-21-05 — Fix iPad landscape and bottom-navigation geometry

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Done
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

- [x] iPad landscape has no app-created black side frames and responds to the
      full available viewport.
- [x] Rotating between portrait and landscape recomputes layout without stale
      width, clipped content or displaced overlays.
- [x] Bottom navigation respects the actual safe-area inset and is not raised by
      a duplicated or hard-coded phone padding.
- [x] The bar never overlaps page content or the platform gesture region.
- [x] Phone portrait/landscape, iPad portrait/landscape and wide viewport tests
      pass.
- [x] A physical iPad landscape verification is recorded separately from
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

## Implementation checkpoint — 2026-11-11

**Frontend commit:** `8375624` — `fix(frontend): V2-21-05 correct responsive shell geometry`

### Investigation and geometry evidence

The packaged iOS metadata permitted portrait orientations only. After enabling
landscape metadata, a served simulator reproduction still showed the root
window retaining portrait dimensions after rotation, which created the black
side frame before page layout ran. The first incorrect owner was therefore the
iOS/root application window, not an individual Home, Quiz, Words, Groups, Add
Word or Profile page.

The shared shell test injects the following logical viewport and safe-area
values. Navigation bounds use the single formula `84 + bottom inset`; its
content is capped at 720 logical pixels and centred inside left/right safe
areas.

| Viewport | Size | Safe area (T/R/B/L) | Navigation bounds | Navigation content |
|---|---:|---:|---:|---:|
| Phone portrait | 393×852 | 59/0/34/0 | y 734–852 | x 0–393 |
| Phone landscape | 852×393 | 0/59/21/59 | y 288–393 | x 66–786 |
| iPad portrait | 1024×1366 | 24/0/20/0 | y 1262–1366 | x 152–872 |
| iPad landscape | 1366×1024 | 24/0/20/0 | y 920–1024 | x 323–1043 |
| Wide desktop | 1440×900 | 0/0/0/0 | y 816–900 | x 360–1080 |

`DLAppPage` fills each viewport, keeps its flickable immediately above the
navigation, and applies left/right safe areas to page content. Home, Quiz,
Words, Groups, Add Word and Profile all inherit this shared owner.

### Changes

- enabled portrait and landscape orientations in the packaged iOS metadata and
  aligned the legacy Felgo configuration with automatic orientation;
- made the iOS root window full-screen and bound its dimensions to the current
  portrait/landscape screen orientation;
- kept page chrome full-width while constraining navigation actions and page
  content to all four reported safe-area edges;
- added deterministic five-viewport and live-resize shell/navigation tests,
  plus static checks for the packaged orientation and root-window policy.

### Verification

- `cmake -S . -B build-tests -DDELEARNER_BUILD_APP=OFF -DDELEARNER_BUILD_TESTS=ON`
- `cmake --build build-tests --parallel 4`
- `ctest --test-dir build-tests --output-on-failure` — 35/35 passed.
- iOS device configuration regenerated with CMake; generated `Info.plist`
  contains portrait, landscape-left and landscape-right for iPhone and iPad.
- Debug iOS Simulator application build succeeded.
- iPad iOS 18.4 simulator runtime check: launched in portrait, rotated to
  landscape, then back to portrait; Home and Words filled the complete
  viewport, navigation stayed at the safe-area bottom and no black side frame
  or stale overlay remained.

### Limitations and next task

- The runtime check used an iPad simulator. No physical iPad installation was
  performed, to avoid replacing user data on a connected personal device.
- V2-21 remains In Progress. The next globally selected task remains subject to
  Ralph dependency and workspace priority rules.
