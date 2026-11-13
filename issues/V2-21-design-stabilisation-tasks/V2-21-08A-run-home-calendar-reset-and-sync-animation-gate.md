# V2-21-08A — Run Home calendar, reset and sync-animation gate

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Ready
**Workspace:** root + frontend
**Size:** 2 story points
**Dependencies:** V2-21-04B, V2-21-07B
**Figma requirement:** None

## Objective

Verify the V2-21 post-completion corrections together before updating the root
frontend submodule pointer and closing the reopened epic.

## Verification matrix

### Manual sync control

- Fast success, slow success, early/late error, retry and recovery.
- 2500 ms minimum manual animation without delaying real sync completion.
- Static automatic-sync/idle state.
- Rotating arrows with zero-rotation exclamation overlay.
- Destruction/account transition leaves no timer or animation active.

### Streak and calendar

- Dog counts 0, 1, 7, 8, 14, 15 and 30 at phone/tablet widths.
- At most two rows, one face total and correct tail/overflow behavior.
- Current-month calendar for 28, 29, 30 and 31-day months with correct weekday
  alignment and compact phone height.
- Completed/today/missed/future visual and accessibility states.
- Yesterday-at-risk behavior, full missed-day reset to zero, rollover while
  active, resume after a missed day and new streak starting at one.
- Historical completed dates remain visible after reset.
- Month/year/leap-day/DST and account-isolation cases.

### Temporary tooling removal

- No preview slider, Loader, component, context/build flag, resource entry,
  preview-only test or V2-21-06 removal TODO remains.
- Release and Debug Home both use only the canonical streak value.

## Required evidence

- Record root/frontend revisions and pre-existing working-tree changes.
- Run focused Home QML, learning-day repository, lifecycle/resume and sync
  coordinator tests.
- Run the complete frontend suite and relevant root learning-day/integration
  checks.
- Inspect the built/source asset composition to prove the supplied
  `red-exclamation-mark.svg` remains stationary while only arrows rotate.
- Record any physical-device limitation separately from automated geometry and
  clock tests.

## Acceptance criteria

- [ ] Every verification-matrix case has a recorded pass/fail result and exact
      command or manual evidence.
- [ ] No UI-thread or network-operation delay was introduced for the animation.
- [ ] The current streak visibly resets after one complete missed local day and
      historical learning days remain intact.
- [ ] Dog and compact calendar satisfy their bounded geometry requirements.
- [ ] Temporary preview tooling is completely absent.
- [ ] Frontend and relevant root suites pass.
- [ ] A compatible frontend commit is ready before the root submodule pointer
      and epic/index status are updated.

## Completion rule

Keep V2-21 and this gate In Progress if a required automated reset, rollover or
asset-layering check fails. Do not mark Done solely from a visual spot check.
