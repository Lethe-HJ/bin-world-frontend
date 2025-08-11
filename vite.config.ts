import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueJsx from '@vitejs/plugin-vue-jsx'
import vueDevTools from 'vite-plugin-vue-devtools'

// 检查是否是桌面环境构建
const isDesktop = process.env.BUILD_TARGET === 'desktop'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    vueJsx(),
    vueDevTools(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  define: {
    // 注入环境变量
    '__APP_ENV__': JSON.stringify(process.env.BUILD_TARGET || 'web')
  },
  server: {
    port: 5173,
    host: '0.0.0.0', // 允许外部访问
    cors: true, // 启用跨域
    strictPort: true, // 如果端口被占用则失败
  },
  // 确保资源使用相对路径
  base: './',
  // 优化依赖处理
  optimizeDeps: {
    include: isDesktop ? ['@tauri-apps/api'] : []
  },
  build: {
    // 根据目标环境设置不同的输出目录
    outDir: isDesktop ? 'dist-desktop' : 'dist',
    // 桌面环境特定配置
    rollupOptions: {
      external: isDesktop ? ['@tauri-apps/api'] : [],
      output: {
        // 确保桌面环境下正确处理外部依赖
        format: isDesktop ? 'esm' : 'umd',
      }
    }
  }
})
