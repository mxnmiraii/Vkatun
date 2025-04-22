package api

import (
	"github.com/gorilla/mux"
	"go.uber.org/zap"
	"net/http"
	"vkatun/pkg/db"
)

type API struct {
	router *mux.Router
	db     db.DB
	logger *zap.Logger
}

func New(db db.DB, logger *zap.Logger) *API {
	api := &API{
		router: mux.NewRouter(),
		db:     db,
		logger: logger,
	}

	api.endpoints()

	return api
}

func (api *API) GetRouter() *mux.Router {
	return api.router
}

func (api *API) Run(addr string) error {
	return http.ListenAndServe(addr, api.router)
}

func (api *API) endpoints() {
	// Auth
	api.router.HandleFunc("/register", api.registerUser).Methods(http.MethodPost)
	api.router.HandleFunc("/login", api.loginUser).Methods(http.MethodPost)
	api.router.HandleFunc("/profile", api.getProfile).Methods(http.MethodGet)
	api.router.HandleFunc("/profile/name", api.updateProfileName).Methods(http.MethodPost)
	api.router.HandleFunc("/profile/password", api.updateProfilePassword).Methods(http.MethodPost)

	// Resume
	api.router.HandleFunc("/upload", api.uploadResume).Methods(http.MethodPost)
	api.router.HandleFunc("/resume/{id}", api.getResumeByID).Methods(http.MethodGet)
	api.router.HandleFunc("/resume/{id}/edit", api.editResume).Methods(http.MethodPost)
	api.router.HandleFunc("/resume/{id}/edit/{section}", api.editResumeSection).Methods(http.MethodPost)
	api.router.HandleFunc("/resume/{id}/check/grammar", api.checkGrammar).Methods(http.MethodPost)
	api.router.HandleFunc("/resume/{id}/check/structure", api.checkStructure).Methods(http.MethodPost)
	api.router.HandleFunc("/resume/{id}/check/skills", api.checkSkills).Methods(http.MethodPost)
	api.router.HandleFunc("/resume/{id}/delete", api.deleteResume).Methods(http.MethodDelete)
	api.router.HandleFunc("/resumes", api.listResumes).Methods(http.MethodGet)

	// Metrics
	api.router.HandleFunc("/metrics", api.getMetrics).Methods(http.MethodGet)
	api.router.HandleFunc("/metrics/update", api.updateMetrics).Methods(http.MethodPost)
}
