// 运行时无关的工具逻辑 —— 同时被 stdio 版(index.ts) 和 Cloudflare Worker 复用。
export type Pitfall = {
  claim: string; fix: string; source: string; confidence: string; provenBy?: string;
};
export type Entry = {
  id: string; title: string; category: string; difficulty: number;
  tags?: string[]; summary: string; verifiedOn: string; docs?: string[];
  code: string; badCode?: string | null; dartpadUrl?: string | null; pitfalls: Pitfall[];
};
export type Catalog = { count: number; categories: string[]; entries: Entry[] };

export const CATEGORIES = [
  'implicit', 'explicit', 'hero', 'staggered', 'physics', 'custom-painter', 'rive-lottie',
] as const;

// 工具定义（JSON Schema 形式，stdio 和 HTTP 两端都能用）
export const TOOL_DEFS = [
  {
    name: 'search_flutter_animation',
    description: '按关键词/分类/标签检索 Flutter 动画实现，返回匹配条目的摘要（不含完整代码）。',
    inputSchema: {
      type: 'object',
      properties: {
        query: { type: 'string', description: '自然语言或关键词，如 "列表 入场" / "hero" / "弹性"' },
        category: { type: 'string', enum: CATEGORIES },
        limit: { type: 'number', minimum: 1, maximum: 20, default: 5 },
      },
      required: ['query'],
    },
  },
  {
    name: 'get_animation',
    description: '按 id 返回完整内容：可直接使用的代码 + 必须注意的坑（含出处与可信度）+ 验证日期。',
    inputSchema: { type: 'object', properties: { id: { type: 'string' } }, required: ['id'] },
  },
  {
    name: 'list_pitfalls',
    description: '返回（某分类下）所有动画的「坑」清单，适合 AI 写完 Flutter 动画后自检。',
    inputSchema: { type: 'object', properties: { category: { type: 'string' } } },
  },
  {
    name: 'list_categories',
    description: '列出所有动画分类及数量。',
    inputSchema: { type: 'object', properties: {} },
  },
] as const;

const score = (e: Entry, q: string) => {
  const t = (q ?? '').toLowerCase();
  if (!t) return 1;
  let s = 0;
  if (e.id.includes(t) || e.title.toLowerCase().includes(t)) s += 5;
  if (e.summary.toLowerCase().includes(t)) s += 2;
  if ((e.tags ?? []).some((tag) => tag.toLowerCase().includes(t))) s += 3;
  if (e.category.includes(t)) s += 2;
  return s;
};

export function searchAnimations(
  catalog: Catalog,
  { query = '', category, limit = 5 }: { query?: string; category?: string; limit?: number },
) {
  return catalog.entries
    .filter((e) => !category || e.category === category)
    .map((e) => ({ e, s: score(e, query) }))
    .filter((x) => x.s > 0)
    .sort((a, b) => b.s - a.s)
    .slice(0, limit)
    .map(({ e }) => ({
      id: e.id, title: e.title, category: e.category, difficulty: e.difficulty,
      tags: e.tags, summary: e.summary, verifiedOn: e.verifiedOn, pitfallCount: e.pitfalls.length,
    }));
}

export function getAnimation(catalog: Catalog, id: string) {
  const e = catalog.entries.find((x) => x.id === id);
  if (!e) return null;
  return {
    id: e.id, title: e.title, category: e.category, verifiedOn: e.verifiedOn,
    code: e.code, pitfalls: e.pitfalls, docs: e.docs, dartpadUrl: e.dartpadUrl,
    usageNote: '采用此代码时，请遵守 pitfalls 中的 fix；confidence 标明了每条依据的强度。',
  };
}

export function listPitfalls(catalog: Catalog, category?: string) {
  return catalog.entries
    .filter((e) => !category || e.category === category)
    .flatMap((e) => e.pitfalls.map((p) => ({ from: e.id, ...p })));
}

export function listCategories(catalog: Catalog) {
  return {
    total: catalog.count,
    counts: catalog.categories.map((c) => ({
      category: c, count: catalog.entries.filter((e) => e.category === c).length,
    })),
  };
}

// 统一的工具调用入口
export function callTool(catalog: Catalog, name: string, args: Record<string, unknown>) {
  switch (name) {
    case 'search_flutter_animation':
      return searchAnimations(catalog, args as any);
    case 'get_animation': {
      const r = getAnimation(catalog, String(args.id));
      if (!r) throw new Error(`not found: ${args.id}`);
      return r;
    }
    case 'list_pitfalls':
      return listPitfalls(catalog, args.category as string | undefined);
    case 'list_categories':
      return listCategories(catalog);
    default:
      throw new Error(`unknown tool: ${name}`);
  }
}
