<!-- 新增/修改动画前，请对照 CONTRIBUTING.md 的质量 checklist。 -->

## 这个 PR 做了什么

<!-- 一句话 -->

## 收录质量自查（新增动画必填）

- [ ] `content/animations/<id>/` 下有 `meta.yaml` + `main.dart`（推荐附 `bad.dart`）
- [ ] `meta.id` == 目录名，且符合 `schema/animation.schema.json`
- [ ] `main.dart` 可直接粘进 DartPad 运行
- [ ] `dart format` / `flutter analyze` / `flutter build web` 本地通过
- [ ] 每条 `pitfall` 都有 `source` + `confidence`（**诚实标注**，经验类用 `author-experience`）
- [ ] 填了 `verifiedOn`（如 `Flutter 3.32 / 2026-06`）

## 备注

<!-- 实测数据、参考链接等 -->
