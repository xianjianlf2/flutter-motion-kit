// Flutter Motion Kit — remote MCP (Cloudflare Worker)
// Routes:
//   POST /mcp     Streamable HTTP MCP (JSON mode, stateless and read-only)
//   GET  /stats   connection count (for the homepage's live badge)
//   GET  /        service info + one-line setup hint
import catalog from '../../catalog.json';
import { dispatch } from '../../mcp/dist/rpc.js';
import type { Catalog } from '../../mcp/dist/tools.js';

const CATALOG = catalog as unknown as Catalog;

interface Env {
  STATS: KVNamespace;
}

const cors = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET, POST, OPTIONS',
  'access-control-allow-headers': 'content-type, mcp-session-id, mcp-protocol-version',
  'access-control-expose-headers': 'mcp-session-id',
};

const json = (data: unknown, init: ResponseInit = {}) =>
  new Response(JSON.stringify(data), {
    ...init,
    headers: { 'content-type': 'application/json; charset=utf-8', ...cors, ...(init.headers ?? {}) },
  });

async function bumpConnections(env: Env) {
  // Approximate count for display (KV read-modify-write, not strongly consistent, but good enough for a live badge).
  const n = Number((await env.STATS.get('connections')) ?? '0') + 1;
  await env.STATS.put('connections', String(n));
  return n;
}

export default {
  async fetch(req: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(req.url);

    if (req.method === 'OPTIONS') return new Response(null, { headers: cors });

    if (url.pathname === '/stats') {
      const connections = Number((await env.STATS.get('connections')) ?? '0');
      return json({ connections, animations: CATALOG.count });
    }

    if (url.pathname === '/' || url.pathname === '') {
      return json({
        name: 'flutter-motion-kit',
        description: 'Remote MCP: verified Flutter animations + pitfalls for AI coding assistants.',
        animations: CATALOG.count,
        connect: {
          claudeCode: 'claude mcp add --transport http flutter-motion ' + url.origin + '/mcp',
          endpoint: url.origin + '/mcp',
        },
        tools: ['search_flutter_animation', 'get_animation', 'list_pitfalls', 'list_categories'],
      });
    }

    if (url.pathname === '/mcp') {
      if (req.method !== 'POST') return json({ error: 'use POST' }, { status: 405 });
      let body: any;
      try {
        body = await req.json();
      } catch {
        return json({ jsonrpc: '2.0', id: null, error: { code: -32700, message: 'Parse error' } }, { status: 400 });
      }

      const messages = Array.isArray(body) ? body : [body];
      const responses = [];
      let sawInitialize = false;
      for (const m of messages) {
        const { response, isInitialize } = dispatch(CATALOG, m);
        if (isInitialize) sawInitialize = true;
        if (response) responses.push(response);
      }
      if (sawInitialize) ctx.waitUntil(bumpConnections(env));

      const headers: Record<string, string> = {};
      if (sawInitialize) headers['mcp-session-id'] = crypto.randomUUID();

      if (responses.length === 0) return new Response(null, { status: 202, headers: cors });
      return json(Array.isArray(body) ? responses : responses[0], { headers });
    }

    return json({ error: 'not found' }, { status: 404 });
  },
};
