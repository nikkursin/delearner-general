#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/common.sh"
if [[ $# -gt 0 ]]; then
  fail "Usage: tests/bootstrap_recovery_regression_gate.sh"
fi
require_command ctest "Build both child repositories with ./scripts/build-all.sh all first."
# Require each suite separately: a missing registration must fail, not disappear
# behind another matching test. Child projects remain authoritative for builds.
for suite in TestBootstrapStateRestorer TestSyncCoordinator TestAppStateAuthBootstrap; do
  ctest --test-dir "$(child_build_dir frontend)" --output-on-failure --no-tests=error -R "^${suite}$"
done
ctest --test-dir "$(child_build_dir backend)" --output-on-failure --no-tests=error -R '^test_event_characterization$'
log "Bootstrap/rebootstrap regression gate passed."
