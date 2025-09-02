# FLUX Creator Desktop App

一个基于 Electron 的桌面应用程序，用于生成 AI 图像。支持本地部署和云端部署两种模式。

## 功能特性

- 🎨 AI 图像生成 (基于 FLUX 模型)
- ☁️ 云端 API 支持
- 🏠 本地服务器支持
- ⚙️ 灵活的服务器配置
- 🔧 实时连接状态监控
- 📱 跨平台支持 (Windows, macOS, Linux)
- 🚀 多种部署方案

## 🚀 快速开始

### 方案一：云端部署（推荐）

**适用场景**：希望应用可以在任何设备上使用，无需本地搭建环境。

#### 🌟 Google Cloud Run（首选免费方案）
```bash
# 1. 一键部署到 Google Cloud Run
./deploy-gcp.sh YOUR_PROJECT_ID

# 2. 构建云端版本前端
./build-cloud.sh https://your-service-url.run.app

# 3. 安装生成的应用包
```

#### 🔄 其他云平台
```bash
# Railway/Render/Heroku 等平台
# 详见：快速云端部署指南

./build-cloud.sh https://your-api-domain.com
```

📖 **详细指南**：
- 🚀 [Google Cloud Run 部署](./GOOGLE_CLOUD_RUN_GUIDE.md) - 推荐免费方案
- 📖 [多平台部署指南](./QUICK_CLOUD_SETUP.md) - 其他云平台选择

### 方案二：本地开发/部署

**适用场景**：开发调试或希望完全本地化运行。

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

#### 启动后端服务

```bash
# 进入后端目录
cd backend

# 安装依赖
pip install -r requirements.txt

# 启动服务
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

#### 构建前端应用

```bash
# 进入前端目录
cd frontend

# 安装依赖
npm install

# 构建前端
npm run build

# 构建 Electron 应用
npm run build:electron

# 跨平台打包
npm run dist -- --mac    # macOS
npm run dist -- --win    # Windows
npm run dist -- --linux  # Linux
```

### 方案三：Docker 部署

```bash
# 使用 Docker Compose 一键启动
docker-compose up -d

# 后端服务将在 http://localhost:8000 启动
# 然后构建前端应用连接到本地服务
```

## GitHub Actions 自动构建

本项目配置了 GitHub Actions 工作流，可以自动构建跨平台安装包：

- **Linux**: AppImage, Snap, DEB, RPM
- **macOS**: DMG, ZIP
- **Windows**: EXE, MSI

详细使用说明请参考 [GitHub Actions 指南](./GITHUB_ACTIONS_GUIDE.md)

## 📚 部署指南

### 云端部署
- 🚀 [5分钟快速云端部署](./QUICK_CLOUD_SETUP.md) - 推荐新手使用
- 📖 [完整云端部署指南](./CLOUD_DEPLOYMENT_GUIDE.md) - 详细配置说明

### 本地部署
- 🏠 [本地部署指南](./DEPLOYMENT_GUIDE.md) - 传统本地部署方式
- 🐳 [Docker 部署](./docker-compose.yml) - 容器化部署

### GitHub Actions
- ⚙️ [自动构建指南](./GITHUB_ACTIONS_GUIDE.md) - CI/CD 配置说明

## 🛠 技术栈

### 前端
- **框架**: React + TypeScript + Vite
- **桌面**: Electron + electron-builder
- **UI**: Ant Design
- **状态管理**: React Hooks

### 后端
- **框架**: FastAPI + Python
- **AI 模型**: FLUX (通过 ComfyUI)
- **图像处理**: PIL + OpenCV

### 部署
- **云平台**: Railway, Render, Heroku
- **容器**: Docker + Docker Compose
- **CI/CD**: GitHub Actions

## 许可证

MIT License