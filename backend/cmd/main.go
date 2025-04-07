package main

import (
	"vkatun/config"
	"vkatun/pkg/server"
)

const addr = ":8080"

func main() {
	config.InitConfig()

	s, _ := server.New()
	s.Run(addr)
}
