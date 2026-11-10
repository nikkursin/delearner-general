#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_files=(
  ".env.example"
  ".gitignore"
  "docker-compose.yml"
)

for path in "${required_files[@]}"; do
  test -s "$root_dir/$path"
done

grep -q '^[.]env$' "$root_dir/.gitignore"
grep -q '^![.]env.example$' "$root_dir/.gitignore"
grep -q "postgres:" "$root_dir/docker-compose.yml"
grep -q "backend:" "$root_dir/docker-compose.yml"
grep -q "POSTGRES_PASSWORD=change_me_for_local_dev" "$root_dir/.env.example"
grep -q "docker compose up -d postgres" "$root_dir/README.md"
grep -q "./scripts/run-backend-dev.sh" "$root_dir/README.md"
grep -q "DELEARNER_BACKEND_REVISION" "$root_dir/docker-compose.yml"

if command -v docker >/dev/null 2>&1; then
  docker compose --env-file "$root_dir/.env.example" -f "$root_dir/docker-compose.yml" config >/dev/null
fi
