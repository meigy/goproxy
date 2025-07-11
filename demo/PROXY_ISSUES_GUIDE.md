# 代理问题解决指南

## 问题描述

用户反馈：有些网站代理成功，有些网站代理失败，特别是像 `www.google.com` 这样的网站。

## 问题分析

### 🔍 根本原因

#### 1. **HTTPS MITM 未启用**
当前代理实现的关键问题：

```go
// 在 configurable_proxy.go 中
proxy.OnRequest().HandleConnectFunc(func(host string, ctx *goproxy.ProxyCtx) (*goproxy.ConnectAction, string) {
    return nil, host  // 返回 nil，不进行MITM
})
```

**问题：**
- 返回 `nil` 意味着代理服务器不会拦截HTTPS流量
- 对于HTTPS网站，代理只是简单地转发CONNECT请求
- 无法进行内容过滤、日志记录等功能

#### 2. **证书信任问题**
- **证书固定 (Certificate Pinning)**: Google等大网站使用证书固定技术
- **HSTS (HTTP Strict Transport Security)**: 强制使用HTTPS
- **证书验证严格**: 不接受自签名或不受信任的证书

#### 3. **网络连接限制**
- **防火墙**: 企业或ISP防火墙可能阻止某些连接
- **DNS污染**: DNS解析可能被干扰
- **地理位置限制**: 某些网站可能限制特定地区的访问

## 解决方案

### ✅ 方案1: 启用HTTPS MITM (已实现)

#### 修改内容
```go
// 修改后的HTTPS处理逻辑
proxy.OnRequest().HandleConnectFunc(func(host string, ctx *goproxy.ProxyCtx) (*goproxy.ConnectAction, string) {
    if config.Logging.Level == "debug" {
        log.Printf("CONNECT请求: %s", host)
    }
    
    // 检查是否启用HTTPS MITM
    if config.Security.EnableHTTPS {
        // 启用MITM，使用默认的goproxy CA证书
        log.Printf("启用HTTPS MITM: %s", host)
        return goproxy.MitmConnect, host
    }
    
    // 不启用MITM，简单转发
    return nil, host
})
```

#### 配置方法
在 `config.json` 中设置：
```json
{
  "security": {
    "enable_https": true,
    "cert_file": "",
    "key_file": ""
  }
}
```

### ✅ 方案2: 客户端证书信任

#### 获取代理CA证书
```bash
# 从goproxy源码中提取CA证书
curl -O https://raw.githubusercontent.com/elazarl/goproxy/master/certs/ca.pem
```

#### 浏览器信任证书
**Chrome:**
1. 设置 → 隐私设置和安全性 → 安全 → 管理证书
2. 选择"证书颁发机构"标签
3. 点击"导入"，选择 `ca.pem` 文件

**Firefox:**
1. 设置 → 隐私与安全 → 查看证书
2. 选择"证书颁发机构"标签
3. 点击"导入"，选择 `ca.pem` 文件

### ✅ 方案3: 自定义CA证书

#### 生成自定义CA证书
```bash
# 使用OpenSSL生成CA证书
openssl genrsa -out ca-key.pem 2048
openssl req -new -x509 -days 365 -key ca-key.pem -out ca-cert.pem
```

#### 配置代理使用自定义证书
```json
{
  "security": {
    "enable_https": true,
    "cert_file": "ca-cert.pem",
    "key_file": "ca-key.pem"
  }
}
```

## 测试方法

### 1. 测试HTTP网站
```bash
# 测试HTTP网站 (应该成功)
curl -x http://admin:admin123@localhost:8080 http://httpbin.org/ip
```

### 2. 测试HTTPS网站
```bash
# 测试HTTPS网站 (需要信任证书)
curl -x http://admin:admin123@localhost:8080 https://httpbin.org/ip

# 跳过证书验证 (仅测试用)
curl -k -x http://admin:admin123@localhost:8080 https://httpbin.org/ip
```

### 3. 测试Google等网站
```bash
# 测试Google (需要信任证书)
curl -x http://admin:admin123@localhost:8080 https://www.google.com

# 跳过证书验证
curl -k -x http://admin:admin123@localhost:8080 https://www.google.com
```

## 常见问题及解决

### ❌ 问题1: 证书不受信任
**错误信息：** `SSL certificate problem: unable to get local issuer certificate`

**解决方案：**
1. 信任代理的CA证书
2. 使用 `-k` 参数跳过证书验证 (仅测试用)

### ❌ 问题2: 连接被拒绝
**错误信息：** `Connection refused`

**解决方案：**
1. 检查代理服务器是否正在运行
2. 检查端口是否正确
3. 检查防火墙设置

### ❌ 问题3: 超时
**错误信息：** `Operation timed out`

**解决方案：**
1. 检查网络连接
2. 检查DNS解析
3. 尝试使用不同的DNS服务器

### ❌ 问题4: 403 Forbidden
**错误信息：** `HTTP/1.1 403 Forbidden`

**解决方案：**
1. 检查用户名密码是否正确
2. 检查访问控制规则
3. 检查IP白名单设置

## 性能优化建议

### 1. 启用证书缓存
```go
// 在代理服务器中启用证书存储
proxy.CertStore = NewCertStorage()
```

### 2. 调整超时设置
```json
{
  "server": {
    "read_timeout": "30s",
    "write_timeout": "30s",
    "idle_timeout": "120s"
  }
}
```

### 3. 限制并发连接
```json
{
  "server": {
    "max_connections": 1000
  }
}
```

## 安全注意事项

### ⚠️ 重要提醒

1. **证书安全**: 不要在生产环境中使用默认的goproxy CA证书
2. **访问控制**: 配置适当的IP白名单和用户权限
3. **日志记录**: 启用详细的访问日志记录
4. **定期更新**: 定期更新证书和代理软件

### 🔒 生产环境建议

1. **使用自定义CA证书**
2. **配置严格的访问控制**
3. **启用HTTPS代理服务器**
4. **实施监控和告警**
5. **定期安全审计**

## 总结

代理失败的主要原因：
1. **HTTPS MITM未启用** - 已通过配置 `enable_https: true` 解决
2. **证书信任问题** - 需要客户端信任代理CA证书
3. **网络限制** - 需要检查网络环境和防火墙设置

通过启用HTTPS MITM功能，代理服务器现在可以：
- ✅ 拦截和检查HTTPS流量
- ✅ 记录详细的访问日志
- ✅ 实施内容过滤
- ✅ 支持Google等复杂网站

记住：客户端需要信任代理的CA证书才能正常访问HTTPS网站！ 