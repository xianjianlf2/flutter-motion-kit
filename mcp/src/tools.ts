// Runtime-agnostic tool logic — shared by both the stdio build (index.ts) and the Cloudflare Worker.
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

// Tool definitions (JSON Schema form, usable by both the stdio and HTTP ends).
export const TOOL_DEFS = [
  {
    name: 'search_flutter_animation',
    description: 'Search Flutter animation implementations by keyword / category / tag; returns matching summaries (no full code).',
    inputSchema: {
      type: 'object',
      properties: {
        query: { type: 'string', description: 'Natural language or keywords, e.g. "list entrance" / "hero" / "spring"' },
        category: { type: 'string', enum: CATEGORIES },
        limit: { type: 'number', minimum: 1, maximum: 20, default: 5 },
      },
      required: ['query'],
    },
  },
  {
    name: 'get_animation',
    description: 'Return the full entry by id: ready-to-use code (code) + an anti-example of the wrong way (badCode, for contrast) + the pitfalls to watch (with sources and confidence) + the verification date.',
    inputSchema: { type: 'object', properties: { id: { type: 'string' } }, required: ['id'] },
  },
  {
    name: 'list_pitfalls',
    description: 'Return the list of pitfalls across all animations (optionally within a category) — handy for an AI to self-check after writing a Flutter animation.',
    inputSchema: { type: 'object', properties: { category: { type: 'string' } } },
  },
  {
    name: 'list_categories',
    description: 'List all animation categories and their counts.',
    inputSchema: { type: 'object', properties: {} },
  },
] as const;

// Per-term scoring: split the query into words and sum, so multi-word queries like "list entrance" still match
// (the old version matched the whole string as a substring, so a single space dropped recall to 0).
const scoreTerm = (e: Entry, t: string) => {
  let s = 0;
  if (e.id.includes(t) || e.title.toLowerCase().includes(t)) s += 5;
  if (e.summary.toLowerCase().includes(t)) s += 2;
  if ((e.tags ?? []).some((tag) => tag.toLowerCase().includes(t))) s += 3;
  if (e.category.includes(t)) s += 2;
  return s;
};

const score = (e: Entry, q: string) => {
  const terms = (q ?? '').toLowerCase().split(/[\s,，、]+/).filter(Boolean);
  if (!terms.length) return 1;
  return terms.reduce((sum, t) => sum + scoreTerm(e, t), 0);
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
    code: e.code, badCode: e.badCode ?? null, pitfalls: e.pitfalls, docs: e.docs, dartpadUrl: e.dartpadUrl,
    usageNote: 'Use the correct implementation in `code` and follow the fixes in `pitfalls`; `confidence` marks how strong each basis is.'
      + (e.badCode ? ' `badCode` is the wrong-way anti-example — for contrast only, never copy it.' : ''),
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

// Unified tool dispatch entry point
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
