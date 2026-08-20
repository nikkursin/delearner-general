#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

usage() {
  cat <<'EOF'
Usage: ./scripts/build-all.sh [all|frontend|backend]

Configures and builds child repositories through their own CMake projects.

Environment:
  BUILD_TYPE                    CMake build type, default Debug.
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

require_command cmake "Install CMake and the child repository prerequisites, then retry."

build_type="${BUILD_TYPE:-Debug}"
target="${1:-all}"

log "Using V2 baselines: SQLite $DELEARNER_SQLITE_SCHEMA_VERSION, PostgreSQL $DELEARNER_POSTGRESQL_SCHEMA_VERSION, sync/API $DELEARNER_SYNC_API_CONTRACT_VERSION."

configure_and_build_child() {
  local child="$1"
  local source_dir
  local build_dir
  source_dir="$(child_source_dir "$child")"
  build_dir="$(child_build_dir "$child")"

  ensure_submodule_ready "$child" "$source_dir"

  log "Configuring $child in $build_dir."
  generator_args=()
  if [[ -n "${CMAKE_GENERATOR:-}" ]]; then
    generator_args=(-G "$CMAKE_GENERATOR")
  elif command -v ninja >/dev/null 2>&1; then
    generator_args=(-G Ninja)
  fi

  if ! cmake -S "$source_dir" -B "$build_dir" "${generator_args[@]}" -DCMAKE_BUILD_TYPE="$build_type"; then
    fail "$child configure failed. Install the prerequisites documented in $source_dir/README.md and retry."
  fi

  log "Building $child."
  build_command=(cmake --build "$build_dir")
  if [[ -n "${CMAKE_BUILD_PARALLEL_LEVEL:-}" ]]; then
    build_command+=(--parallel "$CMAKE_BUILD_PARALLEL_LEVEL")
  else
    build_command+=(--parallel)
  fi

  if ! "${build_command[@]}"; then
    fail "$child build failed. The child repository CMake project remains authoritative for build details."
  fi
}

while IFS= read -r child; do
  configure_and_build_child "$child"
done < <(expand_targets "$target")

log "Build complete."
