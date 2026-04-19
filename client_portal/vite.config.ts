import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

const FRAPPE_BENCH_PORT = 8000

export default defineConfig(({ command }) => ({
  plugins: [vue()],

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