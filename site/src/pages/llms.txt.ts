import type { APIRoute } from 'astro';
import catalog from '../../../catalog.json';

// /llms.txt —— 给 AI 搜索引擎 / agent 的纯文本目录（含 MCP 接入方式）。
export const GET: APIRoute = ({ site }) => {
  const base = site?.href.replace(/\/$/, '') ?? '';
  const lines = [
    '# Flutter Motion Kit',
    '',
    '> 可预览的 Flutter 动画实现集合，每条带「对应的坑（含出处与可信度）」，',
    '> 并提供 MCP server 供 AI 编码助手（Claude Code / Cursor）直接检索复用。',
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
        `- [${e.title}](${base}/a/${e.id}) — ${e.category}, 难度 ${e.difficulty}/5, ` +
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
