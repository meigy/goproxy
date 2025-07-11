# 快速开始指南

## 概述

本指南将帮助您快速搭建和运行HTTPS代理服务器。

## 步骤1: 编译程序

### Windows用户
```bash
build.bat
```

### Linux/macOS用户
```bash
chmod +x build.sh
./build.sh
```

编译完成后，您将看到以下文件：
- `auth_proxy.exe` / `auth_proxy` - 基础认证代理
- `configurable_proxy.exe` / `configurable_proxy` - 可配置代理

## 步骤2: 启动代理服务器

### 选择代理类型

#### 基础认证代理 (推荐新手)
**Windows:**
```bash
start_proxy.bat
```

**Linux/macOS:**
```bash
chmod +x start_proxy.sh
./start_proxy.sh
```

默认配置：
- 端口: 8080
- 用户名: admin
- 密码: admin123

#### 可配置代理 (推荐高级用户)
**Windows:**
```bash
start_config_proxy.bat
```

**Linux/macOS:**
```bash
chmod +x start_config_proxy.sh
./start_config_proxy.sh
```

首次运行会自动创建 `config.json` 配置文件。

## 步骤3: 测试代理

### Windows用户
```bash
test_proxy.bat
```

### Linux/macOS用户
```bash
chmod +x test_proxy.sh
./test_proxy.sh
```

## 任务分工说明

### Build脚本 (编译阶段)
- ✅ 编译生成可执行文件
- ✅ 多平台交叉编译
- ✅ 创建发布包
- ✅ 生成校验和

### Start脚本 (运行阶段)
- ✅ 检查可执行文件是否存在
- ✅ 启动已编译的程序
- ✅ 显示启动信息
- ✅ 错误处理和提示

## 快速命令参考

### 完整流程
```bash
# 1. 编译
./build.sh

# 2. 启动
./start_config_proxy.sh

# 3. 测试
./test_proxy.sh
```

### 仅启动 (需要先编译)
```bash
./start_proxy.sh
```

### 仅测试 (需要先启动)
```bash
./test_proxy.sh
```

## 常见问题

### Q: 提示"可执行文件不存在"
**A:** 请先运行 `build.bat` 或 `build.sh` 编译程序

### Q: 端口被占用
**A:** 修改配置文件中的端口号，或停止占用端口的程序

### Q: 认证失败
**A:** 检查用户名密码是否正确 (默认: admin/admin123)

## 下一步

- 查看 [README.md](README.md) 了解详细功能
- 查看 [STARTUP_GUIDE.md](STARTUP_GUIDE.md) 了解启动选项
- 查看 [BUILD.md](BUILD.md) 了解构建过程 