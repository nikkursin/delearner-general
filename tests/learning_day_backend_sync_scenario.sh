#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/common.sh"

backend_test_source="$ROOT_DIR/delearner-backend/tests/test_event_characterization.cpp"
backend_migrator_test="$ROOT_DIR/delearner-backend/tests/test_database_migrator.cpp"
backend_handler="$ROOT_DIR/delearner-backend/src/handlers/DLEventsCompatibilityHandler.cpp"

for source_file in "$backend_test_source" "$backend_migrator_test" "$backend_handler"; do
  test -s "$source_file"
done

grep -q "testLearningDaysConvergeValidateAndProjectByContract" "$backend_test_source"
grep -q "learning_days" "$backend_migrator_test"
grep -q "X-DELearner-Sync-Contract" "$backend_handler"
grep -q "sync_contract_upgrade_required" "$backend_handler"

"$ROOT_DIR/tests/learning_day_v21_contract_fixtures_smoke.sh"

if [[ $# -eq 0 ]]; then
  exit 0
fi

if [[ $# -ne 1 || "$1" != "--run" ]]; then
  fail "Usage: tests/learning_day_backend_sync_scenario.sh [--run]"
fi

backend_build_dir="$(child_build_dir backend)"
backend_event_test="$backend_build_dir/tests/test_event_characterization"

if [[ ! -x "$backend_event_test" ]]; then
  fail "Missing compiled backend scenario test: $backend_event_test. Run ./scripts/build-all.sh backend first."
fi

log "Running backend learning-day migration and protocol regression suite."
ctest --test-dir "$backend_build_dir" --output-on-failure --no-tests=error \
  -R '^(test_database_migrator|test_v21_learning_day_contract_fixtures)$'
"$backend_event_test" testLearningDaysConvergeValidateAndProjectByContract

log "Backend learning-day synchronization scenario complete."
