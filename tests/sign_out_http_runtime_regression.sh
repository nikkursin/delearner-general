#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
api_origin="${DELEARNER_API_BASE_URL:-http://127.0.0.1:${DELEARNER_BACKEND_HOST_PORT:-8080}}"

if [[ "${DELEARNER_SKIP_BACKEND_START:-0}" != "1" ]]; then
  "$root_dir/scripts/run-backend-dev.sh"
fi

backend_revision="$(git -C "$root_dir/delearner-backend" rev-parse HEAD)"
container_id="$(docker compose -f "$root_dir/docker-compose.yml" ps -q backend)"

if [[ -z "$container_id" ]]; then
  echo "Backend container is not running." >&2
  exit 1
fi

image_id="$(docker inspect --format '{{.Image}}' "$container_id")"
running_revision="$(docker inspect --format '{{ index .Config.Labels "org.opencontainers.image.revision" }}' "$container_id")"
echo "runtime checkout_revision=$backend_revision running_revision=${running_revision:-unlabeled} build_dir=/app/build binary=/app/de_backend image=$image_id api_origin=$api_origin"

python3 "$root_dir/tests/authentication_http_regression.py" --base-url "$api_origin"
