# FLUX Creator 桌面应用部署指南

## 概述

本指南说明如何将 FLUX Creator 桌面应用打包为 macOS 和 Windows 安装包。应用已经配置为云端服务 + 轻客户端架构，用户只需安装一个安装包即可使用。

## 已完成的工作

### ✅ 前端应用优化
- 移除了本地后端依赖
- 添加了云端 API 配置管理
- 实现了连接状态监控
- 添加了设置界面用于配置服务器地址和 API 密钥
- 优化了错误处理和重试机制

### ✅ 打包配置
- 配置了 electron-builder 进行跨平台打包
- 设置了 macOS DMG 和 Windows NSIS 安装包格式
- 成功生成了 Linux 版本安装包（AppImage 和 Snap）

## 跨平台打包要求

### macOS 安装包构建
**要求：** 必须在 macOS 系统上构建

```bash
# 在 macOS 系统上执行
cd flux-creator-desktop/frontend
npm install
npm run build
npm run dist -- --mac
```

**生成文件：**
- `FLUX Creator-1.0.0.dmg` - macOS 安装包
- 支持 Intel (x64) 和 Apple Silicon (arm64) 架构

### Windows 安装包构建
**要求：** 可在 Windows 系统或配置了 Wine 的 Linux 系统上构建

#### 方案一：在 Windows 系统上构建
```bash
# 在 Windows 系统上执行
cd flux-creator-desktop/frontend
npm install
npm run build
npm run dist -- --win
```

#### 方案二：在 Linux 上使用 Wine
```bash
# 安装 Wine（Ubuntu/Debian）
sudo apt update
sudo apt install wine

# 构建 Windows 安装包
cd flux-creator-desktop/frontend
npm run dist -- --win
```

**生成文件：**
- `FLUX Creator Setup 1.0.0.exe` - Windows 安装包
- 支持 x64 架构

## 当前可用的安装包

### Linux 版本（已生成）
位置：`flux-creator-desktop/frontend/dist-packages/`

- **AppImage**: `FLUX Creator-1.0.0.AppImage`
  - 便携式应用，无需安装
  - 适用于大多数 Linux 发行版
  
- **Snap**: `flux-creator-desktop_1.0.0_amd64.snap`
  - Ubuntu/Snap 商店格式
  - 自动依赖管理

## 应用配置说明

### 云端服务器配置
用户首次启动应用时需要配置：

1. **服务器地址**: 您的云端 API 服务器 URL
   - 格式：`https://your-api-server.com`
   - 或：`http://your-ip:port`

2. **API 密钥**（可选）: 如果您的 API 需要认证

### 应用特性
- **轻量级**: 客户端仅包含 UI，无需本地 GPU
- **云端处理**: 所有图像生成在您的服务器上完成
- **实时状态**: 显示与云端服务的连接状态
- **错误处理**: 自动重试和友好的错误提示

## 推荐的发布流程

### 阶段一：测试版本
1. 使用当前的 Linux AppImage 进行内部测试
2. 验证云端 API 连接和功能完整性

### 阶段二：跨平台发布
1. 在 macOS 系统上构建 DMG 安装包
2. 在 Windows 系统或配置 Wine 的环境中构建 EXE 安装包
3. 提供三个平台的安装包供用户下载

## 技术架构优势

### 用户体验
- **一键安装**: 用户只需下载并安装一个文件
- **即时使用**: 配置服务器地址后立即可用
- **无硬件要求**: 不需要本地 GPU 或大量存储空间

### 开发维护
- **集中式更新**: 功能更新只需更新云端服务
- **统一体验**: 所有平台使用相同的 UI 和功能
- **简化部署**: 客户端更新频率低，主要更新在服务端

## 下一步建议

1. **准备 macOS 构建环境**: 获取 macOS 系统进行 DMG 打包
2. **配置 Windows 构建**: 设置 Windows 环境或配置 Wine
3. **代码签名**: 为生产环境配置应用签名（可选但推荐）
4. **自动化 CI/CD**: 设置 GitHub Actions 进行自动化构建

## 联系信息

如需协助配置跨平台构建环境或有其他技术问题，请随时联系。