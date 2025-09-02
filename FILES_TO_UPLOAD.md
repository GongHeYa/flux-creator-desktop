# 📋 GitHub 上传文件清单

本文档详细列出了需要推送到 GitHub 仓库的所有文件和目录。

## ✅ 必须上传的文件

### 📁 项目根目录文件

```
flux-creator-desktop/
├── README.md                    # 项目说明文档
├── .gitignore                   # Git 忽略规则
├── docker-compose.yml           # Docker 编排配置
├── railway.json                 # Railway 部署配置
├── render.yaml                  # Render 部署配置
├── deploy-gcp.sh               # Google Cloud Run 部署脚本
├── build-cloud.sh              # 云端构建脚本
├── build-local.sh              # 本地构建脚本
├── build-all-platforms.sh      # 多平台构建脚本
├── push-to-github.sh           # GitHub 推送脚本
└── test-app-structure.sh       # 应用结构测试脚本
```

### 📚 文档文件

```
├── QUICK_CLOUD_SETUP.md         # 快速云端部署指南
├── GOOGLE_CLOUD_RUN_GUIDE.md    # Google Cloud Run 部署指南
├── CLOUD_DEPLOYMENT_GUIDE.md    # 云端部署指南
├── DEPLOYMENT_GUIDE.md          # 本地部署指南
├── GITHUB_ACTIONS_GUIDE.md      # GitHub Actions 指南
├── GITHUB_PUSH_GUIDE.md         # GitHub 推送指南
├── ALTERNATIVE_BUILD_METHODS.md # 替代构建方法
└── FILES_TO_UPLOAD.md           # 本文件清单
```

### 🐍 后端文件 (backend/)

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                  # FastAPI 主应用
│   ├── models/
│   │   ├── __init__.py
│   │   └── image_request.py     # 数据模型
│   ├── services/
│   │   ├── __init__.py
│   │   ├── comfyui_service.py   # ComfyUI 服务
│   │   └── image_service.py     # 图像处理服务
│   ├── utils/
│   │   ├── __init__.py
│   │   ├── config.py            # 配置管理
│   │   └── logger.py            # 日志工具
│   └── workflows/
│       ├── __init__.py
│       └── flux_workflow.py     # FLUX 工作流
├── Dockerfile                   # Docker 构建文件
└── requirements.txt             # Python 依赖
```

### ⚛️ 前端文件 (frontend/)

```
frontend/
├── src/
│   ├── components/
│   │   ├── ImageGenerator.tsx   # 图像生成组件
│   │   ├── ImageHistory.tsx     # 历史记录组件
│   │   ├── ParameterPanel.tsx   # 参数面板组件
│   │   └── StatusBar.tsx        # 状态栏组件
│   ├── config/
│   │   └── api.ts               # API 配置
│   ├── hooks/
│   │   └── useImageGeneration.ts # 图像生成钩子
│   ├── services/
│   │   └── api.ts               # API 服务
│   ├── types/
│   │   └── index.ts             # 类型定义
│   ├── utils/
│   │   └── helpers.ts           # 工具函数
│   ├── App.tsx                  # 主应用组件
│   ├── App.css                  # 应用样式
│   ├── main.tsx                 # 入口文件
│   └── index.css                # 全局样式
├── .env.example                 # 环境变量示例
├── .gitignore                   # 前端 Git 忽略规则
├── eslint.config.js             # ESLint 配置
├── index.html                   # HTML 模板
├── main.js                      # Electron 主进程
├── preload.js                   # Electron 预加载脚本
├── package.json                 # 项目配置
├── package-lock.json            # 依赖锁定文件
├── tsconfig.json                # TypeScript 配置
├── tsconfig.app.json            # 应用 TypeScript 配置
├── tsconfig.node.json           # Node.js TypeScript 配置
└── vite.config.ts               # Vite 配置
```

### 🔧 CI/CD 配置

```
.github/
└── workflows/
    ├── build-and-test.yml       # 构建和测试工作流
    ├── build-linux.yml          # Linux 构建工作流
    ├── build-windows.yml        # Windows 构建工作流
    ├── build-macos.yml          # macOS 构建工作流
    └── deploy.yml               # 部署工作流

.circleci/
└── config.yml                   # CircleCI 配置

.gitlab-ci.yml                   # GitLab CI 配置
```

## ❌ 不应上传的文件

### 🚫 自动生成的文件

```
# Node.js 依赖
frontend/node_modules/           # 体积巨大 (>500MB)
node_modules/

# 构建产物
frontend/dist/                   # Vite 构建输出
frontend/build/                  # 备用构建目录
frontend/dist-packages/          # Electron 打包产物
build/
dist/

# Python 缓存
__pycache__/
*.pyc
*.pyo
*.pyd

# Python 虚拟环境
.venv/
venv/
ENV/
env/
```

### 🔐 敏感信息

```
# 环境变量文件
.env                             # 包含 API 密钥
.env.local
.env.development.local
.env.test.local
.env.production.local

# 密钥文件
*.key
*.pem
*.p12
*.pfx

# 配置文件
config.json                      # 可能包含敏感配置
secrets.json
```

### 📦 大文件

```
# 打包产物 (通常 >50MB)
*.zip
*.tar.gz
*.deb
*.rpm
*.AppImage
*.exe
*.dmg
*.snap

# 日志文件
*.log
logs/

# 临时文件
*.tmp
*.temp
temp/
outputs/
```

### 🖥️ 系统文件

```
# macOS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes

# Windows
ehthumbs.db
Thumbs.db
Desktop.ini

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
```

## 📊 文件统计

### 📈 预计上传文件数量

- **源代码文件**: ~50-80 个
- **配置文件**: ~15-20 个
- **文档文件**: ~10-15 个
- **总计**: ~75-115 个文件

### 💾 预计仓库大小

- **源代码**: ~2-5 MB
- **文档**: ~1-2 MB
- **配置文件**: ~100-500 KB
- **总计**: ~3-8 MB

## 🔍 验证清单

推送完成后，请确认以下文件已成功上传：

### ✅ 核心文件检查

- [ ] `README.md` - 项目说明完整
- [ ] `backend/app/main.py` - 后端主文件
- [ ] `frontend/src/App.tsx` - 前端主组件
- [ ] `frontend/package.json` - 前端依赖配置
- [ ] `backend/requirements.txt` - 后端依赖配置
- [ ] `docker-compose.yml` - Docker 配置
- [ ] `deploy-gcp.sh` - 部署脚本
- [ ] `.gitignore` - 忽略规则

### ✅ 部署配置检查

- [ ] `railway.json` - Railway 配置
- [ ] `render.yaml` - Render 配置
- [ ] `backend/Dockerfile` - Docker 构建文件
- [ ] `frontend/.env.example` - 环境变量示例

### ✅ 文档检查

- [ ] 所有 `.md` 文件已上传
- [ ] 部署指南完整
- [ ] API 文档存在

### ❌ 敏感文件检查

- [ ] 确认没有 `.env` 文件
- [ ] 确认没有 `node_modules/` 目录
- [ ] 确认没有构建产物
- [ ] 确认没有大文件 (>50MB)

## 🚀 使用推送脚本

使用更新后的自动推送脚本：

```bash
# 基本推送
./push-to-github.sh

# 自定义提交信息
./push-to-github.sh "Add new features and fix bugs"

# 脚本会自动:
# 1. 检查和配置 Git 仓库
# 2. 优化网络连接设置
# 3. 更新 .gitignore 文件
# 4. 显示文件清单
# 5. 检查敏感文件
# 6. 多次重试推送
# 7. 显示推送结果
```

## 📞 获取帮助

如果推送过程中遇到问题：

1. **网络问题**: 检查网络连接，稍后重试
2. **权限问题**: 确认 GitHub 访问权限
3. **大文件问题**: 检查 `.gitignore` 配置
4. **TLS 错误**: 脚本已自动优化连接设置

---

💡 **提示**: 保持仓库整洁，定期清理不必要的文件，使用有意义的提交信息。