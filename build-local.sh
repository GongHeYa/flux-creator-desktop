#!/bin/bash

# FLUX Creator 本地构建脚本
# 支持在本地环境构建所有平台的 Electron 应用

set -e

echo "🚀 开始 FLUX Creator 本地构建..."

# 检查 Node.js 和 npm
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未找到 Node.js，请先安装 Node.js 18+"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ 错误: 未找到 npm，请先安装 npm"
    exit 1
fi

echo "✅ Node.js 版本: $(node --version)"
echo "✅ npm 版本: $(npm --version)"

# 进入前端目录
cd frontend

echo "📦 安装依赖..."
npm install

echo "🔨 构建前端应用..."
npm run build

echo "📱 开始构建 Electron 应用..."

# 获取操作系统类型
OS="$(uname -s)"
case "${OS}" in
    Linux*)
        echo "🐧 检测到 Linux 系统，构建 Linux 版本..."
        npm run dist -- --linux
        echo "✅ Linux 版本构建完成！"
        echo "📁 输出目录: frontend/dist-packages/"
        ls -la dist-packages/ | grep -E "\.(AppImage|deb|rpm|snap)$" || echo "⚠️  未找到 Linux 安装包"
        ;;
    Darwin*)
        echo "🍎 检测到 macOS 系统，构建 macOS 版本..."
        npm run dist -- --mac
        echo "✅ macOS 版本构建完成！"
        echo "📁 输出目录: frontend/dist-packages/"
        ls -la dist-packages/ | grep -E "\.(dmg|zip)$" || echo "⚠️  未找到 macOS 安装包"
        ;;
    MINGW*|CYGWIN*|MSYS*)
        echo "🪟 检测到 Windows 系统，构建 Windows 版本..."
        npm run dist -- --win
        echo "✅ Windows 版本构建完成！"
        echo "📁 输出目录: frontend/dist-packages/"
        ls -la dist-packages/ | grep -E "\.(exe|msi)$" || echo "⚠️  未找到 Windows 安装包"
        ;;
    *)
        echo "❓ 未知操作系统: ${OS}"
        echo "🔧 尝试构建当前平台版本..."
        npm run dist
        ;;
esac

echo ""
echo "🎉 构建完成！"
echo "📁 所有构建文件位于: frontend/dist-packages/"
echo "💡 提示: 你可以直接运行生成的安装包来安装应用"

cd ..