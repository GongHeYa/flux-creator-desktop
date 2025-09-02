# FLUX Creator Desktop App

一个基于 Electron 的桌面应用程序，用于生成 AI 图像。

## 功能特性

- 🎨 AI 图像生成
- ⚙️ 云端 API 配置
- 🔧 实时连接状态监控
- 📱 跨平台支持 (Windows, macOS, Linux)
- 🚀 GitHub Actions 自动构建

## 快速开始

### 本地开发

```bash
# 进入前端目录
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 启动 Electron 应用
npm run electron:dev
```

### 构建应用

```bash
# 构建前端
npm run build

# 构建 Electron 应用
npm run build:electron

# 跨平台打包
npm run dist -- --mac    # macOS
npm run dist -- --win    # Windows
npm run dist -- --linux  # Linux
```

## GitHub Actions 自动构建

本项目配置了 GitHub Actions 工作流，可以自动构建跨平台安装包：

- **Linux**: AppImage, Snap, DEB, RPM
- **macOS**: DMG, ZIP
- **Windows**: EXE, MSI

详细使用说明请参考 [GitHub Actions 指南](./GITHUB_ACTIONS_GUIDE.md)

## 部署指南

查看 [部署指南](./DEPLOYMENT_GUIDE.md) 了解详细的部署和打包说明。

## 技术栈

- **前端**: React + TypeScript + Vite
- **桌面框架**: Electron
- **打包工具**: electron-builder
- **CI/CD**: GitHub Actions
- **UI 组件**: Ant Design

## 许可证

MIT License