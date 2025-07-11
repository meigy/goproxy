#!/bin/bash

# HTTPS代理服务器启动脚本

echo "=== HTTPS代理服务器启动脚本 ==="
echo ""

# 检查是否在demo目录
if [ ! -f "auth_proxy" ]; then
    echo "错误: 可执行文件 auth_proxy 不存在"
    echo "请先运行 build.sh 编译程序"
    exit 1
fi

echo "启动HTTPS代理服务器..."
echo "- 端口: 8080"
echo "- 用户名: admin"
echo "- 密码: admin123"
echo "- 按 Ctrl+C 停止服务器"
echo ""

# 启动代理服务器
./auth_proxy -v 