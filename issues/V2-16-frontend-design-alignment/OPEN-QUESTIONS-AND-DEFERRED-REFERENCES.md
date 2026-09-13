# V2-16 — Open Questions and Deferred References

These items are deliberately recorded rather than guessed.

## Add Word from Group

The Group actions reference includes **Add word**, but its destination/flow reference was not supplied. Keep the action requirement visible, but do not invent the missing flow. Implement that subflow only after the reference is added.

## Adverb form inconsistency

The supplied Add/Edit Word adverb reference does not show comparative/superlative inputs, while the supplied Adverb Word Details reference displays comparative/superlative values. Do not invent a new persistence rule solely to reconcile this visual mismatch. Preserve the provided Add/Edit layout and render details only from fields supported by the finalized V2-17 contract.

## Bottom-navigation destinations

The modern navigation mockup shows a different destination arrangement from the currently implemented bar. V2-16-01 modernizes the shell while preserving working route semantics unless a destination is already available. Do not create a new Home/Profile screen merely to satisfy an icon shown in the visual reference. Final destination-set changes can be resolved with the future UI epic.

## Onboarding assets

Logo and illustration blocks remain placeholders until final assets are supplied.
