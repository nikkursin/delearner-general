#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/common.sh"

backend_source="$ROOT_DIR/delearner-backend/tests/test_event_characterization.cpp"
frontend_reconciler_source="$ROOT_DIR/delearner-frontend/tests/TestRemoteChangeReconciler.cpp"
frontend_outbox_source="$ROOT_DIR/delearner-frontend/tests/TestTransactionalOutbox.cpp"

test -s "$backend_source"
test -s "$frontend_reconciler_source"
test -s "$frontend_outbox_source"

grep -q "testTwoDeviceWordGroupCrudAndMembershipConvergesBothDirections" "$backend_source"
grep -q "twoDeviceWordGroupCrudAndMembershipReconcilesBothDirections" "$frontend_reconciler_source"
grep -q "groupDeleteRecordsTombstoneAndAffectedWordUpdate" "$frontend_outbox_source"

if [[ $# -eq 0 ]]; then
  exit 0
fi

if [[ $# -ne 1 || "$1" != "--run" ]]; then
  fail "Usage: tests/word_group_two_device_sync_scenario.sh [--run]"
fi

backend_test="$(child_build_dir backend)/tests/test_event_characterization"
frontend_reconciler_test="$(child_build_dir frontend)/tests/TestRemoteChangeReconciler"
frontend_outbox_test="$(child_build_dir frontend)/tests/TestTransactionalOutbox"

for test_binary in "$backend_test" "$frontend_reconciler_test" "$frontend_outbox_test"; do
  if [[ ! -x "$test_binary" ]]; then
    fail "Missing compiled scenario test: $test_binary. Run ./scripts/build-all.sh all first."
  fi
done

log "Running backend two-device word/group protocol scenario."
"$backend_test" testTwoDeviceWordGroupCrudAndMembershipConvergesBothDirections

log "Running frontend two-device word/group reconciliation scenario."
"$frontend_reconciler_test" twoDeviceWordGroupCrudAndMembershipReconcilesBothDirections

log "Running frontend group-delete outbox relationship scenario."
"$frontend_outbox_test" groupDeleteRecordsTombstoneAndAffectedWordUpdate

log "Two-device word/group synchronization scenario complete."
