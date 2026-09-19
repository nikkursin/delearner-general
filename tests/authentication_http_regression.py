#!/usr/bin/env python3
"""Exercise a running backend backed by a disposable test database.

Creates a unique test account and vocabulary; does not delete it. Never use a
production endpoint. Credentials remain in memory and are not printed.
"""
import argparse
import json
from pathlib import Path
import urllib.error
import urllib.request
import uuid


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--base-url', required=True)
    args = parser.parse_args()

    def request(path, expected, data=None, token=None):
        headers = {'Content-Type': 'application/json'}
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
        print(f'PASS {path}: HTTP {expected}')
        return body

    credentials = {'email': str(uuid.uuid4()) + '@example.test', 'password': str(uuid.uuid4())}
    registered = request('/api/v1/auth/register', 201, credentials)
    duplicate = request('/api/v1/auth/register', 409,
                        dict(credentials, email=' ' + credentials['email'].upper() + ' '))
    assert duplicate['error'] == 'email_already_registered'
    request('/api/v1/auth/sign-in', 401, dict(credentials, password='wrong-password'))
    signed_in = request('/api/v1/auth/sign-in', 200, credentials)
    assert signed_in['userId'] == registered['userId']
    token = signed_in['sessionToken']
    owner = signed_in['userId']
    device = str(uuid.uuid4())
    request('/api/v1/devices/register', 201, {'deviceId': device}, token)
    empty = request('/bootstrap', 200, token=token)
    assert empty['state']['words'] == []
    assert empty['state']['groups'] == []
    request('/events?after=' + str(empty['serverSequence']), 200, token=token)

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
    uploaded = request('/events', 200, {'events': [group, word]}, token)
    assert len(uploaded['accepted']) == 2 and not uploaded['rejected']
    populated = request('/bootstrap', 200, token=token)
    assert len(populated['state']['words']) == 1
    assert len(populated['state']['groups']) == 1
    assert populated['state']['words'][0]['group_ids'] == [group['entityId']]
    request('/events?after=' + str(populated['serverSequence']), 200, token=token)
    print('PASS empty and populated account bootstrap')


if __name__ == '__main__':
    main()
