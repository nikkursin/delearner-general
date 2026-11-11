# V2-21-01 — Define split authentication flow in Figma

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Ready
**Workspace:** Figma + root
**Size:** 3 story points
**Dependencies:** existing authentication and reauthentication behaviour
**Figma requirement:** Required

## Objective

Define the Sign in and Create account pages in the canonical DELearner Figma
file before implementation, including phone and tablet-responsive intent.

## Canonical design file

- File: <https://www.figma.com/design/7kCGSdFGQ79KpRqdaG5Pfp/DELearner?node-id=0-1>
- File key: `7kCGSdFGQ79KpRqdaG5Pfp`

Use this existing file. Do not create or infer a replacement DELearner file.

## Scope

- Inspect the current auth implementation and existing canonical design before
  editing the file.
- Create or update a dedicated **Sign in** page with Email and Password fields,
  a primary Sign in action and a clear Create account navigation action.
- Create or update a separate **Create account** page with Name, Email,
  Password and Repeat password fields.
- Show disabled or **Coming soon** Apple and Google controls on both pages.
- Define navigation in both directions between the two pages.
- Preserve a **Sign in again** recovery variant that explains saved local work
  and does not offer account creation.
- Define inline empty, invalid-email, weak-password, password-mismatch, busy and
  backend-error states.
- Show responsive intent for at least one phone frame and one tablet/landscape
  frame using the existing design system and visual language.
- Record the final node links in this task's implementation checkpoint.

## Acceptance criteria

- [ ] Sign in and Create account are separate, reviewable Figma frames.
- [ ] Both pages contain Apple and Google placeholder controls that cannot be
      mistaken for implemented providers.
- [ ] Create account includes all four approved fields and visible validation
      states.
- [ ] Sign in again preserves the existing recovery semantics.
- [ ] Phone and tablet layout intent is explicit; the tablet frame is not a
      stretched phone screenshot.
- [ ] Final Figma node links and any deliberate discrepancy from current code
      are recorded in the checkpoint.

## Non-goals

- Production Apple/Google authentication or account linking.
- Email ownership verification, password reset or account deletion.
- Redesigning Home, Profile, quiz or vocabulary screens.

## Stop / escalate if

- The canonical file is unavailable or cannot be edited.
- An existing canonical auth flow conflicts with the explicit V2-21 product
  decision in a way that requires redesigning unrelated screens.
