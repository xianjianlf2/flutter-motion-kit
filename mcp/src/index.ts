#!/usr/bin/env node
/**
 * flutter-motion-kit MCP server (stdio, local/offline build)
 * See worker/ for the remotely hosted build. Both share the tool logic in src/tools.ts.
 *
 * Connect from Claude Code:
 *   claude mcp add flutter-motion -- npx -y flutter-motion-mcp
 */
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  ListToolsRequestSchema,
  CallToolRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { TOOL_DEFS, callTool, type Catalog } from './tools.js';

const here = dirname(fileURLToPath(import.meta.url));
// Resolution order: explicit env > the copy published with the package (mcp/catalog.json) > the repo root during development.
function loadCatalog(): Catalog {
  const candidates = [
    process.env.CATALOG_PATH,
    join(here, '..', 'catalog.json'),
    join(here, '..', '..', 'catalog.json'),
  ].filter(Boolean) as string[];
  for (const p of candidates) {
    try {
      return JSON.parse(readFileSync(p, 'utf8'));
    } catch {
      /* try next */
    }
  }
  throw new Error(`catalog.json not found. Tried:\n${candidates.join('\n')}`);
}
const catalog = loadCatalog();

const server = new Server(
  { name: 'flutter-motion-kit', version: '0.1.0' },
  { capabilities: { tools: {} } },
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({ tools: TOOL_DEFS as any }));

server.setRequestHandler(CallToolRequestSchema, async (req) => {
  try {
    const data = callTool(catalog, req.params.name, req.params.arguments ?? {});
    return { content: [{ type: 'text', text: JSON.stringify(data, null, 2) }] };
  } catch (e) {
    return { content: [{ type: 'text', text: String((e as Error).message) }], isError: true };
  }
});

await server.connect(new StdioServerTransport());
