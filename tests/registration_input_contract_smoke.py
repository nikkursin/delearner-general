#!/usr/bin/env python3
"""Validate the root-owned V2-21 registration input fixture."""

from __future__ import annotations

import json
import sys
from pathlib import Path


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    path = root / "contracts" / "fixtures" / "v1" / "registration-input-contract.json"
    data = json.loads(path.read_text(encoding="utf-8"))

    require(data["fixtureSet"] == "delearner.auth.v1.registration-input", "unexpected fixture set")
    require(data["apiRoute"] == "/api/v1/auth/register", "unexpected registration route")
    require(data["requestFields"]["required"] == ["email", "password"], "required request fields changed")
    require(data["requestFields"]["optional"] == ["displayName"], "optional request fields changed")
    require(data["requestFields"]["clientOnly"] == ["repeatPassword"], "client-only fields changed")
    require("repeatPassword" not in data["requestFields"]["required"], "repeat password entered request")
    require("repeatPassword" not in data["requestFields"]["optional"], "repeat password entered request")

    require(data["errorCodes"] == {
        "displayName": "invalid_display_name",
        "email": "invalid_email",
        "password": "weak_password",
        "duplicateEmail": "email_already_registered",
    }, "stable registration error codes changed")

    fields = data["fields"]
    require(set(fields) == {"displayName", "email", "password"}, "unexpected fixture fields")
    require(fields["displayName"]["optionalAtApiBoundary"] is True, "display name must remain optional")
    require(fields["displayName"]["minimumCharacters"] == 2, "display-name minimum changed")
    require(fields["displayName"]["maximumCharacters"] == 80, "display-name maximum changed")
    require(fields["email"]["minimumCharacters"] == 3, "email minimum changed")
    require(fields["email"]["maximumCharacters"] == 254, "email maximum changed")
    require(fields["password"]["minimumCharacters"] == 8, "password minimum changed")
    require(fields["password"]["maximumCharacters"] == 128, "password maximum changed")
    require(fields["password"]["passphraseMinimumCharacters"] == 12, "passphrase minimum changed")
    require(fields["password"]["transformBeforeHashing"] is False, "password transformation enabled")

    ids: set[str] = set()
    for field_name, field in fields.items():
        for classification in ("valid", "invalid"):
            cases = field[classification]
            require(cases, f"{field_name}.{classification} must not be empty")
            for case in cases:
                require(isinstance(case.get("id"), str) and case["id"], "case id is required")
                require(case["id"] not in ids, f"duplicate case id: {case['id']}")
                ids.add(case["id"])
                require(isinstance(case.get("value"), str), f"{case['id']} value must be a string")

    for case in fields["displayName"]["valid"]:
        require(case["stored"] == case["value"].strip(), f"{case['id']} trim result differs")
    for case in fields["email"]["valid"]:
        require(case["normalized"] == case["value"].strip().casefold(), f"{case['id']} normalization differs")

    print(f"validated {len(ids)} registration input cases from {path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, KeyError, json.JSONDecodeError) as exc:
        print(f"registration input contract validation failed: {exc}", file=sys.stderr)
        raise SystemExit(1)
