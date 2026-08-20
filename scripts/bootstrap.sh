#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

usage() {
  cat <<'EOF'
Usage: ./scripts/bootstrap.sh

Initializes the pinned frontend/backend submodules for root coordination work.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 0 ]]; then
  usage >&2
  fail "bootstrap.sh does not accept positional arguments."
fi

require_command git "Install Git, then retry from the repository root."

[[ -s "$ROOT_DIR/.gitmodules" ]] || fail "Missing .gitmodules; this root repository cannot initialize child repos."

log "Initializing pinned submodules."
git -C "$ROOT_DIR" submodule update --init --recursive

ensure_submodule_ready "frontend" "$ROOT_DIR/delearner-frontend"
ensure_submodule_ready "backend" "$ROOT_DIR/delearner-backend"

if [[ ! -f "$ROOT_DIR/.env" && -f "$ROOT_DIR/.env.example" ]]; then
  log "No .env file found. Copy .env.example to .env before running local integration services."
fi

log "Bootstrap complete."
