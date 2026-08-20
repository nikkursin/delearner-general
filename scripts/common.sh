#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="${DELEARNER_BUILD_ROOT:-$ROOT_DIR/build}"
CONTRACT_VERSION_BASELINE_FILE="$ROOT_DIR/contracts/version-baseline.env"

if [[ -s "$CONTRACT_VERSION_BASELINE_FILE" ]]; then
  source "$CONTRACT_VERSION_BASELINE_FILE"
else
  printf '[delearner] ERROR: Missing contract version baseline: %s\n' "$CONTRACT_VERSION_BASELINE_FILE" >&2
  exit 1
fi

log() {
  printf '[delearner] %s\n' "$*"
}

fail() {
  printf '[delearner] ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  local command_name="$1"
  local install_hint="$2"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    fail "Required command '$command_name' was not found. $install_hint"
  fi
}

ensure_submodule_ready() {
  local name="$1"
  local path="$2"

  if [[ ! -d "$path/.git" && ! -f "$path/.git" ]]; then
    fail "$name submodule is not initialized at $path. Run ./scripts/bootstrap.sh first."
  fi

  if [[ ! -s "$path/CMakeLists.txt" ]]; then
    fail "$name submodule at $path does not expose CMakeLists.txt. Check the pinned submodule revision."
  fi
}

child_source_dir() {
  case "$1" in
    frontend) printf '%s\n' "$ROOT_DIR/delearner-frontend" ;;
    backend) printf '%s\n' "$ROOT_DIR/delearner-backend" ;;
    *) fail "Unknown child repository '$1'. Expected frontend, backend, or all." ;;
  esac
}

child_build_dir() {
  case "$1" in
    frontend) printf '%s\n' "$BUILD_ROOT/delearner-frontend" ;;
    backend) printf '%s\n' "$BUILD_ROOT/delearner-backend" ;;
    *) fail "Unknown child repository '$1'. Expected frontend, backend, or all." ;;
  esac
}

expand_targets() {
  local target="${1:-all}"

  case "$target" in
    all) printf '%s\n' frontend backend ;;
    frontend|backend) printf '%s\n' "$target" ;;
    *) fail "Unknown target '$target'. Expected frontend, backend, or all." ;;
  esac
}
