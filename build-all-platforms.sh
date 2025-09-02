#!/bin/bash

# FLUX Creator 跨平台构建脚本
# 在一台机器上构建所有平台的 Electron 应用

set -e

echo "🌍 开始跨平台构建 FLUX Creator..."

# 检查 Node.js 和 npm
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未找到 Node.js，请先安装 Node.js 18+"
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

echo "📱 开始构建所有平台的 Electron 应用..."

# 创建输出目录
mkdir -p dist-packages

echo ""
echo "🐧 构建 Linux 版本..."
if npm run dist -- --linux; then
    echo "✅ Linux 版本构建成功！"
else
    echo "❌ Linux 版本构建失败"
fi

echo ""
echo "🍎 构建 macOS 版本..."
if npm run dist -- --mac; then
    echo "✅ macOS 版本构建成功！"
else
    echo "❌ macOS 版本构建失败"
fi

echo ""
echo "🪟 构建 Windows 版本..."
if npm run dist -- --win; then
    echo "✅ Windows 版本构建成功！"
else
    echo "❌ Windows 版本构建失败"
fi

echo ""
echo "📊 构建结果汇总:"
echo "📁 输出目录: frontend/dist-packages/"
echo ""

if [ -d "dist-packages" ]; then
    echo "🗂️  生成的文件:"
    ls -la dist-packages/ | grep -v "^total" | grep -v "^d" || echo "⚠️  未找到构建文件"
else
    echo "⚠️  输出目录不存在"
fi

echo ""
echo "🎉 跨平台构建完成！"
echo "💡 提示: 即使某些平台构建失败，其他成功的平台仍可使用"
echo "📋 如需单独构建某个平台，请使用: ./build-local.sh"

cd ..