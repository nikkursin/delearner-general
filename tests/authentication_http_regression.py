#!/usr/bin/env python3
"""Exercise a running backend backed by a disposable test database.

Creates a unique test account and vocabulary; does not delete it. Never use a
production endpoint. Credentials remain in memory and are not printed.
"""
import argparse
import copy
import json
from pathlib import Path
import urllib.error
import urllib.request
import uuid


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--base-url', required=True)
    args = parser.parse_args()

    observed_request_ids = []

    def request(label, path, expected, data=None, token=None):
        request_id = f'v2-19-05c-{label}-{uuid.uuid4()}'
        headers = {
            'Content-Type': 'application/json',
            'X-Request-ID': request_id,
        }
        if token:
            headers['Authorization'] = 'Bearer ' + token
        req = urllib.request.Request(
            args.base_url.rstrip('/') + path,
            data=json.dumps(data).encode() if data is not None else None,
            headers=headers)
        try:
            response = urllib.request.urlopen(req, timeout=10)
        except urllib.error.HTTPError as error:
            response = error
        with response:
            body = json.load(response)
            assert response.status == expected, f'{path}: expected {expected}, got {response.status}'
            echoed_request_id = response.headers.get('X-Request-ID')
            assert echoed_request_id == request_id, (
                f'{path}: expected X-Request-ID {request_id}, got {echoed_request_id}')
        observed_request_ids.append(request_id)
        print(f'PASS {label}: HTTP {expected} request_id={request_id}')
        return body

    credentials = {'email': str(uuid.uuid4()) + '@example.test', 'password': str(uuid.uuid4())}
    registered = request('registration-success', '/api/v1/auth/register', 201, credentials)
    duplicate = request('registration-duplicate', '/api/v1/auth/register', 409,
                        dict(credentials, email=' ' + credentials['email'].upper() + ' '))
    assert duplicate['error'] == 'email_already_registered'
    invalid_credentials = request(
        'sign-in-invalid', '/api/v1/auth/sign-in', 401,
        dict(credentials, password='wrong-password'))
    assert invalid_credentials['error'] == 'invalid_credentials'
    signed_in = request('sign-in-success', '/api/v1/auth/sign-in', 200, credentials)
    assert signed_in['userId'] == registered['userId']
    token = signed_in['sessionToken']
    owner = signed_in['userId']
    first_token = registered['sessionToken']
    signed_out = request('sign-out-presented-session', '/api/v1/auth/sign-out', 200, {}, first_token)
    assert signed_out['signedOut'] is True
    revoked = request('sign-out-revoked-token', '/bootstrap', 401, token=first_token)
    assert revoked['error'] == 'invalid_session'
    still_valid = request('sign-out-other-session-valid', '/bootstrap', 200, token=token)
    assert still_valid['state']['words'] == []
    print('PASS sign out revoked only the presented session')
    device = str(uuid.uuid4())
    rejected_device = request(
        'device-rejected', '/api/v1/devices/register', 400,
        {'deviceId': 'not-a-uuid'}, token)
    assert rejected_device['error'] == 'invalid_device_id'
    request('device-success', '/api/v1/devices/register', 201, {'deviceId': device}, token)
    empty = request('bootstrap-empty', '/bootstrap', 200, token=token)
    assert empty['state']['words'] == []
    assert empty['state']['groups'] == []
    empty_pull = request(
        'pull-empty', '/events?after=' + str(empty['serverSequence']), 200, token=token)
    assert empty_pull['events'] == []
    assert empty_pull['nextSequence'] == empty['serverSequence']

    fixtures_path = Path(__file__).resolve().parents[1] / 'contracts/fixtures/v2/word-and-group-events.json'
    fixtures = json.loads(fixtures_path.read_text())['fixtures']
    group = next(x for x in fixtures if x['name'] == 'group_create_full_state_with_portable_icon')
    word = next(x for x in fixtures if x['name'] == 'noun_create_with_four_groups')
    for event in (group, word):
        event['entityId'] = str(uuid.uuid4())
        event['payload']['id'] = event['entityId']
    word['payload']['group_ids'] = [group['entityId']]
    for event in (group, word):
        event['eventId'] = str(uuid.uuid4())
        event['deviceId'] = device
        event['payload']['ownerUserId'] = owner
        event['baseVersion'] = 0
        event['occurredAt'] = 1768466100
        event.pop('context', None)
    uploaded = request('upload-accepted', '/events', 200, {'events': [group, word]}, token)
    assert len(uploaded['accepted']) == 2 and not uploaded['rejected']

    rejected_group = copy.deepcopy(group)
    rejected_group['eventId'] = str(uuid.uuid4())
    rejected_group['entityId'] = str(uuid.uuid4())
    rejected_group['payload']['id'] = rejected_group['entityId']
    rejected_group['payload']['icon_key'] = 'INVALID ICON'
    rejected_upload = request(
        'upload-rejected', '/events', 200, {'events': [rejected_group]}, token)
    assert not rejected_upload['accepted']
    assert len(rejected_upload['rejected']) == 1
    assert rejected_upload['rejected'][0]['reason'] == 'invalid_icon_key'

    incremental = request(
        'pull-incremental', '/events?after=' + str(empty['serverSequence']), 200, token=token)
    assert len(incremental['events']) == 2
    assert incremental['nextSequence'] == uploaded['accepted'][-1]['serverSequence']
    assert incremental['hasMore'] is False

    acknowledged = request(
        'cursor-acknowledged', '/events/cursor', 200,
        {'deviceId': device, 'consumedSequence': incremental['nextSequence']}, token)
    assert acknowledged['deviceId'] == device
    assert acknowledged['syncCursor'] == incremental['nextSequence']

    populated = request('bootstrap-populated', '/bootstrap', 200, token=token)
    assert len(populated['state']['words']) == 1
    assert len(populated['state']['groups']) == 1
    assert populated['state']['words'][0]['group_ids'] == [group['entityId']]
    caught_up = request(
        'pull-caught-up', '/events?after=' + str(populated['serverSequence']), 200, token=token)
    assert caught_up['events'] == []
    assert caught_up['nextSequence'] == populated['serverSequence']
    assert len(observed_request_ids) == len(set(observed_request_ids))
    print('PASS empty and populated account bootstrap')
    print(f'PASS correlated HTTP matrix: {len(observed_request_ids)} unique request IDs')


if __name__ == '__main__':
    main()
