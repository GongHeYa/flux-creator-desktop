const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const isDev = process.env.NODE_ENV === 'development';

function createWindow() {
  // 创建浏览器窗口
  const mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false,
      preload: path.join(__dirname, 'preload.js')
    },
    icon: path.join(__dirname, 'assets/icon.png'), // 可选：应用图标
    titleBarStyle: 'default',
    show: false // 先隐藏窗口，等加载完成后再显示
  });

  // 加载应用
  if (isDev) {
    mainWindow.loadURL('http://localhost:5173');
    // 开发环境下打开开发者工具
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(__dirname, '../dist/index.html'));
  }

  // 当页面加载完成后显示窗口
  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
  });

  // 当窗口关闭时的处理
  mainWindow.on('closed', () => {
    // 在 macOS 上，通常应用会保持活跃状态
    // 即使没有打开的窗口，直到用户明确退出
    if (process.platform !== 'darwin') {
      app.quit();
    }
  });

  return mainWindow;
}

// 当 Electron 完成初始化并准备创建浏览器窗口时调用此方法
app.whenReady().then(() => {
  createWindow();

  app.on('activate', () => {
    // 在 macOS 上，当点击 dock 图标并且没有其他窗口打开时，
    // 通常会重新创建一个窗口
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

// 当所有窗口关闭时退出应用
app.on('window-all-closed', () => {
  // 在 macOS 上，应用通常会保持活跃状态
  // 即使没有打开的窗口，直到用户明确退出
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// 在开发环境中，可能需要处理证书错误
if (isDev) {
  app.commandLine.appendSwitch('--ignore-certificate-errors');
  app.commandLine.appendSwitch('--ignore-ssl-errors');
}

// IPC 通信处理（用于前后端通信）
ipcMain.handle('get-app-version', () => {
  return app.getVersion();
});

// 移除了本地后端相关的 IPC 处理
// 现在直接通过 HTTP API 调用云端服务