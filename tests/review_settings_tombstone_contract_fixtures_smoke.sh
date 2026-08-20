#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_file="$root_dir/contracts/fixtures/v1/review-settings-and-tombstone-events.json"

python3 - "$fixture_file" <<'PY'
import json
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path

fixture_path = Path(sys.argv[1])
data = json.loads(fixture_path.read_text(encoding="utf-8"))

assert data["fixtureSet"] == "delearner.sync.v1.review-settings-and-tombstone-events"
assert data["contractVersion"] == "1.0"
assert data["apiRouteMajor"] == "/api/v1"

fixtures = data["fixtures"]
assert len(fixtures) == 8
assert {(item["entityType"], item["operation"]) for item in fixtures} == {
    ("word_review_stats", "create"),
    ("word_review_stats", "update"),
    ("app_setting", "create"),
    ("app_setting", "update"),
    ("group", "delete"),
    ("word", "delete"),
    ("word_review_stats", "delete"),
    ("app_setting", "delete"),
}

review_required_fields = {
    "word_id",
    "ownerUserId",
    "correct_answers",
    "wrong_answers",
    "last_reviewed_at",
    "ease_factor",
    "interval_days",
    "due_at",
    "created_at",
    "updated_at",
}
setting_required_fields = {
    "id",
    "ownerUserId",
    "setting_key",
    "setting_value",
    "value_type",
    "scope",
    "created_at",
    "updated_at",
}
tombstone_required_fields = {
    "entity_type",
    "entity_id",
    "ownerUserId",
    "deletedAt",
    "updatedAt",
}
tombstone_allowed_fields = tombstone_required_fields | {"word_id", "setting_key"}
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
dead_payload_fields = {
    "german_word",
    "native_translation",
    "name",
    "color_hex",
    "correct_answers",
    "wrong_answers",
    "setting_value",
}


def assert_uuid(value):
    assert isinstance(value, str)
    uuid.UUID(value)


def assert_timestamp(value):
    assert isinstance(value, str)
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    assert parsed.tzinfo is not None
    assert parsed.utcoffset() == timezone.utc.utcoffset(parsed)


def assert_no_forbidden_fields(mapping):
    assert forbidden_sync_fields.isdisjoint(mapping.keys())


for item in fixtures:
    assert item["operation"] in {"create", "update", "delete"}
    assert item["entityType"] in {"word", "group", "word_review_stats", "app_setting"}
    assert_uuid(item["eventId"])
    assert_uuid(item["deviceId"])
    assert_uuid(item["entityId"])
    assert_timestamp(item["updatedAt"])

    context = item["context"]
    assert_uuid(context["authenticatedUserId"])

    if item["operation"] in {"create", "update"}:
        assert "payload" in item
        assert "tombstone" not in item
        payload = item["payload"]
        assert_no_forbidden_fields(payload)
        assert_uuid(payload["ownerUserId"])
        assert payload["ownerUserId"] == context["authenticatedUserId"]
        assert payload["updated_at"] == item["updatedAt"]
        assert_timestamp(payload["created_at"])
        assert_timestamp(payload["updated_at"])

        if item["entityType"] == "word_review_stats":
            assert review_required_fields <= payload.keys()
            assert_uuid(payload["word_id"])
            assert payload["word_id"] == item["entityId"]
            assert isinstance(payload["correct_answers"], int)
            assert isinstance(payload["wrong_answers"], int)
            assert payload["correct_answers"] >= 0
            assert payload["wrong_answers"] >= 0
            assert isinstance(payload["ease_factor"], (int, float))
            assert isinstance(payload["interval_days"], int)
            assert_timestamp(payload["last_reviewed_at"])
            assert_timestamp(payload["due_at"])
        else:
            assert item["entityType"] == "app_setting"
            assert setting_required_fields <= payload.keys()
            assert_uuid(payload["id"])
            assert payload["id"] == item["entityId"]
            assert payload["scope"] == "account_learning"
            assert payload["setting_key"].startswith("learning.")
            assert payload["value_type"] in {"string", "integer", "boolean", "json"}
    else:
        assert "tombstone" in item
        assert "payload" not in item
        tombstone = item["tombstone"]
        assert tombstone_required_fields <= tombstone.keys()
        assert set(tombstone.keys()) <= tombstone_allowed_fields
        assert_no_forbidden_fields(tombstone)
        assert dead_payload_fields.isdisjoint(tombstone.keys())
        assert tombstone["entity_type"] == item["entityType"]
        assert tombstone["entity_id"] == item["entityId"]
        assert tombstone["ownerUserId"] == context["authenticatedUserId"]
        assert tombstone["deletedAt"] == item["updatedAt"]
        assert tombstone["updatedAt"] == item["updatedAt"]
        assert_timestamp(tombstone["deletedAt"])
        assert_timestamp(tombstone["updatedAt"])

        if item["entityType"] == "word_review_stats":
            assert tombstone["word_id"] == item["entityId"]
        if item["entityType"] == "app_setting":
            assert tombstone["setting_key"].startswith("learning.")
PY
