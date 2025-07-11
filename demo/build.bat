@echo off
chcp 65001 >nul
REM ===============================
REM  HTTPS代理服务器编译打包脚本
REM ===============================
echo.
echo ==========================================
echo     HTTPS代理服务器编译打包脚本
echo ==========================================
echo.

REM 检查是否在正确的目录
if not exist "auth_proxy.go" (
    echo [ERROR] 请在demo目录中运行此脚本
    pause
    exit /b 1
)

REM 检查依赖
echo [INFO] 检查依赖...
go version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Go未安装，请先安装Go
    pause
    exit /b 1
)
echo [SUCCESS] 依赖检查完成

git --version >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Git未安装，版本信息可能不完整
) else (
    echo [SUCCESS] Git检查完成
)

echo.
REM 获取版本信息
set VERSION=1.0.0
set COMMIT=unknown
set BUILD_DATE=%date% %time%
git rev-parse --short HEAD >nul 2>&1
if not errorlevel 1 (
    for /f %%i in ('git rev-parse --short HEAD') do set COMMIT=%%i
)
echo [INFO] 构建信息:
echo ==================
echo Version: %VERSION%
echo Commit: %COMMIT%
echo BuildDate: %BUILD_DATE%
echo ==================
echo.

REM 清理旧文件
echo [INFO] 清理旧文件...
if exist "build" rmdir /s /q build
if exist "release" rmdir /s /q release
if exist "auth_proxy.exe" del auth_proxy.exe
if exist "configurable_proxy.exe" del configurable_proxy.exe
echo [SUCCESS] 清理完成

echo.
REM 创建构建目录
echo [INFO] 创建构建目录...
mkdir build\linux
mkdir build\windows
echo [SUCCESS] 构建目录创建完成

echo.
REM 初始化Go模块
echo [INFO] 初始化Go模块...
go mod tidy

echo.
REM 编译Windows版本
echo [INFO] 编译 Windows/amd64...
set GOOS=windows
set GOARCH=amd64
go build -o build\windows\auth_proxy.exe auth_proxy.go
if errorlevel 1 (
    echo [ERROR] Windows/amd64 编译失败
    exit /b 1
)
echo [SUCCESS] Windows/amd64 编译完成

echo [INFO] 编译 Windows/amd64 (configurable_proxy)...
go build -o build\windows\configurable_proxy.exe configurable_proxy.go config.go
if errorlevel 1 (
    echo [ERROR] Windows/amd64 configurable_proxy 编译失败
    exit /b 1
)
echo [SUCCESS] Windows/amd64 configurable_proxy 编译完成

echo.
REM 编译Linux版本
echo [INFO] 编译 Linux/amd64...
set GOOS=linux
set GOARCH=amd64
go build -o build\linux\auth_proxy auth_proxy.go
if errorlevel 1 (
    echo [ERROR] Linux/amd64 编译失败
    exit /b 1
)
echo [SUCCESS] Linux/amd64 编译完成

echo [INFO] 编译 Linux/amd64 (configurable_proxy)...
go build -o build\linux\configurable_proxy configurable_proxy.go config.go
if errorlevel 1 (
    echo [ERROR] Linux/amd64 configurable_proxy 编译失败
    exit /b 1
)
echo [SUCCESS] Linux/amd64 configurable_proxy 编译完成

echo.
REM 显示生成的文件
echo [INFO] 生成的文件:
dir build /s

echo.
echo [SUCCESS] 全部编译完成！
echo [INFO] 可执行文件位于 build\ 目录 