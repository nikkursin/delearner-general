#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
backend_test="$root_dir/delearner-backend/tests/test_event_characterization.cpp"
backend_handler="$root_dir/delearner-backend/src/handlers/DLEventsCompatibilityHandler.cpp"
backend_transaction="$root_dir/delearner-backend/src/persistence/DLSyncTransactionRepository.cpp"

test -s "$backend_test"
test -s "$backend_handler"
test -s "$backend_transaction"

grep -q "testAcceptedUploadCommitsCanonicalStateAndAcceptedEventAtomically" "$backend_test"
grep -q "testDeleteUploadReturnsCanonicalTombstone" "$backend_test"
grep -q "DLSyncTransactionRepository" "$backend_handler"
grep -q "accepted_sync_events" "$backend_transaction"
grep -q "canonical" "$backend_handler"
grep -q "serverSequence" "$backend_handler"
