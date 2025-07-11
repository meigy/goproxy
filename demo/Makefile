# HTTPS代理服务器 Makefile

# 变量定义
BINARY_NAME=auth_proxy
VERSION=1.0.0
BUILD_TIME=$(shell date '+%Y-%m-%d %H:%M:%S')
GIT_COMMIT=$(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Go编译参数
LDFLAGS=-ldflags "-s -w -X main.Version=$(VERSION) -X main.BuildTime=$(BUILD_TIME) -X main.GitCommit=$(GIT_COMMIT)"

# 默认目标
.PHONY: all
all: build

# 构建当前平台
.PHONY: build
build:
	@echo "构建 $(BINARY_NAME)..."
	@go mod tidy
	@go build $(LDFLAGS) -o $(BINARY_NAME) auth_proxy.go
	@echo "构建完成: $(BINARY_NAME)"

# 构建Windows版本
.PHONY: build-windows
build-windows:
	@echo "构建 Windows 版本..."
	@GOOS=windows GOARCH=amd64 go build $(LDFLAGS) -o $(BINARY_NAME).exe auth_proxy.go
	@echo "构建完成: $(BINARY_NAME).exe"

# 构建Linux版本
.PHONY: build-linux
build-linux:
	@echo "构建 Linux 版本..."
	@GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o $(BINARY_NAME) auth_proxy.go
	@echo "构建完成: $(BINARY_NAME)"

# 构建macOS版本
.PHONY: build-darwin
build-darwin:
	@echo "构建 macOS 版本..."
	@GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o $(BINARY_NAME) auth_proxy.go
	@echo "构建完成: $(BINARY_NAME)"

# 构建所有平台
.PHONY: build-all
build-all: build-windows build-linux build-darwin
	@echo "所有平台构建完成"

# 清理构建文件
.PHONY: clean
clean:
	@echo "清理构建文件..."
	@rm -f $(BINARY_NAME)
	@rm -f $(BINARY_NAME).exe
	@rm -rf build/
	@rm -rf release/
	@echo "清理完成"

# 运行程序
.PHONY: run
run: build
	@echo "运行 $(BINARY_NAME)..."
	@./$(BINARY_NAME) -v

# 测试
.PHONY: test
test:
	@echo "运行测试..."
	@go test -v ./...

# 格式化代码
.PHONY: fmt
fmt:
	@echo "格式化代码..."
	@go fmt ./...

# 代码检查
.PHONY: lint
lint:
	@echo "代码检查..."
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run; \
	else \
		echo "golangci-lint 未安装，跳过代码检查"; \
	fi

# 安装依赖
.PHONY: deps
deps:
	@echo "安装依赖..."
	@go mod tidy
	@go mod download

# 显示帮助
.PHONY: help
help:
	@echo "可用的目标:"
	@echo "  build        - 构建当前平台版本"
	@echo "  build-windows - 构建Windows版本"
	@echo "  build-linux   - 构建Linux版本"
	@echo "  build-darwin  - 构建macOS版本"
	@echo "  build-all     - 构建所有平台版本"
	@echo "  clean         - 清理构建文件"
	@echo "  run           - 构建并运行程序"
	@echo "  test          - 运行测试"
	@echo "  fmt           - 格式化代码"
	@echo "  lint          - 代码检查"
	@echo "  deps          - 安装依赖"
	@echo "  help          - 显示此帮助信息"

# 创建发布包
.PHONY: release
release: build-all
	@echo "创建发布包..."
	@mkdir -p release
	@tar -czf release/auth_proxy_linux_amd64_v$(VERSION).tar.gz \
		--transform 's,^,$(BINARY_NAME)/,' \
		$(BINARY_NAME) README.md QUICK_START.md config_example.json \
		test_proxy.sh start_proxy.sh
	@zip -j release/auth_proxy_windows_amd64_v$(VERSION).zip \
		$(BINARY_NAME).exe README.md QUICK_START.md config_example.json \
		test_proxy.bat start_proxy.bat
	@echo "发布包创建完成"

# 默认目标
.DEFAULT_GOAL := build 