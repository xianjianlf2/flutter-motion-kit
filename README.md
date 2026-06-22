# Flutter Motion Kit

> 可**在线预览**的 Flutter 动画实现集合，每条都标注**对应的坑（含出处与可信度）**，并能让 **Claude Code / Cursor 一键复用**（MCP）。

一份结构化数据源，三个出口：

```
content/animations/<id>/{meta.yaml, main.dart, bad.dart}   ← 唯一真相源
        │  scripts/build-catalog.mjs（schema 校验 + 聚合）
        ▼
   catalog.json
   ├──▶ 站点(Astro)：DartPad 在线预览 + 代码 + 坑 + [复制给 AI] 按钮
   └──▶ MCP server：search / get / list_pitfalls，供 AI 编码助手直接调用
```

## 为什么不是又一个代码片段博客

“最佳实践”不靠口述，靠**能证明 + 有出处 + 机器验证**：

- **每条坑带 `source` + `confidence`**（`official-docs` / `measured` / `author-experience` …）——诚实标注依据强度，MCP 返回时一并给 AI。
- **CI 门禁**：每条 `main.dart` 必须过 `dart format` + `flutter analyze`（very_good_analysis）+ `flutter build web`，跑不过不允许收录。
- **可复现**：`bad.dart` 演示错误写法，可在 DartPad 里直接对比；内存类坑用 `leak_tracker` 测试佐证。
- **防过时**：每条记 `verifiedOn`，CI 每月重跑发现 Flutter 新版的 deprecation。

## 快速开始

```bash
npm install

# 1) 构建目录（校验 schema → catalog.json）
npm run catalog

# 2) 本地起站点（DartPad 预览 + 复制按钮）
npm run site:dev

# 3) 生成 DartPad 预览用的 gist（需要带 gist 权限的 token）
GITHUB_TOKEN=ghp_xxx npm run sync-gists

# 4) 构建并接入 MCP
npm run mcp:build
```

### 接入 Claude Code（一键复用）

```bash
claude mcp add flutter-motion -- node /abs/path/to/flutter-motion-kit/mcp/dist/index.js
```

之后在 CC 里直接：「找一个 Flutter 列表入场动画并加到我的页面」——它会调用 `search_flutter_animation` → `get_animation`，拿到**验证过的代码 + 避坑要点**落地。

## MCP 工具

| Tool | 作用 |
|---|---|
| `search_flutter_animation` | 按关键词/分类检索动画（返回摘要） |
| `get_animation` | 按 id 返回完整代码 + 坑 + 出处 |
| `list_pitfalls` | 拉坑清单，AI 写完自检用 |
| `list_categories` | 浏览分类 |

## 目录

```
content/animations/   # 唯一数据源（每个动画一个目录）
schema/               # meta.yaml 的 JSON Schema
scripts/              # build-catalog（聚合）/ sync-gists（DartPad）
site/                 # Astro 画廊（预览 + 复制按钮）
mcp/                  # MCP server (TypeScript)
.github/workflows/    # verify：schema + analyze + format + build
```

## 贡献

收录新动画前请过 [CONTRIBUTING.md](./CONTRIBUTING.md) 的质量 checklist。欢迎用 issue/PR 纠错——公开可纠错正是它比博客更可信的地方。

## License

MIT
