package main

import "vkatun/pkg/server"

const addr = ":3002"

func main() {
	s, _ := server.New()
	s.Run(addr)
}
