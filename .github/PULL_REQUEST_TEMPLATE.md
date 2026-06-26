<!-- Before adding/changing an animation, check it against the quality checklist in CONTRIBUTING.md. -->

## What does this PR do

<!-- one line -->

## Inclusion quality self-check (required for new animations)

- [ ] `content/animations/<id>/` has `meta.yaml` + `main.dart` (`bad.dart` recommended)
- [ ] `meta.id` == folder name, and conforms to `schema/animation.schema.json`
- [ ] `main.dart` runs as-is when pasted into DartPad
- [ ] `dart format` / `flutter analyze` / `flutter build web` pass locally
- [ ] Every `pitfall` has a `source` + `confidence` (**labeled honestly**; use `author-experience` for experience-based ones)
- [ ] `verifiedOn` is filled in (e.g. `Flutter 3.32 / 2026-06`)

## Notes

<!-- measured data, reference links, etc. -->
