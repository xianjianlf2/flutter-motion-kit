#!/usr/bin/env node
/**
 * flutter-motion-kit MCP server
 * 让 Claude Code / Cursor 等直接检索「验证过的 Flutter 动画实现 + 对应的坑」。
 *
 * 接入 Claude Code：
 *   claude mcp add flutter-motion -- node /abs/path/to/mcp/dist/index.js
 */
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

type Pitfall = {
  claim: string; fix: string; source: string; confidence: string; provenBy?: string;
};
type Entry = {
  id: string; title: string; category: string; difficulty: number;
  tags?: string[]; summary: string; verifiedOn: string; docs?: string[];
  code: string; badCode?: string | null; dartpadUrl?: string | null; pitfalls: Pitfall[];
};
type Catalog = { count: number; categories: string[]; entries: Entry[] };

const here = dirname(fileURLToPath(import.meta.url));
const catalog: Catalog = JSON.parse(
  readFileSync(process.env.CATALOG_PATH ?? join(here, '..', '..', 'catalog.json'), 'utf8'),
);

const score = (e: Entry, q: string) => {
  const t = q.toLowerCase();
  let s = 0;
  if (e.id.includes(t) || e.title.toLowerCase().includes(t)) s += 5;
  if (e.summary.toLowerCase().includes(t)) s += 2;
  if ((e.tags ?? []).some((tag) => tag.toLowerCase().includes(t))) s += 3;
  if (e.category.includes(t)) s += 2;
  return s;
};

const server = new McpServer({ name: 'flutter-motion-kit', version: '0.1.0' });

server.tool(
  'search_flutter_animation',
  '按关键词/分类/标签检索 Flutter 动画实现，返回匹配条目的摘要（不含完整代码）。',
  {
    query: z.string().describe('自然语言或关键词，如 "列表 入场" / "hero" / "弹性"'),
    category: z.enum(['implicit', 'explicit', 'hero', 'staggered', 'physics', 'custom-painter', 'rive-lottie']).optional(),
    limit: z.number().int().min(1).max(20).default(5),
  },
  async ({ query, category, limit }) => {
    let hits = catalog.entries.filter((e) => !category || e.category === category);
    hits = hits
      .map((e) => ({ e, s: score(e, query) }))
      .filter((x) => x.s > 0 || !query)
      .sort((a, b) => b.s - a.s)
      .slice(0, limit)
      .map((x) => x.e);
    const out = hits.map((e) => ({
      id: e.id, title: e.title, category: e.category, difficulty: e.difficulty,
      tags: e.tags, summary: e.summary, verifiedOn: e.verifiedOn,
      pitfallCount: e.pitfalls.length,
    }));
    return { content: [{ type: 'text', text: JSON.stringify(out, null, 2) }] };
  },
);

server.tool(
  'get_animation',
  '按 id 返回完整内容：可直接使用的代码 + 必须注意的坑（含出处与可信度）+ 验证日期。',
  { id: z.string() },
  async ({ id }) => {
    const e = catalog.entries.find((x) => x.id === id);
    if (!e) return { content: [{ type: 'text', text: `not found: ${id}` }], isError: true };
    const payload = {
      id: e.id, title: e.title, category: e.category, verifiedOn: e.verifiedOn,
      code: e.code,
      pitfalls: e.pitfalls,
      docs: e.docs,
      dartpadUrl: e.dartpadUrl,
      usageNote: '采用此代码时，请遵守 pitfalls 中的 fix；confidence 标明了每条依据的强度。',
    };
    return { content: [{ type: 'text', text: JSON.stringify(payload, null, 2) }] };
  },
);

server.tool(
  'list_pitfalls',
  '返回（某分类下）所有动画的「坑」清单，适合 AI 写完 Flutter 动画后自检。',
  { category: z.string().optional() },
  async ({ category }) => {
    const rows = catalog.entries
      .filter((e) => !category || e.category === category)
      .flatMap((e) => e.pitfalls.map((p) => ({ from: e.id, ...p })));
    return { content: [{ type: 'text', text: JSON.stringify(rows, null, 2) }] };
  },
);

server.tool(
  'list_categories',
  '列出所有动画分类及数量。',
  {},
  async () => {
    const counts = catalog.categories.map((c) => ({
      category: c, count: catalog.entries.filter((e) => e.category === c).length,
    }));
    return { content: [{ type: 'text', text: JSON.stringify({ total: catalog.count, counts }, null, 2) }] };
  },
);

await server.connect(new StdioServerTransport());
