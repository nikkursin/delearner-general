# V2-20-04 — Build Home streak page

**Parent epic:** V2-20 — Home, Streak and Navigation Follow-up
**Status:** Done
**Workspace:** frontend + root
**Size:** 5 story points
**Dependencies:** V2-20-03
**Figma requirement:** None; use supplied local references and dog assets

## Objective

Create the authenticated Home page and render the synchronized learning streak
from real local state, following the first panel and streak sequence in the
V2-19-06 references.

## References

- `../V2-19-post-redesign-stabilization/references/V2-19-06/Screenshot 2026-11-10 at 08.10.01.png`
- `../V2-19-post-redesign-stabilization/references/V2-19-06/Screenshot 2026-11-10 at 08.11.37.png`
- `../V2-19-post-redesign-stabilization/references/V2-19-06/streak_dog_tail.png`
- `../V2-19-post-redesign-stabilization/references/V2-19-06/streak_dog_middle_component.png`
- `../V2-19-post-redesign-stabilization/references/V2-19-06/streak_dog_face.png`

Copy runtime assets into the frontend's owned asset catalog during
implementation; do not load issue-reference paths at runtime.

## Scope

- Add a responsive Home page with the top-left Profile/account affordance and
  greeting hierarchy from the reference.
- Add a rounded streak card with current count, supportive copy, recent dates
  and completed/today states backed by V2-20-03.
- Compose the dog from fixed tail/face end caps and a repeatable/stretchable
  middle segment. Do not non-uniformly scale the complete dog.
- Define truthful zero-day, active-today and at-risk-today states without
  fabricating completed days.
- Use flexible width/scroll behavior for phone and tablet safe areas.
- Keep animation subtle, non-blocking and derived from state changes.

## Acceptance criteria

- Home never derives or persists streak state in QML.
- The card correctly renders 0, 1, 2, 7, 8 and long streak values without
  clipping or distorting the dog end pieces.
- Today and recent completed dates match the injected app-state values.
- Offline state remains readable and does not imply failed local storage.
- Phone/tablet QML tests cover layout, accessibility and state variants.
- No source-app branding, unrelated habit features or fabricated account photo
  is copied.
