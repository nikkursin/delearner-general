#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_NAME="$(basename "$ROOT_DIR")"
LOG_DIR="${RALPH_LOG_DIR:-$HOME/.codex/ralph-logs/$PROJECT_NAME}"

# One Codex invocation == at most one completed issue.
# Increase this intentionally if you want Ralph to continue deeper into V2.
MAX_ITERATIONS="${MAX_ITERATIONS:-12}"
SLEEP_SECONDS="${SLEEP_SECONDS:-8}"
# Pin the runtime sign-out regression across fresh Codex contexts. An explicitly
# empty value disables the pin and restores global Ralph selection.
RALPH_PRIORITY_TASK="${RALPH_PRIORITY_TASK-V2-19-08}"
export RALPH_PRIORITY_TASK

echo "==> Starting Ralph AFK loop"
echo "==> Root: $ROOT_DIR"
echo "==> Max task attempts: $MAX_ITERATIONS"
echo "==> Sleep between tasks: ${SLEEP_SECONDS}s"
if [[ -n "$RALPH_PRIORITY_TASK" ]]; then
  echo "==> Priority task tree: $RALPH_PRIORITY_TASK (until Done)"
else
  echo "==> Priority task tree: disabled; using global selection"
fi
echo "==> Logs: $LOG_DIR"
echo
echo "IMPORTANT: each successful iteration creates task commit(s), but never pushes."
echo

for ((i=1; i<=MAX_ITERATIONS; i++)); do
  echo "============================================================"
  echo "==> Ralph iteration $i / $MAX_ITERATIONS"
  echo "============================================================"

  BEFORE="$(find "$LOG_DIR" -maxdepth 1 -type f -name 'run-*.log' 2>/dev/null | sort | tail -n 1 || true)"

  set +e
  "$SCRIPT_DIR/once.sh"
  RUN_EXIT=$?
  set -e

  AFTER="$(find "$LOG_DIR" -maxdepth 1 -type f -name 'run-*.log' 2>/dev/null | sort | tail -n 1 || true)"

  if [[ $RUN_EXIT -ne 0 ]]; then
    echo
    echo "==> Codex/runner exited with code $RUN_EXIT."
    echo "==> Stopping AFK loop to avoid repeated failures or credit usage."
    exit "$RUN_EXIT"
  fi

  if [[ -z "$AFTER" || "$AFTER" == "$BEFORE" ]]; then
    echo "==> Could not identify a new Ralph log. Stopping."
    exit 3
  fi

  RESULT="$(grep -E '^RALPH_RESULT: ' "$AFTER" | tail -n 1 | sed 's/^RALPH_RESULT: //' || true)"

  case "$RESULT" in
    COMPLETED)
      echo
      echo "==> One task completed and committed."
      echo "==> Starting a fresh Codex context for the next eligible V2 task after ${SLEEP_SECONDS}s."
      sleep "$SLEEP_SECONDS"
      ;;
    NO_ELIGIBLE_TASK)
      echo
      echo "==> No dependency-ready Version 2 task remains. Stopping."
      exit 0
      ;;
    BLOCKED|BLOCKED_DIRTY_WORKTREE)
      echo
      echo "==> Ralph is blocked: $RESULT"
      echo "==> Review: $AFTER"
      exit 4
      ;;
    BLOCKED_FIGMA)
      echo "==> Figma task blocked; continuing with independent work."
      sleep "$SLEEP_SECONDS"
      ;;
    # RATE_LIMITED)
    #   echo
    #   echo "==> Codex reported rate/credit exhaustion. Stopping cleanly."
    #   echo "==> Review: $AFTER"
    #   exit 5
    #   ;;
    RATE_LIMITED)
      echo
      echo "==> Rate limited. Continuing so Ralph can try another independent task."
      sleep "$SLEEP_SECONDS"
      ;;
    *)
      echo
      echo "==> Missing or unknown Ralph result marker: '${RESULT:-none}'"
      echo "==> Stopping instead of spending more credits."
      echo "==> Review: $AFTER"
      exit 6
      ;;
  esac
done

echo
echo "==> Reached MAX_ITERATIONS=$MAX_ITERATIONS."
echo "==> This is a safety/credit guard, not a failure."
echo "==> Re-run afk.sh when you want Ralph to continue."
