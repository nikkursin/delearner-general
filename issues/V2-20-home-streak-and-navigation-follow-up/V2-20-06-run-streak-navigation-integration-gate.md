# V2-20-06 — Run streak and navigation integration gate

**Parent epic:** V2-20 — Home, Streak and Navigation Follow-up
**Status:** Planned
**Workspace:** root + backend + frontend
**Size:** 5 story points
**Dependencies:** V2-20-02, V2-20-03, V2-20-04, V2-20-05
**Figma requirement:** None

## Objective

Prove that learning days converge securely across devices and that the final
Home/Profile navigation matches the corrected product model.

## Required scenarios

- Device A completes a quiz offline, records today locally, reconnects and
  uploads exactly once.
- Device B bootstraps the same account and displays the same streak.
- Two devices complete the same date independently and converge to one day.
- Two devices contribute different consecutive dates and retain both.
- A missed date resets current streak without deleting history.
- Pending learning-day work survives 401, same-account reauthentication and
  re-bootstrap.
- Sign out/account switch cannot expose or upload the previous account's days.
- Authenticated startup opens Home; Profile opens only from Home; bottom
  navigation order and all routes remain stable.
- Sign out succeeds against the real HTTP route and revokes only the presented
  session.

## Acceptance criteria

- Root contract/integration tests exercise local → push → pull → bootstrap for
  learning days.
- Backend authorization and frontend isolation tests cover two accounts.
- Frontend tests cover the Home dog/card states, exact navigation order,
  Profile entry/return and retained Profile controls.
- Existing vocabulary, group, review-statistics, quiz and auth/sync regression
  suites pass.
- Canonical docs and schema/contract baselines match implementation.
- Compatible child commits are pinned by one root completion commit.
- Physical-device checks remain explicit manual evidence and are not claimed
  by automated tests.
