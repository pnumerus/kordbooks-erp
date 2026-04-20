import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'
import Icons from 'unplugin-icons/vite'
import IconsResolver from 'unplugin-icons/resolver'
import Components from 'unplugin-vue-components/vite'
import { FileSystemIconLoader } from 'unplugin-icons/loaders'

const FRAPPE_BENCH_PORT = 8000

export default defineConfig(({ command }) => ({
  plugins: [
    vue(),
    Icons({
      autoInstall: true,
      customCollections: {
        lucide: FileSystemIconLoader(
          './node_modules/lucide-static/icons',
          svg => svg.replace(/^<svg /, '<svg fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" ')
        ),
      },
    }),
    Components({
      resolvers: [
        IconsResolver({
          prefix: '',
          customCollections: ['lucide'],
        }),
      ],
    }),
  ],

  server: {
    host: '0.0.0.0',
    port: 5173,
    proxy: {
      '^/(app|api|assets|files|private|login|logout|web_form)': {
        target: `http://127.0.0.1:${FRAPPE_BENCH_PORT}`,
        changeOrigin: true,
        ws: true,
      },
      '/socket.io': {
        target: `http://127.0.0.1:${FRAPPE_BENCH_PORT}`,
        changeOrigin: true,
        ws: true,
      },
    },
  },

  base: command === 'build'
    ? '/assets/kordbooks_erp/client_portal/'
    : '/',

  build: {
    outDir: path.resolve(__dirname, '..', 'public', 'client_portal'),
    emptyOutDir: true,
  },

  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
    },
  },
}))