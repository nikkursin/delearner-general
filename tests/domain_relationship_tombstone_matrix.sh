#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/common.sh"
if [[ $# -ne 0 ]]; then
  fail "Usage: tests/domain_relationship_tombstone_matrix.sh"
fi
require_command cmake "Install CMake and the child Qt prerequisites."
build_dir="$BUILD_ROOT/domain-matrix"
cmake -S "$ROOT_DIR/tests/domain_matrix" -B "$build_dir" -DCMAKE_BUILD_TYPE="${BUILD_TYPE:-Debug}"
cmake --build "$build_dir" --target domain_matrix --parallel "${CMAKE_BUILD_PARALLEL_LEVEL:-4}"
ctest --test-dir "$build_dir" --output-on-failure
