import type { APIRoute } from 'astro';
import catalog from '../../../catalog.json';

// /llms.txt — a plain-text catalog for AI search engines / agents (including how to connect via MCP).
export const GET: APIRoute = ({ site }) => {
  const base = site?.href.replace(/\/$/, '') ?? '';
  const lines = [
    '# Flutter Motion Kit',
    '',
    '> A collection of previewable Flutter animations, each annotated with its pitfalls',
    '> (with sources and confidence), plus an MCP server so AI coding assistants',
    '> (Claude Code / Cursor) can search and reuse them directly.',
    '',
    '## Use via MCP',
    '',
    '- claude mcp add flutter-motion -- npx -y flutter-motion-mcp',
    '- tools: search_flutter_animation, get_animation, list_pitfalls, list_categories',
    '',
    `## Animations (${catalog.count})`,
    '',
    ...catalog.entries.map(
      (e) =>
        `- [${e.title}](${base}/a/${e.id}) — ${e.category}, difficulty ${e.difficulty}/5, ` +
        `${e.pitfalls.length} pitfalls. ${e.summary.trim()}`,
    ),
    '',
    '## Machine-readable catalog',
    '',
    `- ${base}/api/animations.json`,
  ];
  return new Response(lines.join('\n'), {
    headers: { 'content-type': 'text/plain; charset=utf-8' },
  });
};
