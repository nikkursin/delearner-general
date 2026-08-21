# V2-14-01 — Review minimal auth, sync and recovery UX in Figma

**Parent epic:** V2-14 — Production UX Cleanup for Stable Sync  
**Status:** Planned  
**Workspace:** Figma + root  
**Size:** 1 story point(s)  
**Dependencies:** V2-05-04,V2-11-04,V2-12-04,V2-13-04  

## Objective

Only after the functional Version 2 system is working, inspect the existing DELearner Figma file once and review/define the minimal production presentation for authentication, sync status, recoverable errors and automatic stale-device recovery.

## Scope

- Reuse the existing DELearner Figma file and recorded node IDs when available.
- Review the simple functional states implemented earlier rather than redesigning the application.
- Batch inspection/update work where possible to minimize MCP calls.
- Record approved node IDs in the root issue for implementation/verification.

## Figma Requirement

Required. This is the intended late Version 2 Figma checkpoint. If the existing DELearner Figma file cannot be identified safely, stop with `BLOCKED_FIGMA` rather than creating a substitute file.

## Acceptance Criteria

- [ ] Authentication entry/error/offline-reopen presentation is reviewed.
- [ ] Sync status and meaningful recoverable error presentation is reviewed.
- [ ] Automatic stale-device recovery does not become a manual reset workflow.
- [ ] Approved/relevant node IDs are recorded for V2-14-02 and final release verification.
- [ ] No unrelated MVP1 screen redesign is introduced.

## Verification

1. Use recorded Figma file/node references directly where available.
2. Batch required inspection rather than repeatedly traversing the file.
3. Record final node IDs and concise decisions in this issue/root coordination state.

## Canonical References

- `docs/00-SYSTEM-CONCEPT.md`
- `docs/02-SYNC-PROTOCOL.md`
- `docs/07-ISSUE-PLANNING-RULES.md`

## Stop / Escalate If

- Existing DELearner Figma file identity is unavailable.
- Review implies a major product/architecture change rather than presentation cleanup.
