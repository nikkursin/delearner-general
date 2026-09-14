#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/common.sh"
[[ $# -eq 0 ]] || fail "Usage: tests/word_group_domain_regression_gate.sh"
require_command ctest "Build both children with ./scripts/build-all.sh all first."
# Each required suite must exist; a broad regex could silently omit coverage.
for suite in TestV2WordGroupContractFixtures TestWordRepository TestGroupRepository TestSyncEventSerializer TestTransactionalOutbox TestRemoteChangeReconciler; do
  ctest --test-dir "$(child_build_dir frontend)" --output-on-failure --no-tests=error -R "^${suite}$"
done
for suite in test_v2_word_group_contract_fixtures test_domain_repository test_sync_transaction_repository; do
  ctest --test-dir "$(child_build_dir backend)" --output-on-failure --no-tests=error -R "^${suite}$"
done
"$ROOT_DIR/tests/bootstrap_recovery_regression_gate.sh"
"$ROOT_DIR/tests/domain_relationship_tombstone_matrix.sh"
log "Word/Group cross-system regression gate passed."
