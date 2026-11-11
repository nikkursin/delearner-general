# V2-21-06 — Add a removable streak preview slider

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Ready
**Workspace:** frontend
**Size:** 2 story points
**Dependencies:** completed V2-20-04
**Figma requirement:** None; temporary developer tooling

## Objective

Add the simplest removable Home control for previewing different streak lengths
without changing canonical learning-day data.

## Scope

- Add a compact developer/test-only slider on Home with a useful range such as
  0–30 and a visible numeric preview label.
- Initialise the preview from the real current streak.
- While enabled, override only the streak presentation value used by the Home
  count and dog graphic.
- Keep the real recent dates and canonical streak available so the preview is
  clearly distinguishable from persisted state.
- Isolate the UI in one small component or one contiguous block and gate it
  behind one existing or new development-only flag.
- Mark the component, flag/property, loader/integration point and tests with the
  exact comment `// TODO: Remove after testing`.
- Add a focused test proving slider changes update presentation and do not call
  repository, quiz-completion, outbox or sync mutation APIs.
- Ensure production/release builds have no visible, focusable or accessible
  slider control.

## Acceptance criteria

- [ ] A developer build can preview 0, 1, 7, 8, 10, 11, 14, 15 and 30-day
      presentations without completing quizzes.
- [ ] Moving the slider creates no learning-day row, outbox event, network
      request or persisted setting.
- [ ] Returning preview to the real value restores the unmodified presentation.
- [ ] All insertion points carry `// TODO: Remove after testing`.
- [ ] Removing the isolated component/block and its one flag leaves no runtime
      dependency or production behaviour change.
- [ ] A release-mode test or inspection proves the control is absent.

## Non-goals

- Editing historical learning days or providing a user-facing streak editor.
- Sending preview state to the backend.
- Using the slider to hide a repository or date-ordering bug.

## Removal rule

Do not remove the slider as part of V2-21 unless the user explicitly asks. Keep
it development-only and trivially removable in the meantime.
