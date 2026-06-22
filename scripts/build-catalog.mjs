#!/usr/bin/env node
// content/animations/*/{meta.yaml,main.dart,bad.dart} -> catalog.json
// 这是唯一数据源到「站点 + MCP + /api」的单一构建出口。
import { readdir, readFile, writeFile, stat } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parse as parseYaml } from 'yaml';
import Ajv from 'ajv';
import addFormats from 'ajv-formats';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const animDir = join(root, 'content', 'animations');

const schema = JSON.parse(await readFile(join(root, 'schema', 'animation.schema.json'), 'utf8'));
const ajv = new Ajv({ allErrors: true });
addFormats(ajv);
const validate = ajv.compile(schema);

async function readIfExists(p) {
  try { await stat(p); return await readFile(p, 'utf8'); } catch { return null; }
}

const ids = (await readdir(animDir, { withFileTypes: true }))
  .filter((d) => d.isDirectory())
  .map((d) => d.name);

const entries = [];
let errors = 0;

for (const id of ids) {
  const dir = join(animDir, id);
  const meta = parseYaml(await readFile(join(dir, 'meta.yaml'), 'utf8'));

  if (!validate(meta)) {
    errors++;
    console.error(`✗ ${id}/meta.yaml invalid:`);
    for (const e of validate.errors) console.error(`   ${e.instancePath} ${e.message}`);
    continue;
  }
  if (meta.id !== id) {
    errors++;
    console.error(`✗ ${id}: meta.id "${meta.id}" != folder name`);
    continue;
  }

  entries.push({
    ...meta,
    code: await readFile(join(dir, 'main.dart'), 'utf8'),
    badCode: await readIfExists(join(dir, 'bad.dart')),
    dartpadUrl: meta.gistId
      ? `https://dartpad.dev/embed-flutter.html?id=${meta.gistId}&theme=dark&split=60&run=true`
      : null,
  });
  console.log(`✓ ${id}`);
}

if (errors) {
  console.error(`\n${errors} entr${errors > 1 ? 'ies' : 'y'} failed validation`);
  process.exit(1);
}

entries.sort((a, b) => a.difficulty - b.difficulty || a.id.localeCompare(b.id));
const catalog = {
  generatedAt: process.env.BUILD_TIME ?? null, // 由 CI 注入，脚本本身不取系统时间
  count: entries.length,
  categories: [...new Set(entries.map((e) => e.category))].sort(),
  entries,
};

await writeFile(join(root, 'catalog.json'), JSON.stringify(catalog, null, 2));
console.log(`\nwrote catalog.json (${entries.length} entries)`);
