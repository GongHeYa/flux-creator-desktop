const { contextBridge, ipcRenderer } = require('electron');

// 暴露安全的 API 给渲染进程
contextBridge.exposeInMainWorld('electronAPI', {
  // 获取应用版本
  getAppVersion: () => ipcRenderer.invoke('get-app-version'),
  
  // 图像生成 API
  generateImage: (prompt) => ipcRenderer.invoke('generate-image', prompt),
  
  // 其他可能需要的 API
  platform: process.platform,
  
  // 文件操作相关（后续可能需要）
  openFile: () => ipcRenderer.invoke('open-file'),
  saveFile: (data) => ipcRenderer.invoke('save-file', data),
  
  // 应用控制
  minimize: () => ipcRenderer.invoke('minimize-window'),
  maximize: () => ipcRenderer.invoke('maximize-window'),
  close: () => ipcRenderer.invoke('close-window')
});

// 监听主进程发送的消息
contextBridge.exposeInMainWorld('electronEvents', {
  // 监听生成进度更新
  onGenerationProgress: (callback) => {
    ipcRenderer.on('generation-progress', (event, progress) => {
      callback(progress);
    });
  },
  
  // 移除监听器
  removeAllListeners: (channel) => {
    ipcRenderer.removeAllListeners(channel);
  }
});