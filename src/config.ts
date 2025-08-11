// 检查构建环境
const isDesktop = (window as any).__APP_ENV__ === 'desktop'

// API 基础地址
const getApiBaseUrl = () => {
  if (import.meta.env.DEV) {
    // 开发环境
    return 'http://localhost:8080'
  } else {
    // 生产环境
    return isDesktop ? 'http://127.0.0.1:8080' : 'https://your-production-api.com'
  }
}

export const config = {
  apiBaseUrl: getApiBaseUrl(),
  isDesktop: isDesktop
}
