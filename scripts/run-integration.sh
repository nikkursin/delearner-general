#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

usage() {
  cat <<'EOF'
Usage: ./scripts/run-integration.sh

Runs the currently available root integration smoke gate. The Version 2
integration suite will grow as authenticated sync behavior lands.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 0 ]]; then
  usage >&2
  fail "run-integration.sh does not accept positional arguments."
fi

log "Running root environment smoke gate."
"$ROOT_DIR/tests/root_environment_smoke.sh"

if command -v docker >/dev/null 2>&1; then
  log "Validating Docker Compose integration configuration."
  docker compose --env-file "$ROOT_DIR/.env.example" -f "$ROOT_DIR/docker-compose.yml" config >/dev/null
else
  log "Docker is unavailable; skipped Compose configuration validation."
fi

log "Integration smoke gate complete."
