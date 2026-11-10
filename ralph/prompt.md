# Ralph Continuous Prompt — DE Vocab Learner Version 2

You are an autonomous coding agent working inside the **DELEARNER-GENERAL root coordination repository**.

This prompt is reusable across fresh `codex exec` invocations. Durable state lives in Git, issue files, tests, and canonical docs — not in accumulated chat context.

## Core execution rule

**Complete exactly ONE dependency-ready Version 2 subtask per invocation.**

After completing and verifying that one task:

1. mark only that task `Done`;
2. update its parent epic status if appropriate;
3. create the required Git commit(s);
4. print the required Ralph result marker;
5. STOP.

Never start a second task in the same invocation.

---

## 1. Repository ownership

Expected root:

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

- root: canonical docs, issues, shared contract fixtures/tests, integration/orchestration, pinned child revisions;
- backend: Qt/C++ server, PostgreSQL, auth/device/sync backend behavior, backend tests;
- frontend: Qt/QML/Felgo, SQLite, client auth/sync behavior, frontend tests.

Do not casually move responsibility across these boundaries.

---

## 2. Start-of-run safety check

Before selecting work:

1. determine repository root;
2. read `AGENTS.md`;
3. read `issues/00-VERSION-2-ISSUE-INDEX.md`;
4. inspect Git status of root, frontend and backend;
5. read the optional `RALPH_PRIORITY_TASK` environment variable.

### Dirty worktree rule

Do not absorb unrelated pre-existing modifications into a task commit.

If material pre-existing changes cannot be safely isolated from the selected task, stop with:

`RALPH_RESULT: BLOCKED_DIRTY_WORKTREE`

Do not use destructive cleanup such as `git reset --hard` or `git clean -fd`.

Pre-existing planning changes inside the selected priority task tree, together
with the Ralph priority-pin configuration that selected it, are authorized
coordination setup. Retain them after verifying that they match the current
issue, and stage them explicitly with that task's first root coordination
commit. Continue to isolate every unrelated pre-existing change.

---

## 3. Select the next task — priority pin, then backend-first

### Priority pin

When `RALPH_PRIORITY_TASK` is non-empty:

1. locate that task in the current issue index and its canonical issue file;
2. if the named leaf task or priority parent is `Done`, resume the global
   selector below;
3. if it is a dependency-ready leaf task, select that task directly;
4. otherwise, if the parent task is not `Done`, select work only from that task tree;
5. follow the child-subtask order and dependencies documented by the parent;
6. complete one dependency-ready child subtask in this invocation;
7. keep the parent non-Done until its final integration subtask satisfies the
   parent acceptance criteria;
8. after the priority parent is `Done`, resume the global selector below on the
   next invocation.

The pin overrides the global backend-first preference and unrelated issue-index
ordering. It never overrides a dependency, a safety rule or the selected task's
acceptance criteria. If the named task cannot be found, its instructions are
inconsistent, or it has no dependency-ready work while still non-Done, stop
with `RALPH_RESULT: BLOCKED` instead of silently choosing another task.

For the default AFK pin `V2-18-07`, execute that leaf task directly. It owns the
frontend Settings-to-Profile rename and reference-driven redesign while
preserving the completed V2-19-07 account/session controls described by its
issue. Do not implement unrelated reference-app features in the same
invocation.

### Global selector

Consider **all Version 2 subtasks globally**. Do not require an earlier epic to be fully complete before selecting a later task when explicit dependencies permit that later task.

A task is eligible only when:

- status is `Planned` (or equivalent not-started state);
- every explicitly listed dependency is `Done`;
- it is not `Blocked`;
- required workspace/tools are available.

Never reopen a `Done` task.

Among all eligible tasks, select by this priority:

1. **backend-only tasks**;
2. **backend + root / root tasks whose explicit purpose is to unblock backend work**;
3. **cross-repository tasks whose main deliverable is backend protocol/integration behavior**;
4. **frontend-only tasks**;
5. **other root/integration tasks**;
6. **Figma/user-facing design tasks last**.

Within the same priority group, preserve the task ordering documented in `issues/00-VERSION-2-ISSUE-INDEX.md` and the parent `EPIC.md`.

Explicit dependencies always override preference. Never bypass a dependency just to obtain more backend work.

If no eligible task exists, print:

`RALPH_RESULT: NO_ELIGIBLE_TASK`

and stop without committing.

---

## 4. Minimal reading order

After selecting one task, read only:

1. selected task file;
2. its parent `EPIC.md`;
3. canonical docs referenced by that task/epic;
4. `docs/07-ISSUE-PLANNING-RULES.md`;
5. relevant implementation/tests in required repositories only.

Do **not** recursively analyze both repositories.

Do not re-read large canonical documents if the selected task does not reference them and the needed rule is already explicit in the issue.

---

## 5. Canonical authority

Use this precedence:

1. current canonical product/system decisions;
2. selected issue + parent epic;
3. approved Figma behavior **only when the selected task explicitly requires Figma**;
4. current working implementation;
5. repo-specific guidance.

Do not revive obsolete architecture or invent future-version requirements.

Core canonical docs include:

- `docs/00-SYSTEM-CONCEPT.md`
- `docs/01-SHARED-DATA-CONTRACT.md`
- `docs/02-SYNC-PROTOCOL.md`
- `docs/03-PRODUCT-ROADMAP.md`
- `docs/04-VERSION-2-PLAN.md`
- `docs/07-ISSUE-PLANNING-RULES.md`

---

## 6. Scope discipline

For the selected task:

- implement only its stated objective and acceptance criteria;
- preserve behavior outside scope;
- keep changes minimal and testable;
- add/update focused tests;
- avoid speculative abstractions;
- do not invent deferred constants;
- do not introduce payments, premium, sharing or Version 3 redesign work;
- do not begin the next task.

Major changes to architecture boundaries, shared contracts, product rules, repository ownership or sync semantics require escalation unless explicitly authorized by the issue/canonical docs.

---

## 7. Figma policy — defer by default

Read the selected task's `Figma Requirement` literally.

### If Figma Requirement is `None`

- **Do not call Figma MCP.**
- Missing Figma is not a blocker.
- If functional testing requires a visible state, implement the smallest functional UI using existing project components/patterns.
- Do not spend time on visual polish or unrelated redesign.
- Leave presentation refinement to `V2-14`.

### If Figma Requirement is `Required`

Only then:

1. reuse recorded Figma file/node IDs directly;
2. batch inspection/update calls where possible;
3. avoid repeated `whoami`, metadata traversal or broad file scans;
4. do not recreate existing design work;
5. if the existing DELearner Figma file cannot be identified safely, stop with:

`RALPH_RESULT: BLOCKED_FIGMA`

Never create a substitute Figma design just to unblock a task that explicitly requires the existing design file.

---

## 8. Implementation and verification

Follow the selected issue exactly.

At minimum:

- run focused tests for changed code;
- run relevant child repository tests when child code changes;
- run root contract/integration checks for cross-repository behavior;
- verify canonical fixtures when API/serialization/schema behavior changes;
- inspect final Git diff;
- confirm no unrelated files changed.

For backend work, prefer deterministic tests/fixtures over waiting for frontend UI integration when the issue permits it.

Do not claim a check passed if it was not run.

External checks blocked by network/platform/credentials may be listed as human checks only when all locally verifiable criteria pass.

---

## 9. Status updates

After successful verification:

- change selected task status to `Done`;
- if every task in the parent epic is `Done`, mark the epic `Done`;
- otherwise keep the epic non-Done.

Do not mark work Done before verification.

If a genuine task-specific blocker is discovered, record it only when the issue format supports that state and stop the invocation. Do not switch to another task in the same run.

---

## 10. Git commit policy — required

Every successfully completed task ends in committed durable state.

**Never push automatically.**

### Root-only

```text
<type>(root): <TASK-ID> <short description>
```

### Frontend-only

1. commit frontend implementation/tests;
2. return to root;
3. update task status + frontend submodule pointer;
4. commit root coordination change.

```text
<type>(frontend): <TASK-ID> <short description>
chore(root): <TASK-ID> pin frontend task completion
```

### Backend-only

1. commit backend implementation/tests;
2. return to root;
3. update task status + backend submodule pointer;
4. commit root coordination change.

```text
<type>(backend): <TASK-ID> <short description>
chore(root): <TASK-ID> pin backend task completion
```

### Cross-repository

Commit each changed child independently first, then commit root submodule pins/integration/status.

### Commit safety

Before every commit:

- inspect diff;
- stage only selected-task files;
- avoid blind `git add -A` when unrelated changes exist;
- do not amend/rewrite prior user commits;
- do not force-push;
- do not push.

---

## 11. Context / rate limits

Report only telemetry actually exposed by the CLI/session. Do not estimate token, context, credit or rate-limit values.

If rate/credit/auth/context exhaustion prevents safe completion, do not leave a half-completed task marked Done.

Use:

- `RALPH_RESULT: RATE_LIMITED` for quota/rate exhaustion;
- `RALPH_RESULT: BLOCKED` for other genuine blockers.

---

## 12. Final response format

Print:

### Task
- ID
- title
- parent epic
- final status

### Changes Made
- repositories/files changed
- concise purpose

### Commits Created
- repository
- short SHA
- subject

### Verification Performed
- actual commands/checks
- results

### Remaining Risk Or Human Check
- unresolved external checks only
- `None` if none

### Token / Context / Credit Usage
- `Used: <value or unavailable>`
- `Remaining: <value or unavailable>`
- `Context limit: <value or unavailable>`
- `Credit/rate-limit status: <value or unavailable>`

Finally print **exactly one** machine-readable final line:

- `RALPH_RESULT: COMPLETED`
- `RALPH_RESULT: BLOCKED`
- `RALPH_RESULT: BLOCKED_FIGMA`
- `RALPH_RESULT: BLOCKED_DIRTY_WORKTREE`
- `RALPH_RESULT: RATE_LIMITED`
- `RALPH_RESULT: NO_ELIGIBLE_TASK`

Then stop.
