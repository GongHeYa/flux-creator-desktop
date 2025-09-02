import { buildApiUrl, API_ENDPOINTS, fetchWithRetry } from '../config/api';

// 图像生成请求参数
export interface ImageGenerationRequest {
  prompt: string;
  width: number;
  height: number;
  steps: number;
  cfg: number;
  seed: number;
}

// 图像生成响应
export interface ImageGenerationResponse {
  status: 'pending' | 'processing' | 'completed' | 'failed';
  task_id: string;
  message?: string;
}

// 任务状态响应
export interface TaskStatusResponse {
  status: 'pending' | 'processing' | 'completed' | 'failed';
  progress?: number;
  result?: {
    images: Array<{
      filename: string;
      subfolder: string;
      type: string;
      url: string;
    }>;
  };
  error?: string;
}

// API 服务类
export class ApiService {
  // 提交图像生成任务
  static async generateImage(request: ImageGenerationRequest): Promise<ImageGenerationResponse> {
    const url = buildApiUrl(API_ENDPOINTS.generate);
    
    const response = await fetchWithRetry(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(request)
    });
    
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || `HTTP ${response.status}: ${response.statusText}`);
    }
    
    return response.json();
  }
  
  // 查询任务状态
  static async getTaskStatus(taskId: string): Promise<TaskStatusResponse> {
    const url = buildApiUrl(API_ENDPOINTS.task(taskId));
    
    const response = await fetchWithRetry(url, {
      method: 'GET'
    });
    
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || `HTTP ${response.status}: ${response.statusText}`);
    }
    
    return response.json();
  }
  
  // 轮询任务状态直到完成
  static async pollTaskStatus(
    taskId: string,
    onProgress?: (progress: number) => void,
    pollInterval = 2000
  ): Promise<TaskStatusResponse> {
    return new Promise((resolve, reject) => {
      const poll = async () => {
        try {
          const status = await this.getTaskStatus(taskId);
          
          // 更新进度
          if (status.progress !== undefined && onProgress) {
            onProgress(status.progress);
          }
          
          // 检查是否完成
          if (status.status === 'completed' || status.status === 'failed') {
            resolve(status);
            return;
          }
          
          // 继续轮询
          setTimeout(poll, pollInterval);
        } catch (error) {
          reject(error);
        }
      };
      
      // 开始轮询
      setTimeout(poll, pollInterval);
    });
  }
  
  // 下载图像
  static async downloadImage(imageUrl: string, filename?: string): Promise<void> {
    const response = await fetchWithRetry(imageUrl);
    
    if (!response.ok) {
      throw new Error(`下载失败: HTTP ${response.status}`);
    }
    
    const blob = await response.blob();
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename || `flux-generated-${Date.now()}.png`;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    document.body.removeChild(a);
  }
}

// 错误处理工具函数
export function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    // 网络错误
    if (error.name === 'AbortError') {
      return '请求超时，请检查网络连接';
    }
    if (error.message.includes('fetch')) {
      return '无法连接到服务器，请检查网络连接和服务器状态';
    }
    return error.message;
  }
  
  return '未知错误';
}

// 导出默认实例
export default ApiService;