# V2-17-05 — Fix sign-in sync with pre-existing local vocabulary

**Parent epic:** V2-17 — Word/Group Domain and Sync Evolution  
**Status:** Ready  
**Workspace:** frontend + backend + root  
**Size:** 3 story points  
**Dependencies:** existing authentication + sync baseline

## Objective

Characterize and fix the observed failure where signing in with an already-populated local database fails to synchronize with the remote canonical account state.

## Scope

- Reproduce with local words/groups present before sign-in.
- Capture the exact failing path and add a regression test before changing behavior.
- Preserve legitimate local unsynced work.
- Reconcile/bootstrap according to the canonical sync protocol rather than deleting local data as a workaround.
- Do not weaken ownership/authentication validation to make the test pass.
- Ensure this scenario remains compatible with V2-17 multi-group semantics when both changes are present.

## Acceptance criteria

- A populated local vocabulary can enter authenticated synchronization without an unrecoverable sync error.
- Existing legitimate local data is either uploaded/reconciled under the defined protocol or explicitly preserved pending conflict resolution; it is not silently erased.
- Remote canonical state remains authoritative when timestamps/conflicts require it.
- Regression test fails on the old behavior and passes on the fix.
