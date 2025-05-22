package api

import (
	"encoding/json"
	"github.com/golang-jwt/jwt/v5"
	"go.uber.org/zap"
	"golang.org/x/crypto/bcrypt"
	"net/http"
	"strings"
	"time"
	"vkatun/config"
)

func getJwtKey() []byte {
	return []byte(config.JwtSecret)
}

type Claims struct {
	UserID int `json:"user_id"`
	jwt.RegisteredClaims
}

type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type registerRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
	Name     string `json:"name"`
}

func (api *API) registerUser(w http.ResponseWriter, r *http.Request) {
	var req registerRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		api.logger.Error("failed to decode register request", zap.Error(err))
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		api.logger.Error("failed to hash password", zap.Error(err))
		http.Error(w, "Error encrypting password", http.StatusInternalServerError)
		return
	}

	err = api.db.RegisterUser(r.Context(), req.Email, string(hashedPassword), req.Name)
	if err != nil {
		api.logger.Error("failed to register user in DB", zap.String("email", req.Email), zap.Error(err))
		http.Error(w, "Failed to register user", http.StatusInternalServerError)
		return
	}

	_ = api.db.IncrementTotalUsers(r.Context())

	api.logger.Info("user registered successfully", zap.String("email", req.Email))
	json.NewEncoder(w).Encode(map[string]string{"message": "User registered successfully"})
}

func (api *API) loginUser(w http.ResponseWriter, r *http.Request) {
	var req loginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		api.logger.Warn("invalid login JSON input", zap.Error(err))
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	user, err := api.db.GetUserByEmail(r.Context(), req.Email)
	if err != nil {
		api.logger.Warn("email not found during login", zap.String("email", req.Email), zap.Error(err))
		http.Error(w, "Invalid email or password", http.StatusUnauthorized)
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		api.logger.Warn("incorrect password", zap.String("email", req.Email))
		http.Error(w, "Invalid email or password", http.StatusUnauthorized)
		return
	}

	expirationTime := time.Now().Add(7 * 24 * time.Hour)
	claims := &Claims{
		UserID: user.ID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(getJwtKey())
	if err != nil {
		api.logger.Error("failed to sign JWT", zap.Error(err))
		http.Error(w, "Could not create token", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"token":   tokenString,
		"user_id": user.ID,
	})
}

func (api *API) getProfile(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		api.logger.Warn("unauthorized profile request: missing token")
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	user, err := api.db.GetUserByID(r.Context(), userID)
	if err != nil {
		api.logger.Error("failed to get user profile", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	json.NewEncoder(w).Encode(user)
}

func (api *API) updateProfileName(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		api.logger.Warn("unauthorized name update attempt")
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var payload struct {
		Name string `json:"name"`
	}
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		api.logger.Warn("invalid name update payload", zap.Error(err))
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	if err := api.db.UpdateUserName(r.Context(), userID, payload.Name); err != nil {
		api.logger.Error("failed to update user name", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "Failed to update name", http.StatusInternalServerError)
		return
	}

	api.logger.Info(
		"user name updated",
		zap.Int("user_id", userID),
		zap.String("new_name", payload.Name),
	)
	json.NewEncoder(w).Encode(map[string]string{"message": "Name updated"})
}

func (api *API) updateProfilePassword(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		api.logger.Warn("unauthorized password update attempt")
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var payload struct {
		CurrentPassword string `json:"currentPassword"`
		NewPassword     string `json:"newPassword"`
	}
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		api.logger.Warn("invalid password update payload", zap.Error(err))
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	user, err := api.db.GetUserByID(r.Context(), userID)
	if err != nil {
		api.logger.Error("user not found during password update", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(payload.CurrentPassword)); err != nil {
		api.logger.Warn("incorrect current password", zap.Int("user_id", userID))
		http.Error(w, "Current password is incorrect", http.StatusUnauthorized)
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(payload.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		api.logger.Error("failed to hash new password", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "Failed to hash password", http.StatusInternalServerError)
		return
	}

	if err := api.db.UpdateUserPassword(r.Context(), userID, string(hashedPassword)); err != nil {
		api.logger.Error("failed to update password in DB", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "Failed to update password", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(map[string]string{"message": "Password updated"})
}

func getUserIDFromContext(r *http.Request) (int, bool) {
	authHeader := r.Header.Get("Authorization")
	if !strings.HasPrefix(authHeader, "Bearer ") {
		return 0, false
	}
	tokenStr := strings.TrimPrefix(authHeader, "Bearer ")

	claims := &Claims{}
	token, err := jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
		return getJwtKey(), nil
	})
	if err != nil || !token.Valid {
		return 0, false
	}

	return claims.UserID, true
}

func isAdmin(email string) bool {
	for _, admin := range config.AdminEmails {
		if admin == email {
			return true
		}
	}
	return false
}
