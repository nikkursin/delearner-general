# V2-21-04A reference checklist

This folder supplies the approved visual target for the Home synchronization
control. Do not replace the canonical DELearner Figma file or add unrelated Home
redesign references here.

## Minimum required files

### `sync-refresh-idle.svg`

The supplied transparent refresh/sync glyph must retain:

- its square view box and centred optical bounds;
- no baked background rectangle;
- centred optical bounds suitable for rotation;
- strokes rather than a filled white tile;
- enough contrast to be tinted against the current light Home background.

### `sync-refresh-error.svg`

The supplied matching failure state must retain:

- the same square view box and optical centre as the idle SVG;
- the same stroke weight and corner/line-cap language;
- a clear exclamation mark or exclamation badge;
- a transparent background;
- no baked error colour unless the colour itself is an intentional brand
  decision.

## Strongly recommended context references

- `current-bad-phone.png` — screenshot showing the current white-background
  result in the full Home header.
- `target-phone.png` — annotated target placement/scale on a phone.
- `target-ipad-landscape.png` — annotated target placement/scale on iPad
  landscape.
- `syncing-motion.gif` or `syncing-motion.mp4` — optional motion reference when
  clockwise rotation near 800–1000 ms is not the desired animation.

For annotated screenshots, include the intended glyph size and touch-target
size if they differ from the task defaults. Do not crop so tightly that header
alignment and surrounding spacing are impossible to judge.

## PNG fallback

If SVG export is impossible, provide:

- `sync-refresh-idle@3x.png` and `sync-refresh-error@3x.png`;
- true alpha transparency;
- identical pixel dimensions and internal padding;
- at least 72 × 72 pixels for a 24 logical-pixel target;
- an annotated target screenshot proving intended optical scale.

SVG remains preferred because the project already uses a 24 × 24 SVG icon
system and needs reliable tinting/scaling across device densities.

## Do not provide

- screenshots as the only source when their icon edges are not recoverable;
- icons with white or coloured rectangular backgrounds;
- two glyphs from unrelated icon families;
- assets copied from a third-party product without a compatible licence;
- separate animation frames when one centred glyph can be rotated in QML.
