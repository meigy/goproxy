package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"time"
)

// 配置结构
type Config struct {
	Server   ServerConfig   `json:"server"`
	Users    []UserConfig   `json:"users"`
	Rules    []AccessRule   `json:"rules"`
	Logging  LoggingConfig  `json:"logging"`
	Security SecurityConfig `json:"security"`
}

// 服务器配置
type ServerConfig struct {
	Addr           string        `json:"addr"`
	ReadTimeout    time.Duration `json:"read_timeout"`
	WriteTimeout   time.Duration `json:"write_timeout"`
	IdleTimeout    time.Duration `json:"idle_timeout"`
	MaxConnections int           `json:"max_connections"`
}

// 用户配置
type UserConfig struct {
	Username string      `json:"username"`
	Password string      `json:"password"`
	Role     string      `json:"role"`
	Allowed  []string    `json:"allowed"` // 允许访问的域名
	Denied   []string    `json:"denied"`  // 拒绝访问的域名
	Quota    QuotaConfig `json:"quota"`   // 流量配额
}

// 流量配额配置
type QuotaConfig struct {
	DailyLimit   int64 `json:"daily_limit"`   // 每日流量限制（字节）
	MonthlyLimit int64 `json:"monthly_limit"` // 每月流量限制（字节）
	Enabled      bool  `json:"enabled"`       // 是否启用配额
}

// 访问规则配置
type AccessRule struct {
	Name     string `json:"name"`
	Type     string `json:"type"`     // "allow" 或 "deny"
	Pattern  string `json:"pattern"`  // 域名模式
	Username string `json:"username"` // 应用到此规则的用户，空表示所有用户
	Priority int    `json:"priority"` // 规则优先级，数字越大优先级越高
}

// 日志配置
type LoggingConfig struct {
	Level      string `json:"level"`       // "debug", "info", "warn", "error"
	File       string `json:"file"`        // 日志文件路径
	MaxSize    int    `json:"max_size"`    // 单个日志文件最大大小（MB）
	MaxBackups int    `json:"max_backups"` // 保留的日志文件数量
	Compress   bool   `json:"compress"`    // 是否压缩旧日志文件
	Console    bool   `json:"console"`     // 是否输出到控制台
}

// 安全配置
type SecurityConfig struct {
	RequireAuth    bool     `json:"require_auth"`     // 是否要求认证
	AllowedIPs     []string `json:"allowed_ips"`      // 允许的IP地址
	BlockedIPs     []string `json:"blocked_ips"`      // 阻止的IP地址
	RateLimit      int      `json:"rate_limit"`       // 速率限制（请求/分钟）
	MaxRequestSize int64    `json:"max_request_size"` // 最大请求大小（字节）
	EnableHTTPS    bool     `json:"enable_https"`     // 是否启用HTTPS
	CertFile       string   `json:"cert_file"`        // 证书文件路径
	KeyFile        string   `json:"key_file"`         // 私钥文件路径
}

// 默认配置
func getDefaultConfig() Config {
	return Config{
		Server: ServerConfig{
			Addr:           ":8080",
			ReadTimeout:    30 * time.Second,
			WriteTimeout:   30 * time.Second,
			IdleTimeout:    120 * time.Second,
			MaxConnections: 1000,
		},
		Users: []UserConfig{
			{
				Username: "admin",
				Password: "admin123",
				Role:     "admin",
				Allowed:  []string{},
				Denied:   []string{},
				Quota: QuotaConfig{
					DailyLimit:   0,
					MonthlyLimit: 0,
					Enabled:      false,
				},
			},
			{
				Username: "user1",
				Password: "password1",
				Role:     "user",
				Allowed:  []string{"google.com", "github.com"},
				Denied:   []string{"facebook.com", "twitter.com"},
				Quota: QuotaConfig{
					DailyLimit:   100 * 1024 * 1024,      // 100MB
					MonthlyLimit: 2 * 1024 * 1024 * 1024, // 2GB
					Enabled:      true,
				},
			},
		},
		Rules: []AccessRule{
			{
				Name:     "block_malware",
				Type:     "deny",
				Pattern:  "malware.com",
				Username: "",
				Priority: 100,
			},
			{
				Name:     "allow_trusted",
				Type:     "allow",
				Pattern:  "trusted.com",
				Username: "",
				Priority: 90,
			},
		},
		Logging: LoggingConfig{
			Level:      "info",
			File:       "proxy.log",
			MaxSize:    100,
			MaxBackups: 3,
			Compress:   true,
			Console:    true,
		},
		Security: SecurityConfig{
			RequireAuth:    true,
			AllowedIPs:     []string{},
			BlockedIPs:     []string{},
			RateLimit:      1000,
			MaxRequestSize: 10 * 1024 * 1024, // 10MB
			EnableHTTPS:    false,
			CertFile:       "",
			KeyFile:        "",
		},
	}
}

// 加载配置文件
func loadConfig(filename string) (*Config, error) {
	// 检查文件是否存在
	if _, err := os.Stat(filename); os.IsNotExist(err) {
		// 文件不存在，创建默认配置文件
		log.Printf("配置文件 %s 不存在，创建默认配置文件", filename)
		return createDefaultConfigFile(filename)
	}

	// 读取配置文件
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("读取配置文件失败: %v", err)
	}

	// 解析JSON
	var config Config
	if err := json.Unmarshal(data, &config); err != nil {
		return nil, fmt.Errorf("解析配置文件失败: %v", err)
	}

	// 验证配置
	if err := validateConfig(&config); err != nil {
		return nil, fmt.Errorf("配置验证失败: %v", err)
	}

	log.Printf("成功加载配置文件: %s", filename)
	return &config, nil
}

// 创建默认配置文件
func createDefaultConfigFile(filename string) (*Config, error) {
	config := getDefaultConfig()

	// 序列化为JSON
	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return nil, fmt.Errorf("序列化默认配置失败: %v", err)
	}

	// 写入文件
	if err := ioutil.WriteFile(filename, data, 0644); err != nil {
		return nil, fmt.Errorf("写入默认配置文件失败: %v", err)
	}

	log.Printf("已创建默认配置文件: %s", filename)
	return &config, nil
}

// 验证配置
func validateConfig(config *Config) error {
	// 验证服务器配置
	if config.Server.Addr == "" {
		return fmt.Errorf("服务器地址不能为空")
	}

	// 验证用户配置
	if len(config.Users) == 0 {
		return fmt.Errorf("至少需要配置一个用户")
	}

	// 检查用户名重复
	usernames := make(map[string]bool)
	for _, user := range config.Users {
		if user.Username == "" {
			return fmt.Errorf("用户名不能为空")
		}
		if usernames[user.Username] {
			return fmt.Errorf("用户名重复: %s", user.Username)
		}
		usernames[user.Username] = true
	}

	// 验证规则配置
	for _, rule := range config.Rules {
		if rule.Type != "allow" && rule.Type != "deny" {
			return fmt.Errorf("规则类型必须是 'allow' 或 'deny': %s", rule.Name)
		}
		if rule.Pattern == "" {
			return fmt.Errorf("规则模式不能为空: %s", rule.Name)
		}
	}

	// 验证日志配置
	if config.Logging.Level != "debug" && config.Logging.Level != "info" &&
		config.Logging.Level != "warn" && config.Logging.Level != "error" {
		return fmt.Errorf("日志级别必须是 debug, info, warn 或 error")
	}

	return nil
}

// 保存配置到文件
func saveConfig(config *Config, filename string) error {
	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return fmt.Errorf("序列化配置失败: %v", err)
	}

	if err := ioutil.WriteFile(filename, data, 0644); err != nil {
		return fmt.Errorf("保存配置文件失败: %v", err)
	}

	log.Printf("配置已保存到: %s", filename)
	return nil
}

// 打印配置信息
func printConfigInfo(config *Config) {
	log.Printf("=== 配置信息 ===")
	log.Printf("服务器地址: %s", config.Server.Addr)
	log.Printf("用户数量: %d", len(config.Users))
	log.Printf("规则数量: %d", len(config.Rules))
	log.Printf("日志级别: %s", config.Logging.Level)
	log.Printf("认证要求: %v", config.Security.RequireAuth)
	log.Printf("速率限制: %d 请求/分钟", config.Security.RateLimit)
	log.Printf("==================")
}
