#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_file="$root_dir/contracts/fixtures/v1/auth-behavior-contract.json"

python3 - "$fixture_file" <<'PY'
import json
import sys
from pathlib import Path

fixture_path = Path(sys.argv[1])
data = json.loads(fixture_path.read_text(encoding="utf-8"))

assert data["fixtureSet"] == "delearner.auth.v1.behavior-contract"
assert data["contractVersion"] == "1.0"
assert data["apiRouteMajor"] == "/api/v1"
assert data["minimumExecutableProvider"] == "email_password"
assert set(data["providerDirections"]) == {"apple", "google"}

identity_rules = data["identityRules"]
assert identity_rules["authenticatedUserSource"] == "session_credentials"
assert identity_rules["payloadUserIdAuthorization"] == "never_trusted"
assert identity_rules["providerIdentityMerge"] == "explicit_verified_link_only"
assert identity_rules["emailEqualityMerge"] == "forbidden"

states = {state["name"]: state for state in data["states"]}
assert set(states) == {
    "first_use_offline",
    "first_use_online_sign_in_success",
    "authenticated_session",
    "invalid_or_expired_session_online",
    "previously_authenticated_offline_reopen",
    "cross_account_access_attempt",
}

assert states["first_use_offline"]["priorSuccessfulAuthentication"] is False
assert states["first_use_offline"]["network"] == "offline"
assert states["first_use_offline"]["expectedState"] == "authentication_required"
assert states["first_use_offline"]["freeCoreAccess"] is False
assert states["first_use_offline"]["syncAccess"] is False

assert states["first_use_online_sign_in_success"]["network"] == "online"
assert states["first_use_online_sign_in_success"]["session"] == "valid"
assert states["first_use_online_sign_in_success"]["freeCoreAccess"] is True
assert states["first_use_online_sign_in_success"]["syncAccess"] is True

assert states["authenticated_session"]["priorSuccessfulAuthentication"] is True
assert states["authenticated_session"]["session"] == "valid"
assert states["authenticated_session"]["syncAccess"] is True

assert states["invalid_or_expired_session_online"]["expectedState"] == "reauthentication_required"
assert states["invalid_or_expired_session_online"]["freeCoreAccess"] is True
assert states["invalid_or_expired_session_online"]["syncAccess"] is False

offline_reopen = states["previously_authenticated_offline_reopen"]
assert offline_reopen["priorSuccessfulAuthentication"] is True
assert offline_reopen["network"] == "offline"
assert offline_reopen["expectedState"] == "offline_free_core"
assert offline_reopen["freeCoreAccess"] is True
assert offline_reopen["syncAccess"] is False

cross_account = states["cross_account_access_attempt"]
assert cross_account["session"] == "valid_for_user_a"
assert cross_account["payloadOwnerUser"] == "user_b"
assert cross_account["expectedState"] == "authorization_rejected"
assert cross_account["syncAccess"] is False

for state in states.values():
    assert isinstance(state["requiredBehavior"], str)
    assert state["requiredBehavior"]
PY
