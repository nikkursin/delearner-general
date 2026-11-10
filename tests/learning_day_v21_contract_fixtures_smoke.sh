#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_dir="$root_dir/contracts/fixtures/v2.1"
fixture_file="$fixture_dir/learning-day-events.json"

PYTHONDONTWRITEBYTECODE=1 python3 "$root_dir/contracts/validate_contract_fixtures.py" \
  --fixture-dir "$fixture_dir" \
  --fixture-files learning-day-events.json >/dev/null

PYTHONDONTWRITEBYTECODE=1 python3 - "$root_dir" "$fixture_file" <<'PY'
import copy
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
fixture_path = Path(sys.argv[2])
sys.path.insert(0, str(root / "contracts"))

from validate_contract_fixtures import ContractError, validate_event

data = json.loads(fixture_path.read_text(encoding="utf-8"))
assert data["fixtureSet"] == "delearner.sync.v2.1.learning-day-events"
assert data["contractVersion"] == "2.1"
assert data["apiRouteMajor"] == "/api/v2"

events = {item["name"]: item for item in data["fixtures"]}
assert len(events) == 2
assert {item["entityType"] for item in events.values()} == {"learning_day"}
assert {item["operation"] for item in events.values()} == {"create"}

logical_keys = {
    (item["payload"]["ownerUserId"], item["payload"]["activity_date"])
    for item in events.values()
}
assert len(logical_keys) == 1
assert len({item["entityId"] for item in events.values()}) == 2
assert len({item["deviceId"] for item in events.values()}) == 2

convergence = data["sameDateConvergence"]
assert convergence["expectedCanonicalRowCount"] == 1
canonical_id = convergence["expectedCanonicalEntityId"]
assert events[convergence["firstAcceptedFixtureName"]]["entityId"] == canonical_id
assert {item["canonicalEntityId"] for item in convergence["acknowledgements"]} == {canonical_id}


def apply_overrides(event, overrides):
    for dotted_path, value in overrides.items():
        target = event
        parts = dotted_path.split(".")
        for part in parts[:-1]:
            target = target[part]
        target[parts[-1]] = value


for invalid in data["invalidFixtures"]:
    event = copy.deepcopy(events[invalid["sourceFixture"]])
    apply_overrides(event, invalid["overrides"])
    try:
        validate_event(event, data["contractVersion"])
    except ContractError as exc:
        assert invalid["expectedError"] in str(exc), (invalid["name"], str(exc))
    else:
        raise AssertionError(f"invalid learning-day fixture accepted: {invalid['name']}")

try:
    validate_event(copy.deepcopy(events["device_a_learning_day_create"]), "2.0")
except ContractError as exc:
    assert "requires sync contract 2.1" in str(exc)
else:
    raise AssertionError("contract 2.0 accepted a learning_day mutation")

bootstrap = data["bootstrapResponse"]
assert bootstrap["contractVersion"] == "2.1"
assert bootstrap["state"]["learningDays"] == [events["device_a_learning_day_create"]["payload"]]

incremental = data["incrementalResponse"]
assert [item["serverSequence"] for item in incremental["events"]] == [41, 42]
assert incremental["nextSequence"] == 42
assert all(
    item["entityId"] == canonical_id
    and item["payload"] == events["device_a_learning_day_create"]["payload"]
    for item in incremental["events"]
)

negotiation = data["readNegotiation"]
assert negotiation["omittedHeaderMeans"] == "2.0"
legacy = data["legacy20Projection"]
assert legacy["contractVersion"] == "2.0"
legacy_supported_types = {"word", "group", "word_review_stats", "app_setting"}
projected_events = [
    event for event in incremental["events"]
    if event["entityType"] in legacy_supported_types
]
assert legacy["incrementalEvents"] == projected_events == []
assert legacy["nextSequence"] == max(event["serverSequence"] for event in incremental["events"])
assert legacy["nextSequence"] == incremental["nextSequence"]
assert "learningDays" in legacy["bootstrapStateOmittedKeys"]
assert "bootstrap" in negotiation["upgradeRule"].lower()

baseline = {}
for line in (root / "contracts" / "version-baseline.env").read_text(encoding="utf-8").splitlines():
    line = line.strip()
    if line and not line.startswith("#"):
        key, value = line.split("=", 1)
        baseline[key] = value
assert baseline["DELEARNER_SQLITE_SCHEMA_VERSION"] == "1.5"
assert baseline["DELEARNER_SYNC_API_CONTRACT_VERSION"] == "2.1"
assert baseline["DELEARNER_V2_20_TARGET_SQLITE_SCHEMA_VERSION"] == "1.5"
assert baseline["DELEARNER_V2_20_TARGET_POSTGRESQL_SCHEMA_VERSION"] == "1.5"
assert baseline["DELEARNER_V2_20_TARGET_SYNC_API_CONTRACT_VERSION"] == "2.1"
assert baseline["DELEARNER_V2_20_TARGET_SYNC_API_ROUTE_MAJOR"] == "/api/v2"
PY
