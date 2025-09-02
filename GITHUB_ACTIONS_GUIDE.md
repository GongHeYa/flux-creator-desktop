# GitHub Actions 自动构建指南

本指南详细说明如何使用 GitHub Actions 实现 FLUX Creator 桌面应用的跨平台自动构建和发布。

## 🚀 功能特性

- **跨平台构建**：自动在 Linux、macOS、Windows 三个平台上构建应用
- **自动发布**：推送版本标签时自动创建 GitHub Release
- **构建缓存**：优化构建速度，减少重复下载
- **多格式支持**：生成多种安装包格式

## 📋 前置要求

1. **GitHub 仓库**：将代码推送到 GitHub 仓库
2. **GitHub Actions**：确保仓库启用了 GitHub Actions
3. **代码签名**（可选）：用于 macOS 和 Windows 应用签名

## 🔧 配置步骤

### 1. 推送代码到 GitHub

```bash
# 初始化 Git 仓库（如果还没有）
git init
git add .
git commit -m "Initial commit"

# 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/flux-creator-desktop.git

# 推送代码
git push -u origin main
```

### 2. 启用 GitHub Actions

1. 进入 GitHub 仓库页面
2. 点击 "Actions" 标签
3. 如果是第一次使用，点击 "I understand my workflows, enable them"

### 3. 触发构建

#### 方式一：推送代码触发
```bash
# 任何推送到 main 分支的代码都会触发构建
git push origin main
```

#### 方式二：手动触发
1. 进入 GitHub 仓库的 Actions 页面
2. 选择 "Build and Release Electron App" 工作流
3. 点击 "Run workflow" 按钮
4. 选择分支并点击 "Run workflow"

#### 方式三：版本发布触发
```bash
# 创建版本标签会触发构建和自动发布
git tag v1.0.0
git push origin v1.0.0
```

## 📦 构建产物

### Linux 平台
- **AppImage**：便携式应用程序（推荐）
- **Snap**：Ubuntu 软件商店格式
- **DEB**：Debian/Ubuntu 安装包
- **RPM**：Red Hat/CentOS 安装包

### macOS 平台
- **DMG**：macOS 磁盘映像（推荐）
- **ZIP**：压缩包格式

### Windows 平台
- **EXE**：NSIS 安装程序（推荐）
- **MSI**：Windows Installer 格式

## 🔐 代码签名配置（可选但推荐）

### macOS 代码签名

1. **获取开发者证书**：
   - 注册 Apple Developer Program
   - 生成 Developer ID Application 证书

2. **配置 GitHub Secrets**：
   ```
   MAC_CERTS: Base64 编码的 .p12 证书文件
   MAC_CERTS_PASSWORD: 证书密码
   APPLE_ID: Apple ID 邮箱
   APPLE_ID_PASSWORD: App 专用密码
   ```

3. **启用签名**：
   在 `.github/workflows/build.yml` 中取消注释 macOS 签名相关的环境变量

### Windows 代码签名

1. **获取代码签名证书**：
   - 从 CA 机构购买代码签名证书
   - 导出为 .p12 格式

2. **配置 GitHub Secrets**：
   ```
   WIN_CERTS: Base64 编码的 .p12 证书文件
   WIN_CERTS_PASSWORD: 证书密码
   ```

3. **启用签名**：
   在 `.github/workflows/build.yml` 中取消注释 Windows 签名相关的环境变量

## 📋 使用流程

### 开发阶段
1. 在本地开发和测试应用
2. 推送代码到 GitHub
3. GitHub Actions 自动构建并生成测试版本
4. 从 Actions 页面下载构建产物进行测试

### 发布阶段
1. 更新 `frontend/package.json` 中的版本号
2. 提交版本更新：`git commit -am "Release v1.0.0"`
3. 创建版本标签：`git tag v1.0.0`
4. 推送标签：`git push origin v1.0.0`
5. GitHub Actions 自动构建并创建 GitHub Release
6. 编辑 Release 说明并发布

## 🔍 监控构建状态

1. **查看构建进度**：
   - 进入 GitHub 仓库的 Actions 页面
   - 点击具体的工作流运行
   - 查看各个平台的构建状态

2. **下载构建产物**：
   - 在工作流运行页面向下滚动
   - 在 "Artifacts" 部分下载对应平台的安装包

3. **查看构建日志**：
   - 点击具体的构建步骤
   - 查看详细的构建日志和错误信息

## ⚡ 优化建议

### 构建速度优化
1. **使用缓存**：工作流已配置 npm 和 Electron 缓存
2. **并行构建**：三个平台同时构建，节省时间
3. **增量构建**：只有代码变更时才重新构建

### 成本控制
1. **GitHub Actions 免费额度**：
   - 公开仓库：无限制
   - 私有仓库：每月 2000 分钟
2. **优化触发条件**：避免不必要的构建
3. **使用 draft release**：避免频繁发布

## 🛠️ 故障排除

### 常见问题

1. **构建失败**：
   - 检查 `package.json` 中的脚本配置
   - 确保所有依赖都在 `package.json` 中声明
   - 查看构建日志中的错误信息

2. **macOS 构建失败**：
   - 检查是否需要额外的 macOS 依赖
   - 确认代码签名配置（如果启用）

3. **Windows 构建失败**：
   - 检查路径分隔符问题
   - 确认 Windows 特定的依赖

4. **发布失败**：
   - 检查 `GITHUB_TOKEN` 权限
   - 确认标签格式正确（v*.*.* ）

### 调试技巧

1. **本地测试**：
   ```bash
   cd frontend
   npm run build
   npm run build:electron  # Linux
   npm run dist -- --mac   # macOS
   npm run dist -- --win   # Windows
   ```

2. **查看详细日志**：
   在工作流中添加调试步骤：
   ```yaml
   - name: Debug info
     run: |
       node --version
       npm --version
       ls -la
   ```

## 🎯 下一步

1. **自动化测试**：添加单元测试和集成测试
2. **多渠道发布**：发布到应用商店（Mac App Store、Microsoft Store）
3. **自动更新**：集成应用内自动更新功能
4. **性能监控**：添加应用性能和错误监控

## 📞 支持

如果在使用过程中遇到问题：
1. 查看 GitHub Actions 的官方文档
2. 检查 electron-builder 的配置文档
3. 在项目 Issues 中提出问题

---

通过 GitHub Actions，您现在可以轻松实现 FLUX Creator 桌面应用的跨平台自动构建和发布，无需手动在不同操作系统上进行构建操作。