@echo off
REM 快速启动脚本 - 一键启动可配置代理服务器

echo 快速启动可配置HTTPS代理服务器...
echo.

REM 检查必要文件
if not exist "configurable_proxy.go" (
    echo [错误] 缺少主程序文件
    pause
    exit /b 1
)

if not exist "config.go" (
    echo [错误] 缺少配置文件模块
    pause
    exit /b 1
)

REM 启动代理服务器
echo [信息] 正在启动代理服务器...
echo - 配置文件: config.json (自动创建)
echo - 默认端口: 8080
echo - 默认用户: admin/admin123
echo.
echo 按 Ctrl+C 停止服务器
echo.

go run configurable_proxy.go config.go -v 