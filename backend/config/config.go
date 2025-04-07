package config

import (
	"github.com/spf13/viper"
	"log"
)

var (
	JwtSecret      string
	AdminEmail     []string
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
	viper.SetConfigFile("backend/config.env")
	viper.SetConfigType("env")
	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err != nil {
		log.Fatalf("ошибка чтения .env конфигурации: %v", err)
	}

	JwtSecret = viper.GetString("JWT_SECRET")
	AdminEmail = viper.GetStringSlice("ADMIN_EMAILS")
	DeepSeekAPIKey = viper.GetString("DEEPSEEK_API_KEY")
	DeepSeekURL = viper.GetString("DEEPSEEK_URL")
	Model = viper.GetString("DEEPSEEK_MODEL")
	RoleSystem = viper.GetString("ROLE_SYSTEM")
	RoleUser = viper.GetString("ROLE_USER")
	Extract = viper.GetString("EXTRACT")
	Grammar = viper.GetString("GRAMMAR")
	Structure = viper.GetString("STRUCTURE")
	Skills = viper.GetStringSlice("SKILLS")
	Postgres = viper.GetString("POSTGRES_STR")
}
