@echo off

REM 简化构建脚本 - 只编译当前平台

echo === 简化构建脚本 ===
echo 只编译当前平台的可执行文件
echo.

REM 检查依赖
go version >nul 2>&1
if errorlevel 1 (
    echo 错误: Go未安装
    pause
    exit /b 1
)

REM 检查是否在正确的目录
if not exist "auth_proxy.go" (
    echo 错误: 请在demo目录中运行此脚本
    pause
    exit /b 1
)

REM 获取当前平台信息
echo 当前平台: Windows/amd64
echo.

REM 初始化Go模块
echo 1. 初始化Go模块...
go mod tidy

REM 编译
echo 2. 编译程序...
go build -ldflags="-s -w" -o auth_proxy.exe auth_proxy.go

if errorlevel 1 (
    echo ✗ 编译失败
    pause
    exit /b 1
) else (
    echo ✓ 编译成功
    echo.
    echo 生成的文件:
    dir auth_proxy.exe
    echo.
    echo 使用方法:
    echo   auth_proxy.exe -v
    echo   auth_proxy.exe -addr :9090
    echo   auth_proxy.exe -h
)

pause 