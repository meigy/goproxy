#!/bin/bash

# 可配置HTTPS代理服务器测试脚本
# 使用方法: ./test_proxy.sh [代理地址] [用户名] [密码]

# 默认参数
PROXY_ADDR=${1:-"localhost:8080"}
USERNAME=${2:-"admin"}
PASSWORD=${3:-"admin123"}

echo "=== HTTPS代理服务器测试 ==="
echo "代理地址: $PROXY_ADDR"
echo "用户名: $USERNAME"
echo "密码: $PASSWORD"
echo ""

# 检查curl是否可用
if ! command -v curl &> /dev/null; then
    echo "错误: curl命令未找到，请安装curl"
    exit 1
fi

# 测试HTTP请求
echo "1. 测试HTTP请求..."
HTTP_RESPONSE=$(curl -s -w "%{http_code}" -x "http://$USERNAME:$PASSWORD@$PROXY_ADDR" "http://httpbin.org/ip" -o /tmp/http_response.txt)
HTTP_STATUS=$(tail -c 3 /tmp/http_response.txt)

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✓ HTTP请求成功"
    echo "响应内容:"
    cat /tmp/http_response.txt
else
    echo "✗ HTTP请求失败，状态码: $HTTP_STATUS"
fi
echo ""

# 测试HTTPS请求
echo "2. 测试HTTPS请求..."
HTTPS_RESPONSE=$(curl -s -w "%{http_code}" -x "http://$USERNAME:$PASSWORD@$PROXY_ADDR" "https://httpbin.org/ip" -o /tmp/https_response.txt)
HTTPS_STATUS=$(tail -c 3 /tmp/https_response.txt)

if [ "$HTTPS_STATUS" = "200" ]; then
    echo "✓ HTTPS请求成功"
    echo "响应内容:"
    cat /tmp/https_response.txt
else
    echo "✗ HTTPS请求失败，状态码: $HTTPS_STATUS"
fi
echo ""

# 测试错误认证
echo "3. 测试错误认证..."
WRONG_RESPONSE=$(curl -s -w "%{http_code}" -x "http://wronguser:wrongpass@$PROXY_ADDR" "http://httpbin.org/ip" -o /tmp/wrong_response.txt)
WRONG_STATUS=$(tail -c 3 /tmp/wrong_response.txt)

if [ "$WRONG_STATUS" = "407" ]; then
    echo "✓ 错误认证被正确拒绝"
else
    echo "✗ 错误认证测试失败，状态码: $WRONG_STATUS"
fi
echo ""

# 测试无认证
echo "4. 测试无认证..."
NO_AUTH_RESPONSE=$(curl -s -w "%{http_code}" -x "http://$PROXY_ADDR" "http://httpbin.org/ip" -o /tmp/noauth_response.txt)
NO_AUTH_STATUS=$(tail -c 3 /tmp/noauth_response.txt)

if [ "$NO_AUTH_STATUS" = "407" ]; then
    echo "✓ 无认证被正确拒绝"
else
    echo "✗ 无认证测试失败，状态码: $NO_AUTH_STATUS"
fi
echo ""

# 清理临时文件
rm -f /tmp/http_response.txt /tmp/https_response.txt /tmp/wrong_response.txt /tmp/noauth_response.txt

echo "=== 测试完成 ==="
echo ""
echo "如果所有测试都通过，说明代理服务器工作正常！"
echo ""
echo "提示:"
echo "- 确保代理服务器正在运行"
echo "- 检查用户名和密码是否正确"
echo "- 确保网络连接正常" 