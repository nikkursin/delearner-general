#!/usr/bin/env python3
"""Validate DE Learner sync contract fixtures and compatibility rules."""

from __future__ import annotations

import argparse
import copy
import json
import re
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


CONTRACT_PROFILES = {
    "1.0": "/api/v1",
    "2.0": "/api/v2",
}
SUPPORTED_CONTRACT_MAJORS = {int(version.split(".")[0]) for version in CONTRACT_PROFILES}

KNOWN_REQUIRED_SEMANTICS: set[str] = set()

FIXTURE_FILES = (
    "word-and-group-events.json",
    "review-settings-and-tombstone-events.json",
)

EXPECTED_OPERATIONS = {
    "word-and-group-events.json": {
        ("group", "create"),
        ("group", "update"),
        ("word", "create"),
        ("word", "update"),
    },
    "review-settings-and-tombstone-events.json": {
        ("word_review_stats", "create"),
        ("word_review_stats", "update"),
        ("app_setting", "create"),
        ("app_setting", "update"),
        ("group", "delete"),
        ("word", "delete"),
        ("word_review_stats", "delete"),
        ("app_setting", "delete"),
    },
}

PAYLOAD_REQUIRED_FIELDS = {
    "group": {
        "id",
        "ownerUserId",
        "name",
        "color_hex",
        "created_at",
        "updated_at",
    },
    "word": {
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
    },
    "word_review_stats": {
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
    },
    "app_setting": {
        "id",
        "ownerUserId",
        "setting_key",
        "setting_value",
        "value_type",
        "scope",
        "created_at",
        "updated_at",
    },
}

V2_WORD_REQUIRED_FIELDS = (
    PAYLOAD_REQUIRED_FIELDS["word"]
    .difference({"group_id"})
    .union({"group_ids", "literal_translation", "praesens_third_person_form"})
)
V2_GROUP_REQUIRED_FIELDS = PAYLOAD_REQUIRED_FIELDS["group"].union({"icon_key"})

V2_PARTS_OF_SPEECH = {"noun", "verb", "adjective", "adverb", "phrase"}
V2_NOUN_ARTICLES = {"der", "die", "das", "plural_only"}

TOMBSTONE_REQUIRED_FIELDS = {
    "entity_type",
    "entity_id",
    "ownerUserId",
    "deletedAt",
    "updatedAt",
}

FORBIDDEN_SYNC_FIELDS = {
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

DEAD_PAYLOAD_FIELDS = {
    "german_word",
    "native_translation",
    "name",
    "color_hex",
    "correct_answers",
    "wrong_answers",
    "setting_value",
}


class ContractError(ValueError):
    pass


def assert_condition(condition: bool, message: str) -> None:
    if not condition:
        raise ContractError(message)


def major(version: str) -> int:
    parts = version.split(".")
    assert_condition(len(parts) == 2 and all(part.isdigit() for part in parts), f"invalid version: {version}")
    return int(parts[0])


def assert_uuid(value: Any, field_name: str) -> None:
    assert_condition(isinstance(value, str), f"{field_name} must be a UUID string")
    try:
        uuid.UUID(value)
    except ValueError as exc:
        raise ContractError(f"{field_name} must be a UUID string") from exc


def assert_timestamp(value: Any, field_name: str) -> None:
    assert_condition(isinstance(value, str), f"{field_name} must be an ISO-8601 UTC timestamp")
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as exc:
        raise ContractError(f"{field_name} must be an ISO-8601 UTC timestamp") from exc
    assert_condition(parsed.tzinfo is not None, f"{field_name} must include timezone")
    assert_condition(parsed.utcoffset() == timezone.utc.utcoffset(parsed), f"{field_name} must be UTC")


def assert_no_forbidden_fields(mapping: dict[str, Any], context: str) -> None:
    overlap = sorted(FORBIDDEN_SYNC_FIELDS.intersection(mapping.keys()))
    assert_condition(not overlap, f"{context} contains non-sync fields: {', '.join(overlap)}")


def validate_required_semantics(event: dict[str, Any]) -> None:
    required_semantics = event.get("requiredSemantics", [])
    assert_condition(isinstance(required_semantics, list), "requiredSemantics must be a list when present")
    unknown = sorted(str(item) for item in required_semantics if item not in KNOWN_REQUIRED_SEMANTICS)
    assert_condition(not unknown, f"unknown required semantics: {', '.join(unknown)}")


def validate_payload(event: dict[str, Any], payload: dict[str, Any], fixture_version: str) -> None:
    entity_type = event["entityType"]
    if major(fixture_version) == 2 and entity_type == "word":
        required_fields = V2_WORD_REQUIRED_FIELDS
    elif major(fixture_version) == 2 and entity_type == "group":
        required_fields = V2_GROUP_REQUIRED_FIELDS
    else:
        required_fields = PAYLOAD_REQUIRED_FIELDS[entity_type]
    missing = sorted(required_fields.difference(payload.keys()))
    assert_condition(not missing, f"{event['name']} payload missing: {', '.join(missing)}")

    assert_no_forbidden_fields(payload, f"{event['name']} payload")
    assert_uuid(payload["ownerUserId"], f"{event['name']}.payload.ownerUserId")
    assert_condition(payload["ownerUserId"] == event["context"]["authenticatedUserId"], "payload owner must match authenticated user")
    assert_condition(payload["updated_at"] == event["updatedAt"], "payload.updated_at must match event.updatedAt")
    assert_timestamp(payload["created_at"], "payload.created_at")
    assert_timestamp(payload["updated_at"], "payload.updated_at")

    if entity_type in {"word", "group", "app_setting"}:
        assert_uuid(payload["id"], f"{event['name']}.payload.id")
        assert_condition(payload["id"] == event["entityId"], "payload.id must match entityId")

    if entity_type == "word":
        if major(fixture_version) == 2:
            group_ids = payload["group_ids"]
            assert_condition(isinstance(group_ids, list), "word.group_ids must be a list")
            assert_condition(len(group_ids) <= 4, "word.group_ids must contain at most four memberships")
            for group_id in group_ids:
                assert_uuid(group_id, "word.payload.group_ids[]")
            assert_condition(len(group_ids) == len(set(group_ids)), "word.group_ids must contain unique UUIDs")

            part_of_speech = payload["part_of_speech"]
            assert_condition(part_of_speech in V2_PARTS_OF_SPEECH, "word.part_of_speech is unsupported")
            article = payload["article"]
            if part_of_speech == "noun":
                assert_condition(article in V2_NOUN_ARTICLES, "noun.article is unsupported")
                if article == "plural_only":
                    assert_condition(payload["plural_form"] is None, "plural-only noun.plural_form must be null")
            else:
                assert_condition(article is None, "article must be null for non-nouns")
                assert_condition(payload["plural_form"] is None, "plural_form is only applicable to nouns")

            assert_condition(
                part_of_speech == "phrase" or payload["literal_translation"] is None,
                "literal_translation is only applicable to phrases",
            )
            verb_fields = ("praesens_third_person_form", "praeteritum_form", "partizip_ii_form")
            adjective_fields = ("positive_form", "comparative_form", "superlative_form")
            if part_of_speech != "verb":
                assert_condition(
                    all(payload[field] is None for field in verb_fields),
                    "verb forms are only applicable to verbs",
                )
            if part_of_speech != "adjective":
                assert_condition(
                    all(payload[field] is None for field in adjective_fields),
                    "comparison forms are only applicable to adjectives",
                )
        else:
            assert_condition(isinstance(payload["group_id"], str) or payload["group_id"] is None, "word.group_id must be UUID string or null")
            if payload["group_id"] is not None:
                assert_uuid(payload["group_id"], "word.payload.group_id")
        assert_condition(bool(payload["german_word"]), "word.german_word must not be empty")
        assert_condition(bool(payload["native_translation"]), "word.native_translation must not be empty")
    elif entity_type == "group":
        assert_condition(bool(payload["name"]), "group.name must not be empty")
        assert_condition(isinstance(payload["color_hex"], str) and payload["color_hex"].startswith("#"), "group.color_hex must be hex-like")
        if major(fixture_version) == 2:
            icon_key = payload["icon_key"]
            assert_condition(isinstance(icon_key, str) and bool(icon_key.strip()), "group.icon_key must be a non-empty stable key")
            assert_condition(
                re.fullmatch(r"[a-z0-9][a-z0-9._-]*", icon_key) is not None,
                "group.icon_key must be a portable lowercase catalog key",
            )
    elif entity_type == "word_review_stats":
        assert_uuid(payload["word_id"], "word_review_stats.word_id")
        assert_condition(payload["word_id"] == event["entityId"], "review stats word_id must match entityId")
        assert_condition(isinstance(payload["correct_answers"], int) and payload["correct_answers"] >= 0, "correct_answers must be non-negative int")
        assert_condition(isinstance(payload["wrong_answers"], int) and payload["wrong_answers"] >= 0, "wrong_answers must be non-negative int")
        assert_condition(isinstance(payload["ease_factor"], (int, float)), "ease_factor must be numeric")
        assert_condition(isinstance(payload["interval_days"], int), "interval_days must be int")
        assert_timestamp(payload["last_reviewed_at"], "last_reviewed_at")
        assert_timestamp(payload["due_at"], "due_at")
    elif entity_type == "app_setting":
        assert_condition(payload["scope"] == "account_learning", "app_setting.scope must be account_learning")
        assert_condition(str(payload["setting_key"]).startswith("learning."), "app_setting.setting_key must be account learning scoped")
        assert_condition(payload["value_type"] in {"string", "integer", "boolean", "json"}, "app_setting.value_type is unsupported")


def validate_tombstone(event: dict[str, Any], tombstone: dict[str, Any]) -> None:
    missing = sorted(TOMBSTONE_REQUIRED_FIELDS.difference(tombstone.keys()))
    assert_condition(not missing, f"{event['name']} tombstone missing: {', '.join(missing)}")
    assert_no_forbidden_fields(tombstone, f"{event['name']} tombstone")
    assert_condition(DEAD_PAYLOAD_FIELDS.isdisjoint(tombstone.keys()), "tombstone must not carry dead full payload fields")
    assert_condition(tombstone["entity_type"] == event["entityType"], "tombstone entity_type must match entityType")
    assert_condition(tombstone["entity_id"] == event["entityId"], "tombstone entity_id must match entityId")
    assert_condition(tombstone["ownerUserId"] == event["context"]["authenticatedUserId"], "tombstone owner must match authenticated user")
    assert_condition(tombstone["deletedAt"] == event["updatedAt"], "tombstone.deletedAt must match updatedAt")
    assert_condition(tombstone["updatedAt"] == event["updatedAt"], "tombstone.updatedAt must match updatedAt")
    assert_timestamp(tombstone["deletedAt"], "tombstone.deletedAt")
    assert_timestamp(tombstone["updatedAt"], "tombstone.updatedAt")

    if event["entityType"] == "word_review_stats":
        assert_condition(tombstone.get("word_id") == event["entityId"], "review stats tombstone word_id must match entityId")
    if event["entityType"] == "app_setting":
        assert_condition(str(tombstone.get("setting_key", "")).startswith("learning."), "setting tombstone key must be account learning scoped")


def validate_event(event: dict[str, Any], fixture_version: str) -> None:
    assert_condition(major(fixture_version) in SUPPORTED_CONTRACT_MAJORS, "fixture contract major is unsupported")
    validate_required_semantics(event)

    for field_name in ("name", "operation", "eventId", "deviceId", "entityType", "entityId", "updatedAt", "context"):
        assert_condition(field_name in event, f"event missing {field_name}")

    assert_condition(event["operation"] in {"create", "update", "delete"}, "unsupported operation")
    assert_condition(event["entityType"] in PAYLOAD_REQUIRED_FIELDS, "unsupported entity type")
    assert_uuid(event["eventId"], "eventId")
    assert_uuid(event["deviceId"], "deviceId")
    assert_uuid(event["entityId"], "entityId")
    assert_timestamp(event["updatedAt"], "updatedAt")

    context = event["context"]
    assert_condition(isinstance(context, dict), "context must be an object")
    assert_uuid(context.get("authenticatedUserId"), "context.authenticatedUserId")

    if event["operation"] in {"create", "update"}:
        assert_condition("payload" in event, "create/update events must include payload")
        assert_condition("tombstone" not in event, "create/update events must not include tombstone")
        payload = event["payload"]
        assert_condition(isinstance(payload, dict), "payload must be object")
        validate_payload(event, payload, fixture_version)
    else:
        assert_condition("tombstone" in event, "delete events must include tombstone")
        assert_condition("payload" not in event, "delete events must not include payload")
        tombstone = event["tombstone"]
        assert_condition(isinstance(tombstone, dict), "tombstone must be object")
        validate_tombstone(event, tombstone)


def validate_fixture_set(path: Path) -> list[dict[str, Any]]:
    data = json.loads(path.read_text(encoding="utf-8"))
    fixture_version = data["contractVersion"]
    assert_condition(fixture_version in CONTRACT_PROFILES, f"{path.name} contractVersion is unsupported")
    assert_condition(
        data["apiRouteMajor"] == CONTRACT_PROFILES[fixture_version],
        f"{path.name} apiRouteMajor does not match contractVersion {fixture_version}",
    )

    fixtures = data["fixtures"]
    assert_condition(isinstance(fixtures, list) and fixtures, f"{path.name} must contain fixtures")
    expected = EXPECTED_OPERATIONS[path.name]
    actual = {(item.get("entityType"), item.get("operation")) for item in fixtures}
    assert_condition(actual == expected, f"{path.name} operations differ from canonical set")

    for event in fixtures:
        assert_condition(isinstance(event, dict), f"{path.name} fixture event must be object")
        validate_event(event, data["contractVersion"])

    return fixtures


def run_compatibility_probes(fixtures: list[dict[str, Any]], fixture_version: str) -> None:
    create_or_update = next(
        event
        for event in fixtures
        if event["entityType"] == "word" and event["operation"] in {"create", "update"}
    )

    optional_probe = copy.deepcopy(create_or_update)
    optional_probe["optionalClientMetadata"] = {"debugSource": "compatibility-probe"}
    optional_probe["payload"]["optionalExampleSource"] = "manual-entry"
    compatible_minor = f"{major(fixture_version)}.1"
    validate_event(optional_probe, compatible_minor)

    required_probe = copy.deepcopy(create_or_update)
    required_probe["requiredSemantics"] = ["server_assigned_entity_ids"]
    try:
        validate_event(required_probe, compatible_minor)
    except ContractError:
        pass
    else:
        raise ContractError("unknown required semantics must be rejected")

    major_probe = copy.deepcopy(create_or_update)
    incompatible_version = "2.0" if major(fixture_version) == 1 else "1.0"
    try:
        validate_event(major_probe, incompatible_version)
    except ContractError:
        pass
    else:
        raise ContractError("different major contract versions must be rejected")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--fixture-dir",
        type=Path,
        default=Path(__file__).resolve().parent / "fixtures" / "v1",
        help="Directory containing Version 1 contract fixture JSON files.",
    )
    parser.add_argument(
        "--fixture-files",
        nargs="+",
        choices=FIXTURE_FILES,
        default=list(FIXTURE_FILES),
        help="Fixture files to validate. Defaults to every canonical fixture file.",
    )
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    fixture_dir = args.fixture_dir.resolve()

    try:
        all_fixtures: list[dict[str, Any]] = []
        fixture_versions: set[str] = set()
        for file_name in args.fixture_files:
            path = fixture_dir / file_name
            assert_condition(path.is_file(), f"missing fixture file: {path}")
            all_fixtures.extend(validate_fixture_set(path))
            fixture_versions.add(json.loads(path.read_text(encoding="utf-8"))["contractVersion"])
        assert_condition(len(fixture_versions) == 1, "fixture files must use one contract version")
        run_compatibility_probes(all_fixtures, fixture_versions.pop())
    except (ContractError, KeyError, json.JSONDecodeError) as exc:
        print(f"contract fixture validation failed: {exc}", file=sys.stderr)
        return 1

    print(f"validated {len(all_fixtures)} contract fixtures from {fixture_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
