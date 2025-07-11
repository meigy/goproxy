@echo off
setlocal enabledelayedexpansion

REM 可配置HTTPS代理服务器测试脚本 (Windows版本)
REM 使用方法: test_proxy.bat [代理地址] [用户名] [密码]

REM 默认参数
set PROXY_ADDR=%1
if "%PROXY_ADDR%"=="" set PROXY_ADDR=localhost:8080

set USERNAME=%2
if "%USERNAME%"=="" set USERNAME=admin

set PASSWORD=%3
if "%PASSWORD%"=="" set PASSWORD=admin123

echo === HTTPS代理服务器测试 ===
echo 代理地址: %PROXY_ADDR%
echo 用户名: %USERNAME%
echo 密码: %PASSWORD%
echo.

REM 检查curl是否可用
curl --version >nul 2>&1
if errorlevel 1 (
    echo 错误: curl命令未找到，请安装curl
    pause
    exit /b 1
)

REM 测试HTTP请求
echo 1. 测试HTTP请求...
curl -s -w "%%{http_code}" -x "http://%USERNAME%:%PASSWORD%@%PROXY_ADDR%" "http://httpbin.org/ip" -o http_response.txt
set /p HTTP_STATUS=<http_response.txt
set HTTP_STATUS=!HTTP_STATUS:~-3!

if "!HTTP_STATUS!"=="200" (
    echo ✓ HTTP请求成功
    echo 响应内容:
    type http_response.txt
) else (
    echo ✗ HTTP请求失败，状态码: !HTTP_STATUS!
)
echo.

REM 测试HTTPS请求
echo 2. 测试HTTPS请求...
curl -s -w "%%{http_code}" -x "http://%USERNAME%:%PASSWORD%@%PROXY_ADDR%" "https://httpbin.org/ip" -o https_response.txt
set /p HTTPS_STATUS=<https_response.txt
set HTTPS_STATUS=!HTTPS_STATUS:~-3!

if "!HTTPS_STATUS!"=="200" (
    echo ✓ HTTPS请求成功
    echo 响应内容:
    type https_response.txt
) else (
    echo ✗ HTTPS请求失败，状态码: !HTTPS_STATUS!
)
echo.

REM 测试错误认证
echo 3. 测试错误认证...
curl -s -w "%%{http_code}" -x "http://wronguser:wrongpass@%PROXY_ADDR%" "http://httpbin.org/ip" -o wrong_response.txt
set /p WRONG_STATUS=<wrong_response.txt
set WRONG_STATUS=!WRONG_STATUS:~-3!

if "!WRONG_STATUS!"=="407" (
    echo ✓ 错误认证被正确拒绝
) else (
    echo ✗ 错误认证测试失败，状态码: !WRONG_STATUS!
)
echo.

REM 测试无认证
echo 4. 测试无认证...
curl -s -w "%%{http_code}" -x "http://%PROXY_ADDR%" "http://httpbin.org/ip" -o noauth_response.txt
set /p NO_AUTH_STATUS=<noauth_response.txt
set NO_AUTH_STATUS=!NO_AUTH_STATUS:~-3!

if "!NO_AUTH_STATUS!"=="407" (
    echo ✓ 无认证被正确拒绝
) else (
    echo ✗ 无认证测试失败，状态码: !NO_AUTH_STATUS!
)
echo.

REM 清理临时文件
del http_response.txt https_response.txt wrong_response.txt noauth_response.txt 2>nul

echo === 测试完成 ===
echo.
echo 如果所有测试都通过，说明代理服务器工作正常！
echo.
echo 提示:
echo - 确保代理服务器正在运行
echo - 检查用户名和密码是否正确
echo - 确保网络连接正常
echo.
pause 