# Render 平台部署指南

本指南详细说明如何在 Render 平台部署 FLUX Creator 后端服务，并解决常见的部署问题。

## 🚨 常见问题解决

### 问题："failed to read dockerfile: open Dockerfile: no such file or directory"

**原因：** Render 平台无法找到 Dockerfile 文件，通常是路径配置问题。

**解决方案：**

1. **检查 render.yaml 配置**
   确保 `dockerfilePath` 和 `dockerContext` 配置正确：
   ```yaml
   services:
     - type: web
       name: flux-creator-backend
       env: docker
       dockerfilePath: backend/Dockerfile  # 相对于项目根目录
       dockerContext: .                    # 构建上下文为项目根目录
   ```

2. **验证文件结构**
   确保项目结构如下：
   ```
   flux-creator-desktop/
   ├── render.yaml
   ├── backend/
   │   ├── Dockerfile
   │   ├── requirements.txt
   │   └── app/
   └── ...
   ```

## 🚀 完整部署步骤

### 步骤 1: 准备代码

1. **确保代码已推送到 GitHub**
   ```bash
   git add .
   git commit -m "Update render.yaml configuration"
   git push origin main
   ```

### 步骤 2: 在 Render 创建服务

1. **访问 Render 控制台**
   - 打开 [Render.com](https://render.com)
   - 登录或注册账号

2. **连接 GitHub 仓库**
   - 点击 "New +" → "Web Service"
   - 选择 "Build and deploy from a Git repository"
   - 连接你的 GitHub 账号
   - 选择 `flux-creator-desktop` 仓库

3. **配置服务设置**
   - **Name**: `flux-creator-backend`
   - **Environment**: `Docker`
   - **Region**: 选择离你最近的区域
   - **Branch**: `main`

### 步骤 3: 高级配置

1. **环境变量设置**
   ```
   PYTHONPATH=/app
   FLUX_OUTPUT_DIR=/tmp/flux_images
   PORT=8000
   ```

2. **健康检查**
   - **Health Check Path**: `/health`

3. **自动部署**
   - 启用 "Auto-Deploy" 选项

### 步骤 4: 部署和验证

1. **开始部署**
   - 点击 "Create Web Service"
   - 等待构建和部署完成（通常需要 5-10 分钟）

2. **验证部署**
   - 部署完成后，Render 会提供一个 URL（如：`https://flux-creator-backend.onrender.com`）
   - 访问 `https://your-service-url.onrender.com/health` 检查服务状态
   - 访问 `https://your-service-url.onrender.com/docs` 查看 API 文档

## 🔧 故障排除

### 构建失败

1. **检查构建日志**
   - 在 Render 控制台查看详细的构建日志
   - 查找具体的错误信息

2. **常见问题**
   - **Dockerfile 路径错误**: 确保 `dockerfilePath` 正确
   - **依赖安装失败**: 检查 `requirements.txt` 文件
   - **端口配置错误**: 确保使用环境变量 `$PORT`

### 服务启动失败

1. **检查启动命令**
   ```dockerfile
   CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
   ```

2. **检查健康检查端点**
   确保 `/health` 端点正常响应

### 内存不足

1. **升级服务计划**
   - 免费计划有 512MB 内存限制
   - 考虑升级到付费计划获得更多资源

## 📊 监控和维护

### 查看日志
```bash
# 在 Render 控制台的 "Logs" 标签页查看实时日志
```

### 性能监控
- 使用 Render 内置的监控功能
- 监控 CPU 和内存使用情况
- 设置告警通知

### 自动重启
- Render 会自动重启失败的服务
- 可以手动重启服务进行故障恢复

## 💰 费用说明

### 免费计划
- **内存**: 512MB
- **CPU**: 共享
- **带宽**: 100GB/月
- **限制**: 服务会在无活动时休眠

### 付费计划
- **Starter**: $7/月，1GB 内存，不休眠
- **Standard**: $25/月，2GB 内存，更好性能

## 🔗 相关链接

- [Render 官方文档](https://render.com/docs)
- [Docker 部署指南](https://render.com/docs/docker)
- [环境变量配置](https://render.com/docs/environment-variables)

---

**注意**: 如果仍然遇到问题，请检查 GitHub 仓库中的文件是否完整，特别是 `backend/Dockerfile` 和 `render.yaml` 文件。