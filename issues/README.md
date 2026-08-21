# DE Vocab Learner — Version 2 Loop Issue Pack

This package expands the canonical Version 2 plan into Loop-sized executable epics and subtasks.

## Source of truth

Do not treat this ZIP as a replacement for the canonical root documentation. Before execution, read only the canonical documents referenced by the selected issue, plus `AGENTS.md` and `docs/07-ISSUE-PLANNING-RULES.md`.

## Current planning direction

- Completed work remains completed and must not be reopened by the loop.
- Version 2 remains authenticated account + complete basic multi-device synchronization for the current free core.
- The remaining route is deliberately backend-first: authentication/account persistence, device lifecycle, mutation processing, ordered pull/bootstrap/retention backend primitives, then client wiring and end-to-end convergence.
- Existing quiz execution remains local; resulting review statistics sync.
- Payments/entitlements, sharing and Version 3 redesign remain out of scope.

## Figma policy for Version 2 implementation

Figma is intentionally deferred until the production UX cleanup stage (`V2-14`). Earlier technical tasks must not query Figma unless their own `Figma Requirement` explicitly says `Required`.

When a minimal UI is necessary before V2-14 for functional testing:

- implement the smallest functional state/presentation required by the issue;
- reuse existing project components and styling where practical;
- do not redesign unrelated screens;
- do not use Figma MCP merely for visual polish;
- record any temporary/simple presentation so V2-14 can review it later.

## Execution hierarchy

`Version 2 → dependency-ready task → focused implementation/tests → child commit(s) → root status/pin commit`

Task selection is global across Version 2, not strictly epic-by-epic. Among dependency-ready tasks, prefer backend work, then backend-unblocking root/cross-repo work, then frontend work, and Figma work last. Explicit dependencies always win over preference.
