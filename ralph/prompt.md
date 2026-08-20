# Ralph Loop Prompt — V2-01-01

You are executing **one autonomous implementation iteration** for the DE Vocab Learner root coordination repository.

## Current task

Implement only:

`issues/V2-01-root-coordination-repository-foundation/V2-01-01-create-root-repository-skeleton-and-submodule-layout.md`

Parent epic:

`issues/V2-01-root-coordination-repository-foundation/EPIC.md`

Do not start V2-01-02 or any later task.

## Mandatory reading order

Read only the material needed for this task, in this order:

1. `AGENTS.md`
2. The current task file above
3. The parent `EPIC.md`
4. `docs/07-ISSUE-PLANNING-RULES.md`
5. `docs/00-SYSTEM-CONCEPT.md`
6. Read other canonical docs only if the current task actually requires them.

Do **not** recursively analyze the whole frontend or backend source trees. This task is root-repository coordination work.

## Existing repository naming

The established child repository paths are:

- `delearner-frontend`
- `delearner-backend`

Treat generic `frontend` / `backend` wording in the issue as ownership labels. **Do not rename these existing submodule directories merely to match generic wording.** Preserve established names unless a canonical root document explicitly requires a rename; if that would be a structural change, stop and report the conflict instead of making it silently.

## Objective

Make the smallest safe changes needed so the root repository has a reproducible coordination skeleton with the existing frontend/backend repositories represented as Git submodules and the required root coordination directories present.

Expected root-level concepts include:

- the two existing child repositories as Git submodules;
- `docs/`;
- `issues/`;
- `ralph/` or equivalent already-established agent-loop directory;
- root coordination/test/script directories required by the task, but do not invent unrelated tooling.

The repository may already satisfy part or all of this task. **Inspect before editing.** If something already works, preserve it.

## Hard scope limits

- Root repository only unless read-only inspection of child Git metadata is required.
- Do not modify child repository implementation files.
- Do not rewrite child Git history.
- Do not change product behavior, UI, sync contracts, schemas, APIs, quizzes, authentication, payments, or Version 3+ work.
- Do not perform unrelated refactors or cleanup.
- Do not rename `delearner-frontend` or `delearner-backend` without explicit approval.
- Do not push to remotes.
- Do not create commits; leave a reviewable working-tree diff for the human owner.
- Figma is **not required for V2-01-01**. Do not spend tokens inspecting Figma for this task.

## Iteration procedure

### 1. Inspect the current root state

Use focused commands such as:

- `pwd`
- `git status --short`
- `git rev-parse --show-toplevel`
- `git submodule status`
- inspect `.gitmodules`
- inspect the root directory layout
- inspect Git index entries for the two child paths when useful

Determine what is already complete and what is genuinely missing.

### 2. Implement only missing task requirements

Prefer minimal edits. Reuse the existing root layout and naming. Do not replace working configuration just because another layout would also work.

For submodules, preserve the existing child repositories and their history. The root must pin exact child revisions through normal Git submodule gitlink entries.

### 3. Verify

Run the smallest meaningful checks for this task. At minimum, verify where applicable:

- `.gitmodules` contains valid entries for both established child paths;
- both child paths are tracked by the root as Git submodules/gitlinks;
- `git submodule status` resolves both submodules without structural errors;
- required root coordination directories exist;
- no child repository history/content was rewritten;
- no unrelated files were changed.

If a true fresh recursive clone can be tested safely without credentials, remote writes, or destructive actions, do so in a temporary directory. Otherwise document that this acceptance check remains a human/network verification step; do not fake it.

### 4. Review your own diff

Before finishing:

- run `git status --short`;
- inspect the diff;
- remove accidental or unrelated edits;
- confirm the change still belongs only to V2-01-01.

### 5. Update task status

Only after the task's acceptance criteria are satisfied, update the task file line:

`**Status:** Planned`

to:

`**Status:** Done`

If the task cannot be completed safely because of a real conflict, missing remote information, credentials, or contradictory canonical requirements, set it to:

`**Status:** Blocked`

and add a short `## Blocker` section to the task file explaining the exact blocker and the smallest human decision/action required.

Do not mark the parent epic Done; later V2-01 subtasks remain.

## Final response format

Return a concise final report containing:

1. **Result:** Done / Blocked / Partial
2. **Files changed**
3. **Verification performed**
4. **Remaining risk or human check**, if any

Do not propose or begin the next task.
