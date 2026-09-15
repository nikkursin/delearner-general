# V2-16 — Frontend Design Alignment

**Status:** Done
**Workspace:** frontend + root  
**Dependencies:** existing V2 sync/authentication baseline; V2-17 for new synchronized Word/Group semantics

## Objective

Align the currently implemented free vocabulary product with the supplied target designs while preserving existing architecture, data flow and working behavior outside the described UI/product changes.

## In scope

- modern responsive bottom-navigation shell;
- first-run loading/onboarding flow;
- Add/Edit Word redesign;
- reusable multi-group selection popup/component;
- Groups list/create/edit redesign;
- Group Details and word actions;
- Words list/search/filter/sort redesign;
- Word Details/Edit Word redesign;
- loading/skeleton, empty and lightweight feedback states shown in the supplied references.

## Global UI constraints

- Reference frames were designed around iPhone 14/15 Pro proportions, but implementation must not hard-code those dimensions.
- Use responsive/flexible QML containers, safe-area handling and scrolling so layouts remain usable on supported iOS phones, Android phones and tablet-sized displays.
- Preserve existing managers, repositories, navigation ownership and domain flow unless a task explicitly changes them.
- Do not introduce unrelated refactors or redesign unrelated screens.
- Use the packaged screenshots as the implementation source. Figma/MCP access is not required unless a material detail is missing.
- Placeholder logo/illustration areas in onboarding remain placeholders.
- Quiz, authentication/login and Settings/Profile redesign are out of scope and deferred to V2-18.

## Cross-system boundary

The visual references introduce product semantics that cannot be implemented safely as frontend-only changes. V2-17 owns the synchronized domain changes, including:

- up to four groups per word;
- new/normalized word-form fields;
- Phrase as a word type where contract changes are required;
- group icon metadata;
- sync/bootstrap/reconciliation coverage.

V2-16 must consume those semantics rather than implementing a second frontend-only representation.

## Acceptance gate

- New screens match the supplied visual intent without fixed iPhone-only coordinates.
- Existing free-core behavior outside these changes remains functional.
- UI state that is device-local remains local.
- Domain mutations still follow the transactional local-first/outbox model.
- No Quiz, login or Settings redesign is introduced incidentally.
