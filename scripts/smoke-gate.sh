#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

usage() {
  cat <<'EOF'
Usage: ./scripts/smoke-gate.sh

Runs the Version 2 root contract and fresh-environment smoke gate:
  - validates pinned schema/contract versions and shared fixtures;
  - validates and starts the Docker Compose backend environment;
  - verifies live backend health and PostgreSQL schema compatibility;
  - delegates to the frontend and backend CTest entry points.

Environment:
  DELEARNER_BACKEND_HEALTH_URL            Health URL; defaults to the configured localhost port.
  DELEARNER_SMOKE_HEALTH_TIMEOUT_SECONDS  Maximum health wait; defaults to 60 seconds.
  DELEARNER_SMOKE_SKIP_COMPOSE_START      Set to true only when checking an already-running backend.
  DELEARNER_BUILD_ROOT                    Root-owned child build output directory, default ./build.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 0 ]]; then
  usage >&2
  fail "smoke-gate.sh does not accept positional arguments."
fi

require_command git "Install Git and initialize this checkout before running the smoke gate."
require_command python3 "Install Python 3 to validate shared contract fixtures and health output."
require_command cmake "Install CMake and the child repository prerequisites."
require_command ctest "Install CTest/CMake and the child repository prerequisites."

ensure_submodule_ready "frontend" "$ROOT_DIR/delearner-frontend"
ensure_submodule_ready "backend" "$ROOT_DIR/delearner-backend"

log "Checking pinned schema and contract compatibility."
"$ROOT_DIR/scripts/contract-diagnostics.sh"
python3 "$ROOT_DIR/scripts/verify-version-compatibility.py"

log "Validating shared Version 2 contract fixtures."
python3 "$ROOT_DIR/contracts/validate_contract_fixtures.py" \
  --fixture-dir "$ROOT_DIR/contracts/fixtures/v1"
"$ROOT_DIR/tests/auth_behavior_contract_smoke.sh"

compose_file="$ROOT_DIR/docker-compose.yml"
compose_env="$ROOT_DIR/.env.example"
if [[ "${DELEARNER_SMOKE_SKIP_COMPOSE_START:-false}" != "true" ]]; then
  require_command docker "Install and start Docker, then retry the fresh-environment smoke gate."
  if ! docker info >/dev/null 2>&1; then
    fail "Docker is installed but its daemon is unavailable. Start Docker, then retry."
  fi

  log "Validating Docker Compose configuration."
  if ! docker compose --env-file "$compose_env" -f "$compose_file" config >/dev/null; then
    fail "Docker Compose configuration is invalid. Check $compose_file and $compose_env."
  fi

  log "Starting PostgreSQL and the pinned backend image."
  if ! docker compose --env-file "$compose_env" -f "$compose_file" up -d --build backend; then
    fail "Backend integration services failed to start. Inspect: docker compose logs backend postgres"
  fi
fi

backend_port="${DELEARNER_BACKEND_HOST_PORT:-8080}"
health_url="${DELEARNER_BACKEND_HEALTH_URL:-http://127.0.0.1:${backend_port}/health}"
health_timeout="${DELEARNER_SMOKE_HEALTH_TIMEOUT_SECONDS:-60}"

log "Checking live backend health at $health_url."
python3 "$ROOT_DIR/scripts/verify-backend-health.py" \
  --url "$health_url" \
  --expected-postgres-schema "$DELEARNER_POSTGRESQL_SCHEMA_VERSION" \
  --timeout-seconds "$health_timeout"

log "Running the pinned frontend test entry point."
"$ROOT_DIR/scripts/test-all.sh" frontend

log "Running the pinned backend test entry point."
"$ROOT_DIR/scripts/test-all.sh" backend

log "Contract and environment smoke gate passed."
