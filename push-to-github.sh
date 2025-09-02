#!/bin/bash

# FLUX Creator Desktop - GitHub 自动推送脚本
# 优化版本，解决 TLS 连接问题

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_header() {
    echo -e "\n${PURPLE}=== $1 ===${NC}\n"
}

print_success() {
    print_message "$GREEN" "✅ $1"
}

print_warning() {
    print_message "$YELLOW" "⚠️  $1"
}

print_error() {
    print_message "$RED" "❌ $1"
}

print_info() {
    print_message "$BLUE" "ℹ️  $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 未安装，请先安装 $1"
        exit 1
    fi
}

# 优化 Git 配置以解决网络问题
optimize_git_config() {
    print_header "优化 Git 网络配置"
    
    # 增加缓冲区大小
    git config --global http.postBuffer 524288000
    print_info "设置 HTTP 缓冲区大小: 500MB"
    
    # 使用 HTTP/1.1
    git config --global http.version HTTP/1.1
    print_info "设置 HTTP 版本: HTTP/1.1"
    
    # 增加超时时间
    git config --global http.lowSpeedLimit 1000
    git config --global http.lowSpeedTime 300
    print_info "设置连接超时: 300秒"
    
    # 禁用 SSL 验证（仅用于解决连接问题）
    git config --global http.sslVerify false
    print_warning "临时禁用 SSL 验证以解决连接问题"
    
    # 设置用户代理
    git config --global http.userAgent "git/2.0 (compatible)"
    print_info "设置用户代理"
    
    print_success "Git 网络配置优化完成"
}

# 恢复 Git 配置
restore_git_config() {
    print_header "恢复 Git 安全配置"
    
    # 重新启用 SSL 验证
    git config --global http.sslVerify true
    print_success "重新启用 SSL 验证"
}

# 检查 Git 仓库状态
check_git_repo() {
    print_header "检查 Git 仓库状态"
    
    if [ ! -d ".git" ]; then
        print_info "初始化 Git 仓库..."
        git init
        print_success "Git 仓库初始化完成"
    else
        print_success "Git 仓库已存在"
    fi
    
    # 检查远程仓库
    if ! git remote get-url origin &> /dev/null; then
        print_info "添加远程仓库..."
        git remote add origin https://github.com/GongHeYa/flux-creator-desktop.git
        print_success "远程仓库添加完成"
    else
        current_remote=$(git remote get-url origin)
        expected_remote="https://github.com/GongHeYa/flux-creator-desktop.git"
        if [ "$current_remote" != "$expected_remote" ]; then
            print_info "更新远程仓库地址..."
            git remote set-url origin $expected_remote
            print_success "远程仓库地址更新完成"
        else
            print_success "远程仓库配置正确"
        fi
    fi
}

# 更新 .gitignore 文件
update_gitignore() {
    print_header "更新 .gitignore 文件"
    
    cat > .gitignore << 'EOF'
# 依赖目录
node_modules/
frontend/node_modules/
__pycache__/
*.pyc
*.pyo
*.pyd
.Python

# 构建产物
frontend/dist/
frontend/build/
frontend/dist-packages/
build/
dist/
*.egg-info/

# 环境变量和配置
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
config.json
secrets.json

# 虚拟环境
.venv/
venv/
ENV/
env/

# 日志文件
*.log
logs/

# 临时文件
*.tmp
*.temp
temp/
outputs/

# 打包产物
*.zip
*.tar.gz
*.deb
*.rpm
*.AppImage
*.exe
*.dmg
*.snap

# 系统文件
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
Desktop.ini

# IDE 文件
.vscode/
.idea/
*.swp
*.swo
*~

# 密钥文件
*.key
*.pem
*.p12
*.pfx
EOF
    
    print_success ".gitignore 文件更新完成"
}

# 检查敏感文件
check_sensitive_files() {
    print_header "检查敏感文件"
    
    sensitive_files=(
        ".env"
        "config.json"
        "secrets.json"
        "*.key"
        "*.pem"
    )
    
    found_sensitive=false
    for pattern in "${sensitive_files[@]}"; do
        if ls $pattern 2>/dev/null | grep -q .; then
            print_warning "发现敏感文件: $pattern"
            found_sensitive=true
        fi
    done
    
    if [ "$found_sensitive" = true ]; then
        print_warning "请确保敏感文件已添加到 .gitignore"
    else
        print_success "未发现敏感文件"
    fi
}

# 检查大文件
check_large_files() {
    print_header "检查大文件"
    
    large_files=$(find . -type f -size +50M 2>/dev/null | grep -v '.git/' || true)
    
    if [ -n "$large_files" ]; then
        print_warning "发现大文件 (>50MB):"
        echo "$large_files"
        print_warning "建议将大文件添加到 .gitignore"
    else
        print_success "未发现大文件"
    fi
}

# 显示将要提交的文件
show_files_to_commit() {
    print_header "将要提交的文件"
    
    # 添加所有文件到暂存区
    git add .
    
    # 显示暂存的文件
    if git diff --cached --name-only | head -20; then
        file_count=$(git diff --cached --name-only | wc -l)
        print_info "总共 $file_count 个文件将被提交"
        
        if [ $file_count -gt 20 ]; then
            print_info "(仅显示前20个文件)"
        fi
    else
        print_info "没有文件需要提交"
    fi
}

# 多次重试推送
push_with_retry() {
    local commit_message="$1"
    local max_retries=5
    local retry_count=0
    
    print_header "提交和推送代码"
    
    # 提交代码
    if git diff --cached --quiet; then
        print_info "没有新的更改需要提交"
    else
        git commit -m "$commit_message"
        print_success "代码提交完成"
    fi
    
    # 多次重试推送
    while [ $retry_count -lt $max_retries ]; do
        retry_count=$((retry_count + 1))
        print_info "尝试推送 (第 $retry_count/$max_retries 次)..."
        
        if git push origin main 2>&1; then
            print_success "代码推送成功！"
            return 0
        else
            print_warning "推送失败，等待 5 秒后重试..."
            sleep 5
            
            # 尝试不同的推送策略
            if [ $retry_count -eq 2 ]; then
                print_info "尝试强制推送..."
                git push origin main --force-with-lease 2>&1 && {
                    print_success "强制推送成功！"
                    return 0
                } || true
            fi
            
            if [ $retry_count -eq 3 ]; then
                print_info "尝试设置上游分支..."
                git push --set-upstream origin main 2>&1 && {
                    print_success "设置上游分支并推送成功！"
                    return 0
                } || true
            fi
        fi
    done
    
    print_error "推送失败，已重试 $max_retries 次"
    return 1
}

# 显示推送结果
show_push_result() {
    print_header "推送结果"
    
    # 显示远程仓库信息
    remote_url=$(git remote get-url origin)
    print_info "远程仓库: $remote_url"
    
    # 显示最新提交
    latest_commit=$(git log --oneline -1)
    print_info "最新提交: $latest_commit"
    
    # 显示分支状态
    branch_status=$(git status -b --porcelain=v1 | head -1)
    print_info "分支状态: $branch_status"
    
    print_success "\n🎉 代码已成功推送到 GitHub!"
    print_info "\n📱 访问仓库: https://github.com/GongHeYa/flux-creator-desktop"
    print_info "🚀 现在可以进行云端部署了！"
}

# 主函数
main() {
    print_header "FLUX Creator Desktop - GitHub 自动推送"
    
    # 检查必要的命令
    check_command "git"
    
    # 获取提交信息
    commit_message="${1:-Update FLUX Creator Desktop App - $(date +'%Y-%m-%d %H:%M:%S')}"
    print_info "提交信息: $commit_message"
    
    # 执行推送流程
    optimize_git_config
    check_git_repo
    update_gitignore
    check_sensitive_files
    check_large_files
    show_files_to_commit
    
    # 确认推送
    echo
    read -p "$(echo -e "${YELLOW}是否继续推送到 GitHub? (y/N): ${NC}")" -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if push_with_retry "$commit_message"; then
            show_push_result
            restore_git_config
        else
            print_error "推送失败，请检查网络连接或联系管理员"
            restore_git_config
            exit 1
        fi
    else
        print_info "推送已取消"
        restore_git_config
        exit 0
    fi
}

# 运行主函数
main "$@"