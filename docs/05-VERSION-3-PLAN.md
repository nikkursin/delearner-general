# DE Vocab Learner — Version 3 Plan

## Version Goal

Align the authenticated/synchronized free product with the current approved Figma design and stabilize the complete free-core experience.

Version 3 is the design/product-quality milestone. It must build on Version 2 rather than replacing its architecture.

## Preconditions

- Version 2 release gate passed;
- authentication and device bootstrap are stable;
- supported personal data synchronizes end-to-end;
- root coordination repository and canonical docs are in use;
- current Figma file is available as the product/UX source for meaningful user-facing flows.

## Recommended Epic / Issue Order

### V3-01 — Figma vs Implementation Audit

**Scope**

- enumerate current product screens/flows;
- compare current implementation to current Figma;
- classify each discrepancy as:
  - implementation outdated;
  - Figma stale/ambiguous;
  - small local mismatch;
  - structurally impactful mismatch requiring user approval;
- produce a finite Version-3 implementation backlog.

**Acceptance criteria**

- no large UI rewrite begins from assumption alone;
- each planned screen change has a clear Figma/product basis;
- structural discrepancies are surfaced before implementation.

---

### V3-02 — Authentication and Account UX

**Scope**

- implement/align sign-in and required account-entry flow;
- first-launch online-auth requirement;
- offline-return behavior after successful auth;
- account/session error states;
- account management entry points required by the free product;
- device management/revocation UI if part of the approved flow.

**Acceptance criteria**

- auth behavior matches the system concept;
- no guest path exists accidentally;
- network absence on first launch is explained clearly;
- existing free core remains accessible offline after prior auth.

---

### V3-03 — Navigation and Base Layout Alignment

**Scope**

- align bottom navigation/base-screen behavior with Figma;
- preserve established route semantics unless Figma explicitly changes product behavior;
- correct inconsistent/obsolete page wiring;
- ensure common safe-area/responsive behavior.

**Acceptance criteria**

- all primary routes are reachable through intended navigation;
- no obsolete placeholder page is used in the production flow;
- navigation regression tests pass.

---

### V3-04 — Words + Word Details Alignment

**Scope**

- align Words screen;
- align Word Details screen;
- search/sort/filter behavior remains correct;
- sync state does not leak unnecessary technical complexity into the UI.

**Acceptance criteria**

- intended Figma information hierarchy/actions are implemented;
- existing word business rules remain intact;
- offline and synchronized states behave consistently.

---

### V3-05 — Add/Edit Word Alignment

**Scope**

- align fields, ordering, validation feedback and actions with Figma;
- preserve domain validation/business rules;
- avoid adding speculative grammar features not part of approved free-core design.

**Acceptance criteria**

- create/edit works offline;
- UUID/outbox behavior remains invisible to normal UX;
- validation is consistent with domain rules.

---

### V3-06 — Groups + Group Edit Alignment

**Scope**

- align Groups screen and editing interaction;
- remove/replace obsolete placeholder paths where needed;
- preserve group/word relationship behavior.

**Acceptance criteria**

- group CRUD matches intended product flow;
- delete/update interactions synchronize correctly;
- no duplicate competing group-edit flows remain unintentionally.

---

### V3-07 — Quiz Home + Setup Alignment

**Scope**

- align Quiz Home and Quiz Setup flows;
- preserve current local-only quiz execution;
- keep current supported quiz types only unless Figma/product decision explicitly adds another.

**Acceptance criteria**

- quiz configuration rules remain valid;
- quiz generation has no backend runtime dependency;
- resulting review statistics still sync.

---

### V3-08 — Quiz Session + Results Alignment

**Scope**

- align Translation Quiz Session;
- align Article Quiz Session;
- align Quiz Results;
- correct any obsolete/empty results-page wiring;
- preserve scoring and review-stat updates.

**Acceptance criteria**

- current quiz flows complete without navigation dead ends;
- result UI reflects real session data;
- review statistics remain correct and syncable.

---

### V3-09 — Settings Alignment

**Scope**

- align Settings screen;
- distinguish synchronized learning settings from device-local UI settings;
- remove normal user-facing file-sync/import-export behavior after Version-2 sync is stable;
- keep internal diagnostics separate from product UI.

**Acceptance criteria**

- account-level learning settings synchronize;
- theme/device-only settings remain local;
- settings UI does not imply manual file transfer is the primary sync system.

---

### V3-10 — Loading, Empty, Error and Offline States

**Scope**

- startup/loading state;
- empty vocabulary/groups states;
- first-auth network failure;
- temporary backend unavailability;
- pending sync/offline status where product-relevant;
- recoverable error presentation.

**Acceptance criteria**

- offline free usage is not presented as failure after prior auth;
- temporary sync failure does not block ordinary local edits;
- user-facing state vocabulary is consistent across screens.

---

### V3-11 — Responsive/Platform Validation

**Scope**

- validate intended mobile dimensions and safe areas;
- check supported iOS/Android layouts;
- fix only layout/platform issues required for the approved design;
- avoid unrelated desktop redesign unless desktop support is explicitly in the Version-3 target matrix.

**Acceptance criteria**

- no major clipping/navigation breakage on supported target devices;
- shared components preserve consistent visual behavior.

---

### V3-12 — Free-Core Regression and Stabilization

**Scope**

- frontend component tests where practical;
- root end-to-end regression flows;
- local CRUD while offline;
- reconnect/sync;
- second-device propagation;
- quiz/review-stat propagation;
- account/session lifecycle;
- known MVP1 defects addressed if still present.

**Release gate**

Version 3 is complete when the free product is both functionally stable and aligned with approved Figma intent across the agreed core flows.

## Version 3 Non-Goals

- subscription purchase flows;
- premium entitlement gating;
- AI features;
- new sharing infrastructure;
- public/community publishing;
- large architecture rewrite of the Version-2 sync system.
