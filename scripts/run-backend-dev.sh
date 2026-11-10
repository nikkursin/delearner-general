#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
compose_file="$root_dir/docker-compose.yml"
backend_dir="$root_dir/delearner-backend"
api_origin="${DELEARNER_API_BASE_URL:-http://127.0.0.1:${DELEARNER_BACKEND_HOST_PORT:-8080}}"

backend_revision="$(git -C "$backend_dir" rev-parse HEAD)"
if [[ -n "$(git -C "$backend_dir" status --short --untracked-files=normal)" ]]; then
  backend_revision="${backend_revision}-dirty"
fi
export DELEARNER_BACKEND_REVISION="$backend_revision"

docker compose -f "$compose_file" build backend
docker compose -f "$compose_file" up -d --force-recreate backend

health_status=""
for _ in {1..30}; do
  health_status="$(curl --silent --output /dev/null --write-out '%{http_code}' "$api_origin/health" || true)"
  if [[ "$health_status" == "200" ]]; then
    break
  fi
  sleep 1
done

if [[ "$health_status" != "200" ]]; then
  echo "Backend health check failed at $api_origin/health (HTTP ${health_status:-unreachable})." >&2
  exit 1
fi

container_id="$(docker compose -f "$compose_file" ps -q backend)"
if [[ -z "$container_id" ]]; then
  echo "Backend container is not running." >&2
  exit 1
fi

running_revision="$(docker inspect --format '{{ index .Config.Labels "org.opencontainers.image.revision" }}' "$container_id")"
if [[ "$running_revision" != "$backend_revision" ]]; then
  echo "Backend revision mismatch: expected $backend_revision, running ${running_revision:-unlabeled}." >&2
  exit 1
fi

probe_body="$(mktemp)"
trap 'rm -f "$probe_body"' EXIT
probe_status="$(curl --silent --show-error --output "$probe_body" --write-out '%{http_code}' \
  --request POST \
  --header 'Content-Type: application/json' \
  --data '{}' \
  "$api_origin/api/v1/auth/sign-out")"

if [[ "$probe_status" != "401" ]]; then
  echo "Sign-out route probe expected HTTP 401 without a session, got HTTP $probe_status." >&2
  exit 1
fi

image_id="$(docker inspect --format '{{.Image}}' "$container_id")"
echo "Backend ready: revision=$backend_revision build_dir=/app/build binary=/app/de_backend image=$image_id api_origin=$api_origin sign_out_probe=401"
