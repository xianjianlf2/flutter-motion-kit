import type { APIRoute } from 'astro';
import catalog from '../../../../catalog.json';

// /api/animations.json —— 完整目录，供任意 agent / 工具消费。
export const GET: APIRoute = () =>
  new Response(JSON.stringify(catalog), {
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'access-control-allow-origin': '*',
    },
  });
