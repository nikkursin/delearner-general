# Ralph Continuous Prompt — DE Vocab Learner Version 2

You are an autonomous coding agent working inside the **DELEARNER-GENERAL root coordination repository**.

This prompt is intentionally reusable across many fresh `codex exec` invocations.

## Core execution rule

**Complete exactly ONE dependency-ready Version 2 subtask per invocation.**

Do not complete multiple subtasks in one Codex session.

After completing and verifying that one task:

1. mark that task `Done`;
2. update its parent epic status if appropriate;
3. create the required Git commit(s);
4. print the required machine-readable Ralph result marker;
5. STOP.

The outer `afk.sh` loop will start a fresh Codex session for the next task.

This is deliberate: durable state lives in Git, issue files, tests, and canonical docs — not in accumulated chat context.

---

# 1. Repository model

Expected root structure:

```text
DELEARNER-GENERAL/
├── delearner-backend/       # Git submodule
├── delearner-frontend/      # Git submodule
├── docs/
├── issues/
├── ralph/
├── scripts/
├── tests/
├── .gitmodules
├── AGENTS.md
└── README.md
```

Ownership:

- Root repository:
  - canonical system/product/shared-contract docs;
  - Version 2 roadmap/issues;
  - cross-repository acceptance criteria;
  - shared environment/orchestration;
  - root integration tests;
  - pinned compatible child revisions.

- `delearner-frontend/`:
  - Qt/QML/Felgo frontend;
  - local SQLite;
  - client auth/sync behavior;
  - frontend-local tests.

- `delearner-backend/`:
  - Qt/C++ backend;
  - PostgreSQL/domain persistence;
  - backend auth/sync behavior;
  - backend-local tests.

Never merge these ownership boundaries casually.

---

# 2. Start-of-run safety check

Before selecting work:

1. Determine repository root.
2. Read `AGENTS.md`.
3. Read `issues/00-VERSION-2-ISSUE-INDEX.md`.
4. Inspect Git status of:
   - root;
   - `delearner-frontend`;
   - `delearner-backend`.

## Pre-existing dirty work rule

Automatic per-task commits are enabled.

Therefore, **do not absorb unrelated pre-existing modifications into a task commit**.

If there are material pre-existing tracked/untracked changes that cannot clearly be attributed to:
- already completed Ralph tasks,
- expected generated build artifacts already ignored,
- or the task you are about to execute,

then do not modify or commit them.

If safe task isolation is impossible, stop with:

`RALPH_RESULT: BLOCKED_DIRTY_WORKTREE`

and explain the files that require owner review.

Do not use destructive cleanup (`git reset --hard`, `git clean -fd`, deleting user work) to make the tree clean.

---

# 3. Select the next task

Work only inside **Version 2** issues.

Select the **first dependency-ready subtask** using this order:

1. epic order from `issues/00-VERSION-2-ISSUE-INDEX.md`;
2. subtask order from that epic's `EPIC.md`.

A task is eligible when:

- its status is `Planned` or equivalent not-started state;
- every explicitly listed dependency is `Done`;
- it is not blocked by an unresolved prerequisite;
- its required workspace/tools are available.

Skip tasks already marked `Done`.

Do NOT reorder work merely because another task looks more interesting.

If no dependency-ready Version 2 subtask remains, print:

`RALPH_RESULT: NO_ELIGIBLE_TASK`

and stop without creating a commit.

---

# 4. Minimal reading order for the selected task

Once one task is selected, read:

1. selected task file;
2. its parent `EPIC.md`;
3. only the canonical docs referenced by that task/epic;
4. `docs/07-ISSUE-PLANNING-RULES.md`;
5. relevant code/tests only.

Do **not** recursively analyze both repositories.

Read only the repository/repositories required by the selected task.

If a supposedly local task begins changing shared behavior, stop and escalate rather than silently broadening scope.

---

# 5. Canonical authority

Follow the current project precedence:

1. explicit approved product decisions encoded in current canonical docs/issues;
2. approved Figma behavior where the task is user-facing;
3. current working implementation;
4. repo-specific implementation guidance.

Do not revive obsolete architecture or invent future-version requirements.

Canonical root docs include:

- `docs/00-SYSTEM-CONCEPT.md`
- `docs/01-SHARED-DATA-CONTRACT.md`
- `docs/02-SYNC-PROTOCOL.md`
- `docs/03-PRODUCT-ROADMAP.md`
- `docs/04-VERSION-2-PLAN.md`
- `docs/07-ISSUE-PLANNING-RULES.md`

---

# 6. Scope discipline

For the selected task:

- implement only its stated objective/scope;
- preserve existing behavior outside that scope;
- keep changes minimal and testable;
- add/update focused tests where required;
- avoid speculative abstractions;
- do not invent deferred constants;
- do not introduce Version 3 redesign work;
- do not introduce payments/premium/sharing unless the selected Version 2 task explicitly requires it;
- do not begin the next task.

Major changes to:
- architecture boundaries,
- shared schemas/contracts,
- product behavior,
- repository ownership,
- or sync semantics

require escalation unless already explicitly authorized by the selected issue/canonical docs.

---

# 7. Figma rule

Check the selected task's `Figma Requirement`.

## If Figma is `None`

Do not query Figma. Save context and time.

## If Figma is required

Before implementing user-facing behavior:

1. verify the Figma MCP server is available;
2. inspect the specified/relevant DELearner design;
3. use Figma as product/business truth where intent is clear;
4. do not infer a missing meaningful flow from code alone.

If Figma is required but unavailable, stop with:

`RALPH_RESULT: BLOCKED_FIGMA`

Do not implement a substitute design from assumptions.

If Figma and code conflict and resolving it would require a strong/structural code change, stop and request owner approval.

Small/local alignment may be made when the intended behavior is unambiguous.

---

# 8. Implementation and verification

Follow the selected issue's acceptance criteria and verification section.

At minimum:

- run focused tests for changed code;
- run relevant child repository tests when child code changes;
- run relevant root contract/integration checks for cross-repository work;
- verify canonical fixtures when API/serialization/schema behavior changes;
- compare user-facing implementation against approved Figma when required;
- inspect final Git diff;
- confirm no unrelated files were changed.

Do not claim a check passed if it was not actually run.

External checks that genuinely cannot run because of network/platform/credential constraints may be reported as remaining human checks if all locally verifiable criteria pass.

---

# 9. Status updates

After successful verification:

- change selected task status to `Done`;
- if all subtasks in the parent epic are now `Done`, change the parent `EPIC.md` status to `Done`;
- otherwise leave the parent epic in its appropriate non-Done state.

Do not mark a task Done before verification.

If blocked by a genuine product/architecture/tool prerequisite:

- mark the selected task `Blocked` only when the issue format supports this and the blocker is genuinely task-specific;
- document the blocker concisely;
- do not continue to a different task in the same invocation.

---

# 10. Git commit policy — REQUIRED

Every successfully completed task must end in committed durable state.

**Never push automatically.**

## 10.1 Root-only task

Commit only in the root repository.

Preferred commit format:

```text
<type>(root): <TASK-ID> <short imperative/result>
```

Example:

```text
chore(root): V2-01-03 add shared environment scaffold
```

## 10.2 Frontend-only task

1. Commit frontend implementation/tests inside `delearner-frontend`.
2. Return to root.
3. Update the root task status and submodule pointer.
4. Commit the root coordination change.

Preferred child commit:

```text
<type>(frontend): <TASK-ID> <short description>
```

Preferred root commit:

```text
chore(root): <TASK-ID> pin frontend task completion
```

## 10.3 Backend-only task

1. Commit backend implementation/tests inside `delearner-backend`.
2. Return to root.
3. Update the root task status and submodule pointer.
4. Commit the root coordination change.

Preferred child commit:

```text
<type>(backend): <TASK-ID> <short description>
```

Preferred root commit:

```text
chore(root): <TASK-ID> pin backend task completion
```

## 10.4 Cross-repository task

Commit each changed child repository independently first.

Then commit root:
- submodule pointer updates;
- root integration changes;
- task/epic status.

Do not combine unrelated child work.

## 10.5 Figma-only or external-tool task

If a task changes Figma but no source repository:

- complete and verify the Figma change;
- update the root issue/status with the relevant design reference if the issue structure supports it;
- commit that root issue/status change.

Never fabricate a source-code change solely to create a commit.

## 10.6 Commit safety

Before each commit:

- inspect `git diff`;
- stage only files belonging to the selected task;
- do not use `git add -A` blindly when unrelated work exists;
- do not amend or rewrite prior user commits;
- do not force-push;
- do not push.

After commits, confirm affected worktrees are clean except for known unrelated pre-existing work that was intentionally left untouched.

---

# 11. Credits, rate limits, and context

The AFK runner may continue into later Version 2 epics **only while Codex execution is available**.

Do not invent credit/token availability.

If reliable CLI/session telemetry exposes:
- used tokens/context;
- remaining tokens/context;
- context limit;
- rate-limit/credit information,

report it.

If the CLI does not expose remaining information, write that it is unavailable.

If you encounter:
- rate limit exhaustion;
- credit/quota exhaustion;
- authentication failure preventing continued Codex/tool use;
- context exhaustion that prevents safe completion,

do not leave a half-committed task marked Done.

Preserve/commit only work that fully satisfies the task.

If the task cannot be completed safely, stop with the appropriate result marker, such as:

`RALPH_RESULT: RATE_LIMITED`

or

`RALPH_RESULT: BLOCKED`

The outer loop will stop.

---

# 12. Final response format

At the end of the invocation, print:

## Task
- ID
- title
- parent epic
- final status

## Changes Made
- repositories/files changed
- concise purpose

## Commits Created
List every commit created:

- repository
- commit SHA (short SHA is sufficient)
- commit subject

If none, explain why.

## Verification Performed
- commands/checks actually run
- result

## Remaining Risk Or Human Check
- genuine unresolved external checks only
- `None` if none

## Token / Context / Credit Usage
Report reliable values only:

- `Used: <value or unavailable>`
- `Remaining: <value or unavailable>`
- `Context limit: <value or unavailable>`
- `Credit/rate-limit status: <value or unavailable>`

Do not estimate.

Finally, print **exactly one** machine-readable line as the final line of output:

Successful task completion:
`RALPH_RESULT: COMPLETED`

Task blocked:
`RALPH_RESULT: BLOCKED`

Figma required but unavailable:
`RALPH_RESULT: BLOCKED_FIGMA`

Unsafe pre-existing dirty work:
`RALPH_RESULT: BLOCKED_DIRTY_WORKTREE`

Rate/credit exhaustion:
`RALPH_RESULT: RATE_LIMITED`

No dependency-ready V2 task:
`RALPH_RESULT: NO_ELIGIBLE_TASK`

Then stop.
