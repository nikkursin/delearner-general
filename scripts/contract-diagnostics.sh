#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

usage() {
  cat <<'EOF'
Usage: ./scripts/contract-diagnostics.sh

Prints the root-owned Version 2 schema and sync/API contract baselines.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 0 ]]; then
  usage >&2
  fail "contract-diagnostics.sh does not accept positional arguments."
fi

cat <<EOF
Version 2 compatibility baselines
SQLite schema: $DELEARNER_SQLITE_SCHEMA_VERSION
PostgreSQL schema: $DELEARNER_POSTGRESQL_SCHEMA_VERSION
Sync/API contract: $DELEARNER_SYNC_API_CONTRACT_VERSION
Sync/API route major prefix: $DELEARNER_SYNC_API_ROUTE_MAJOR
Independent version families: $DELEARNER_VERSION_BASELINES_INDEPENDENT
Same-major interoperability: $DELEARNER_COMPAT_SAME_MAJOR_INTEROPERATES
Minor compatibility: $DELEARNER_COMPAT_MINOR_BACKWARD_COMPATIBLE
Unknown optional fields: $DELEARNER_COMPAT_UNKNOWN_OPTIONAL_FIELDS
Unknown required semantics: $DELEARNER_COMPAT_UNKNOWN_REQUIRED_SEMANTICS
EOF
