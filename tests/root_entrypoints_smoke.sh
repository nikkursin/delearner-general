#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_files=(
  "AGENTS.md"
  "CLAUDE.md"
  "README.md"
  "scripts/common.sh"
  "scripts/bootstrap.sh"
  "scripts/build-all.sh"
  "scripts/contract-diagnostics.sh"
  "scripts/test-all.sh"
  "scripts/run-integration.sh"
  "contracts/version-baseline.env"
  "issues/00-VERSION-2-ISSUE-INDEX.md"
  "docs/00-SYSTEM-CONCEPT.md"
  "docs/01-SHARED-DATA-CONTRACT.md"
  "docs/02-SYNC-PROTOCOL.md"
  "docs/03-PRODUCT-ROADMAP.md"
  "docs/04-VERSION-2-PLAN.md"
  "docs/07-ISSUE-PLANNING-RULES.md"
)

for path in "${required_files[@]}"; do
  test -s "$root_dir/$path"
done

grep -q "Mandatory Reading Order" "$root_dir/AGENTS.md"
grep -q "issues/00-VERSION-2-ISSUE-INDEX.md" "$root_dir/README.md"
grep -q "AGENTS.md" "$root_dir/CLAUDE.md"

for path in \
  "scripts/bootstrap.sh" \
  "scripts/build-all.sh" \
  "scripts/contract-diagnostics.sh" \
  "scripts/test-all.sh" \
  "scripts/run-integration.sh"; do
  test -x "$root_dir/$path"
  "$root_dir/$path" --help >/dev/null
done

grep -q "git .*submodule update --init --recursive" "$root_dir/scripts/bootstrap.sh"
grep -q "cmake --build" "$root_dir/scripts/build-all.sh"
grep -q "ctest --test-dir" "$root_dir/scripts/test-all.sh"
grep -q "root_environment_smoke.sh" "$root_dir/scripts/run-integration.sh"
grep -q "DELEARNER_SYNC_API_CONTRACT_VERSION" "$root_dir/contracts/version-baseline.env"
