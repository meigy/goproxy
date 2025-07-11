#!/bin/bash

# HTTPS代理服务器编译打包脚本 (Linux/macOS版本)

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    print_info "检查依赖..."
    
    if ! command -v go &> /dev/null; then
        print_error "Go未安装，请先安装Go"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        print_warning "Git未安装，版本信息可能不完整"
    fi
    
    print_success "依赖检查完成"
}

# 获取版本信息
get_version() {
    local version="1.0.0"
    local commit=""
    local date=$(date '+%Y-%m-%d %H:%M:%S')
    
    if command -v git &> /dev/null; then
        commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    fi
    
    echo "Version: $version"
    echo "Commit: $commit"
    echo "BuildDate: $date"
}

# 清理旧文件
cleanup() {
    print_info "清理旧文件..."
    rm -rf build/
    rm -f auth_proxy
    rm -f auth_proxy.exe
    print_success "清理完成"
}

# 创建构建目录
create_build_dir() {
    print_info "创建构建目录..."
    mkdir -p build/{linux,linux-arm64,darwin,windows}
    print_success "构建目录创建完成"
}

# 编译单个平台
build_platform() {
    local platform=$1
    local arch=$2
    local output_dir=$3
    local binary_name=$4
    
    print_info "编译 $platform/$arch..."
    
    local env_vars=""
    if [ "$platform" = "windows" ]; then
        env_vars="GOOS=windows GOARCH=$arch"
        binary_name="${binary_name}.exe"
    elif [ "$platform" = "darwin" ]; then
        env_vars="GOOS=darwin GOARCH=$arch"
    else
        env_vars="GOOS=linux GOARCH=$arch"
    fi
    
    # 编译
    eval "$env_vars go build -ldflags='-s -w' -o build/$output_dir/$binary_name auth_proxy.go"
    
    if [ $? -eq 0 ]; then
        print_success "$platform/$arch 编译完成"
    else
        print_error "$platform/$arch 编译失败"
        return 1
    fi
}

# 编译所有平台
build_all_platforms() {
    print_info "开始编译所有平台..."
    
    # 初始化Go模块
    print_info "初始化Go模块..."
    go mod tidy
    
    # 编译各平台
    build_platform "linux" "amd64" "linux" "auth_proxy" || exit 1
    build_platform "linux" "arm64" "linux-arm64" "auth_proxy" || exit 1
    build_platform "darwin" "amd64" "darwin" "auth_proxy" || exit 1
    build_platform "darwin" "arm64" "darwin" "auth_proxy_arm64" || exit 1
    build_platform "windows" "amd64" "windows" "auth_proxy" || exit 1
    build_platform "windows" "arm64" "windows" "auth_proxy_arm64" || exit 1
    
    print_success "所有平台编译完成"
}

# 创建发布包
create_release_packages() {
    print_info "创建发布包..."
    
    local version=$(get_version | grep "Version:" | cut -d' ' -f2)
    local release_dir="release"
    
    # 创建发布目录
    mkdir -p $release_dir
    
    # Linux AMD64
    print_info "打包 Linux AMD64..."
    tar -czf "$release_dir/auth_proxy_linux_amd64_v${version}.tar.gz" \
        -C build/linux auth_proxy \
        README.md QUICK_START.md config_example.json \
        test_proxy.sh start_proxy.sh
    
    # Linux ARM64
    print_info "打包 Linux ARM64..."
    tar -czf "$release_dir/auth_proxy_linux_arm64_v${version}.tar.gz" \
        -C build/linux-arm64 auth_proxy \
        README.md QUICK_START.md config_example.json \
        test_proxy.sh start_proxy.sh
    
    # macOS AMD64
    print_info "打包 macOS AMD64..."
    tar -czf "$release_dir/auth_proxy_darwin_amd64_v${version}.tar.gz" \
        -C build/darwin auth_proxy \
        README.md QUICK_START.md config_example.json \
        test_proxy.sh start_proxy.sh
    
    # macOS ARM64
    print_info "打包 macOS ARM64..."
    tar -czf "$release_dir/auth_proxy_darwin_arm64_v${version}.tar.gz" \
        -C build/darwin auth_proxy_arm64 \
        README.md QUICK_START.md config_example.json \
        test_proxy.sh start_proxy.sh
    
    # Windows AMD64
    print_info "打包 Windows AMD64..."
    zip -j "$release_dir/auth_proxy_windows_amd64_v${version}.zip" \
        build/windows/auth_proxy.exe \
        README.md QUICK_START.md config_example.json \
        test_proxy.bat start_proxy.bat
    
    # Windows ARM64
    print_info "打包 Windows ARM64..."
    zip -j "$release_dir/auth_proxy_windows_arm64_v${version}.zip" \
        build/windows/auth_proxy_arm64.exe \
        README.md QUICK_START.md config_example.json \
        test_proxy.bat start_proxy.bat
    
    print_success "发布包创建完成"
}

# 生成校验和
generate_checksums() {
    print_info "生成校验和..."
    
    local release_dir="release"
    cd $release_dir
    
    # 生成SHA256校验和
    sha256sum *.tar.gz *.zip > checksums.txt
    
    cd ..
    print_success "校验和生成完成"
}

# 显示构建信息
show_build_info() {
    print_info "构建信息:"
    echo "=================="
    get_version
    echo "=================="
    echo ""
    
    print_info "生成的文件:"
    echo "=================="
    ls -la build/
    echo ""
    
    print_info "发布包:"
    echo "=================="
    ls -la release/
    echo ""
    
    print_info "校验和:"
    echo "=================="
    cat release/checksums.txt
}

# 主函数
main() {
    echo "=========================================="
    echo "    HTTPS代理服务器编译打包脚本"
    echo "=========================================="
    echo ""
    
    # 检查是否在正确的目录
    if [ ! -f "auth_proxy.go" ]; then
        print_error "请在demo目录中运行此脚本"
        exit 1
    fi
    
    # 执行构建步骤
    check_dependencies
    cleanup
    create_build_dir
    build_all_platforms
    create_release_packages
    generate_checksums
    show_build_info
    
    echo ""
    print_success "构建完成！"
    print_info "发布包位于 release/ 目录"
}

# 运行主函数
main "$@" 