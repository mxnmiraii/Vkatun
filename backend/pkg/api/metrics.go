package api

import (
	"encoding/json"
	"net/http"
	"vkatun/pkg/models"
)

func (api *API) getMetrics(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	user, err := api.db.GetUserByID(r.Context(), userID)
	if err != nil {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	if !isAdmin(user.Email) {
		http.Error(w, "Forbidden: admin only", http.StatusForbidden)
		return
	}

	metrics, err := api.db.GetMetrics(r.Context())
	if err != nil {
		http.Error(w, "Failed to fetch metrics", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(metrics)
}

func (api *API) updateMetrics(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	user, err := api.db.GetUserByID(r.Context(), userID)
	if err != nil {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	if !isAdmin(user.Email) {
		http.Error(w, "Forbidden: admin only", http.StatusForbidden)
		return
	}

	var input models.MetricsUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}
	if err := api.db.UpdateMetrics(r.Context(), input); err != nil {
		http.Error(w, "Failed to update metrics", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(map[string]string{"message": "Metrics updated successfully"})
}
