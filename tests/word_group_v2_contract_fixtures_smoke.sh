#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_dir="$root_dir/contracts/fixtures/v2"

python3 "$root_dir/contracts/validate_contract_fixtures.py" \
  --fixture-dir "$fixture_dir" \
  --fixture-files word-and-group-events.json >/dev/null

python3 - "$root_dir" "$fixture_dir/word-and-group-events.json" <<'PY'
import copy
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
root = Path(sys.argv[1])
fixture_path = Path(sys.argv[2])
sys.path.insert(0, str(root / "contracts"))

from validate_contract_fixtures import ContractError, validate_event

data = json.loads(fixture_path.read_text(encoding="utf-8"))
assert data["fixtureSet"] == "delearner.sync.v2.word-and-group-events"
assert data["contractVersion"] == "2.0"
assert data["apiRouteMajor"] == "/api/v2"

fixtures = data["fixtures"]
word_events = [item for item in fixtures if item["entityType"] == "word"]
group_events = [item for item in fixtures if item["entityType"] == "group"]
assert {item["payload"]["part_of_speech"] for item in word_events} == {
    "noun", "verb", "adjective", "adverb", "phrase"
}
assert any(len(item["payload"]["group_ids"]) == 0 for item in word_events)
assert any(len(item["payload"]["group_ids"]) == 4 for item in word_events)
assert all("group_id" not in item["payload"] for item in word_events)
assert all(item["payload"]["icon_key"] for item in group_events)

plural_only = next(item for item in word_events if item["payload"]["article"] == "plural_only")
assert plural_only["payload"]["plural_form"] is None


def assert_rejected(event, expected_message):
    try:
        validate_event(event, "2.0")
    except ContractError as exc:
        assert expected_message in str(exc), str(exc)
    else:
        raise AssertionError(f"invalid event was accepted: {expected_message}")


too_many = copy.deepcopy(word_events[0])
too_many["payload"]["group_ids"].append("7fc4f0b9-1169-47bf-965e-b2db7c04992e")
assert_rejected(too_many, "at most four")

duplicate = copy.deepcopy(word_events[0])
duplicate["payload"]["group_ids"][1] = duplicate["payload"]["group_ids"][0]
assert_rejected(duplicate, "unique UUIDs")

plural_form = copy.deepcopy(plural_only)
plural_form["payload"]["plural_form"] = "Leute"
assert_rejected(plural_form, "must be null")

legacy_other = copy.deepcopy(word_events[0])
legacy_other["payload"]["part_of_speech"] = "Andere"
assert_rejected(legacy_other, "unsupported")

platform_icon = copy.deepcopy(group_events[0])
platform_icon["payload"]["icon_key"] = "qrc:/ios/travel.svg"
assert_rejected(platform_icon, "portable lowercase catalog key")
PY
