# Quality checklist before adding an animation

This project earns trust from "provable + sourced + machine-verified", not from the author's tone. Before adding or changing an entry, go through each item:

## 1. Structure

Under `content/animations/<id>/`, add:

- `meta.yaml` — conforms to [`schema/animation.schema.json`](./schema/animation.schema.json); `id` must equal the folder name
- `main.dart` — the **minimal reproducible** correct implementation, runnable as-is in [DartPad](https://dartpad.dev)
- `bad.dart` (recommended) — the matching wrong way, for a side-by-side demo
- `test/*.dart` (recommended for memory/state pitfalls) — automated evidence

## 2. Code must pass the machine gate

```bash
dart format --set-exit-if-changed main.dart
flutter analyze main.dart          # baseline: very_good_analysis.yaml
flutter build web                  # must compile and run (no hallucinated APIs)
```

If `main.dart` fails any of these → it can't be merged (CI blocks it).

## 3. Every pitfall must be traceable

Each entry in `pitfalls[]` needs:

- `claim` (the symptom) + `fix` (the right way)
- `source` (**prefer official**: cookbook > API docs > flutter/samples > flutter/flutter issue)
- `confidence`, **labeled honestly**:
  - `official-docs` — stated clearly in the official docs
  - `github-issue` — backed by an issue
  - `measured` — measured yourself with DevTools / `--profile` (please attach the data in the PR)
  - `community-consensus` — broad community agreement
  - `author-experience` — personal experience (**don't dress it up as authority**)
- `provenBy` (optional) — points to a test that proves it

## 4. Record verification info

- `verifiedOn`: like `"Flutter 3.32 / 2026-06"` — others use it to judge whether it's stale
- After upgrading Flutter and re-verifying, update this date

## 5. Performance / accessibility (when applicable)

- For performance pitfalls, give a DevTools timeline or frame-time numbers, not "feels janky"
- For strong motion, consider `MediaQuery.of(context).disableAnimations`

---

> When in doubt, label it `author-experience` and explain why. **Traceable uncertainty beats faked certainty.**
