#!/bin/bash

# 可配置HTTPS代理服务器启动脚本 (Linux/macOS版本)

echo "=========================================="
echo "   可配置HTTPS代理服务器启动脚本"
echo "=========================================="
echo ""

# 检查是否在demo目录
if [ ! -f "configurable_proxy" ]; then
    echo "[ERROR] 可执行文件 configurable_proxy 不存在"
    echo "请先运行 build.sh 编译程序"
    exit 1
fi

echo "[INFO] 启动可配置HTTPS代理服务器..."
echo ""
echo "配置信息:"
echo "- 配置文件: config.json (自动创建)"
echo "- 默认端口: 8080"
echo "- 默认用户: admin/admin123"
echo "- 日志级别: debug (详细模式)"
echo ""
echo "如果配置文件不存在，将自动创建默认配置"
echo "按 Ctrl+C 停止服务器"
echo ""

# 启动代理服务器
./configurable_proxy -v 