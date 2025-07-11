# 构建说明

本文档说明如何构建和打包HTTPS代理服务器。

## 构建脚本

### 1. 简化构建脚本（推荐）

**Linux/macOS:**
```bash
chmod +x build_simple.sh
./build_simple.sh
```

**Windows:**
```cmd
build_simple.bat
```

这些脚本只编译当前平台的可执行文件，适合日常开发使用。

### 2. 完整构建脚本

**Linux/macOS:**
```bash
chmod +x build.sh
./build.sh
```

**Windows:**
```cmd
build.bat
```

这些脚本会编译所有平台（Linux、macOS、Windows）的版本，并创建发布包。

### 3. 使用Makefile

**Linux/macOS:**
```bash
# 构建当前平台
make

# 构建所有平台
make build-all

# 清理构建文件
make clean

# 显示帮助
make help
```

## 手动构建

### 1. 构建当前平台

```bash
# 初始化依赖
go mod tidy

# 构建
go build -ldflags="-s -w" -o auth_proxy auth_proxy.go
```

### 2. 交叉编译

```bash
# Windows AMD64
GOOS=windows GOARCH=amd64 go build -ldflags="-s -w" -o auth_proxy.exe auth_proxy.go

# Linux AMD64
GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o auth_proxy auth_proxy.go

# macOS AMD64
GOOS=darwin GOARCH=amd64 go build -ldflags="-s -w" -o auth_proxy auth_proxy.go
```

## 构建参数说明

### ldflags参数

- `-s`: 去除符号表信息，减小文件大小
- `-w`: 去除调试信息，减小文件大小
- `-X main.Version=1.0.0`: 注入版本信息

### 环境变量

- `GOOS`: 目标操作系统 (linux, darwin, windows)
- `GOARCH`: 目标架构 (amd64, arm64, 386)
- `CGO_ENABLED`: 是否启用CGO (0=禁用, 1=启用)

## 发布包结构

构建完成后，会在`release/`目录下生成以下文件：

```
release/
├── auth_proxy_linux_amd64_v1.0.0.tar.gz
├── auth_proxy_windows_amd64_v1.0.0.zip
└── checksums.txt
```

## 依赖要求

- Go 1.20 或更高版本
- Git（用于版本信息）

## 故障排除

### 常见问题

1. **编译失败**
   ```bash
   go clean -modcache
   go mod tidy
   ```

2. **交叉编译失败**
   ```bash
   CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build auth_proxy.go
   ```

3. **权限问题**
   ```bash
   chmod +x *.sh
   ``` 