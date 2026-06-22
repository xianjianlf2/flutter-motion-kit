import { defineConfig } from 'astro/config';

// 部署到 Vercel/CF Pages 时把 site 改成你的域名，base 视情况调整。
export default defineConfig({
  site: 'https://flutter-motion-kit.pages.dev',
  srcDir: './src',
});
