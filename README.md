# Flutter Motion Kit

> 可**在线预览**的 Flutter 动画实现集合，每条都标注**对应的坑（含出处与可信度）**，并能让 **Claude Code / Cursor 一键复用**（MCP）。

[![developers connected](https://img.shields.io/badge/dynamic/json?url=https://mcp.markxian.cn/stats&query=$.connections&label=devs%20connected&color=brightgreen)](https://motion.markxian.cn)
[![animations](https://img.shields.io/badge/dynamic/json?url=https://mcp.markxian.cn/stats&query=$.animations&label=animations&color=blue)](https://motion.markxian.cn)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**🌐 在线预览：[motion.markxian.cn](https://motion.markxian.cn)**

## 一键接入（远程 MCP · 零安装）

托管在 Cloudflare Worker，加一个 URL 即用，**内容更新即时生效**：

**Claude Code**
```bash
claude mcp add --transport http flutter-motion https://mcp.markxian.cn/mcp
```

**Cursor / VS Code**：点按钮一键导入

[![Add to Cursor](https://img.shields.io/badge/Add%20to-Cursor-000?logo=cursor)](cursor://anysphere.cursor-deeplink/mcp/install?name=flutter-motion&config=eyJ1cmwiOiJodHRwczovL21jcC5tYXJreGlhbi5jbi9tY3AifQ==)
[![Add to VS Code](https://img.shields.io/badge/Add%20to-VS%20Code-007ACC?logo=visualstudiocode)](https://insiders.vscode.dev/redirect/mcp/install?name=flutter-motion&config=%7B%22url%22%3A%22https%3A%2F%2Fmcp.markxian.cn%2Fmcp%22%7D)

> 离线/本地版（npx、无需托管）见下方 [本地开发版](#接入-claude-code一键复用)。

一份结构化数据源，三个出口：

```
content/animations/<id>/{meta.yaml, main.dart, bad.dart}   ← 唯一真相源
        │  scripts/build-catalog.mjs（schema 校验 + 聚合）
        ▼
   catalog.json
   ├──▶ 站点(Astro)：真实运行的 Flutter web 预览（自托管）+ 代码 + 坑 + [复制给 AI] 按钮
   └──▶ MCP server：search / get / list_pitfalls，供 AI 编码助手直接调用
```

## 为什么不是又一个代码片段博客

“最佳实践”不靠口述，靠**能证明 + 有出处 + 机器验证**：

- **每条坑带 `source` + `confidence`**（`official-docs` / `measured` / `author-experience` …）——诚实标注依据强度，MCP 返回时一并给 AI。
- **CI 门禁**：每条 `main.dart` 必须过 `dart format` + `flutter analyze`（very_good_analysis）+ `flutter build web`，跑不过不允许收录。
- **可复现**：每条都自托管一个**真实运行的 Flutter web 预览**（`npm run previews` 编译，非录屏）；`bad.dart` 演示错误写法可直接对比。
- **防过时**：每条记 `verifiedOn`，CI 每月重跑发现 Flutter 新版的 deprecation。

## 快速开始

```bash
npm install

# 1) 构建目录（校验 schema → catalog.json）
npm run catalog

# 2) 构建自托管预览（把每条 main.dart 编译成真能跑的 Flutter web）
#    需本地有 Flutter（自动探测 fvm；产物在 site/public/preview/，已 gitignore）
npm run previews

# 3) 本地起站点（内嵌真实运行的预览 + 复制按钮）
npm run site:dev

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

cp wrangler.toml.example wrangler.toml   # 真实配置不进仓库（已 gitignore）

# 建 KV（连接计数），把输出的 id 填进本地 wrangler.toml
wrangler kv namespace create STATS
wrangler kv namespace create STATS --preview

npm run deploy        # 自动重建 catalog 并打包部署
```

部署后访问 `/stats` 看实时连接数，`/mcp` 是 MCP 端点，`/` 看接入提示。

站点侧：`cp site/.env.example site/.env` 并把 `PUBLIC_MCP_ORIGIN` 填成你的 Worker 端点（这份 `.env` 也不进仓库）。

> **部署配置私有化**：`worker/wrangler.toml`、`site/.env`、`.dev.vars` 均已 gitignore——你的 KV id / account / 子域不会出现在公开仓库，仓库只留 `*.example` 占位。想连账号子域都不暴露，给 Worker 绑自定义域（见 `wrangler.toml.example` 注释）。

> 统计：每次 `initialize` 计一次连接（KV 近似计数，够做实时徽章）。需要精确去重时升级为 Durable Object / Analytics Engine。

## 目录

```
content/animations/   # 唯一数据源（每个动画一个目录）
schema/               # meta.yaml 的 JSON Schema
scripts/              # build-catalog（聚合）/ build-previews（自托管预览）/ sync-gists（DartPad，可选）
site/                 # Astro 画廊（预览 + 复制按钮）
mcp/                  # MCP server (TypeScript)
.github/workflows/    # verify：schema + analyze + format + build
```

## 贡献

收录新动画前请过 [CONTRIBUTING.md](./CONTRIBUTING.md) 的质量 checklist。欢迎用 issue/PR 纠错——公开可纠错正是它比博客更可信的地方。

## License

MIT
