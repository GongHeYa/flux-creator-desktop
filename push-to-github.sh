#!/bin/bash

# GitHub 推送脚本
# 使用方法: ./push-to-github.sh [commit_message]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取提交信息
COMMIT_MESSAGE=${1:-"Update project files"}

print_info "开始推送到 GitHub..."
print_info "提交信息: $COMMIT_MESSAGE"

# 检查是否在 Git 仓库中
if [ ! -d ".git" ]; then
    print_error "当前目录不是 Git 仓库"
    print_info "请先运行: git init"
    exit 1
fi

# 检查是否有远程仓库
if ! git remote get-url origin &> /dev/null; then
    print_error "未配置远程仓库"
    print_info "请先添加远程仓库: git remote add origin https://github.com/username/repo.git"
    exit 1
fi

# 创建或更新 .gitignore
print_info "检查 .gitignore 文件..."
if [ ! -f ".gitignore" ]; then
    print_warning ".gitignore 文件不存在，正在创建..."
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
    print_success ".gitignore 文件已创建"
fi

# 检查敏感文件
print_info "检查敏感文件..."
SENSITIVE_FILES=()
if [ -f ".env" ]; then
    SENSITIVE_FILES+=(".env")
fi
if [ -d "node_modules" ]; then
    SENSITIVE_FILES+=("node_modules/")
fi
if [ -d "frontend/node_modules" ]; then
    SENSITIVE_FILES+=("frontend/node_modules/")
fi
if [ -d "__pycache__" ]; then
    SENSITIVE_FILES+=("__pycache__/")
fi

if [ ${#SENSITIVE_FILES[@]} -gt 0 ]; then
    print_warning "发现敏感文件，将被忽略:"
    for file in "${SENSITIVE_FILES[@]}"; do
        echo "  - $file"
    done
fi

# 检查大文件
print_info "检查大文件（>50MB）..."
LARGE_FILES=$(find . -size +50M -type f 2>/dev/null | grep -v '.git' || true)
if [ ! -z "$LARGE_FILES" ]; then
    print_warning "发现大文件:"
    echo "$LARGE_FILES"
    print_warning "建议将大文件添加到 .gitignore 或使用 Git LFS"
fi

# 显示当前状态
print_info "当前 Git 状态:"
git status --short

# 添加文件
print_info "添加文件到暂存区..."
git add .

# 显示将要提交的文件
print_info "将要提交的文件:"
git diff --cached --name-only

# 确认提交
echo ""
read -p "确认提交这些文件？(y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "取消提交"
    exit 0
fi

# 提交文件
print_info "提交更改..."
git commit -m "$COMMIT_MESSAGE"

if [ $? -ne 0 ]; then
    print_error "提交失败"
    exit 1
fi

print_success "提交完成"

# 推送到远程仓库
print_info "推送到远程仓库..."
REMOTE_URL=$(git remote get-url origin)
print_info "远程仓库: $REMOTE_URL"

git push origin main

if [ $? -ne 0 ]; then
    print_warning "推送失败，尝试推送到 master 分支..."
    git push origin master
    if [ $? -ne 0 ]; then
        print_error "推送失败，请检查网络连接和权限"
        exit 1
    fi
fi

print_success "推送完成！"

# 显示仓库信息
echo ""
print_info "=== 仓库信息 ==="
print_info "远程仓库: $REMOTE_URL"
print_info "当前分支: $(git branch --show-current)"
print_info "最新提交: $(git log -1 --oneline)"
echo ""
print_info "=== 下一步操作 ==="
print_info "1. 访问 GitHub 仓库确认文件已上传"
print_info "2. 使用仓库 URL 进行云端部署"
print_info "3. 配置 GitHub Actions（可选）"
echo ""
print_success "GitHub 推送完成！"