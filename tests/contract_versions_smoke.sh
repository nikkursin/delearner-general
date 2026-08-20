#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$root_dir/scripts/common.sh"

required_vars=(
  DELEARNER_SQLITE_SCHEMA_MAJOR
  DELEARNER_SQLITE_SCHEMA_MINOR
  DELEARNER_SQLITE_SCHEMA_VERSION
  DELEARNER_POSTGRESQL_SCHEMA_MAJOR
  DELEARNER_POSTGRESQL_SCHEMA_MINOR
  DELEARNER_POSTGRESQL_SCHEMA_VERSION
  DELEARNER_SYNC_API_CONTRACT_MAJOR
  DELEARNER_SYNC_API_CONTRACT_MINOR
  DELEARNER_SYNC_API_CONTRACT_VERSION
  DELEARNER_SYNC_API_ROUTE_MAJOR
  DELEARNER_VERSION_BASELINES_INDEPENDENT
  DELEARNER_COMPAT_SAME_MAJOR_INTEROPERATES
  DELEARNER_COMPAT_MINOR_BACKWARD_COMPATIBLE
  DELEARNER_COMPAT_UNKNOWN_OPTIONAL_FIELDS
  DELEARNER_COMPAT_UNKNOWN_REQUIRED_SEMANTICS
)

for name in "${required_vars[@]}"; do
  test -n "${!name:-}"
done

assert_version_family() {
  local label="$1"
  local major="$2"
  local minor="$3"
  local version="$4"

  [[ "$major" =~ ^[0-9]+$ ]]
  [[ "$minor" =~ ^[0-9]+$ ]]
  [[ "$version" =~ ^[0-9]+[.][0-9]+$ ]]
  [[ "$version" == "$major.$minor" ]]

  case "$label" in
    sqlite|postgresql|sync-api) ;;
    *) return 1 ;;
  esac
}

assert_version_family \
  sqlite \
  "$DELEARNER_SQLITE_SCHEMA_MAJOR" \
  "$DELEARNER_SQLITE_SCHEMA_MINOR" \
  "$DELEARNER_SQLITE_SCHEMA_VERSION"

assert_version_family \
  postgresql \
  "$DELEARNER_POSTGRESQL_SCHEMA_MAJOR" \
  "$DELEARNER_POSTGRESQL_SCHEMA_MINOR" \
  "$DELEARNER_POSTGRESQL_SCHEMA_VERSION"

assert_version_family \
  sync-api \
  "$DELEARNER_SYNC_API_CONTRACT_MAJOR" \
  "$DELEARNER_SYNC_API_CONTRACT_MINOR" \
  "$DELEARNER_SYNC_API_CONTRACT_VERSION"

[[ "$DELEARNER_VERSION_BASELINES_INDEPENDENT" == "true" ]]
[[ "$DELEARNER_COMPAT_SAME_MAJOR_INTEROPERATES" == "true" ]]
[[ "$DELEARNER_COMPAT_MINOR_BACKWARD_COMPATIBLE" == "true" ]]
[[ "$DELEARNER_COMPAT_UNKNOWN_OPTIONAL_FIELDS" == "ignore" ]]
[[ "$DELEARNER_COMPAT_UNKNOWN_REQUIRED_SEMANTICS" == "reject" ]]
[[ "$DELEARNER_SYNC_API_ROUTE_MAJOR" == "/api/v$DELEARNER_SYNC_API_CONTRACT_MAJOR" ]]

"$root_dir/scripts/contract-diagnostics.sh" | grep -q "SQLite schema: $DELEARNER_SQLITE_SCHEMA_VERSION"
