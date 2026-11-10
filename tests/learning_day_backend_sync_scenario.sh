#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/common.sh"

backend_test_source="$ROOT_DIR/delearner-backend/tests/test_event_characterization.cpp"
backend_migrator_test="$ROOT_DIR/delearner-backend/tests/test_database_migrator.cpp"
backend_handler="$ROOT_DIR/delearner-backend/src/handlers/DLEventsCompatibilityHandler.cpp"
frontend_learning_day_test="$ROOT_DIR/delearner-frontend/tests/TestLearningDayRepository.cpp"
frontend_reconciler_test="$ROOT_DIR/delearner-frontend/tests/TestRemoteChangeReconciler.cpp"
frontend_bootstrap_test="$ROOT_DIR/delearner-frontend/tests/TestBootstrapStateRestorer.cpp"

for source_file in \
  "$backend_test_source" \
  "$backend_migrator_test" \
  "$backend_handler" \
  "$frontend_learning_day_test" \
  "$frontend_reconciler_test" \
  "$frontend_bootstrap_test"; do
  test -s "$source_file"
done

grep -q "testLearningDaysConvergeValidateAndProjectByContract" "$backend_test_source"
grep -q "learning_days" "$backend_migrator_test"
grep -q "X-DELearner-Sync-Contract" "$backend_handler"
grep -q "sync_contract_upgrade_required" "$backend_handler"
grep -q "completionIsAtomicAndIdempotent" "$frontend_learning_day_test"
grep -q "remoteLearningDaysConvergeWithoutOutboxFeedbackAndRejectOtherAccount" "$frontend_reconciler_test"
grep -q "pendingLearningDaySurvivesBootstrapAndAdoptsCanonicalIdentity" "$frontend_bootstrap_test"

"$ROOT_DIR/tests/learning_day_v21_contract_fixtures_smoke.sh"

if [[ $# -eq 0 ]]; then
  exit 0
fi

if [[ $# -ne 1 || "$1" != "--run" ]]; then
  fail "Usage: tests/learning_day_backend_sync_scenario.sh [--run]"
fi

backend_build_dir="$(child_build_dir backend)"
backend_event_test="$backend_build_dir/tests/test_event_characterization"
frontend_build_dir="$(child_build_dir frontend)"
frontend_learning_day_binary="$frontend_build_dir/tests/TestLearningDayRepository"
frontend_reconciler_binary="$frontend_build_dir/tests/TestRemoteChangeReconciler"
frontend_bootstrap_binary="$frontend_build_dir/tests/TestBootstrapStateRestorer"

for test_binary in \
  "$backend_event_test" \
  "$frontend_learning_day_binary" \
  "$frontend_reconciler_binary" \
  "$frontend_bootstrap_binary"; do
  if [[ ! -x "$test_binary" ]]; then
    fail "Missing compiled learning-day scenario test: $test_binary. Run ./scripts/build-all.sh all first."
  fi
done

log "Running frontend offline capture, same-day deduplication, and streak derivation scenarios."
"$frontend_learning_day_binary" \
  completionIsAtomicAndIdempotent \
  missedDateResetsOnlyCurrentStreak \
  accountIsolationAndReviewResetPreserveLearningDays

log "Running backend learning-day migration and protocol regression suite."
ctest --test-dir "$backend_build_dir" --output-on-failure --no-tests=error \
  -R '^(test_database_migrator|test_v21_learning_day_contract_fixtures)$'
"$backend_event_test" testLearningDaysConvergeValidateAndProjectByContract

log "Running frontend learning-day pull reconciliation and bootstrap-preservation scenarios."
"$frontend_reconciler_binary" remoteLearningDaysConvergeWithoutOutboxFeedbackAndRejectOtherAccount
"$frontend_bootstrap_binary" \
  restoresBootstrapStateForFreeCoreRepositories \
  pendingLearningDaySurvivesBootstrapAndAdoptsCanonicalIdentity

log "Cross-system learning-day synchronization scenario complete."
