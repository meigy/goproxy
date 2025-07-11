@echo off
REM HTTPS代理服务器启动脚本 (Windows版本)

echo === HTTPS代理服务器启动脚本 ===
echo.

REM 检查是否在demo目录
if not exist "auth_proxy.exe" (
    echo 错误: 可执行文件 auth_proxy.exe 不存在
    echo 请先运行 build.bat 编译程序
    pause
    exit /b 1
)

echo 启动HTTPS代理服务器...
echo - 端口: 8080
echo - 用户名: admin
echo - 密码: admin123
echo - 按 Ctrl+C 停止服务器
echo.

REM 启动代理服务器
auth_proxy.exe -v 