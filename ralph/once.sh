#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROMPT_FILE="$SCRIPT_DIR/prompt.md"

if ! command -v codex >/dev/null 2>&1; then
  echo "ERROR: codex CLI is not available on PATH."
  echo 'Try: source ~/.zprofile'
  exit 127
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "ERROR: missing $PROMPT_FILE"
  exit 2
fi

if [[ ! -f "$ROOT_DIR/AGENTS.md" || ! -d "$ROOT_DIR/issues" ]]; then
  echo "ERROR: expected DELEARNER-GENERAL root was not found at: $ROOT_DIR"
  exit 2
fi

PROJECT_NAME="$(basename "$ROOT_DIR")"
LOG_DIR="${RALPH_LOG_DIR:-$HOME/.codex/ralph-logs/$PROJECT_NAME}"
mkdir -p "$LOG_DIR"

STAMP="$(date '+%Y%m%d-%H%M%S')"
LOG_FILE="$LOG_DIR/run-$STAMP.log"

echo "==> Ralph run"
echo "==> Root: $ROOT_DIR"
echo "==> Log:  $LOG_FILE"
echo

cd "$ROOT_DIR"

set +e
codex exec --sandbox danger-full-access - < "$PROMPT_FILE" 2>&1 | tee "$LOG_FILE"
CODEX_EXIT=${PIPESTATUS[0]}
set -e

echo
echo "==> Codex exit code: $CODEX_EXIT"
echo "==> Log saved: $LOG_FILE"

# Expose the last machine-readable result to afk.sh.
RESULT="$(grep -E '^RALPH_RESULT: ' "$LOG_FILE" | tail -n 1 || true)"

if [[ -n "$RESULT" ]]; then
  echo "==> $RESULT"
else
  echo "==> RALPH_RESULT: UNKNOWN"
fi

if [[ $CODEX_EXIT -ne 0 ]]; then
  exit "$CODEX_EXIT"
fi

exit 0
