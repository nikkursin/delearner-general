#!/usr/bin/env python3
"""Wait for the backend health endpoint and verify its PostgreSQL schema."""

from __future__ import annotations

import argparse
import json
import sys
import time
import urllib.error
import urllib.request
from typing import Any, Dict


class HealthError(ValueError):
    pass


def validate(payload: Dict[str, Any], expected_schema: str) -> None:
    if payload.get("status") != "ok":
        raise HealthError(f"status is {payload.get('status')!r}, expected 'ok'")
    if not isinstance(payload.get("timestamp"), (int, float)) or payload["timestamp"] <= 0:
        raise HealthError("timestamp is missing or invalid")

    schema = payload.get("postgresSchemaVersion")
    if not isinstance(schema, dict):
        raise HealthError("postgresSchemaVersion is missing; backend may not have initialized PostgreSQL")
    if schema.get("version") != expected_schema:
        raise HealthError(
            f"PostgreSQL schema is {schema.get('version')!r}, root baseline expects {expected_schema!r}"
        )

    expected_parts = expected_schema.split(".")
    if len(expected_parts) != 2 or not all(part.isdigit() for part in expected_parts):
        raise HealthError(f"expected PostgreSQL schema {expected_schema!r} is not MAJOR.MINOR")
    if schema.get("major") != int(expected_parts[0]) or schema.get("minor") != int(expected_parts[1]):
        raise HealthError("PostgreSQL schema version string disagrees with its major/minor fields")


def fetch(url: str, request_timeout: float) -> Dict[str, Any]:
    with urllib.request.urlopen(url, timeout=request_timeout) as response:
        status_code = response.getcode()
        if status_code not in (None, 200):
            raise HealthError(f"HTTP status is {status_code}, expected 200")
        try:
            payload = json.loads(response.read().decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise HealthError(f"response is not valid JSON: {exc}") from exc
    if not isinstance(payload, dict):
        raise HealthError("response JSON must be an object")
    return payload


def wait_for_health(url: str, expected_schema: str, timeout_seconds: float) -> None:
    deadline = time.monotonic() + timeout_seconds
    last_error = "no request attempted"
    while True:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            break
        try:
            payload = fetch(url, min(5.0, max(0.1, remaining)))
            validate(payload, expected_schema)
            print(f"Backend health is ok at {url}; PostgreSQL schema {expected_schema} matches the root baseline.")
            return
        except (HealthError, OSError, urllib.error.URLError) as exc:
            last_error = str(exc)
            time.sleep(min(1.0, max(0.0, deadline - time.monotonic())))

    raise HealthError(
        f"backend did not become compatible at {url} within {timeout_seconds:g}s: {last_error}. "
        "Inspect `docker compose logs backend postgres` and verify the configured host port."
    )


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--url", required=True, help="Backend health endpoint URL.")
    parser.add_argument("--expected-postgres-schema", required=True, help="Expected MAJOR.MINOR schema version.")
    parser.add_argument("--timeout-seconds", type=float, default=60.0, help="Maximum wait time, default 60 seconds.")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    if args.timeout_seconds <= 0:
        print("backend health check failed: --timeout-seconds must be positive", file=sys.stderr)
        return 1
    try:
        wait_for_health(args.url, args.expected_postgres_schema, args.timeout_seconds)
    except HealthError as exc:
        print(f"backend health check failed: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
