#!/usr/bin/env bash

set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT

python3 "$root_dir/scripts/verify-version-compatibility.py" >/dev/null

mkdir -p \
  "$temporary_dir/contracts/fixtures/v1" \
  "$temporary_dir/contracts/fixtures/v2" \
  "$temporary_dir/delearner-frontend/src/Managers" \
  "$temporary_dir/delearner-frontend/src/Sync" \
  "$temporary_dir/delearner-backend/src/persistence"
cp "$root_dir/contracts/version-baseline.env" "$temporary_dir/contracts/version-baseline.env"
cp "$root_dir/contracts/fixtures/v1/"*.json "$temporary_dir/contracts/fixtures/v1/"
cp "$root_dir/contracts/fixtures/v2/"*.json "$temporary_dir/contracts/fixtures/v2/"
cp "$root_dir/delearner-frontend/src/Managers/DLDatabaseManager.cpp" \
  "$temporary_dir/delearner-frontend/src/Managers/DLDatabaseManager.cpp"
cp "$root_dir/delearner-frontend/src/Sync/DLSyncEventSerializer.cpp" \
  "$temporary_dir/delearner-frontend/src/Sync/DLSyncEventSerializer.cpp"
cp "$root_dir/delearner-backend/src/persistence/DLDatabaseSchemaVersion.cpp" \
  "$temporary_dir/delearner-backend/src/persistence/DLDatabaseSchemaVersion.cpp"

sed -i.bak 's/kSqliteSchemaMinor = 4/kSqliteSchemaMinor = 5/' \
  "$temporary_dir/delearner-frontend/src/Managers/DLDatabaseManager.cpp"
if python3 "$root_dir/scripts/verify-version-compatibility.py" --root "$temporary_dir" \
  >"$temporary_dir/version-output" 2>"$temporary_dir/version-error"; then
  echo "expected mismatched frontend schema to fail" >&2
  exit 1
fi
grep -q "SQLite schema mismatch" "$temporary_dir/version-error"
grep -q "pin a compatible child revision" "$temporary_dir/version-error"

healthy_payload="$temporary_dir/healthy.json"
printf '%s\n' \
  '{"status":"ok","timestamp":1,"postgresSchemaVersion":{"major":1,"minor":4,"version":"1.4"}}' \
  >"$healthy_payload"
python3 "$root_dir/scripts/verify-backend-health.py" \
  --url "file://$healthy_payload" \
  --expected-postgres-schema 1.4 \
  --timeout-seconds 1 >/dev/null

incompatible_payload="$temporary_dir/incompatible.json"
printf '%s\n' \
  '{"status":"ok","timestamp":1,"postgresSchemaVersion":{"major":1,"minor":1,"version":"1.1"}}' \
  >"$incompatible_payload"
if python3 "$root_dir/scripts/verify-backend-health.py" \
  --url "file://$incompatible_payload" \
  --expected-postgres-schema 1.4 \
  --timeout-seconds 0.1 \
  >"$temporary_dir/health-output" 2>"$temporary_dir/health-error"; then
  echo "expected incompatible live schema to fail" >&2
  exit 1
fi
grep -q "PostgreSQL schema is '1.1'" "$temporary_dir/health-error"
grep -q "docker compose logs backend postgres" "$temporary_dir/health-error"

grep -q 'validate_contract_fixtures.py' "$root_dir/scripts/smoke-gate.sh"
grep -q 'verify-version-compatibility.py' "$root_dir/scripts/smoke-gate.sh"
grep -q 'verify-backend-health.py' "$root_dir/scripts/smoke-gate.sh"
grep -q 'test-all.sh" frontend' "$root_dir/scripts/smoke-gate.sh"
grep -q 'test-all.sh" backend' "$root_dir/scripts/smoke-gate.sh"
