# 📚 GitHub 代码推送指南

本指南将帮助您将 FLUX Creator 项目推送到 GitHub，为云端部署做准备。

## 🎯 推送目标

- ✅ 创建 GitHub 仓库
- ✅ 推送必要的项目文件
- ✅ 为云端部署做准备
- ✅ 保护敏感信息不被上传

## 📋 需要推送的文件清单

### ✅ 必须推送的文件

**项目配置文件：**
- `README.md` - 项目说明
- `.gitignore` - Git 忽略规则
- `docker-compose.yml` - Docker 配置

**后端文件：**
- `backend/` 整个目录
  - `backend/app/` - FastAPI 应用代码
  - `backend/Dockerfile` - Docker 构建文件
  - `backend/requirements.txt` - Python 依赖

**前端文件：**
- `frontend/` 整个目录（除了 node_modules）
  - `frontend/src/` - 源代码
  - `frontend/package.json` - 项目配置
  - `frontend/package-lock.json` - 依赖锁定
  - `frontend/.env.example` - 环境变量示例

**部署配置：**
- `railway.json` - Railway 部署配置
- `render.yaml` - Render 部署配置
- `deploy-gcp.sh` - Google Cloud Run 部署脚本
- `build-cloud.sh` - 云端构建脚本

**文档文件：**
- `QUICK_CLOUD_SETUP.md` - 快速部署指南
- `GOOGLE_CLOUD_RUN_GUIDE.md` - GCP 部署指南
- `CLOUD_DEPLOYMENT_GUIDE.md` - 云端部署指南
- `DEPLOYMENT_GUIDE.md` - 本地部署指南

### ❌ 不应推送的文件

**自动生成的文件：**
- `frontend/node_modules/` - Node.js 依赖（体积大）
- `frontend/dist/` - 构建产物
- `backend/__pycache__/` - Python 缓存
- `backend/.venv/` - Python 虚拟环境

**敏感信息：**
- `.env` - 环境变量（包含密钥）
- `*.log` - 日志文件
- `*.key` - 私钥文件

**系统文件：**
- `.DS_Store` - macOS 系统文件
- `Thumbs.db` - Windows 缩略图
- `*.tmp` - 临时文件

## 🚀 推送步骤

### 第一步：创建 GitHub 仓库

1. 访问 [GitHub.com](https://github.com)
2. 点击右上角的 "+" → "New repository"
3. 填写仓库信息：
   - **Repository name**: `flux-creator-desktop`
   - **Description**: `FLUX Creator Desktop App - AI Image Generation`
   - **Visibility**: Public（推荐）或 Private
   - ✅ 勾选 "Add a README file"
   - ✅ 选择 "Python" 作为 .gitignore 模板
4. 点击 "Create repository"

### 第二步：克隆仓库到本地

```bash
# 克隆你刚创建的仓库
git clone https://github.com/YOUR_USERNAME/flux-creator-desktop.git

# 进入仓库目录
cd flux-creator-desktop
```

### 第三步：复制项目文件

```bash
# 复制项目文件到 Git 仓库目录
# 假设你的项目在 /path/to/flux-creator-desktop

# 复制所有必要文件
cp -r /path/to/flux-creator-desktop/backend .
cp -r /path/to/flux-creator-desktop/frontend .
cp /path/to/flux-creator-desktop/*.md .
cp /path/to/flux-creator-desktop/*.json .
cp /path/to/flux-creator-desktop/*.yaml .
cp /path/to/flux-creator-desktop/*.yml .
cp /path/to/flux-creator-desktop/*.sh .
```

### 第四步：配置 .gitignore

创建或更新 `.gitignore` 文件：

```bash
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
.venv/
venv/
ENV/
env/

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.npm
.yarn-integrity

# Build outputs
frontend/dist/
frontend/build/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
*.log
logs/

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Temporary files
*.tmp
*.temp

# Output directories
outputs/
temp/
EOF
```

### 第五步：添加和提交文件

```bash
# 添加所有文件
git add .

# 检查要提交的文件
git status

# 提交文件
git commit -m "Initial commit: Add FLUX Creator Desktop App

- Add FastAPI backend with FLUX integration
- Add React + Electron frontend
- Add cloud deployment configurations
- Add deployment guides and scripts"
```

### 第六步：推送到 GitHub

```bash
# 推送到远程仓库
git push origin main
```

## 🔧 快速推送脚本

创建一个自动化脚本 `push-to-github.sh`：

```bash
#!/bin/bash

# GitHub 推送脚本
# 使用方法: ./push-to-github.sh "commit message"

set -e

COMMIT_MESSAGE=${1:-"Update project files"}

echo "🔍 检查 Git 状态..."
git status

echo "📁 添加文件..."
git add .

echo "💾 提交更改..."
git commit -m "$COMMIT_MESSAGE"

echo "🚀 推送到 GitHub..."
git push origin main

echo "✅ 推送完成！"
echo "📖 查看仓库: $(git remote get-url origin)"
```

使用方法：
```bash
chmod +x push-to-github.sh
./push-to-github.sh "Add new deployment features"
```

## 🔍 验证推送结果

推送完成后，检查以下内容：

1. **访问 GitHub 仓库页面**，确认文件已上传
2. **检查文件结构**：
   ```
   flux-creator-desktop/
   ├── README.md
   ├── backend/
   ├── frontend/
   ├── *.json
   ├── *.yaml
   ├── *.sh
   └── docs/
   ```
3. **确认敏感文件未上传**（如 .env、node_modules）
4. **测试克隆**：在另一个目录克隆仓库，确认完整性

## 🚨 常见问题

### 问题 1：文件太大无法推送

```bash
# 检查大文件
find . -size +100M -type f

# 移除大文件并添加到 .gitignore
echo "large-file.bin" >> .gitignore
git rm --cached large-file.bin
```

### 问题 2：推送被拒绝

```bash
# 拉取最新更改
git pull origin main --rebase

# 重新推送
git push origin main
```

### 问题 3：意外推送了敏感文件

```bash
# 从历史记录中移除敏感文件
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch .env' \
  --prune-empty --tag-name-filter cat -- --all

# 强制推送
git push origin --force --all
```

## 📋 推送检查清单

- [ ] 创建了 GitHub 仓库
- [ ] 配置了正确的 .gitignore
- [ ] 推送了所有必要的源代码文件
- [ ] 推送了部署配置文件
- [ ] 推送了文档文件
- [ ] 没有推送敏感信息（.env、密钥等）
- [ ] 没有推送大文件（node_modules、构建产物等）
- [ ] 仓库可以被云平台访问（Public 或正确配置的 Private）

## 🎯 下一步

推送完成后，您可以：
1. 使用 GitHub 仓库 URL 进行云端部署
2. 配置 GitHub Actions 自动构建
3. 邀请团队成员协作开发
4. 设置 GitHub Pages 展示项目文档

---

💡 **提示**：保持仓库整洁，定期清理不必要的文件，使用有意义的提交信息。