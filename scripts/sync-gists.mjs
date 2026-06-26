#!/usr/bin/env node
// Sync each animation's main.dart to a GitHub Gist and write the gistId back into meta.yaml.
// DartPad embeds and runs it via ?id=<gistId>.
//
// Usage: GITHUB_TOKEN=ghp_xxx node scripts/sync-gists.mjs
// The token needs gist permission. Entries with an existing gistId update that gist; otherwise a new one is created.
import { readdir, readFile, writeFile } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parse as parseYaml } from 'yaml';

const token = process.env.GITHUB_TOKEN;
if (!token) { console.error('GITHUB_TOKEN required (with gist permission)'); process.exit(1); }

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const animDir = join(root, 'content', 'animations');
const api = (path, init) =>
  fetch(`https://api.github.com${path}`, {
    ...init,
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: 'application/vnd.github+json',
      'Content-Type': 'application/json',
    },
  });

const ids = (await readdir(animDir, { withFileTypes: true }))
  .filter((d) => d.isDirectory()).map((d) => d.name);

for (const id of ids) {
  const metaPath = join(animDir, id, 'meta.yaml');
  const raw = await readFile(metaPath, 'utf8');
  const meta = parseYaml(raw);
  const code = await readFile(join(animDir, id, 'main.dart'), 'utf8');

  const body = JSON.stringify({
    description: `flutter-motion-kit · ${meta.title} (${id})`,
    public: true,
    files: { 'main.dart': { content: code } },
  });

  const existing = meta.gistId?.trim();
  const res = existing
    ? await api(`/gists/${existing}`, { method: 'PATCH', body })
    : await api('/gists', { method: 'POST', body });

  if (!res.ok) { console.error(`✗ ${id}: ${res.status} ${await res.text()}`); continue; }
  const gist = await res.json();

  if (gist.id !== existing) {
    // Write back the gistId (conservative line-based replace, to avoid reshuffling YAML comments)
    const updated = raw.match(/^gistId:/m)
      ? raw.replace(/^gistId:.*$/m, `gistId: "${gist.id}"`)
      : raw.replace(/^(verifiedOn:.*)$/m, `$1\ngistId: "${gist.id}"`);
    await writeFile(metaPath, updated);
  }
  console.log(`✓ ${id} -> https://dartpad.dev/?id=${gist.id}`);
}
