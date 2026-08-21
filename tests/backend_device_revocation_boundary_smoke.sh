#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
backend_test="$root_dir/delearner-backend/tests/test_event_characterization.cpp"
backend_handler="$root_dir/delearner-backend/src/handlers/DLEventsCompatibilityHandler.cpp"

test -s "$backend_test"
test -s "$backend_handler"

grep -q "testRevokedDeviceUploadRejected" "$backend_test"
grep -q "testActiveDeviceUploadStillAcceptedAfterAnotherDeviceRevoked" "$backend_test"
grep -q "device_revoked" "$backend_handler"
grep -q "DLRegisteredDeviceRepository" "$backend_handler"
