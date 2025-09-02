#!/bin/bash

echo "🔍 检查应用结构和潜在的白屏问题..."
echo ""

# 检查 Linux 版本
echo "📁 Linux 版本 (linux-unpacked):" 
if [ -d "frontend/dist-packages/linux-unpacked" ]; then
    echo "✅ Linux 应用目录存在"
    
    # 检查主要文件
    if [ -f "frontend/dist-packages/linux-unpacked/flux-creator-desktop" ]; then
        echo "✅ 主执行文件存在"
    else
        echo "❌ 主执行文件缺失"
    fi
    
    # 检查资源文件
    if [ -f "frontend/dist-packages/linux-unpacked/resources/app.asar" ]; then
        echo "✅ 应用资源包存在"
        
        # 尝试提取并检查 app.asar 内容
        echo "📦 检查应用资源包内容..."
        npx asar list frontend/dist-packages/linux-unpacked/resources/app.asar | head -10
    else
        echo "❌ 应用资源包缺失"
    fi
else
    echo "❌ Linux 应用目录不存在"
fi

echo ""
echo "📁 Windows 版本 (win-unpacked):"
if [ -d "frontend/dist-packages/win-unpacked" ]; then
    echo "✅ Windows 应用目录存在"
    
    # 检查主要文件
    if [ -f "frontend/dist-packages/win-unpacked/FLUX Creator.exe" ]; then
        echo "✅ 主执行文件存在"
    else
        echo "❌ 主执行文件缺失"
    fi
    
    # 检查资源文件
    if [ -f "frontend/dist-packages/win-unpacked/resources/app.asar" ]; then
        echo "✅ 应用资源包存在"
    else
        echo "❌ 应用资源包缺失"
    fi
else
    echo "❌ Windows 应用目录不存在"
fi

echo ""
echo "🔧 检查构建配置..."
echo "📄 main.js 路径配置:"
grep -n "loadFile" frontend/main.js

echo ""
echo "📄 index.html 内容:"
if [ -f "frontend/dist/index.html" ]; then
    echo "✅ index.html 存在"
    echo "📋 HTML 内容预览:"
    head -10 frontend/dist/index.html
else
    echo "❌ index.html 缺失"
fi

echo ""
echo "📊 安装包大小:"
ls -lah frontend/dist-packages/*.{deb,rpm,snap,AppImage,zip} 2>/dev/null | awk '{print $5 "\t" $9}'

echo ""
echo "💡 白屏问题可能的原因:"
echo "1. 资源路径错误 (已修复: main.js 中的路径)"
echo "2. 缺失的图标文件 (已修复: 移除了错误的 vite.svg 引用)"
echo "3. JavaScript 加载失败"
echo "4. 权限问题 (需要 --no-sandbox 参数)"
echo "5. 缺少必要的系统依赖"

echo ""
echo "🚀 建议的测试步骤:"
echo "1. 在有 GUI 的 Linux 系统上测试 AppImage"
echo "2. 在 Windows 系统上测试解压后的应用"
echo "3. 检查浏览器控制台是否有 JavaScript 错误"
echo "4. 确保系统有必要的图形库支持"