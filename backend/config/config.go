package config

import (
	"github.com/spf13/viper"
	"log"
	"os"
	"strings"
	"vkatun/pkg/utils"
)

var (
	JwtSecret      string
	AdminEmails    []string
	DeepSeekAPIKey string
	DeepSeekURL    string
	Model          string
	RoleSystem     string
	RoleUser       string
	Extract        string
	Grammar        string
	Structure      string
	Skills         []string
	Postgres       string
)

func InitConfig() {
	var envPath string

	if p := os.Getenv("ENV_PATH"); p != "" {
		envPath = p
	} else {
		envPath = ".env"
	}

	if _, err := os.Stat(envPath); err == nil {
		viper.SetConfigFile(envPath)
		viper.SetConfigType("env")

		if err := viper.ReadInConfig(); err != nil {
			log.Fatalf("ошибка чтения .env конфигурации: %v", err)
		}
	}

	viper.AutomaticEnv()

	JwtSecret = viper.GetString("JWT_SECRET")
	AdminEmails = utils.Trim(strings.Split(viper.GetString("ADMIN_EMAILS"), ","))
	DeepSeekAPIKey = viper.GetString("DEEPSEEK_API_KEY")
	DeepSeekURL = viper.GetString("DEEPSEEK_URL")
	Model = viper.GetString("DEEPSEEK_MODEL")
	RoleSystem = viper.GetString("ROLE_SYSTEM")
	RoleUser = viper.GetString("ROLE_USER")
	Extract = viper.GetString("EXTRACT")
	Grammar = viper.GetString("GRAMMAR")
	Structure = viper.GetString("STRUCTURE")
	Skills = utils.Trim(strings.Split(viper.GetString("SKILLS"), ","))
	Postgres = viper.GetString("POSTGRES_STR")
}
