import type { APIRoute } from 'astro';
import catalog from '../../../../catalog.json';

// /api/animations.json — the full catalog, for any agent / tool to consume.
export const GET: APIRoute = () =>
  new Response(JSON.stringify(catalog), {
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'access-control-allow-origin': '*',
    },
  });
