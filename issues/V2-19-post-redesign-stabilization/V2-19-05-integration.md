# V2-19-05C — Correlated auth/sync reproduction, fixes and verification

**Parent:** V2-19-05
**Status:** Planned
**Workspace:** frontend + backend + root
**Dependencies:** V2-19-05A, V2-19-05B

## Objective

Use the newly correlated frontend/backend diagnostics to reproduce the reported
account-creation and existing-account startup failures, fix the first verified
failing seams, and verify the parent issue end to end.

## Required sequence

1. Run the parent reproduction matrix with frontend and backend logs captured
   from matching request IDs.
2. Identify the first failing seam for each reproduced failure.
3. Add a failing test at the owning seam before changing behavior.
4. Implement the smallest fix in the owning repository.
5. Rerun focused tests after each fix.
6. Run empty and populated bootstrap, pending-outbox preservation and
   incremental-sync integration coverage.
7. Append the exact commands, outcomes, request IDs or sanitized excerpts, and
   remaining risks to the parent checkpoint.

## Rules

- Preserve backend-owned conflict resolution, ownership, transaction and sync
  semantics.
- Preserve offline-after-initial-auth behavior and pending local work.
- Use diagnostic identifiers/counts; keep credentials and personal payloads out
  of logs and evidence.
- Keep unrelated V2-19 UI tasks untouched.

## Acceptance criteria

- The parent reproduction matrix has an evidence-backed result for every case.
- Every reproduced defect has a focused regression test and smallest safe fix.
- Frontend, backend and root auth/sync checks pass.
- Disposable PostgreSQL HTTP coverage passes for account creation, sign-in,
  device registration, empty/populated bootstrap and incremental sync.
- Secret-redaction checks pass across frontend and backend diagnostics.
- The parent V2-19-05 acceptance criteria are satisfied or a precise external
  verification requirement remains documented without claiming Done.
