# 构建脚本总结

## 概述

本文档总结了为HTTPS代理服务器创建的所有构建和打包脚本。

## 构建脚本列表

### 1. 简化构建脚本（推荐日常使用）

| 文件名 | 平台 | 功能 |
|--------|------|------|
| `build_simple.sh` | Linux/macOS | 编译当前平台版本 |
| `build_simple.bat` | Windows | 编译当前平台版本 |

**特点：**
- 只编译当前平台
- 快速构建
- 适合日常开发
- 自动检测平台

**使用方法：**
```bash
# Linux/macOS
./build_simple.sh

# Windows
build_simple.bat
```

### 2. 完整构建脚本（推荐发布使用）

| 文件名 | 平台 | 功能 |
|--------|------|------|
| `build.sh` | Linux/macOS | 多平台编译和打包 |
| `build.bat` | Windows | 多平台编译和打包 |

**特点：**
- 编译所有平台（Linux、macOS、Windows）
- 支持AMD64和ARM64架构
- 自动创建发布包
- 生成校验和
- 彩色输出和详细日志

**使用方法：**
```bash
# Linux/macOS
./build.sh

# Windows
build.bat
```

### 3. Makefile（推荐开发者使用）

| 文件名 | 平台 | 功能 |
|--------|------|------|
| `Makefile` | Linux/macOS | 多目标构建系统 |

**特点：**
- 支持多种构建目标
- 依赖管理
- 代码格式化和检查
- 测试运行

**使用方法：**
```bash
make              # 构建当前平台
make build-all    # 构建所有平台
make clean        # 清理构建文件
make help         # 显示帮助
```

## 支持的平台和架构

### 编译目标

| 操作系统 | 架构 | 输出文件 |
|----------|------|----------|
| Linux | AMD64 | `auth_proxy` |
| Linux | ARM64 | `auth_proxy` |
| macOS | AMD64 | `auth_proxy` |
| macOS | ARM64 | `auth_proxy_arm64` |
| Windows | AMD64 | `auth_proxy.exe` |
| Windows | ARM64 | `auth_proxy_arm64.exe` |

### 发布包格式

| 平台 | 格式 | 包含文件 |
|------|------|----------|
| Linux | `.tar.gz` | 可执行文件 + 文档 + 脚本 |
| macOS | `.tar.gz` | 可执行文件 + 文档 + 脚本 |
| Windows | `.zip` | 可执行文件 + 文档 + 批处理 |

## 构建优化

### 编译优化

- 使用 `-ldflags="-s -w"` 减小文件大小
- 去除调试信息和符号表
- 支持版本信息注入

### 文件大小对比

| 优化级别 | 文件大小 | 说明 |
|----------|----------|------|
| 未优化 | ~8MB | 包含调试信息 |
| 基本优化 | ~5.6MB | 去除调试信息 |
| UPX压缩 | ~2MB | 进一步压缩 |

## 目录结构

```
demo/
├── auth_proxy.go              # 主程序源码
├── go.mod                     # Go模块文件
├── go.sum                     # 依赖校验文件
├── README.md                  # 详细文档
├── QUICK_START.md             # 快速开始指南
├── BUILD.md                   # 构建说明
├── BUILD_SUMMARY.md           # 本文档
├── config_example.json        # 配置示例
├── Makefile                   # Makefile构建系统
├── build.sh                   # Linux/macOS完整构建脚本
├── build.bat                  # Windows完整构建脚本
├── build_simple.sh            # Linux/macOS简化构建脚本
├── build_simple.bat           # Windows简化构建脚本
├── start_proxy.sh             # Linux/macOS启动脚本
├── start_proxy.bat            # Windows启动脚本
├── test_proxy.sh              # Linux/macOS测试脚本
├── test_proxy.bat             # Windows测试脚本
└── auth_proxy.exe             # 编译后的可执行文件
```

## 使用建议

### 开发阶段
- 使用 `build_simple.sh` 或 `build_simple.bat`
- 使用 `make` 进行快速构建
- 使用 `test_proxy.sh` 或 `test_proxy.bat` 测试

### 发布阶段
- 使用 `build.sh` 或 `build.bat` 创建完整发布包
- 检查生成的校验和
- 测试所有平台版本

### 持续集成
- 使用 `Makefile` 的 `build-all` 目标
- 集成到CI/CD流水线
- 自动生成发布包

## 故障排除

### 常见问题

1. **权限问题**
   ```bash
   chmod +x *.sh
   ```

2. **依赖问题**
   ```bash
   go mod tidy
   go clean -modcache
   ```

3. **交叉编译问题**
   ```bash
   CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build auth_proxy.go
   ```

4. **打包工具缺失**
   ```bash
   # 安装tar（Linux/macOS）
   sudo apt-get install tar
   
   # 安装zip（Windows）
   # 通常已预装
   ```

## 扩展功能

### 可以添加的功能

1. **Docker支持**
   - 创建Dockerfile
   - 多阶段构建
   - 镜像优化

2. **CI/CD集成**
   - GitHub Actions
   - GitLab CI
   - Jenkins Pipeline

3. **自动化测试**
   - 单元测试
   - 集成测试
   - 性能测试

4. **代码质量**
   - golangci-lint集成
   - 代码覆盖率
   - 安全扫描

## 总结

这套构建脚本提供了完整的构建和打包解决方案：

- ✅ **多平台支持**：Linux、macOS、Windows
- ✅ **多架构支持**：AMD64、ARM64
- ✅ **自动化构建**：一键编译和打包
- ✅ **发布就绪**：包含文档和脚本
- ✅ **开发友好**：简化脚本和Makefile
- ✅ **质量保证**：校验和和错误检查

选择适合您需求的构建脚本，开始构建您的HTTPS代理服务器！ 