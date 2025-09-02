# FLUX Creator 云服务部署指南

本指南将帮助你将 FLUX Creator 后端服务部署到云平台，实现前端应用的云端化。

## 🌟 推荐云平台

### 1. Railway (推荐 - 最简单)

**优点：**
- 免费额度：每月 $5 免费使用
- 自动从 GitHub 部署
- 内置域名和 HTTPS
- 零配置部署

**部署步骤：**
1. 访问 [Railway.app](https://railway.app)
2. 连接你的 GitHub 账号
3. 选择 flux-creator-desktop 仓库
4. Railway 会自动检测 Dockerfile 并部署
5. 获取分配的域名（如：`https://your-app.railway.app`）

### 2. Render (推荐 - 稳定)

**优点：**
- 免费层：每月 750 小时
- 自动 SSL 证书
- 从 GitHub 自动部署
- 良好的日志系统

**部署步骤：**
1. 访问 [Render.com](https://render.com)
2. 连接 GitHub 账号
3. 创建新的 Web Service
4. 选择 flux-creator-desktop 仓库
5. 设置构建命令：`cd backend && pip install -r requirements.txt`
6. 设置启动命令：`cd backend && python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT`

### 3. Heroku

**优点：**
- 成熟的平台
- 丰富的插件生态
- 简单的 CLI 工具

**部署步骤：**
1. 安装 Heroku CLI
2. 登录：`heroku login`
3. 创建应用：`heroku create flux-creator-backend`
4. 设置构建包：`heroku buildpacks:set heroku/python`
5. 部署：`git push heroku main`

### 4. 阿里云/腾讯云 (国内用户)

**优点：**
- 国内访问速度快
- 丰富的云服务
- 中文支持

**部署步骤：**
1. 创建云服务器实例
2. 安装 Docker
3. 上传代码并构建镜像
4. 运行容器

## 🚀 快速部署脚本

### Railway 部署

创建 `railway.json` 配置文件：

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "backend/Dockerfile"
  },
  "deploy": {
    "startCommand": "python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT",
    "healthcheckPath": "/health",
    "healthcheckTimeout": 100
  }
}
```

### Render 部署

创建 `render.yaml` 配置文件：

```yaml
services:
  - type: web
    name: flux-creator-backend
    env: python
    buildCommand: cd backend && pip install -r requirements.txt
    startCommand: cd backend && python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT
    healthCheckPath: /health
    envVars:
      - key: PYTHONPATH
        value: /opt/render/project/src/backend
```

## 🔧 环境变量配置

在云平台设置以下环境变量：

```bash
# 必需的环境变量
PYTHONPATH=/app  # 或根据平台调整
FLUX_OUTPUT_DIR=/tmp/flux_images
PORT=8000  # 某些平台会自动设置

# 可选的环境变量
COMFYUI_MODEL_PATH=/app/models
MAX_WORKERS=2
TIMEOUT=300
```

## 📝 部署后配置

### 1. 获取云端 API 地址

部署成功后，你会获得一个公网地址，例如：
- Railway: `https://flux-creator-backend-production.railway.app`
- Render: `https://flux-creator-backend.onrender.com`
- Heroku: `https://flux-creator-backend.herokuapp.com`

### 2. 测试云端服务

```bash
# 测试健康检查
curl https://your-domain.com/health

# 测试 API 端点
curl https://your-domain.com/api/v1/health
```

### 3. 更新前端配置

修改前端的 API 配置，将默认地址改为云端地址：

```typescript
// frontend/src/config/api.ts
const defaultConfig: ApiConfig = {
  baseUrl: 'https://your-domain.com', // 改为云端地址
  timeout: 30000,
  retryAttempts: 3,
  retryDelay: 1000
};
```

## 🔒 安全配置

### CORS 设置

更新后端 CORS 配置以允许前端域名：

```python
# backend/app/main.py
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",  # 开发环境
        "https://your-frontend-domain.com",  # 生产环境
        "*"  # 或允许所有域名（不推荐生产环境）
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### API 密钥（可选）

为了增加安全性，可以添加 API 密钥验证：

```python
# 在路由中添加认证
from fastapi import Header, HTTPException

async def verify_api_key(x_api_key: str = Header()):
    if x_api_key != os.getenv("API_KEY"):
        raise HTTPException(status_code=401, detail="Invalid API Key")
```

## 📊 监控和日志

### 健康检查

确保云平台配置了健康检查：
- 路径：`/health`
- 间隔：30秒
- 超时：10秒

### 日志查看

各平台查看日志的方法：
- Railway: 在控制台的 "Deployments" 页面
- Render: 在服务详情页的 "Logs" 标签
- Heroku: `heroku logs --tail`

## 🚨 故障排除

### 常见问题

1. **部署失败**
   - 检查 Dockerfile 路径
   - 确认依赖文件存在
   - 查看构建日志

2. **服务无法访问**
   - 检查端口配置
   - 确认健康检查通过
   - 验证 CORS 设置

3. **前端连接失败**
   - 确认 API 地址正确
   - 检查 HTTPS/HTTP 协议
   - 验证网络连接

### 调试命令

```bash
# 本地测试 Docker 镜像
docker build -t flux-backend ./backend
docker run -p 8000:8000 flux-backend

# 测试云端 API
curl -v https://your-domain.com/api/v1/health
```

## 💰 成本估算

| 平台 | 免费额度 | 付费起价 | 适用场景 |
|------|----------|----------|----------|
| Railway | $5/月 | $5/月 | 个人项目 |
| Render | 750小时/月 | $7/月 | 小型应用 |
| Heroku | 550小时/月 | $7/月 | 原型开发 |
| 阿里云 | 试用额度 | ¥50/月 | 国内用户 |

选择最适合你需求和预算的平台进行部署！
