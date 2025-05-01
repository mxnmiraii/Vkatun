package server

import (
	"context"
	"go.uber.org/zap"
	"vkatun/config"
	"vkatun/pkg/api"
	"vkatun/pkg/db"
	"vkatun/pkg/db/pgsql"
	"vkatun/pkg/logger"
)

type Server struct {
	api *api.API
	db  db.DB
}

func New() (*Server, error) {
	logger.Init()
	defer logger.Log.Sync()

	srv := new(Server)

	database, err := pgsql.New(config.Postgres)
	if err != nil {
		logger.Log.Error("failed to connect to DB", zap.Error(err))
		return nil, err
	}

	if err = database.Migrate(context.Background()); err != nil {
		logger.Log.Error("failed to run migration", zap.Error(err))
		return nil, err
	}

	srv.db = database
	srv.api = api.New(srv.db, logger.Log)

	return srv, nil
}

func (s *Server) Run(addr string) error {
	err := s.api.Run(addr)
	if err != nil {
		return err
	}
	return nil
}
