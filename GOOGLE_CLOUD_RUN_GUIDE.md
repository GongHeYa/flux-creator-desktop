# Google Cloud Run 部署指南

## 🌟 为什么选择 Google Cloud Run

- ✅ **免费额度充足**：每月 200 万次请求，180 万 CPU 秒
- ✅ **按需付费**：空闲时不收费，只为实际使用付费
- ✅ **自动扩缩容**：根据流量自动调整实例数量
- ✅ **支持 Docker**：可以直接使用我们的 Dockerfile
- ✅ **全球 CDN**：Google 的全球网络，访问速度快
- ✅ **HTTPS 自动配置**：自动提供 SSL 证书

## 🚀 快速部署步骤

### 第一步：准备 Google Cloud 账户

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 注册/登录 Google 账户
3. 创建新项目或选择现有项目
4. 启用 Cloud Run API 和 Container Registry API

### 第二步：安装 Google Cloud CLI

**Windows:**
```bash
# 下载并安装 Google Cloud CLI
# https://cloud.google.com/sdk/docs/install
```

**macOS:**
```bash
brew install google-cloud-sdk
```

**Linux:**
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

### 第三步：配置认证

```bash
# 登录 Google Cloud
gcloud auth login

# 设置项目 ID（替换为你的项目 ID）
gcloud config set project YOUR_PROJECT_ID

# 配置 Docker 认证
gcloud auth configure-docker
```

### 第四步：构建和推送 Docker 镜像

```bash
# 进入项目目录
cd flux-creator-desktop

# 设置项目 ID 和镜像名称
export PROJECT_ID=YOUR_PROJECT_ID
export IMAGE_NAME=flux-creator-backend
export IMAGE_TAG=latest

# 构建 Docker 镜像
docker build -t gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG ./backend

# 推送镜像到 Google Container Registry
docker push gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG
```

### 第五步：部署到 Cloud Run

```bash
# 部署服务
gcloud run deploy flux-creator-api \
  --image gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8000 \
  --memory 2Gi \
  --cpu 1 \
  --max-instances 10 \
  --set-env-vars PYTHONPATH=/app,FLUX_OUTPUT_DIR=/tmp/outputs
```

### 第六步：获取服务 URL

部署完成后，命令行会显示服务 URL，格式类似：
```
https://flux-creator-api-xxxxxxxxx-uc.a.run.app
```

## 🔧 环境变量配置

如果需要配置额外的环境变量：

```bash
gcloud run services update flux-creator-api \
  --region us-central1 \
  --set-env-vars PYTHONPATH=/app,FLUX_OUTPUT_DIR=/tmp/outputs,API_KEY=your-secret-key
```

## 📱 前端配置

获取 Cloud Run 服务 URL 后，使用构建脚本：

```bash
# 使用你的 Cloud Run URL
./build-cloud.sh https://flux-creator-api-xxxxxxxxx-uc.a.run.app
```

## 🔍 监控和日志

### 查看服务状态
```bash
gcloud run services describe flux-creator-api --region us-central1
```

### 查看日志
```bash
gcloud logs read --service flux-creator-api --region us-central1
```

### 查看实时日志
```bash
gcloud logs tail --service flux-creator-api --region us-central1
```

## 💰 成本估算

**免费额度（每月）：**
- 请求数：200 万次
- CPU 时间：180 万 CPU 秒
- 内存时间：36 万 GiB 秒
- 网络出站：1 GB

**超出免费额度后的价格：**
- CPU：$0.00002400 每 CPU 秒
- 内存：$0.00000250 每 GiB 秒
- 请求：$0.40 每百万次请求

对于个人项目，通常不会超出免费额度。

## 🛠 高级配置

### 自定义域名

1. 在 Cloud Run 控制台中选择服务
2. 点击「管理自定义域名」
3. 添加你的域名并验证
4. 配置 DNS 记录

### 设置最小实例数（避免冷启动）

```bash
gcloud run services update flux-creator-api \
  --region us-central1 \
  --min-instances 1
```

### 配置 VPC 连接器（连接数据库）

```bash
gcloud run services update flux-creator-api \
  --region us-central1 \
  --vpc-connector your-vpc-connector
```

## 🔧 故障排除

### 常见问题

**1. 部署失败：权限不足**
```bash
# 确保启用了必要的 API
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

**2. 镜像推送失败**
```bash
# 重新配置 Docker 认证
gcloud auth configure-docker
```

**3. 服务无法访问**
- 检查防火墙规则
- 确认 `--allow-unauthenticated` 参数
- 验证端口配置（8000）

**4. 内存不足**
```bash
# 增加内存限制
gcloud run services update flux-creator-api \
  --region us-central1 \
  --memory 4Gi
```

### 调试命令

```bash
# 查看服务详情
gcloud run services describe flux-creator-api --region us-central1

# 查看最近的部署
gcloud run revisions list --service flux-creator-api --region us-central1

# 测试服务健康状态
curl https://your-service-url.run.app/health
```

## 📚 相关文档

- [Google Cloud Run 官方文档](https://cloud.google.com/run/docs)
- [Cloud Run 定价](https://cloud.google.com/run/pricing)
- [Docker 容器最佳实践](https://cloud.google.com/run/docs/tips)

## 🎯 下一步

部署成功后：
1. 测试 API 端点：`https://your-service-url.run.app/docs`
2. 使用 `build-cloud.sh` 构建前端应用
3. 测试完整的图像生成功能
4. 配置监控和告警（可选）

---

💡 **提示**：Google Cloud Run 是目前最推荐的免费云端部署方案，特别适合个人项目和小型应用。