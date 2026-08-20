# DE Vocab Learner — Version 4 and Later Scope

## Purpose

Keep future scope visible without prematurely turning it into implementation commitments.

Only Version 2 and Version 3 should be decomposed into detailed executable backlogs now. Later versions remain milestone-level until the preceding product foundation is stable.

## Version 4 — Payments and Entitlements

### Goal

Introduce monetization/account entitlement infrastructure on top of the stable free product.

### Planned scope direction

- Apple native in-app subscriptions;
- Google Play native subscriptions;
- RevenueCat as preferred subscription normalization layer;
- backend-canonical effective entitlement;
- account-level entitlement across devices;
- cached premium entitlement for offline use;
- disable premium after more than 48 hours without valid backend payment confirmation;
- preserve free core regardless of premium validation state;
- cancellation keeps premium until paid entitlement expiry;
- premium-only derived data retention for 30 days after premium becomes inactive;
- duplicate-subscription avoidance where practical;
- provider/store transaction metadata and entitlement reconciliation;
- payment/account UX defined in Figma before meaningful implementation.

### Out of scope unless separately selected

- broad premium feature bundle;
- sharing;
- public/community content;
- web payments.

## Version 5 — First Premium Learning Value

### Goal

Ship a deliberately selected set of premium learning features that justify the entitlement system.

### Candidate pool

- advanced statistics;
- advanced spaced repetition;
- advanced quiz modes;
- AI-generated examples/explanations/content;
- grammar/media features;
- higher configurable limits.

Before Version 5 implementation, run a separate product-prioritization pass and select a small coherent subset. Do not implement the entire candidate pool by default.

## Version 6 — Cross-User Sharing

### Goal

Introduce explicit sharing without collaborative-editing complexity.

### Initial sharing model

- share individual words;
- share groups;
- recipient receives an independent copy;
- copied entity becomes recipient-owned;
- subsequent edits do not propagate automatically;
- ownership already exists in backend domain model from earlier versions.

### Explicit non-goals

- public publishing feed;
- automatic community contribution;
- shared live object ownership;
- collaborative simultaneous editing.

## Version 7+ — Expanded Learning Platform

Potential later directions:

- richer grammar training;
- attachment/media library;
- more advanced AI-assisted learning;
- deeper analytics;
- further cross-user features;
- live collaboration only after explicit product decision;
- additional platforms/desktop refinement if product priority justifies it.

These are intentionally not committed tasks.

## Rule for Promoting Future Scope

A future feature becomes executable work only when:

1. the preceding version foundation is stable;
2. product intent is explicit;
3. meaningful user-facing flows are represented in Figma where required;
4. canonical docs are updated if architecture/data contracts change;
5. root acceptance criteria are written before frontend/backend implementation starts.
