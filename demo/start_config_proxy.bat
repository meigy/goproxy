@echo off
REM 可配置HTTPS代理服务器启动脚本 (Windows版本)

echo ==========================================
echo    可配置HTTPS代理服务器启动脚本
echo ==========================================
echo.

REM 检查是否在demo目录
if not exist "build\windows\configurable_proxy.exe" (
    echo [ERROR] 可执行文件 build\windows\configurable_proxy.exe 不存在
    echo 请先运行 build.bat 编译程序
    pause
    exit /b 1
)

echo [INFO] 启动可配置HTTPS代理服务器...
echo.
echo 配置信息:
echo - 配置文件: config.json (自动创建)
echo - 默认端口: 18080
echo - 默认用户: admin/admin123
echo - 日志级别: debug (详细模式)
echo.
echo 如果配置文件不存在，将自动创建默认配置
echo 按 Ctrl+C 停止服务器
echo.

REM 启动代理服务器
build\windows\configurable_proxy.exe -v 