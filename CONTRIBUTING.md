# 收录一条动画前的质量 checklist

本项目的可信度来自「能证明 + 有出处 + 机器验证」，而非作者语气。新增/修改条目前，请逐项过：

## 1. 结构

在 `content/animations/<id>/` 下放：

- `meta.yaml` — 符合 [`schema/animation.schema.json`](./schema/animation.schema.json)，`id` 必须等于目录名
- `main.dart` — **最小可复现**的「正确实现」，可直接粘进 [DartPad](https://dartpad.dev) 运行
- `bad.dart`（推荐）— 对应的「错误写法」，用于对比演示
- `test/*.dart`（内存/状态类坑推荐）— 自动化佐证

## 2. 代码必须过机器门禁

```bash
dart format --set-exit-if-changed main.dart
flutter analyze main.dart          # 基线：very_good_analysis.yaml
flutter build web                  # 必须能编译运行（杜绝幻觉 API）
```

`main.dart` 跑不过以上任一项 → 不允许合并（CI 会拦）。

## 3. 每条「坑」必须可追溯

`pitfalls[]` 里每条都要有：

- `claim` 现象 + `fix` 正确做法
- `source` 出处（**优先官方**：cookbook > API docs > flutter/samples > flutter/flutter issue）
- `confidence` 依据强度，**诚实标注**：
  - `official-docs` 官方文档明确
  - `github-issue` 有 issue 佐证
  - `measured` 自己用 DevTools / `--profile` 实测（请在 PR 附数据）
  - `community-consensus` 社区广泛共识
  - `author-experience` 个人经验（**不要伪装成权威**）
- `provenBy`（可选）指向证明它的测试

## 4. 标注验证信息

- `verifiedOn`: 形如 `"Flutter 3.32 / 2026-06"`——别人据此判断是否过时
- 升级 Flutter 后若重验通过，更新该日期

## 5. 性能/可达性（适用时）

- 性能类坑给出 DevTools timeline 或帧耗时数据，不写“感觉卡”
- 涉及强动效的，考虑 `MediaQuery.of(context).disableAnimations`

---

> 拿不准就标 `author-experience` 并说明理由。**可追溯的不确定，好过伪装的确定。**
