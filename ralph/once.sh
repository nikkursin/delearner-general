#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
PROMPT_FILE="$SCRIPT_DIR/prompt.md"
TASK_FILE="$ROOT_DIR/issues/V2-01-root-coordination-repository-foundation/V2-01-01-create-root-repository-skeleton-and-submodule-layout.md"
LOG_DIR="$SCRIPT_DIR/logs"

if ! command -v codex >/dev/null 2>&1; then
  echo "error: Codex CLI is not installed or not on PATH." >&2
  exit 127
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "error: missing prompt file: $PROMPT_FILE" >&2
  exit 2
fi

if [[ ! -f "$TASK_FILE" ]]; then
  echo "error: missing task file: $TASK_FILE" >&2
  exit 2
fi

if grep -q '^\*\*Status:\*\* Done[[:space:]]*$' "$TASK_FILE"; then
  echo "V2-01-01 is already marked Done. Nothing to run."
  exit 0
fi

if grep -q '^\*\*Status:\*\* Blocked[[:space:]]*$' "$TASK_FILE"; then
  echo "V2-01-01 is marked Blocked. Resolve the blocker before another loop run." >&2
  exit 3
fi

mkdir -p "$LOG_DIR"
TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
LOG_FILE="$LOG_DIR/V2-01-01-$TIMESTAMP.log"

cd "$ROOT_DIR"

echo "==> Running one Codex iteration for V2-01-01"
echo "==> Root: $ROOT_DIR"
echo "==> Log:  $LOG_FILE"

# The prompt file is the complete instruction. workspace-write is the minimum
# useful sandbox for an implementation loop; avoid danger-full-access here.
set +e
codex exec --sandbox workspace-write - < "$PROMPT_FILE" 2>&1 | tee "$LOG_FILE"
CODEX_EXIT=${PIPESTATUS[0]}
set -e

if [[ $CODEX_EXIT -ne 0 ]]; then
  echo "error: Codex exited with status $CODEX_EXIT. See $LOG_FILE" >&2
  exit "$CODEX_EXIT"
fi

if grep -q '^\*\*Status:\*\* Done[[:space:]]*$' "$TASK_FILE"; then
  echo "==> V2-01-01 is Done. Review the diff before committing."
elif grep -q '^\*\*Status:\*\* Blocked[[:space:]]*$' "$TASK_FILE"; then
  echo "==> V2-01-01 is Blocked. Read the task file and log."
  exit 3
else
  echo "==> Iteration finished, but V2-01-01 is not yet Done."
fi
