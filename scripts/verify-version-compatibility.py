#!/usr/bin/env python3
"""Verify that root compatibility baselines match the pinned child revisions."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Dict, Match


class CompatibilityError(ValueError):
    pass


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError as exc:
        raise CompatibilityError(f"cannot read required compatibility source {path}: {exc}") from exc


def parse_baseline(path: Path) -> Dict[str, str]:
    values: Dict[str, str] = {}
    for line in read_text(path).splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if "=" not in stripped:
            raise CompatibilityError(f"invalid baseline entry in {path}: {stripped}")
        key, value = stripped.split("=", 1)
        values[key] = value
    return values


def require_value(values: Dict[str, str], key: str, path: Path) -> str:
    value = values.get(key, "")
    if not value:
        raise CompatibilityError(f"missing {key} in {path}")
    return value


def require_match(pattern: str, text: str, description: str, path: Path) -> Match[str]:
    match = re.search(pattern, text, re.MULTILINE | re.DOTALL)
    if not match:
        raise CompatibilityError(
            f"could not determine {description} from {path}; the pinned child version declaration may have changed"
        )
    return match


def assert_equal(actual: str, expected: str, label: str, source: Path) -> None:
    if actual != expected:
        raise CompatibilityError(
            f"{label} mismatch: pinned child reports {actual}, root baseline expects {expected} "
            f"({source}). Update the root baseline intentionally or pin a compatible child revision."
        )


def verify(root: Path) -> None:
    baseline_path = root / "contracts" / "version-baseline.env"
    frontend_schema_path = root / "delearner-frontend" / "src" / "Managers" / "DLDatabaseManager.cpp"
    frontend_contract_path = root / "delearner-frontend" / "src" / "Sync" / "DLSyncEventSerializer.cpp"
    backend_schema_path = root / "delearner-backend" / "src" / "persistence" / "DLDatabaseSchemaVersion.cpp"
    baseline = parse_baseline(baseline_path)
    sqlite_version = require_value(baseline, "DELEARNER_SQLITE_SCHEMA_VERSION", baseline_path)
    postgres_version = require_value(baseline, "DELEARNER_POSTGRESQL_SCHEMA_VERSION", baseline_path)
    contract_version = require_value(baseline, "DELEARNER_SYNC_API_CONTRACT_VERSION", baseline_path)
    route_major = require_value(baseline, "DELEARNER_SYNC_API_ROUTE_MAJOR", baseline_path)
    fixture_dir = root / "contracts" / "fixtures" / f"v{require_value(baseline, 'DELEARNER_SYNC_API_CONTRACT_MAJOR', baseline_path)}"

    sqlite_expected = "{}.{}".format(
        require_value(baseline, "DELEARNER_SQLITE_SCHEMA_MAJOR", baseline_path),
        require_value(baseline, "DELEARNER_SQLITE_SCHEMA_MINOR", baseline_path),
    )
    postgres_expected = "{}.{}".format(
        require_value(baseline, "DELEARNER_POSTGRESQL_SCHEMA_MAJOR", baseline_path),
        require_value(baseline, "DELEARNER_POSTGRESQL_SCHEMA_MINOR", baseline_path),
    )
    contract_expected = "{}.{}".format(
        require_value(baseline, "DELEARNER_SYNC_API_CONTRACT_MAJOR", baseline_path),
        require_value(baseline, "DELEARNER_SYNC_API_CONTRACT_MINOR", baseline_path),
    )
    assert_equal(sqlite_version, sqlite_expected, "root SQLite version fields", baseline_path)
    assert_equal(postgres_version, postgres_expected, "root PostgreSQL version fields", baseline_path)
    assert_equal(contract_version, contract_expected, "root sync/API version fields", baseline_path)
    assert_equal(
        route_major,
        "/api/v{}".format(require_value(baseline, "DELEARNER_SYNC_API_CONTRACT_MAJOR", baseline_path)),
        "root API route major",
        baseline_path,
    )

    frontend_schema = read_text(frontend_schema_path)
    sqlite_major = require_match(
        r"constexpr\s+int\s+kSqliteSchemaMajor\s*=\s*(\d+)\s*;",
        frontend_schema,
        "frontend SQLite schema major",
        frontend_schema_path,
    ).group(1)
    sqlite_minor = require_match(
        r"constexpr\s+int\s+kSqliteSchemaMinor\s*=\s*(\d+)\s*;",
        frontend_schema,
        "frontend SQLite schema minor",
        frontend_schema_path,
    ).group(1)
    assert_equal(f"{sqlite_major}.{sqlite_minor}", sqlite_version, "SQLite schema", frontend_schema_path)

    backend_schema = read_text(backend_schema_path)
    backend_match = require_match(
        r"DLDatabaseSchemaVersion::postgresBaseline\s*\(\s*\)\s*\{.*?return\s*\{\s*(\d+)\s*,\s*(\d+)\s*\}\s*;",
        backend_schema,
        "backend PostgreSQL schema baseline",
        backend_schema_path,
    )
    assert_equal(
        f"{backend_match.group(1)}.{backend_match.group(2)}",
        postgres_version,
        "PostgreSQL schema",
        backend_schema_path,
    )

    frontend_contract = read_text(frontend_contract_path)
    contract_match = require_match(
        r"kContractVersion\s*=\s*QStringLiteral\s*\(\s*\"(\d+\.\d+)\"\s*\)",
        frontend_contract,
        "frontend sync/API contract version",
        frontend_contract_path,
    )
    assert_equal(contract_match.group(1), contract_version, "sync/API contract", frontend_contract_path)

    fixture_paths = sorted(fixture_dir.glob("*.json"))
    if not fixture_paths:
        raise CompatibilityError(f"no shared contract fixtures found in {fixture_dir}")
    for fixture_path in fixture_paths:
        try:
            fixture = json.loads(read_text(fixture_path))
        except json.JSONDecodeError as exc:
            raise CompatibilityError(f"invalid JSON in {fixture_path}: {exc}") from exc
        assert_equal(str(fixture.get("contractVersion", "")), contract_version, "fixture contract version", fixture_path)
        assert_equal(str(fixture.get("apiRouteMajor", "")), route_major, "fixture API route major", fixture_path)

    print(
        "Pinned compatibility versions match: "
        f"SQLite {sqlite_version}, PostgreSQL {postgres_version}, sync/API {contract_version} ({route_major}); "
        f"checked {len(fixture_paths)} fixture sets."
    )


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="Coordination repository root. Defaults to the parent of scripts/.",
    )
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    try:
        verify(args.root.resolve())
    except CompatibilityError as exc:
        print(f"compatibility check failed: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
