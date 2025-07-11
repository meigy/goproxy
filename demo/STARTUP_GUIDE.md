# 启动指南

## 概述

本文档说明如何启动可配置HTTPS代理服务器，该服务器支持配置文件驱动，无需编译即可运行。

## 启动方式

### 1. 快速启动（推荐）

**Windows:**
```cmd
quick_start.bat
```

**Linux/macOS:**
```bash
chmod +x quick_start.sh
./quick_start.sh
```

**特点：**
- 一键启动
- 自动创建配置文件
- 无需编译
- 详细日志输出

### 2. 使用启动脚本

**Windows:**
```cmd
start_config_proxy.bat
```

**Linux/macOS:**
```bash
chmod +x start_config_proxy.sh
./start_config_proxy.sh
```

**特点：**
- 完整的错误检查
- 详细的配置信息显示
- 自动创建配置文件

### 3. 手动启动

```bash
# 使用默认配置文件（自动创建）
go run configurable_proxy.go config.go -v

# 使用自定义配置文件
go run configurable_proxy.go config.go -config myconfig.json

# 创建默认配置文件
go run configurable_proxy.go config.go -create-config

# 显示帮助信息
go run configurable_proxy.go config.go -h
```

## 配置文件

### 自动创建

首次启动时，如果配置文件不存在，程序会自动创建默认配置文件 `config.json`。

### 默认配置

```json
{
  "server": {
    "addr": ":8080",
    "read_timeout": "30s",
    "write_timeout": "30s",
    "idle_timeout": "120s",
    "max_connections": 1000
  },
  "users": [
    {
      "username": "admin",
      "password": "admin123",
      "role": "admin"
    },
    {
      "username": "user1",
      "password": "password1",
      "role": "user"
    }
  ],
  "security": {
    "require_auth": true,
    "rate_limit": 1000
  }
}
```

### 自定义配置

您可以编辑 `config.json` 文件来自定义：
- 服务器设置
- 用户账户
- 访问规则
- 日志配置
- 安全设置

## 启动流程

1. **检查依赖**
   - 验证Go环境
   - 检查必要文件

2. **加载配置**
   - 读取配置文件
   - 如果不存在则创建默认配置
   - 验证配置有效性

3. **启动服务**
   - 创建代理服务器
   - 应用配置设置
   - 开始监听

4. **显示信息**
   - 配置摘要
   - 服务器状态
   - 使用说明

## 命令行参数

| 参数 | 说明 | 示例 |
|------|------|------|
| `-config` | 配置文件路径 | `-config myconfig.json` |
| `-addr` | 监听地址 | `-addr :9090` |
| `-v` | 详细日志 | `-v` |
| `-h` | 显示帮助 | `-h` |
| `-create-config` | 创建配置文件 | `-create-config` |

## 故障排除

### 常见问题

1. **Go未安装**
   ```
   错误: Go未安装，请先安装Go
   解决: 安装Go 1.20或更高版本
   ```

2. **文件缺失**
   ```
   错误: 缺少主程序文件
   解决: 确保在demo目录中运行
   ```

3. **端口被占用**
   ```
   错误: listen tcp :8080: bind: address already in use
   解决: 使用不同端口 -addr :9090
   ```

4. **配置文件错误**
   ```
   错误: 配置验证失败
   解决: 检查config.json格式
   ```

### 调试模式

使用 `-v` 参数启用详细日志：
```bash
go run configurable_proxy.go config.go -v
```

## 服务管理

### 启动服务
```bash
# 后台运行（Linux/macOS）
nohup go run configurable_proxy.go config.go > proxy.log 2>&1 &

# Windows服务
# 可以使用nssm等工具注册为Windows服务
```

### 停止服务
```bash
# 查找进程
ps aux | grep configurable_proxy

# 停止进程
kill <PID>

# 或者按 Ctrl+C
```

### 重启服务
```bash
# 停止后重新启动
kill <PID>
go run configurable_proxy.go config.go -v
```

## 监控和日志

### 日志文件
- 默认日志文件：`proxy.log`
- 日志级别：可配置（debug, info, warn, error）
- 日志轮转：支持大小限制和备份

### 监控指标
- 连接数
- 请求数
- 响应时间
- 错误率

## 安全建议

1. **修改默认密码**
   - 编辑config.json中的用户密码
   - 使用强密码

2. **限制访问IP**
   - 配置allowed_ips
   - 配置blocked_ips

3. **启用HTTPS**
   - 配置证书文件
   - 设置enable_https为true

4. **设置访问规则**
   - 配置域名白名单/黑名单
   - 设置用户权限

## 总结

可配置HTTPS代理服务器提供了灵活的启动方式：

- ✅ **快速启动**：一键启动，无需编译
- ✅ **配置文件驱动**：所有设置通过配置文件管理
- ✅ **自动配置**：首次启动自动创建默认配置
- ✅ **多种启动方式**：适应不同使用场景
- ✅ **详细日志**：便于调试和监控
- ✅ **错误处理**：友好的错误提示

选择适合您需求的启动方式，开始使用可配置HTTPS代理服务器！ 