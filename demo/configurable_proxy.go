package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"strings"

	"github.com/elazarl/goproxy"
	"github.com/elazarl/goproxy/ext/auth"
)

// 全局配置
var config *Config
var userMap map[string]UserConfig

// 认证函数
func authenticateUser(username, password string) bool {
	if !config.Security.RequireAuth {
		return true
	}

	if user, exists := userMap[username]; exists {
		return user.Username == username && user.Password == password
	}
	return false
}

// 检查访问权限
func checkAccess(username, host string) bool {
	user, exists := userMap[username]
	if !exists {
		return false
	}

	// 检查拒绝列表
	for _, denied := range user.Denied {
		if strings.Contains(host, denied) {
			return false
		}
	}

	// 检查允许列表
	if len(user.Allowed) > 0 {
		allowed := false
		for _, allowedDomain := range user.Allowed {
			if strings.Contains(host, allowedDomain) {
				allowed = true
				break
			}
		}
		if !allowed {
			return false
		}
	}

	// 检查全局规则（按优先级排序）
	for _, rule := range config.Rules {
		if rule.Username != "" && rule.Username != username {
			continue
		}
		if strings.Contains(host, rule.Pattern) {
			return rule.Type == "allow"
		}
	}

	return true
}

// 检查IP地址
func checkIPAddress(clientIP string) bool {
	// 检查阻止的IP
	for _, blockedIP := range config.Security.BlockedIPs {
		if clientIP == blockedIP {
			return false
		}
	}

	// 检查允许的IP
	if len(config.Security.AllowedIPs) > 0 {
		allowed := false
		for _, allowedIP := range config.Security.AllowedIPs {
			if clientIP == allowedIP {
				allowed = true
				break
			}
		}
		if !allowed {
			return false
		}
	}

	return true
}

// 打印使用说明
func printUsage() {
	fmt.Println("可配置HTTPS代理服务器 - 支持配置文件")
	fmt.Println("使用方法:")
	fmt.Println("  configurable_proxy [选项]")
	fmt.Println("")
	fmt.Println("选项:")
	fmt.Println("  -config string")
	fmt.Println("        配置文件路径 (默认 \"config.json\")")
	fmt.Println("  -addr string")
	fmt.Println("        代理服务器监听地址 (覆盖配置文件)")
	fmt.Println("  -v    启用详细日志输出")
	fmt.Println("  -h    显示此帮助信息")
	fmt.Println("  -create-config")
	fmt.Println("        创建默认配置文件")
	fmt.Println("")
	fmt.Println("示例:")
	fmt.Println("  configurable_proxy -config myconfig.json")
	fmt.Println("  configurable_proxy -addr :9090 -v")
	fmt.Println("  configurable_proxy -create-config")
	fmt.Println("")
	fmt.Println("配置文件格式请参考 config.json.example")
}

func main() {
	// 解析命令行参数
	configFile := flag.String("config", "config.json", "配置文件路径")
	addr := flag.String("addr", "", "代理服务器监听地址")
	verbose := flag.Bool("v", false, "启用详细日志输出")
	help := flag.Bool("h", false, "显示帮助信息")
	createConfig := flag.Bool("create-config", false, "创建默认配置文件")
	flag.Parse()

	// 显示帮助信息
	if *help {
		printUsage()
		os.Exit(0)
	}

	// 创建默认配置文件
	if *createConfig {
		if _, err := createDefaultConfigFile(*configFile); err != nil {
			log.Fatal("创建默认配置文件失败:", err)
		}
		fmt.Printf("默认配置文件已创建: %s\n", *configFile)
		os.Exit(0)
	}

	// 加载配置文件
	var err error
	config, err = loadConfig(*configFile)
	if err != nil {
		log.Fatal("加载配置文件失败:", err)
	}

	// 构建用户映射
	userMap = make(map[string]UserConfig)
	for _, user := range config.Users {
		userMap[user.Username] = user
	}

	// 命令行参数覆盖配置文件
	if *addr != "" {
		config.Server.Addr = *addr
	}
	if *verbose {
		// 设置详细日志级别
		config.Logging.Level = "debug"
	}

	// 打印配置信息
	printConfigInfo(config)

	// 创建代理服务器
	proxy := goproxy.NewProxyHttpServer()
	proxy.Verbose = config.Logging.Level == "debug"

	// 添加认证中间件（如果启用）
	if config.Security.RequireAuth {
		auth.ProxyBasic(proxy, "GoProxy Configurable Realm", authenticateUser)
	}

	// 添加请求处理
	proxy.OnRequest().DoFunc(func(req *http.Request, ctx *goproxy.ProxyCtx) (*http.Request, *http.Response) {
		// 获取客户端IP
		clientIP := getClientIP(req)

		// 检查IP地址
		if !checkIPAddress(clientIP) {
			if config.Logging.Level == "debug" {
				log.Printf("IP地址被拒绝: %s", clientIP)
			}
			resp := goproxy.NewResponse(req, goproxy.ContentTypeText, http.StatusForbidden, "IP地址被拒绝")
			return req, resp
		}

		// 检查请求大小
		if req.ContentLength > config.Security.MaxRequestSize {
			if config.Logging.Level == "debug" {
				log.Printf("请求过大: %d bytes", req.ContentLength)
			}
			resp := goproxy.NewResponse(req, goproxy.ContentTypeText, http.StatusRequestEntityTooLarge, "请求过大")
			return req, resp
		}

		// 获取认证用户（简化处理）
		username := ""
		if authHeader := req.Header.Get("Proxy-Authorization"); authHeader != "" {
			// 在实际场景中，应该从ctx中获取认证信息
			// 这里简化处理
		}

		// 检查访问权限
		host := req.Host
		if !checkAccess(username, host) {
			if config.Logging.Level == "debug" {
				log.Printf("访问被拒绝: 用户=%s, 主机=%s", username, host)
			}
			resp := goproxy.NewResponse(req, goproxy.ContentTypeText, http.StatusForbidden, "访问被拒绝")
			return req, resp
		}

		// 记录请求日志
		if config.Logging.Level == "debug" {
			log.Printf("请求: %s %s (用户: %s, IP: %s)", req.Method, req.URL, username, clientIP)
			log.Printf("用户代理: %s", req.UserAgent())
		}

		return req, nil
	})

	// 添加响应处理
	proxy.OnResponse().DoFunc(func(resp *http.Response, ctx *goproxy.ProxyCtx) *http.Response {
		if config.Logging.Level == "debug" {
			log.Printf("响应: %s %s - %d", ctx.Req.Method, ctx.Req.URL, resp.StatusCode)
		}
		return resp
	})

	// 添加HTTPS处理
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

	// 启动服务器
	log.Printf("启动可配置HTTPS代理服务器，监听地址: %s", config.Server.Addr)
	log.Printf("配置文件: %s", *configFile)
	log.Printf("日志级别: %s", config.Logging.Level)
	log.Printf("认证要求: %v", config.Security.RequireAuth)
	log.Printf("用户数量: %d", len(config.Users))
	log.Printf("规则数量: %d", len(config.Rules))
	log.Printf("按 Ctrl+C 停止服务器")

	// 创建HTTP服务器
	server := &http.Server{
		Addr:         config.Server.Addr,
		Handler:      proxy,
		ReadTimeout:  config.Server.ReadTimeout,
		WriteTimeout: config.Server.WriteTimeout,
		IdleTimeout:  config.Server.IdleTimeout,
	}

	// 启动服务器
	if err := server.ListenAndServe(); err != nil {
		log.Fatal("服务器启动失败:", err)
	}
}

// 获取客户端IP地址
func getClientIP(req *http.Request) string {
	// 检查X-Forwarded-For头
	if forwardedFor := req.Header.Get("X-Forwarded-For"); forwardedFor != "" {
		ips := strings.Split(forwardedFor, ",")
		if len(ips) > 0 {
			return strings.TrimSpace(ips[0])
		}
	}

	// 检查X-Real-IP头
	if realIP := req.Header.Get("X-Real-IP"); realIP != "" {
		return realIP
	}

	// 从RemoteAddr获取
	if req.RemoteAddr != "" {
		host, _, err := net.SplitHostPort(req.RemoteAddr)
		if err == nil {
			return host
		}
		return req.RemoteAddr
	}

	return "unknown"
}
