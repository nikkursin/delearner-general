#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/common.sh"

[[ $# -eq 0 ]] || fail "Usage: tests/session_account_controls_regression_gate.sh"
require_command ctest "Build both children with ./scripts/build-all.sh all first."

for suite in TestAppStateAuthBootstrap TestProductionSettingsUi TestAuthSyncPresentationUi; do
  ctest --test-dir "$(child_build_dir frontend)" --output-on-failure --no-tests=error -R "^${suite}$"
done

ctest --test-dir "$(child_build_dir backend)" --output-on-failure --no-tests=error -R '^test_auth_service$'

log "Session recovery, sign-out, and account-isolation regression gate passed."
