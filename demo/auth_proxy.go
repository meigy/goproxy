package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/elazarl/goproxy"
	"github.com/elazarl/goproxy/ext/auth"
)

// 用户认证信息
type UserCredentials struct {
	Username string
	Password string
}

// 用户数据库（在实际应用中应该使用数据库或配置文件）
var users = map[string]UserCredentials{
	"admin": {Username: "admin", Password: "admin123"},
	"user1": {Username: "user1", Password: "password1"},
	"user2": {Username: "user2", Password: "password2"},
}

// 认证函数
func authenticateUser(username, password string) bool {
	if user, exists := users[username]; exists {
		return user.Username == username && user.Password == password
	}
	return false
}

// 打印使用说明
func printUsage() {
	fmt.Println("HTTPS代理服务器 - 支持用户名密码认证")
	fmt.Println("使用方法:")
	fmt.Println("  auth_proxy [选项]")
	fmt.Println("")
	fmt.Println("选项:")
	fmt.Println("  -addr string")
	fmt.Println("        代理服务器监听地址 (默认 \":8080\")")
	fmt.Println("  -v    启用详细日志输出")
	fmt.Println("  -h    显示此帮助信息")
	fmt.Println("")
	fmt.Println("示例:")
	fmt.Println("  auth_proxy -addr :9090 -v")
	fmt.Println("")
	fmt.Println("支持的认证用户:")
	for username, cred := range users {
		fmt.Printf("  用户名: %s, 密码: %s\n", username, cred.Password)
	}
	fmt.Println("")
	fmt.Println("客户端配置:")
	fmt.Println("  代理地址: http://localhost:8080")
	fmt.Println("  认证方式: Basic Auth")
	fmt.Println("  用户名: admin/user1/user2")
	fmt.Println("  密码: 对应的密码")
}

func main() {
	// 解析命令行参数
	addr := flag.String("addr", ":8080", "代理服务器监听地址")
	verbose := flag.Bool("v", false, "启用详细日志输出")
	help := flag.Bool("h", false, "显示帮助信息")
	flag.Parse()

	// 显示帮助信息
	if *help {
		printUsage()
		os.Exit(0)
	}

	// 创建代理服务器
	proxy := goproxy.NewProxyHttpServer()
	proxy.Verbose = *verbose

	// 设置代理标题（通过日志显示）
	log.Printf("GoProxy Auth Server 已启动")

	// 添加认证中间件
	auth.ProxyBasic(proxy, "GoProxy Realm", authenticateUser)

	// 添加请求日志记录
	proxy.OnRequest().DoFunc(func(req *http.Request, ctx *goproxy.ProxyCtx) (*http.Request, *http.Response) {
		if *verbose {
			log.Printf("请求: %s %s", req.Method, req.URL)
			log.Printf("用户代理: %s", req.UserAgent())
		}
		return req, nil
	})

	// 添加响应日志记录
	proxy.OnResponse().DoFunc(func(resp *http.Response, ctx *goproxy.ProxyCtx) *http.Response {
		if *verbose {
			log.Printf("响应: %s %s - %d", ctx.Req.Method, ctx.Req.URL, resp.StatusCode)
		}
		return resp
	})

	// 添加错误处理
	proxy.OnRequest().HandleConnectFunc(func(host string, ctx *goproxy.ProxyCtx) (*goproxy.ConnectAction, string) {
		if *verbose {
			log.Printf("CONNECT请求: %s", host)
		}
		return nil, host
	})

	// 启动服务器
	log.Printf("启动HTTPS代理服务器，监听地址: %s", *addr)
	log.Printf("支持的认证用户:")
	for username := range users {
		log.Printf("  - %s", username)
	}
	log.Printf("按 Ctrl+C 停止服务器")

	// 启动HTTP服务器
	if err := http.ListenAndServe(*addr, proxy); err != nil {
		log.Fatal("服务器启动失败:", err)
	}
}
