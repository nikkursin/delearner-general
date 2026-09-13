#!/usr/bin/env bash
set -euo pipefail
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT
mkdir -p "$temporary_dir/bin"
cat > "$temporary_dir/bin/cmake" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
cat > "$temporary_dir/bin/ctest" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$SCENARIO_CALL_LOG"
if [[ "$*" == *authentication_device_lifecycle* ]]; then
  exit "${AUTH_SCENARIO_EXIT:-0}"
fi
STUB
chmod +x "$temporary_dir/bin/"*
export PATH="$temporary_dir/bin:$PATH"
export DELEARNER_BUILD_ROOT="$temporary_dir/build"
export SCENARIO_CALL_LOG="$temporary_dir/calls"
runner="$root_dir/tests/domain_relationship_tombstone_matrix.sh"

# A failed authorization gate must prevent the domain matrix from executing.
if AUTH_SCENARIO_EXIT=7 "$runner"; then
  echo 'Authorization failure incorrectly passed the gate' >&2
  exit 1
fi
test "$(wc -l < "$SCENARIO_CALL_LOG" | tr -d ' ')" = 1
grep -q authentication_device_lifecycle "$SCENARIO_CALL_LOG"

: > "$SCENARIO_CALL_LOG"
"$runner"
test "$(wc -l < "$SCENARIO_CALL_LOG" | tr -d ' ')" = 2
sed -n '1p' "$SCENARIO_CALL_LOG" | grep -q authentication_device_lifecycle
sed -n '2p' "$SCENARIO_CALL_LOG" | grep -q domain_relationship_tombstone_matrix
sed -n '2p' "$SCENARIO_CALL_LOG" | grep -q automatic_two_device_reconnect
sed -n '2p' "$SCENARIO_CALL_LOG" | grep -q bootstrap_race_catch_up

: > "$SCENARIO_CALL_LOG"
"$runner" --auth-only
test "$(wc -l < "$SCENARIO_CALL_LOG" | tr -d ' ')" = 1
if "$runner" --unknown >/dev/null 2>&1; then
  echo 'Unknown scenario option was accepted' >&2
  exit 1
fi
