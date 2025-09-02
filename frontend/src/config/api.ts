// API 配置文件
export interface ApiConfig {
  baseUrl: string;
  timeout: number;
  retryAttempts: number;
  retryDelay: number;
}

// 默认配置
const defaultConfig: ApiConfig = {
  baseUrl: 'http://localhost:8000', // 开发环境默认值
  timeout: 30000, // 30秒超时
  retryAttempts: 3,
  retryDelay: 1000 // 1秒重试延迟
};

// 从环境变量或本地存储获取配置
function getApiConfig(): ApiConfig {
  // 优先从本地存储获取用户设置的服务器地址
  const savedConfig = localStorage.getItem('flux-api-config');
  if (savedConfig) {
    try {
      const parsed = JSON.parse(savedConfig);
      return { ...defaultConfig, ...parsed };
    } catch (error) {
      console.warn('Failed to parse saved API config:', error);
    }
  }
  
  // 从环境变量获取（打包时可以设置）
  const envBaseUrl = import.meta.env.VITE_API_BASE_URL;
  if (envBaseUrl) {
    return { ...defaultConfig, baseUrl: envBaseUrl };
  }
  
  return defaultConfig;
}

// 保存 API 配置到本地存储
export function saveApiConfig(config: Partial<ApiConfig>): void {
  const currentConfig = getApiConfig();
  const newConfig = { ...currentConfig, ...config };
  localStorage.setItem('flux-api-config', JSON.stringify(newConfig));
}

// 获取当前 API 配置
export function getConfig(): ApiConfig {
  return getApiConfig();
}

// API 端点
export const API_ENDPOINTS = {
  generate: '/api/v1/generate',
  task: (taskId: string) => `/api/v1/task/${taskId}`,
  health: '/api/v1/health'
} as const;

// 构建完整的 API URL
export function buildApiUrl(endpoint: string): string {
  const config = getConfig();
  return `${config.baseUrl}${endpoint}`;
}

// 检查 API 连接状态
export async function checkApiHealth(): Promise<{ status: 'online' | 'offline'; message: string }> {
  try {
    const config = getConfig();
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), config.timeout);
    
    const response = await fetch(buildApiUrl(API_ENDPOINTS.health), {
      method: 'GET',
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    
    if (response.ok) {
      return { status: 'online', message: '服务连接正常' };
    } else {
      return { status: 'offline', message: `服务响应异常: ${response.status}` };
    }
  } catch (error) {
    if (error instanceof Error) {
      if (error.name === 'AbortError') {
        return { status: 'offline', message: '连接超时' };
      }
      return { status: 'offline', message: `连接失败: ${error.message}` };
    }
    return { status: 'offline', message: '未知连接错误' };
  }
}

// 带重试的 fetch 函数
export async function fetchWithRetry(
  url: string,
  options: RequestInit = {},
  retryCount = 0
): Promise<Response> {
  const config = getConfig();
  
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), config.timeout);
    
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    return response;
  } catch (error) {
    if (retryCount < config.retryAttempts) {
      console.warn(`Request failed, retrying (${retryCount + 1}/${config.retryAttempts}):`, error);
      await new Promise(resolve => setTimeout(resolve, config.retryDelay * (retryCount + 1)));
      return fetchWithRetry(url, options, retryCount + 1);
    }
    throw error;
  }
}