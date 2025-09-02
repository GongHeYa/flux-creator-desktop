#!/bin/bash

# FLUX Creator 云端部署构建脚本

set -e

echo "🌐 FLUX Creator 云端部署构建脚本"
echo "======================================"

# 检查参数
if [ $# -eq 0 ]; then
    echo "使用方法: $0 <cloud-api-url> [platform]"
    echo "示例:"
    echo "  $0 https://your-app.railway.app railway"
    echo "  $0 https://your-app.onrender.com render"
    echo "  $0 https://your-api.herokuapp.com heroku"
    echo "  $0 https://api.yourdomain.com custom"
    exit 1
fi

CLOUD_API_URL="$1"
PLATFORM="${2:-custom}"

echo "🔧 配置信息:"
echo "  API 地址: $CLOUD_API_URL"
echo "  平台类型: $PLATFORM"
echo ""

# 进入前端目录
cd frontend

echo "📦 安装前端依赖..."
npm install

echo "🔧 配置 API 地址..."
# 创建环境变量文件
cat > .env.local << EOF
VITE_API_BASE_URL=$CLOUD_API_URL
VITE_APP_NAME=FLUX Creator
VITE_APP_VERSION=1.0.0
VITE_DEPLOYMENT_PLATFORM=$PLATFORM
EOF

echo "✅ 环境变量已配置:"
cat .env.local
echo ""

echo "🔨 构建前端应用..."
npm run build

echo "📱 构建 Electron 应用..."
# 获取操作系统类型
OS="$(uname -s)"
case "${OS}" in
    Linux*)
        echo "🐧 构建 Linux 版本..."
        npm run dist -- --linux
        echo "✅ Linux 版本构建完成！"
        ;;
    Darwin*)
        echo "🍎 构建 macOS 版本..."
        npm run dist -- --mac
        echo "✅ macOS 版本构建完成！"
        ;;
    MINGW*|CYGWIN*|MSYS*)
        echo "🪟 构建 Windows 版本..."
        npm run dist -- --win
        echo "✅ Windows 版本构建完成！"
        ;;
    *)
        echo "❓ 未知操作系统，构建当前平台版本..."
        npm run dist
        ;;
esac

echo ""
echo "🎉 云端版本构建完成！"
echo "📁 构建文件位于: frontend/dist-packages/"
echo "🌐 API 地址已配置为: $CLOUD_API_URL"
echo ""
echo "📋 下一步:"
echo "1. 测试云端 API 是否正常: curl $CLOUD_API_URL/health"
echo "2. 安装并测试生成的应用"
echo "3. 在应用设置中验证服务器连接状态"

cd ..