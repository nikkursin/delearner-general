# V2-16-02 — First-run onboarding flow

**Parent epic:** V2-16 — Frontend Design Alignment  
**Status:** Ready  
**Workspace:** frontend  
**Size:** 3 story points  
**Dependencies:** existing authentication entry point

## Objective

Implement the supplied loading + three-stage onboarding flow before the user's first registration/authentication entry, without redesigning authentication itself.

## Scope

- Initial loading/splash state.
- Three onboarding pages/stages.
- `Skip` on the first two onboarding stages.
- `Continue` on stages one and two.
- `Get started` on the final stage.
- Progress indicators across the three stages.
- Completion/skip state stored as device-local UI state.
- Completed/skipped onboarding is not shown again during normal future launches on that local installation.
- `Get started`/`Skip` transitions into the existing authentication entry point.
- Keep logo and illustration areas as replaceable placeholders.

## Design references

See `references/V2-16-02/`:

- `onboarding-target-flow-annotated.png`
- `onboarding-target-flow-clean.png`

## Constraints

- Do not create production mascot/logo artwork.
- Do not change authentication/session semantics.
- Do not synchronize onboarding completion as account-level data.

## Acceptance criteria

- Fresh local install/state shows loading then onboarding.
- Skip and completion both suppress onboarding on later ordinary launches.
- Final action reaches the existing auth flow.
- Layout adapts to supported phone/tablet widths without fixed-frame clipping.
