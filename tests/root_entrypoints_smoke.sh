#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_files=(
  "AGENTS.md"
  "CLAUDE.md"
  "README.md"
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
