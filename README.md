# Flutter Motion Kit

> A collection of **previewable** Flutter animations, each annotated with **its pitfalls (with sources and confidence)**, and reusable from **Claude Code / Cursor in one click** (MCP).

<p align="center">
  <a href="https://motion.markxian.cn"><img src="assets/demo.gif" alt="Flutter Motion Kit — preview, copy, trust" width="860"></a>
</p>

<p align="center">
  <a href="cursor://anysphere.cursor-deeplink/mcp/install?name=flutter-motion&config=eyJ1cmwiOiJodHRwczovL21jcC5tYXJreGlhbi5jbi9tY3AifQ=="><img src="https://img.shields.io/badge/Add%20to-Cursor-000?logo=cursor&logoColor=white&style=for-the-badge" alt="Add to Cursor"></a>
  <a href="https://insiders.vscode.dev/redirect/mcp/install?name=flutter-motion&config=%7B%22url%22%3A%22https%3A%2F%2Fmcp.markxian.cn%2Fmcp%22%7D"><img src="https://img.shields.io/badge/Add%20to-VS%20Code-007ACC?logo=visualstudiocode&logoColor=white&style=for-the-badge" alt="Add to VS Code"></a>
  <a href="https://motion.markxian.cn"><img src="https://img.shields.io/badge/Live%20demo-motion.markxian.cn-4dd0e1?style=for-the-badge&logo=flutter&logoColor=white" alt="Live demo"></a>
</p>

[![developers connected](https://img.shields.io/badge/dynamic/json?url=https://mcp.markxian.cn/stats&query=$.connections&label=devs%20connected&color=brightgreen)](https://motion.markxian.cn)
[![animations](https://img.shields.io/badge/dynamic/json?url=https://mcp.markxian.cn/stats&query=$.animations&label=animations&color=blue)](https://motion.markxian.cn)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**🎛 Live interactive playground: [motion.markxian.cn](https://motion.markxian.cn)** · **📚 Verified catalog: [motion.markxian.cn/gallery](https://motion.markxian.cn/gallery)**

**Claude Code** — one line:

```bash
claude mcp add --transport http flutter-motion https://mcp.markxian.cn/mcp
```

## One-click connect (remote MCP · zero install)

Hosted on a Cloudflare Worker — add one URL and go, **content updates take effect instantly**:

**Claude Code**
```bash
claude mcp add --transport http flutter-motion https://mcp.markxian.cn/mcp
```

**Cursor / VS Code** — import with one button:

[![Add to Cursor](https://img.shields.io/badge/Add%20to-Cursor-000?logo=cursor)](cursor://anysphere.cursor-deeplink/mcp/install?name=flutter-motion&config=eyJ1cmwiOiJodHRwczovL21jcC5tYXJreGlhbi5jbi9tY3AifQ==)
[![Add to VS Code](https://img.shields.io/badge/Add%20to-VS%20Code-007ACC?logo=visualstudiocode)](https://insiders.vscode.dev/redirect/mcp/install?name=flutter-motion&config=%7B%22url%22%3A%22https%3A%2F%2Fmcp.markxian.cn%2Fmcp%22%7D)

> Prefer offline/local (npx, no hosting)? See [Connect Claude Code (local)](#connect-claude-code-one-click-reuse) below.

One structured source, three outputs:

```
content/animations/<id>/{meta.yaml, main.dart, bad.dart}   ← single source of truth
        │  scripts/build-catalog.mjs (schema validation + aggregation)
        ▼
   catalog.json
   ├──▶ Site (Astro): real running Flutter web previews (self-hosted) + code + pitfalls + [Copy for AI]
   └──▶ MCP server: search / get / list_pitfalls, callable directly by AI coding assistants
```

## Why this isn't just another snippet blog

"Best practices" shouldn't rest on someone's word — they should be **provable + sourced + machine-verified**:

- **Every pitfall carries a `source` + `confidence`** (`official-docs` / `measured` / `author-experience` …) — an honest signal of how strong the basis is, returned to the AI alongside the code.
- **CI gate**: every `main.dart` must pass `dart format` + `flutter analyze` (very_good_analysis) + `flutter build web`; if it doesn't, it isn't included.
- **Reproducible**: every entry self-hosts a **real running Flutter web preview** (compiled by `npm run previews`, not a screen recording); `bad.dart` demonstrates the wrong way for side-by-side comparison.
- **Anti-rot**: every entry records `verifiedOn`, and CI re-runs monthly to catch deprecations in new Flutter releases.

## Quick start

```bash
npm install

# 1) Build the catalog (validate schema → catalog.json)
npm run catalog

# 2) Build the self-hosted previews (compile each main.dart into runnable Flutter web)
#    Requires a local Flutter (auto-detects fvm; outputs to site/public/preview/, gitignored)
npm run previews

# 3) Run the site locally (embeds the running previews + copy buttons)
npm run site:dev

# 4) Build and connect the MCP server
npm run mcp:build
```

### Connect Claude Code (one-click reuse)

Once published to npm, anyone can connect with zero install:

```bash
claude mcp add flutter-motion -- npx -y flutter-motion-mcp
```

Local dev build:

```bash
npm run mcp:build
claude mcp add flutter-motion -- node /abs/path/to/flutter-motion-kit/mcp/dist/index.js
```

Then, right in Claude Code: "find a Flutter list-entrance animation and add it to my page" — it calls `search_flutter_animation` → `get_animation` and lands the **verified code + pitfalls**.

## MCP tools

| Tool | Purpose |
|---|---|
| `search_flutter_animation` | Search animations by keyword/category (returns summaries) |
| `get_animation` | Return full code + pitfalls + sources by id |
| `list_pitfalls` | Pull the pitfall list for an AI to self-check after writing |
| `list_categories` | Browse categories |

## Deploy the remote MCP (Cloudflare Worker)

```bash
cd worker
npm i -g wrangler && wrangler login

cp wrangler.toml.example wrangler.toml   # real config stays out of the repo (gitignored)

# Create the KV namespace (connection counter) and put the printed id into your local wrangler.toml
wrangler kv namespace create STATS
wrangler kv namespace create STATS --preview

npm run deploy        # rebuilds the catalog and bundles + deploys
```

After deploy: `/stats` shows the live connection count, `/mcp` is the MCP endpoint, `/` shows connect hints.

On the site side: `cp site/.env.example site/.env` and set `PUBLIC_MCP_ORIGIN` to your Worker endpoint (this `.env` is also kept out of the repo).

> **Private deploy config**: `worker/wrangler.toml`, `site/.env`, and `.dev.vars` are all gitignored — your KV id / account / subdomain never appear in the public repo, which only keeps `*.example` placeholders. To avoid exposing even the account subdomain, bind a custom domain to the Worker (see the comments in `wrangler.toml.example`).

> Stats: each `initialize` counts one connection (an approximate KV counter — good enough for a live badge). For exact de-duplication, upgrade to a Durable Object / Analytics Engine.

## Layout

```
content/animations/   # single source of truth (one directory per animation)
schema/               # JSON Schema for meta.yaml
scripts/              # build-catalog (aggregate) / build-previews (self-hosted previews) / sync-gists (DartPad, optional)
site/                 # interactive playground at / + verified gallery at /gallery (Astro)
mcp/                  # MCP server (TypeScript)
.github/workflows/    # verify: schema + analyze + format + build
```

## Contributing

Please run through the quality checklist in [CONTRIBUTING.md](./CONTRIBUTING.md) before adding a new animation. Corrections via issue/PR are welcome — being publicly correctable is exactly what makes this more trustworthy than a blog.

## License

MIT
