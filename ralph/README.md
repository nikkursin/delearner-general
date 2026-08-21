# Continuous Ralph runner for DE Vocab Learner V2

This version replaces task-specific prompts.

## Execution model

One `codex exec` invocation completes **at most one** dependency-ready Version 2 task:

```text
fresh Codex context
  -> select next dependency-ready task
  -> implement
  -> verify
  -> mark Done
  -> commit task
  -> stop

afk.sh
  -> starts another fresh Codex context
```

This means the same prompt can finish the remaining V2-01 tasks and then continue into V2-02, V2-03, etc., while keeping each task isolated in Git and context.

## Important before the first AFK run

Your repository should have the already-finished V2-01-01 work committed first.

Check:

```bash
git status
git -C delearner-frontend status --short
git -C delearner-backend status --short
```

If V2-01-01 is Done but its root changes are still uncommitted, review and commit them manually before starting the continuous runner. Otherwise the agent will intentionally stop with `BLOCKED_DIRTY_WORKTREE` rather than mix old work into V2-01-02.

## Install

Copy:

```text
prompt.md
once.sh
afk.sh
```

to:

```text
DELEARNER-GENERAL/ralph/
```

Then:

```bash
chmod +x ralph/once.sh ralph/afk.sh
```

## Controlled test

Run one fresh task:

```bash
./ralph/once.sh
```

Then inspect:

```bash
git log --oneline --decorate -5
git status
git submodule status
```

## AFK mode

Default is at most 12 task attempts:

```bash
./ralph/afk.sh
```

For only the remaining V2-01 work, use a small guard:

```bash
MAX_ITERATIONS=3 ./ralph/afk.sh
```

because V2-01-01 is already complete and V2-01-02 through V2-01-04 remain.

To allow work to continue into later V2 epics:

```bash
MAX_ITERATIONS=10 ./ralph/afk.sh
```

or:

```bash
MAX_ITERATIONS=20 SLEEP_SECONDS=10 ./ralph/afk.sh
```

Do not interpret `MAX_ITERATIONS` as guaranteed completed tasks. An invocation may stop because of a blocker, unavailable Figma, dirty worktree, or rate/credit limit.

## Credits / token behavior

The runner does not guess remaining Codex credits.

It continues while executions succeed, up to `MAX_ITERATIONS`, and stops immediately when:
- Codex returns an execution error;
- the agent reports `RATE_LIMITED`;
- a task is blocked;
- Figma is required but unavailable;
- task isolation is unsafe;
- no eligible V2 task remains.

The prompt asks Codex to report used and remaining context/credits only when reliable CLI telemetry exposes them.

## Commit behavior

Successful tasks are committed automatically but **never pushed**.

Root-only task:
- one root commit.

Child-only task:
- child implementation/test commit;
- root commit updating the submodule pointer and issue status.

Cross-repo task:
- one commit in each affected child first;
- one root coordination commit afterward.

Always inspect before pushing:

```bash
git log --oneline --decorate --graph -15
git status
git submodule status
```
