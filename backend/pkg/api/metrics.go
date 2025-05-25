package api

import (
	"encoding/json"
	"go.uber.org/zap"
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
		api.logger.Error("user not found for metrics", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	if !isAdmin(user.Email) {
		http.Error(w, "Forbidden: admin only", http.StatusForbidden)
		return
	}

	metrics, err := api.db.GetMetrics(r.Context())
	if err != nil {
		api.logger.Error("failed to fetch metrics", zap.Error(err))
		http.Error(w, "Failed to fetch metrics", http.StatusInternalServerError)
		return
	}

	if metrics.TotalChangesApp > 0 {
		ratio := float64(metrics.AcceptedRecommendations) / float64(metrics.TotalChangesApp)
		metrics.TotalChangesApp = int(ratio * 100)
	} else {
		metrics.TotalChangesApp = 0
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
		api.logger.Error("user not found for metrics", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	if !isAdmin(user.Email) {
		http.Error(w, "Forbidden: admin only", http.StatusForbidden)
		return
	}

	var input models.MetricsUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		api.logger.Warn("invalid metrics update input", zap.Error(err))
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}
	if input.Updates.TotalUsers == 0 && input.Updates.TotalResumes == 0 && input.Updates.TotalChangesApp == 0 {
		api.logger.Warn("empty or missing updates field", zap.Any("input", input))
		http.Error(w, "Invalid or missing updates", http.StatusBadRequest)
		return
	}

	if err := api.db.UpdateMetrics(r.Context(), input); err != nil {
		api.logger.Error("failed to update metrics", zap.Error(err))
		http.Error(w, "Failed to update metrics", http.StatusInternalServerError)
		return
	}
	api.logger.Info("metrics update", zap.String("source", input.Source))

	json.NewEncoder(w).Encode(map[string]string{"message": "Metrics updated successfully"})
}

func (api *API) incrementRecommendations(w http.ResponseWriter, r *http.Request) {
	if err := api.db.IncrementRecommendations(r.Context()); err != nil {
		api.logger.Error("failed to increment recommendations", zap.Error(err))
		http.Error(w, "Failed to increment", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(map[string]string{"message": "Recommendations incremented"})
}

func (api *API) incrementAcceptedRecommendations(w http.ResponseWriter, r *http.Request) {
	if err := api.db.IncrementAcceptedRecommendations(r.Context()); err != nil {
		api.logger.Error("failed to increment accepted recommendations", zap.Error(err))
		http.Error(w, "Failed to increment", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(map[string]string{"message": "Accepted recommendations incremented"})
}
