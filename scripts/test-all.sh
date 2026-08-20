#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

usage() {
  cat <<'EOF'
Usage: ./scripts/test-all.sh [all|root|frontend|backend]

Runs root smoke checks and delegates child repository tests to CTest.

Environment:
  BUILD_TYPE                    CMake build type used when configuring children, default Debug.
  DELEARNER_BUILD_ROOT          Root-owned build output directory, default ./build.
  CMAKE_GENERATOR               Optional CMake generator. Defaults to Ninja when available.
  CMAKE_BUILD_PARALLEL_LEVEL    Optional build parallelism.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 1 ]]; then
  usage >&2
  fail "Too many arguments."
fi

target="${1:-all}"

run_root_tests() {
  log "Running root smoke checks."
  "$ROOT_DIR/tests/root_entrypoints_smoke.sh"
  "$ROOT_DIR/tests/root_environment_smoke.sh"
  "$ROOT_DIR/tests/contract_versions_smoke.sh"
  "$ROOT_DIR/tests/word_group_contract_fixtures_smoke.sh"
  "$ROOT_DIR/tests/review_settings_tombstone_contract_fixtures_smoke.sh"
  "$ROOT_DIR/tests/contract_fixture_compatibility_smoke.sh"
}

run_child_tests() {
  local child="$1"
  local build_dir
  build_dir="$(child_build_dir "$child")"

  require_command ctest "Install CTest/CMake and the child repository prerequisites, then retry."
  "$ROOT_DIR/scripts/build-all.sh" "$child"

  log "Running $child CTest suite."
  if ! ctest --test-dir "$build_dir" --output-on-failure; then
    fail "$child tests failed. The child repository CTest configuration remains authoritative."
  fi
}

case "$target" in
  all)
    run_root_tests
    run_child_tests frontend
    run_child_tests backend
    ;;
  root)
    run_root_tests
    ;;
  frontend|backend)
    run_child_tests "$target"
    ;;
  *)
    usage >&2
    fail "Unknown target '$target'. Expected all, root, frontend, or backend."
    ;;
esac

log "Tests complete."
