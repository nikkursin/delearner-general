#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
backend_test="$root_dir/delearner-backend/tests/test_event_characterization.cpp"
backend_handler="$root_dir/delearner-backend/src/handlers/DLEventsCompatibilityHandler.cpp"

test -s "$backend_test"
test -s "$backend_handler"

grep -q "testDownloadStaleCursorRequiresRebootstrap" "$backend_test"
grep -q "stale_cursor" "$backend_test"
grep -q "rebootstrapRequired" "$backend_test"
grep -q "firstAvailableSequence" "$backend_test"
grep -q "stale_cursor" "$backend_handler"
grep -q "rebootstrapRequired" "$backend_handler"
grep -q "QHttpServerResponse::StatusCode::Conflict" "$backend_handler"
grep -q "Requested cursor predates retained sync history" "$backend_handler"
