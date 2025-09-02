# 🚀 FLUX Creator 云端部署快速指南

本指南将帮助你在 5 分钟内完成 FLUX Creator 的云端部署。

## 📋 准备工作

1. ✅ 确保你有 GitHub 账号
2. ✅ 将代码推送到 GitHub 仓库
3. ✅ 选择一个云平台（推荐 Google Cloud Run）

## 🎯 方案一：Google Cloud Run 部署（推荐）

**优势：**
- 🆓 每月 200 万次请求免费
- ⚡ 自动扩缩容，按需付费
- 🌍 全球 CDN 加速
- 🔒 自动 HTTPS 证书

### 快速部署步骤

```bash
# 1. 运行自动部署脚本
./deploy-gcp.sh YOUR_PROJECT_ID

# 2. 构建前端应用（使用脚本返回的 URL）
./build-cloud.sh https://your-service-url.run.app

# 3. 安装生成的应用包
```

📖 **详细指南**：[Google Cloud Run 完整部署教程](./GOOGLE_CLOUD_RUN_GUIDE.md)

---

## 🎯 方案二：Railway 部署

### 步骤 1: 部署后端

1. 访问 [Railway.app](https://railway.app)
2. 点击 "Start a New Project"
3. 选择 "Deploy from GitHub repo"
4. 选择你的 `flux-creator-desktop` 仓库
5. Railway 会自动检测到 `railway.json` 配置并开始部署
6. 等待部署完成（约 3-5 分钟）
7. 复制分配的域名（如：`https://flux-creator-backend-production.railway.app`）

### 步骤 2: 测试后端

```bash
# 替换为你的实际域名
curl https://your-app.railway.app/health
```

应该返回：
```json
{"status":"healthy","message":"FLUX Creator Desktop API is running"}
```

### 步骤 3: 构建前端

```bash
# 使用云端构建脚本
./build-cloud.sh https://your-app.railway.app railway
```

### 步骤 4: 测试应用

1. 安装生成的应用（在 `frontend/dist-packages/` 目录）
2. 打开应用设置
3. 服务器地址应该已自动配置为云端地址
4. 点击"测试连接"，状态应显示"已连接"

## 🎯 方案三：Render 部署

### 步骤 1: 部署后端

1. 访问 [Render.com](https://render.com)
2. 连接 GitHub 账号
3. 点击 "New" → "Web Service"
4. 选择你的 `flux-creator-desktop` 仓库
5. Render 会自动检测到 `render.yaml` 配置
6. 点击 "Create Web Service"
7. 等待部署完成
8. 复制分配的域名（如：`https://flux-creator-backend.onrender.com`）

### 步骤 2: 构建前端

```bash
./build-cloud.sh https://your-app.onrender.com render
```

## 🎯 方案四：手动配置

如果你已经有云服务器或其他部署方式：

### 1. 部署后端

```bash
# 克隆代码
git clone https://github.com/your-username/flux-creator-desktop.git
cd flux-creator-desktop

# 使用 Docker 部署
docker-compose up -d

# 或手动部署
cd backend
pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### 2. 构建前端

```bash
# 替换为你的服务器地址
./build-cloud.sh https://your-server.com custom
```

## 🔧 故障排除

### 后端部署失败

1. **检查日志**：在云平台控制台查看部署日志
2. **验证文件**：确保 `Dockerfile` 和配置文件存在
3. **检查依赖**：确保 `requirements.txt` 包含所有依赖

### 前端连接失败

1. **测试后端**：
   ```bash
   curl https://your-domain.com/health
   curl https://your-domain.com/api/v1/health
   ```

2. **检查 CORS**：确保后端允许前端域名访问

3. **验证 HTTPS**：确保使用 HTTPS 协议

### 应用显示离线

1. **检查网络**：确保设备能访问云端服务
2. **验证配置**：在应用设置中检查服务器地址
3. **重新构建**：使用正确的云端地址重新构建应用

## 📊 部署状态检查

创建一个简单的检查脚本：

```bash
#!/bin/bash
API_URL="https://your-domain.com"

echo "🔍 检查后端服务状态..."
curl -s "$API_URL/health" | jq .

echo "🔍 检查 API 端点..."
curl -s "$API_URL/api/v1/health" | jq .

echo "✅ 如果以上都返回正常，说明部署成功！"
```

## 💡 优化建议

1. **监控设置**：在云平台设置健康检查和监控
2. **日志管理**：定期查看应用日志
3. **备份策略**：定期备份重要数据
4. **性能优化**：根据使用情况调整服务器配置

## 🆘 获取帮助

如果遇到问题：

1. 查看详细的 [云端部署指南](./CLOUD_DEPLOYMENT_GUIDE.md)
2. 检查 [故障排除文档](./DEPLOYMENT_GUIDE.md)
3. 在 GitHub Issues 中提问

---

🎉 **恭喜！你的 FLUX Creator 现在可以在任何设备上使用了！**