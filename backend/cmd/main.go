package main

import (
	"go.uber.org/zap"
	"vkatun/config"
	"vkatun/pkg/logger"
	"vkatun/pkg/server"
)

const addr = ":8080"

func main() {
	config.InitConfig()

	s, err := server.New()
	if err != nil {
		logger.Log.Fatal("failed to init server", zap.Error(err))
	}
	err = s.Run(addr)
	if err != nil {
		logger.Log.Fatal("failed to run server", zap.Error(err))
	}
}
