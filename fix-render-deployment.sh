#!/bin/bash

# FLUX Creator Render 部署修复脚本
# 解决 "failed to read dockerfile" 错误

echo "🔧 FLUX Creator Render 部署修复脚本"
echo "======================================"

# 检查当前目录
if [ ! -f "render.yaml" ]; then
    echo "❌ 错误: 请在项目根目录运行此脚本"
    exit 1
fi

echo "✅ 检查项目结构..."

# 检查必要文件
if [ ! -f "backend/Dockerfile" ]; then
    echo "❌ 错误: backend/Dockerfile 不存在"
    exit 1
fi

if [ ! -f "backend/requirements.txt" ]; then
    echo "❌ 错误: backend/requirements.txt 不存在"
    exit 1
fi

if [ ! -f "backend/app/main.py" ]; then
    echo "❌ 错误: backend/app/main.py 不存在"
    exit 1
fi

echo "✅ 所有必要文件都存在"

# 检查 render.yaml 配置
echo "🔍 检查 render.yaml 配置..."

if grep -q "dockerfilePath: ./backend/Dockerfile" render.yaml; then
    echo "🔧 修复 render.yaml 中的 dockerfilePath..."
    sed -i 's|dockerfilePath: ./backend/Dockerfile|dockerfilePath: backend/Dockerfile|g' render.yaml
    
    # 添加 dockerContext 如果不存在
    if ! grep -q "dockerContext:" render.yaml; then
        sed -i '/dockerfilePath: backend\/Dockerfile/a\    dockerContext: .' render.yaml
    fi
fi

echo "✅ render.yaml 配置已修复"

# 验证 Dockerfile 内容
echo "🔍 验证 Dockerfile 配置..."

if ! grep -q "EXPOSE 8000" backend/Dockerfile; then
    echo "⚠️  警告: Dockerfile 中没有 EXPOSE 8000"
fi

if ! grep -q "CMD.*uvicorn" backend/Dockerfile; then
    echo "⚠️  警告: Dockerfile 中没有正确的启动命令"
fi

# 检查健康检查端点
echo "🔍 检查健康检查端点..."

if grep -q "/health" backend/app/main.py; then
    echo "✅ 健康检查端点存在"
else
    echo "❌ 错误: 健康检查端点不存在"
fi

# 提交更改
echo "📝 提交配置更改..."

git add render.yaml
if git diff --staged --quiet; then
    echo "ℹ️  没有需要提交的更改"
else
    git commit -m "Fix render.yaml configuration for deployment"
    echo "✅ 配置更改已提交"
fi

# 推送到 GitHub
echo "🚀 推送更改到 GitHub..."

if git push origin main; then
    echo "✅ 更改已推送到 GitHub"
else
    echo "❌ 推送失败，请检查 Git 配置"
    exit 1
fi

echo ""
echo "🎉 修复完成！"
echo "======================================"
echo "📋 接下来的步骤:"
echo "1. 访问 https://render.com"
echo "2. 创建新的 Web Service"
echo "3. 连接你的 GitHub 仓库"
echo "4. 选择 flux-creator-desktop 仓库"
echo "5. Render 会自动检测 render.yaml 配置"
echo "6. 等待部署完成"
echo ""
echo "📖 详细部署指南: ./RENDER_DEPLOYMENT_GUIDE.md"
echo "🔗 Render 控制台: https://dashboard.render.com"
echo ""
echo "💡 提示: 如果仍然遇到问题，请检查:"
echo "   - GitHub 仓库是否为公开仓库"
echo "   - 所有文件是否已正确推送"
echo "   - render.yaml 配置是否正确"