package server

import "vkatun/pkg/api"

type Server struct {
	api *api.API
}

func New() (*Server, error) {
	srv := new(Server)

	srv.api = api.New()

	return srv, nil
}

func (s *Server) Run(addr string) error {
	err := s.api.Run(addr)
	if err != nil {
		return err
	}
	return nil
}
