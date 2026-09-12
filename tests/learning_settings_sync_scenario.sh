#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/common.sh"
PYTHONDONTWRITEBYTECODE=1 python3 - "$ROOT_DIR" <<'PY'
import json
import sys
from pathlib import Path
root = Path(sys.argv[1])
sys.path.insert(0, str(root / 'contracts'))
from validate_contract_fixtures import validate_event
scenario = json.loads((root / 'contracts/fixtures/v1/review-settings-and-tombstone-events.json').read_text())['learningSettingIdentityScenario']
events = scenario['mutations']
for event in events:
    validate_event(event, '1.0')
bodies = [event.get('payload', event.get('tombstone')) for event in events]
assert len({(body['ownerUserId'], body['setting_key']) for body in bodies}) == 1
assert events[0]['entityId'] == scenario['canonicalEntityId']
assert events[1]['entityId'] == events[2]['entityId'] != scenario['canonicalEntityId']
assert events[0]['deviceId'] != events[1]['deviceId']
print('Learning-setting logical identity fixtures passed.')
PY
if [[ $# -eq 0 ]]; then exit 0; fi
if [[ $# -ne 1 || "$1" != "--run" ]]; then
  fail "Usage: tests/learning_settings_sync_scenario.sh [--run]"
fi
backend_test="$(child_build_dir backend)/tests/test_event_characterization"
frontend_test="$(child_build_dir frontend)/tests/TestAppSettingRepository"
for binary in "$backend_test" "$frontend_test"; do
  [[ -x "$binary" ]] || fail "Missing compiled test: $binary. Run scripts/build-all.sh all."
done
"$backend_test" testLearningSettingsReconcileDifferentUuidsAndTombstones
"$frontend_test"
