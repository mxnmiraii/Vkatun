package server

import (
	"vkatun/config"
	"vkatun/pkg/api"
	"vkatun/pkg/db"
	"vkatun/pkg/db/pgsql"
)

type Server struct {
	api *api.API
	db  db.DB
}

func New() (*Server, error) {
	srv := new(Server)

	database, err := pgsql.New(config.Postgres)
	if err != nil {
		return nil, err
	}

	srv.db = database
	srv.api = api.New(srv.db)

	return srv, nil
}

func (s *Server) Run(addr string) error {
	err := s.api.Run(addr)
	if err != nil {
		return err
	}
	return nil
}
