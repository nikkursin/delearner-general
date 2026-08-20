#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 "$root_dir/contracts/validate_contract_fixtures.py" \
  --fixture-dir "$root_dir/contracts/fixtures/v1" >/dev/null
