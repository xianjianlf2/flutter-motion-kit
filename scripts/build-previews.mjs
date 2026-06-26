#!/usr/bin/env node
// content/animations/*/main.dart -> site/public/preview/<id>/ （真实可跑的 Flutter web）
//
// 自托管「在线预览」：每条 main.dart 编译成真正运行的 Flutter web，站点直接 iframe 内嵌。
// 不依赖 DartPad / gist / token，和唯一数据源同步——和「机器验证」一脉相承：能编译能跑才收录。
//
// 用法：
//   node scripts/build-previews.mjs            # 自动探测 flutter（本地优先 fvm）
//   FLUTTER="fvm flutter" node scripts/...     # 显式指定
//   PREVIEW_IDS=hero-shared-element node ...    # 只构建部分（逗号分隔，调试用）
//
// 产物在 .gitignore 中——本地按需重建，CI 部署时生成。
import { readdir, mkdir, rm, cp, stat, writeFile, readFile } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execSync, execFileSync } from 'node:child_process';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const animDir = join(root, 'content', 'animations');
const outRoot = join(root, 'site', 'public', 'preview');
const work = join(root, '_preview'); // gitignored 脚手架工程，复用以省去重复 create

const FLUTTER_VERSION = process.env.FLUTTER_VERSION ?? '3.32.0';

// 删掉只为体积/调试存在、运行时用不到的产物（canvaskit 渲染器不需要 skwasm/chromium/symbols）。
const STRIP = ['canvaskit/chromium', 'canvaskit/skwasm.js', 'canvaskit/skwasm.js.symbols',
  'canvaskit/skwasm.wasm', 'canvaskit/canvaskit.js.symbols'];

function detectFlutter() {
  if (process.env.FLUTTER) return process.env.FLUTTER;
  try { execSync('fvm --version', { stdio: 'ignore' }); return 'fvm flutter'; } catch {}
  return 'flutter';
}
const FLUTTER = detectFlutter();
const usingFvm = FLUTTER.startsWith('fvm');

function run(cmd, args, cwd) {
  const [bin, ...pre] = cmd.split(' ');
  execFileSync(bin, [...pre, ...args], { cwd, stdio: 'inherit' });
}

async function exists(p) { try { await stat(p); return true; } catch { return false; } }

// 一次性脚手架：空 web 工程，pin 到目标 Flutter 版本（用 fvm 时）。
async function ensureWorkspace() {
  if (usingFvm) try { run('fvm', ['install', FLUTTER_VERSION], root); } catch {}
  if (!(await exists(join(work, 'pubspec.yaml')))) {
    await rm(work, { recursive: true, force: true });
    // 用 pin 的版本来 create，避免「用旧版生成模板、用新版构建」的版本错配
    if (usingFvm) run('fvm', ['spawn', FLUTTER_VERSION, 'create', '--platforms=web', '-e', work], root);
    else run(FLUTTER, ['create', '--platforms=web', '-e', work], root);
  }
  if (usingFvm) {
    // 让 `fvm flutter` 在该目录锁定到验证用的版本
    await writeFile(join(work, '.fvmrc'), JSON.stringify({ flutter: FLUTTER_VERSION }, null, 2) + '\n');
  }
  // 镜像 CI 的 lint 基线，保证本地预览版与 main.dart 同源
  const lint = join(root, 'very_good_analysis.yaml');
  if (await exists(lint)) await cp(lint, join(work, 'analysis_options.yaml'));
}

async function buildOne(id) {
  const src = join(animDir, id, 'main.dart');
  if (!(await exists(src))) { console.error(`✗ ${id}: 缺 main.dart`); return false; }
  await cp(src, join(work, 'lib', 'main.dart'));

  const base = `/preview/${id}/`;
  run(FLUTTER, ['build', 'web', '--release', '--pwa-strategy=none', `--base-href=${base}`], work);

  const webDir = join(work, 'build', 'web');
  for (const rel of STRIP) await rm(join(webDir, rel), { recursive: true, force: true });

  const dest = join(outRoot, id);
  await rm(dest, { recursive: true, force: true });
  await mkdir(dest, { recursive: true });
  await cp(webDir, dest, { recursive: true });
  console.log(`✓ ${id} -> site/public/preview/${id}/`);
  return true;
}

const all = (await readdir(animDir, { withFileTypes: true }))
  .filter((d) => d.isDirectory()).map((d) => d.name);
const only = process.env.PREVIEW_IDS?.split(',').map((s) => s.trim()).filter(Boolean);
const ids = only?.length ? all.filter((id) => only.includes(id)) : all;

console.log(`flutter: ${FLUTTER}${usingFvm ? ` (pin ${FLUTTER_VERSION})` : ''} · 构建 ${ids.length} 条预览`);
await ensureWorkspace();
await mkdir(outRoot, { recursive: true });

let ok = 0;
for (const id of ids) { if (await buildOne(id)) ok++; }

// 一个 manifest，站点据此知道哪些预览已就绪（避免内嵌坏 iframe）
const built = [];
for (const id of all) if (await exists(join(outRoot, id, 'index.html'))) built.push(id);
await writeFile(join(outRoot, 'manifest.json'), JSON.stringify({ built }, null, 2) + '\n');

console.log(`\n${ok}/${ids.length} 预览构建成功；manifest: ${built.length} 条就绪`);
if (ok < ids.length) process.exit(1);
