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
  -> keeps the configured priority task tree selected until it is Done
  -> starts another fresh Codex context for its next child task
  -> resumes normal Version 2 selection afterward
```

This keeps each task isolated in Git and context while allowing a priority task
tree to span several fresh invocations.

## Important before the first AFK run

Review existing changes before handing the repository to Ralph:

Check:

```bash
git status
git -C delearner-frontend status --short
git -C delearner-backend status --short
```

V2-18-07 planning files, supplied reference screenshots and Ralph priority-pin changes are authorized
coordination setup. If they are not already committed, the prompt allows the
V2-18-07 root completion commit to include them after review. Every unrelated
change must remain safely isolatable or Ralph will stop with
`BLOCKED_DIRTY_WORKTREE`.

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

The current default priority pin is `V2-18-07`. A normal run therefore executes
the Settings-to-Profile redesign before returning to global selection:

```text
V2-18-07 rename Settings to Profile and redesign the page
```

The pin is exported to every fresh `codex exec` invocation. Once the pinned
leaf task or parent task tree is Done, Ralph returns to its normal global
selector. Override the pin explicitly:

```bash
RALPH_PRIORITY_TASK=V2-18-07 ./ralph/afk.sh
```

Disable it and use global selection with an explicitly empty value:

```bash
RALPH_PRIORITY_TASK= ./ralph/afk.sh
```

Default is at most 12 task attempts:

```bash
./ralph/afk.sh
```

To run only the priority Profile task, use:

```bash
MAX_ITERATIONS=1 ./ralph/afk.sh
```

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
