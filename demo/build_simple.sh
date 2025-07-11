#!/bin/bash

# 简化构建脚本 - 只编译当前平台

set -e

echo "=== 简化构建脚本 ==="
echo "只编译当前平台的可执行文件"
echo ""

# 检查依赖
if ! command -v go &> /dev/null; then
    echo "错误: Go未安装"
    exit 1
fi

# 检查是否在正确的目录
if [ ! -f "auth_proxy.go" ]; then
    echo "错误: 请在demo目录中运行此脚本"
    exit 1
fi

# 获取当前平台信息
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
fi

echo "当前平台: $OS/$ARCH"
echo ""

# 初始化Go模块
echo "1. 初始化Go模块..."
go mod tidy

# 编译
echo "2. 编译程序..."
if [ "$OS" = "darwin" ]; then
    # macOS
    go build -ldflags='-s -w' -o auth_proxy auth_proxy.go
elif [ "$OS" = "linux" ]; then
    # Linux
    go build -ldflags='-s -w' -o auth_proxy auth_proxy.go
else
    echo "不支持的操作系统: $OS"
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "✓ 编译成功"
    echo ""
    echo "生成的文件:"
    ls -la auth_proxy
    echo ""
    echo "使用方法:"
    echo "  ./auth_proxy -v"
    echo "  ./auth_proxy -addr :9090"
    echo "  ./auth_proxy -h"
else
    echo "✗ 编译失败"
    exit 1
fi 