#!/usr/bin/env bash
set -euo pipefail
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT
mkdir -p "$temporary_dir/bin"
cat > "$temporary_dir/bin/ctest" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$GATE_CALL_LOG"
[[ "$*" == *--no-tests=error* ]] || exit 8
if [[ -n "${FAIL_SUITE:-}" && "$*" == *"^${FAIL_SUITE}$"* ]]; then
  exit 7
fi
STUB
chmod +x "$temporary_dir/bin/ctest"
export PATH="$temporary_dir/bin:$PATH"
export DELEARNER_BUILD_ROOT="$temporary_dir/build"
export GATE_CALL_LOG="$temporary_dir/calls"
runner="$root_dir/tests/bootstrap_recovery_regression_gate.sh"
count=0
for suite in TestBootstrapStateRestorer TestSyncCoordinator TestAppStateAuthBootstrap test_event_characterization; do
  count=$((count + 1))
  : > "$GATE_CALL_LOG"
  if FAIL_SUITE="$suite" "$runner"; then
    echo "Failed suite $suite incorrectly passed the recovery gate" >&2
    exit 1
  fi
  test "$(wc -l < "$GATE_CALL_LOG" | tr -d ' ')" = "$count"
done
: > "$GATE_CALL_LOG"
"$runner"
test "$(wc -l < "$GATE_CALL_LOG" | tr -d ' ')" = 4
if "$runner" --unknown >/dev/null 2>&1; then
  exit 1
fi
