package api

import (
	"github.com/gorilla/mux"
	"net/http"
)

type API struct {
	router *mux.Router
}

func New() *API {
	api := &API{
		router: mux.NewRouter(),
	}

	api.endpoints()

	return api
}

func (api *API) Run(addr string) error {
	return http.ListenAndServe(addr, api.router)
}

func (api *API) endpoints() {
}
