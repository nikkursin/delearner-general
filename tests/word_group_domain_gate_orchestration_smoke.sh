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
cat > "$temporary_dir/bin/cmake" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "$temporary_dir/bin/ctest" "$temporary_dir/bin/cmake"
export PATH="$temporary_dir/bin:$PATH"
export DELEARNER_BUILD_ROOT="$temporary_dir/build"
export GATE_CALL_LOG="$temporary_dir/calls"
runner="$root_dir/tests/word_group_domain_regression_gate.sh"
count=0
for suite in TestV2WordGroupContractFixtures TestWordRepository TestGroupRepository TestSyncEventSerializer TestTransactionalOutbox TestRemoteChangeReconciler test_v2_word_group_contract_fixtures test_domain_repository test_sync_transaction_repository TestBootstrapStateRestorer TestSyncCoordinator TestAppStateAuthBootstrap test_event_characterization authentication_device_lifecycle; do
  count=$((count + 1))
  : > "$GATE_CALL_LOG"
  if FAIL_SUITE="$suite" "$runner"; then
    echo "Failed suite $suite incorrectly passed the Word/Group gate" >&2
    exit 1
  fi
  test "$(wc -l < "$GATE_CALL_LOG" | tr -d ' ')" = "$count"
done
: > "$GATE_CALL_LOG"
"$runner"
test "$(wc -l < "$GATE_CALL_LOG" | tr -d ' ')" = 15
if "$runner" --unknown >/dev/null 2>&1; then
  exit 1
fi
