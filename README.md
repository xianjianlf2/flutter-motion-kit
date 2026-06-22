# Flutter Motion Kit

> 可**在线预览**的 Flutter 动画实现集合，每条都标注**对应的坑（含出处与可信度）**，并能让 **Claude Code / Cursor 一键复用**（MCP）。

[![developers connected](https://img.shields.io/badge/dynamic/json?url=https://flutter-motion-kit.YOUR_SUBDOMAIN.workers.dev/stats&query=$.connections&label=devs%20connected&color=brightgreen)](https://flutter-motion-kit.pages.dev)
[![animations](https://img.shields.io/badge/dynamic/json?url=https://flutter-motion-kit.YOUR_SUBDOMAIN.workers.dev/stats&query=$.animations&label=animations&color=blue)](https://flutter-motion-kit.pages.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 一键接入（远程 MCP · 零安装）

托管在 Cloudflare Worker，加一个 URL 即用，**内容更新即时生效**：

**Claude Code**
```bash
claude mcp add --transport http flutter-motion https://flutter-motion-kit.YOUR_SUBDOMAIN.workers.dev/mcp
```

**Cursor / VS Code**：点按钮一键导入

[![Add to Cursor](https://img.shields.io/badge/Add%20to-Cursor-000?logo=cursor)](cursor://anysphere.cursor-deeplink/mcp/install?name=flutter-motion&config=eyJ1cmwiOiJodHRwczovL2ZsdXR0ZXItbW90aW9uLWtpdC5ZT1VSX1NVQkRPTUFJTi53b3JrZXJzLmRldi9tY3AifQ==)
[![Add to VS Code](https://img.shields.io/badge/Add%20to-VS%20Code-007ACC?logo=visualstudiocode)](https://insiders.vscode.dev/redirect/mcp/install?name=flutter-motion&config=%7B%22url%22%3A%22https%3A%2F%2Fflutter-motion-kit.YOUR_SUBDOMAIN.workers.dev%2Fmcp%22%7D)

> 部署后把 `YOUR_SUBDOMAIN` 换成你的 Worker 子域；Cursor 按钮的 `config` 是 `{"url":"<你的/mcp>"}` 的 base64。
> 离线/本地版（npx、无需托管）见下方 [本地开发版](#接入-claude-code一键复用)。

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

发布到 npm 后，任何人零安装接入：

```bash
claude mcp add flutter-motion -- npx -y flutter-motion-mcp
```

本地开发版：

```bash
npm run mcp:build
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

## 部署远程 MCP（Cloudflare Worker）

```bash
cd worker
npm i -g wrangler && wrangler login

# 建 KV（连接计数），把输出的 id 填进 wrangler.toml
wrangler kv namespace create STATS
wrangler kv namespace create STATS --preview

npm run deploy        # 自动重建 catalog 并打包部署
```

部署后访问 `/stats` 看实时连接数，`/mcp` 是 MCP 端点，`/` 看接入提示。再把 README/site 里的 `YOUR_SUBDOMAIN` 换成你的 Worker 子域即可。

> 统计：每次 `initialize` 计一次连接（KV 近似计数，够做实时徽章）。需要精确去重时升级为 Durable Object / Analytics Engine。

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
