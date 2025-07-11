# HTTPS代理服务器 Demo

这是一个基于 [goproxy](https://github.com/elazarl/goproxy) 的HTTPS代理服务器示例，支持用户名密码认证和配置文件管理。

## 功能特性

- ✅ HTTPS代理服务器
- ✅ 用户名密码认证
- ✅ 配置文件支持
- ✅ 多平台支持 (Windows/Linux/macOS)
- ✅ 详细的日志记录
- ✅ IP访问控制
- ✅ 请求大小限制
- ✅ 并发连接限制

## 快速开始

### 1. 编译程序

**Windows:**
```bash
build.bat
```

**Linux/macOS:**
```bash
./build.sh
```

编译完成后会生成以下可执行文件：
- `auth_proxy.exe` / `auth_proxy` - 基础认证代理
- `configurable_proxy.exe` / `configurable_proxy` - 可配置代理

### 2. 启动代理服务器

#### 基础认证代理 (简单版本)

**Windows:**
```bash
start_proxy.bat
```

**Linux/macOS:**
```bash
./start_proxy.sh
```

默认配置：
- 端口: 8080
- 用户名: admin
- 密码: admin123

#### 可配置代理 (高级版本)

**Windows:**
```bash
start_config_proxy.bat
```

**Linux/macOS:**
```bash
./start_config_proxy.sh
```

首次运行会自动创建 `config.json` 配置文件。

### 3. 测试代理

**Windows:**
```bash
test_proxy.bat
```

**Linux/macOS:**
```bash
./test_proxy.sh
```

## 文件说明

### 核心文件
- `auth_proxy.go` - 基础认证代理程序
- `configurable_proxy.go` - 可配置代理程序
- `config.go` - 配置文件管理模块

### 构建脚本
- `build.bat` / `build.sh` - 多平台编译打包脚本
- `build_simple.bat` / `build_simple.sh` - 简单编译脚本
- `Makefile` - Make构建文件

### 启动脚本
- `start_proxy.bat` / `start_proxy.sh` - 启动基础认证代理
- `start_config_proxy.bat` / `start_config_proxy.sh` - 启动可配置代理
- `quick_start.bat` / `quick_start.sh` - 快速启动脚本

### 测试脚本
- `test_proxy.bat` / `test_proxy.sh` - 代理测试脚本

### 配置文件
- `config.json` - 代理服务器配置文件 (自动生成)
- `config_example.json` - 配置文件示例

### 文档
- `README.md` - 项目说明文档
- `QUICK_START.md` - 快速开始指南
- `STARTUP_GUIDE.md` - 启动指南
- `BUILD.md` - 构建说明
- `BUILD_SUMMARY.md` - 构建总结

## 任务分工

### Build脚本职责
- 编译生成可执行文件
- 多平台交叉编译
- 创建发布包
- 生成校验和

### Start脚本职责
- 检查可执行文件是否存在
- 启动已编译的程序
- 显示启动信息
- 错误处理和提示

## 使用示例

### 1. 完整构建和启动流程

```bash
# 1. 编译程序
./build.sh

# 2. 启动代理
./start_config_proxy.sh

# 3. 测试代理
./test_proxy.sh
```

### 2. 仅启动已编译的程序

```bash
# 直接启动 (需要先编译)
./start_proxy.sh
```

### 3. 自定义配置

编辑 `config.json` 文件：

```json
{
  "server": {
    "port": 8080,
    "host": "0.0.0.0"
  },
  "auth": {
    "enabled": true,
    "users": {
      "admin": "admin123",
      "user1": "password1"
    }
  },
  "security": {
    "allowed_ips": ["127.0.0.1", "192.168.1.0/24"],
    "max_request_size": 10485760,
    "max_concurrent_connections": 100
  },
  "logging": {
    "level": "debug",
    "file": "proxy.log"
  }
}
```

## 代理设置

### 浏览器设置
- 代理类型: HTTPS
- 地址: 127.0.0.1
- 端口: 8080
- 用户名: admin
- 密码: admin123

### 系统设置
- Windows: 设置 → 网络和Internet → 代理
- Linux: 系统设置 → 网络 → 网络代理
- macOS: 系统偏好设置 → 网络 → 高级 → 代理

## 故障排除

### 常见问题

1. **可执行文件不存在**
   ```
   错误: 可执行文件 auth_proxy.exe 不存在
   请先运行 build.bat 编译程序
   ```
   解决方案: 运行 `build.bat` 或 `build.sh` 编译程序

2. **端口被占用**
   ```
   错误: 端口 8080 已被占用
   ```
   解决方案: 修改配置文件中的端口号

3. **认证失败**
   ```
   错误: 用户名或密码错误
   ```
   解决方案: 检查用户名密码是否正确

### 日志查看

- 控制台输出: 实时查看代理运行状态
- 日志文件: 查看 `proxy.log` (如果启用)

## 开发说明

### 依赖管理
```bash
go mod tidy
```

### 代码结构
```
demo/
├── auth_proxy.go          # 基础认证代理
├── configurable_proxy.go  # 可配置代理
├── config.go             # 配置管理
├── build.sh              # 构建脚本
├── start_proxy.sh        # 启动脚本
└── test_proxy.sh         # 测试脚本
```

### 编译选项
- `-ldflags='-s -w'`: 减小二进制文件大小
- `GOOS=linux GOARCH=amd64`: 交叉编译

## 许可证

本项目基于 MIT 许可证开源。 