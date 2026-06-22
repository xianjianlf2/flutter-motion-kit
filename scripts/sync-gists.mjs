#!/usr/bin/env node
// 把每条动画的 main.dart 同步成一个 GitHub Gist，并把 gistId 回写进 meta.yaml。
// DartPad 通过 ?id=<gistId> 内嵌运行。
//
// 用法：GITHUB_TOKEN=ghp_xxx node scripts/sync-gists.mjs
// token 需要 gist 权限。已有 gistId 的会更新该 gist，否则新建。
import { readdir, readFile, writeFile } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parse as parseYaml } from 'yaml';

const token = process.env.GITHUB_TOKEN;
if (!token) { console.error('需要 GITHUB_TOKEN（含 gist 权限）'); process.exit(1); }

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
    // 回写 gistId（保守地按行替换，避免重排 YAML 注释）
    const updated = raw.match(/^gistId:/m)
      ? raw.replace(/^gistId:.*$/m, `gistId: "${gist.id}"`)
      : raw.replace(/^(verifiedOn:.*)$/m, `$1\ngistId: "${gist.id}"`);
    await writeFile(metaPath, updated);
  }
  console.log(`✓ ${id} -> https://dartpad.dev/?id=${gist.id}`);
}
