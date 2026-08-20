#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
TASK_FILE="$ROOT_DIR/issues/V2-01-root-coordination-repository-foundation/V2-01-01-create-root-repository-skeleton-and-submodule-layout.md"
ONCE="$SCRIPT_DIR/once.sh"

MAX_ITERATIONS="${MAX_ITERATIONS:-4}"
SLEEP_SECONDS="${SLEEP_SECONDS:-5}"

if ! [[ "$MAX_ITERATIONS" =~ ^[1-9][0-9]*$ ]]; then
  echo "error: MAX_ITERATIONS must be a positive integer." >&2
  exit 2
fi

if ! [[ "$SLEEP_SECONDS" =~ ^[0-9]+$ ]]; then
  echo "error: SLEEP_SECONDS must be a non-negative integer." >&2
  exit 2
fi

if [[ ! -x "$ONCE" ]]; then
  echo "error: $ONCE is not executable. Run: chmod +x ralph/once.sh ralph/afk.sh" >&2
  exit 2
fi

for ((i=1; i<=MAX_ITERATIONS; i++)); do
  if grep -q '^\*\*Status:\*\* Done[[:space:]]*$' "$TASK_FILE"; then
    echo "V2-01-01 is Done. AFK loop stopping."
    exit 0
  fi

  if grep -q '^\*\*Status:\*\* Blocked[[:space:]]*$' "$TASK_FILE"; then
    echo "V2-01-01 is Blocked. AFK loop stopping to avoid wasting tokens." >&2
    exit 3
  fi

  echo
  echo "========== Ralph iteration $i/$MAX_ITERATIONS =========="

  set +e
  "$ONCE"
  RUN_EXIT=$?
  set -e

  if [[ $RUN_EXIT -ne 0 ]]; then
    echo "Iteration exited with status $RUN_EXIT. Stopping instead of retrying blindly." >&2
    exit "$RUN_EXIT"
  fi

  if grep -q '^\*\*Status:\*\* Done[[:space:]]*$' "$TASK_FILE"; then
    echo "V2-01-01 completed on iteration $i."
    exit 0
  fi

  if (( i < MAX_ITERATIONS )); then
    echo "Task is still open. Sleeping ${SLEEP_SECONDS}s before the next fresh Codex run."
    sleep "$SLEEP_SECONDS"
  fi
done

echo "Reached MAX_ITERATIONS=$MAX_ITERATIONS without a Done/Blocked task status." >&2
echo "Review ralph/logs and the working-tree diff before deciding whether to continue." >&2
exit 4
