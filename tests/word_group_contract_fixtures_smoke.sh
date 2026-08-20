#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_file="$root_dir/contracts/fixtures/v1/word-and-group-events.json"

python3 - "$fixture_file" <<'PY'
import json
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path

fixture_path = Path(sys.argv[1])
data = json.loads(fixture_path.read_text(encoding="utf-8"))

assert data["fixtureSet"] == "delearner.sync.v1.word-and-group-events"
assert data["contractVersion"] == "1.0"
assert data["apiRouteMajor"] == "/api/v1"

fixtures = data["fixtures"]
assert len(fixtures) == 4
assert {(item["entityType"], item["operation"]) for item in fixtures} == {
    ("group", "create"),
    ("group", "update"),
    ("word", "create"),
    ("word", "update"),
}

word_required_fields = {
    "id",
    "ownerUserId",
    "german_word",
    "normalized_german_word",
    "article",
    "part_of_speech",
    "native_translation",
    "normalized_native_translation",
    "example_phrase_de",
    "example_phrase_native",
    "group_id",
    "notes",
    "plural_form",
    "praeteritum_form",
    "partizip_ii_form",
    "positive_form",
    "comparative_form",
    "superlative_form",
    "created_at",
    "updated_at",
}
group_required_fields = {
    "id",
    "ownerUserId",
    "name",
    "color_hex",
    "created_at",
    "updated_at",
}
forbidden_sync_fields = {
    "quiz_session_id",
    "quiz_history",
    "raw_quiz_history",
    "question_history",
    "answers",
    "theme",
    "navigation_state",
    "transient_filters",
    "search_query",
    "layout_state",
    "window_state",
    "device_preferences",
}


def assert_uuid(value):
    assert isinstance(value, str)
    uuid.UUID(value)


def assert_timestamp(value):
    assert isinstance(value, str)
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    assert parsed.tzinfo is not None
    assert parsed.utcoffset() == timezone.utc.utcoffset(parsed)


group_ids = {
    item["entityId"]
    for item in fixtures
    if item["entityType"] == "group"
}

for item in fixtures:
    assert item["operation"] in {"create", "update"}
    assert item["entityType"] in {"word", "group"}
    assert_uuid(item["eventId"])
    assert_uuid(item["deviceId"])
    assert_uuid(item["entityId"])
    assert_timestamp(item["updatedAt"])

    context = item["context"]
    payload = item["payload"]
    assert forbidden_sync_fields.isdisjoint(payload.keys())
    assert_uuid(context["authenticatedUserId"])
    assert_uuid(payload["id"])
    assert_uuid(payload["ownerUserId"])
    assert payload["id"] == item["entityId"]
    assert payload["ownerUserId"] == context["authenticatedUserId"]
    assert payload["updated_at"] == item["updatedAt"]
    assert_timestamp(payload["created_at"])
    assert_timestamp(payload["updated_at"])

    if item["entityType"] == "word":
        assert word_required_fields <= payload.keys()
        assert_uuid(payload["group_id"])
        assert payload["group_id"] in group_ids
        assert payload["german_word"]
        assert payload["native_translation"]
    else:
        assert group_required_fields <= payload.keys()
        assert payload["name"]
        assert payload["color_hex"].startswith("#")
PY
