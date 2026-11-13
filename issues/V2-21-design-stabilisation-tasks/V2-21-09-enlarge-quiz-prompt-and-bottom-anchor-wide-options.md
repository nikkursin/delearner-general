# V2-21-09 — Enlarge quiz prompt stage and bottom-anchor wide options

**Parent epic:** V2-21 — Design Stabilisation Tasks
**Status:** Ready
**Workspace:** frontend
**Size:** 5 story points
**Dependencies:** completed V2-18-03, completed V2-18-05, completed V2-21-05
**Figma requirement:** None; use the supplied exported screenshot without
accessing or modifying Figma

## Objective

Correct the Translation and Article quiz-session composition so the word or
phrase being guessed has a deliberate, spacious prompt stage and the answer
choices form wide, easy-to-scan controls near the bottom of the usable screen
instead of floating around the middle or collapsing into narrow article pills.

Preserve all existing question, scoring, answer-feedback, progress, result and
review-statistics behavior.

## Visual references

Use these supplied files:

- `references/V2-21-04A/translation_quiz_bad_phone.jpeg` — current Translation
  layout and excessive unstructured space below the choices;
- `references/V2-21-04A/article_quiz_bad_phone.jpeg` — current Article layout,
  especially the narrow centered answer controls;
- `references/V2-21-04A/quiz_reference_figma.png` — exported target hierarchy:
  header/progress, strong prompt area, wide answer stack and bottom action.

This is a small local alignment using an exported reference. Do not access or
modify the canonical Figma file and do not redesign unrelated quiz screens.

## Approved layout

### Prompt stage

- Keep the existing header and progress area at the top.
- Give the question prompt a large flexible stage between progress and the
  answer region. Centre the word/phrase both optically and textually.
- Present the prompt on a subtle rounded frame/surface using the existing
  DELearner neutral palette. The frame should establish hierarchy without
  becoming a heavy card or consuming the whole viewport.
- Support at least three wrapped lines for a long translation phrase without
  clipping or elliding the answer-bearing text. Use responsive typography and
  padding rather than a fixed single-word height.
- Article Quiz continues to show only the noun prompt; it must not reveal the
  correct article. Translation Quiz preserves its configured direction and may
  keep any existing non-answer context that is already part of the prompt.

### Bottom answer region

- Place the answer stack near the bottom of the **usable page**, above the
  platform safe area and any feedback/continue action. Do not use an absolute
  screen coordinate; use responsive layout/anchors derived from available
  height.
- Translation and Article options use the same wide answer-container geometry:
  fill the available phone content width with normal page margins, and use a
  readable centred maximum width on tablets.
- Target 52–58 logical pixels per option on normal phones, with consistent
  vertical spacing and at least a 44 logical-pixel interactive height in
  constrained layouts.
- For Article Quiz, the **outer answer button/tap target** must be full width.
  The existing der/die/das/Plural color may remain as a centred pill, accent or
  text treatment, but it must not make the button itself appear or behave like
  the narrow controls in the bad screenshot.
- Preserve neutral, correct and incorrect semantics. Selected-wrong and
  actual-correct states must remain visually unambiguous on the wider controls.
- Feedback and `Next Question`/`Continue`/`Show Results` belong to the same
  bottom region. Reserve or smoothly accommodate their space so selecting an
  answer does not cause a large, disorienting jump in the prompt or options.
- Follow the exported reference's hierarchy, but retain current DELearner copy,
  answer colors and functionality rather than copying a mock value or state.

## Responsive behavior

- Use the page's actual content rectangle and safe-area insets. Do not use
  device-name checks, hard-coded iPhone dimensions or a large fixed top margin.
- On ordinary portrait phones, the prompt stage takes the flexible remaining
  space and the answer region sits low on the page.
- On short phones and landscape, compress optional gaps and prompt padding
  first. If content still cannot fit, provide bounded scrolling so all prompt,
  feedback and answer actions remain reachable without overlap.
- On tablets, cap the prompt and option content widths; do not stretch buttons
  edge-to-edge across the entire landscape display.
- Preserve readable text wrapping for long prompts and long translation
  options, dynamic text growth within supported bounds and accessibility focus
  order from header to prompt to options to feedback/action.

## Required regression matrix

- Translation Quiz before answer, correct answer and incorrect answer.
- Article Quiz before answer, each article choice and Plural where eligible.
- Short word, long compound noun, and a translation prompt/option requiring
  multiple lines.
- 320/360/393 logical-pixel phone widths, a short-height/landscape case, tablet
  portrait and tablet landscape.
- Safe-area/no-safe-area variants.
- Option double-tap, back navigation, progress advance, final-question result
  routing and exactly-once review statistics.
- Geometry assertions proving Article and Translation options share the wide
  container, meet minimum tap height, do not overlap, and sit below the prompt
  stage in the lower portion of a normal portrait viewport.

## Acceptance criteria

- [ ] Both quiz types show a visibly larger framed prompt stage suitable for a
      word or wrapped phrase.
- [ ] Translation and Article answer controls use the wide responsive container;
      Article buttons no longer render as narrow floating controls.
- [ ] On a normal portrait phone, options are positioned near the bottom usable
      area with safe spacing rather than floating around mid-screen.
- [ ] Feedback and the continuation action remain visible/reachable and do not
      cause a large layout jump after selection.
- [ ] Long text and constrained-height layouts do not clip, overlap or make any
      answer/action unreachable.
- [ ] Existing answer-state colors, scoring, progress, navigation, results and
      exactly-once review-statistics behavior remain intact.
- [ ] Focused QML/quiz tests and the relevant frontend suite pass, with a
      checkpoint recording files, commands, results and device limitations.

## Non-goals

- Changing quiz generation, answer sets, scoring or review-statistics rules.
- Adding new quiz families or changing result screens.
- Accessing or modifying Figma.
- Copying the mock answer text or exposing the correct article in Article Quiz.

## Stop / escalate if

- The requested visual correction would require a product change to question or
  answer semantics.
- A shared quiz component change would alter an unrelated quiz family without
  focused coverage and explicit scope.
