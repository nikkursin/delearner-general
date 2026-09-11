#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/common.sh"

backend_source="$ROOT_DIR/delearner-backend/tests/test_event_characterization.cpp"
frontend_outbox_source="$ROOT_DIR/delearner-frontend/tests/TestTransactionalOutbox.cpp"
frontend_reconciler_source="$ROOT_DIR/delearner-frontend/tests/TestRemoteChangeReconciler.cpp"
frontend_bootstrap_source="$ROOT_DIR/delearner-frontend/tests/TestBootstrapStateRestorer.cpp"

for source_file in "$backend_source" "$frontend_outbox_source" "$frontend_reconciler_source" "$frontend_bootstrap_source"; do
  test -s "$source_file"
done

grep -q "testQuizReviewStatsPropagateWithoutSessionHistory" "$backend_source"
grep -q "quizAnswerCreatesReviewStatsOnlySyncEvent" "$frontend_outbox_source"
grep -q "remoteReviewStatsPayloadReconcilesWithoutOutboxFeedback" "$frontend_reconciler_source"
grep -q "restoresBootstrapStateForFreeCoreRepositories" "$frontend_bootstrap_source"

if [[ $# -eq 0 ]]; then
  exit 0
fi

if [[ $# -ne 1 || "$1" != "--run" ]]; then
  fail "Usage: tests/review_stats_quiz_sync_scenario.sh [--run]"
fi

backend_test="$(child_build_dir backend)/tests/test_event_characterization"
frontend_outbox_test="$(child_build_dir frontend)/tests/TestTransactionalOutbox"
frontend_reconciler_test="$(child_build_dir frontend)/tests/TestRemoteChangeReconciler"
frontend_bootstrap_test="$(child_build_dir frontend)/tests/TestBootstrapStateRestorer"

for test_binary in "$backend_test" "$frontend_outbox_test" "$frontend_reconciler_test" "$frontend_bootstrap_test"; do
  if [[ ! -x "$test_binary" ]]; then
    fail "Missing compiled scenario test: $test_binary. Run ./scripts/build-all.sh all first."
  fi
done

log "Running frontend local quiz-to-review-statistics outbox scenario."
"$frontend_outbox_test" quizAnswerCreatesReviewStatsOnlySyncEvent

log "Running backend review-statistics propagation and storage-boundary scenario."
"$backend_test" testQuizReviewStatsPropagateWithoutSessionHistory

log "Running frontend review-statistics reconciliation scenario."
"$frontend_reconciler_test" remoteReviewStatsPayloadReconcilesWithoutOutboxFeedback

log "Running frontend review-statistics bootstrap-restore scenario."
"$frontend_bootstrap_test" restoresBootstrapStateForFreeCoreRepositories

log "Review-statistics quiz synchronization scenario complete."
