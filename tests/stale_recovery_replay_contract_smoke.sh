#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
frontend_coordinator="$root_dir/delearner-frontend/src/Sync/DLSyncCoordinator.cpp"
frontend_test="$root_dir/delearner-frontend/tests/TestSyncCoordinator.cpp"
frontend_restore_test="$root_dir/delearner-frontend/tests/TestBootstrapStateRestorer.cpp"
backend_test="$root_dir/delearner-backend/tests/test_event_characterization.cpp"

test -s "$frontend_coordinator"
test -s "$frontend_test"
test -s "$frontend_restore_test"
test -s "$backend_test"

grep -q "requiresRebootstrap" "$frontend_coordinator"
grep -q "pushPendingOutboxEvents(true)" "$frontend_coordinator"
grep -q "staleDeviceRebootstrapsReplaysOriginalEventAndConverges" "$frontend_test"
grep -q "preservesAndReplaysPendingOutboxWhenReplacingState" "$frontend_restore_test"
grep -q "testOlderOfflineReplayPreservesNewerCanonicalStateAndPullOutput" "$backend_test"
