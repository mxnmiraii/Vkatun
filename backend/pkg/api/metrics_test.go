package api

import (
	"bytes"
	"encoding/json"
	"github.com/golang-jwt/jwt/v5"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"go.uber.org/zap"
	"log"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"
	"vkatun/config"
	"vkatun/pkg/db/mock-db"
	"vkatun/pkg/logger"
	"vkatun/pkg/models"
)

func generateTestToken(userID int) string {
	claims := &Claims{
		UserID: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour)),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(config.JwtSecret))
	if err != nil {
		panic("не удалось подписать токен: " + err.Error())
	}
	return tokenString
}

func injectUserID(req *http.Request, userID int) *http.Request {
	token := generateTestToken(userID)
	req.Header.Set("Authorization", "Bearer "+token)
	return req
}

func TestMain(m *testing.M) {
	config.InitConfig()

	var err error
	logger.Log, err = zap.NewDevelopment()
	if err != nil {
		log.Fatal("не удалось инициализировать логгер: " + err.Error())
	}

	os.Exit(m.Run())
}

func TestGetMetrics(t *testing.T) {
	mockDB := new(mock_db.MockDB)

	adminUser := &models.User{ID: 1, Email: config.AdminEmails[0]}
	mockDB.On("GetUserByID", mock.Anything, mock.Anything).Return(adminUser, nil)

	expectedMetrics := &models.Metrics{
		TotalUsers:       10,
		TotalResumes:     5,
		TotalChangesApp:  20,
		ActiveUsersToday: 3,
	}
	mockDB.On("GetMetrics", mock.Anything).Return(expectedMetrics, nil)

	a := New(mockDB, logger.Log)

	req := httptest.NewRequest(http.MethodGet, "/metrics", nil)
	req = injectUserID(req, 1)
	rr := httptest.NewRecorder()
	a.GetRouter().ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)

	var result models.Metrics
	err := json.NewDecoder(rr.Body).Decode(&result)
	assert.NoError(t, err)
	assert.Equal(t, expectedMetrics.TotalUsers, result.TotalUsers)

	mockDB.AssertExpectations(t)
}

func TestUpdateMetrics(t *testing.T) {
	mockDB := new(mock_db.MockDB)

	adminUser := &models.User{ID: 1, Email: config.AdminEmails[0]}
	mockDB.On("GetUserByID", mock.Anything, mock.MatchedBy(func(id int) bool {
		return id == 1
	})).Return(adminUser, nil)

	update := models.MetricsUpdateRequest{
		Source: "admin",
		Updates: models.MetricsUpdate{
			TotalUsers:      100,
			TotalResumes:    50,
			TotalChangesApp: 200,
		},
	}
	mockDB.On("UpdateMetrics", mock.Anything, update).Return(nil)

	a := New(mockDB, logger.Log)

	body, _ := json.Marshal(update)
	req := httptest.NewRequest(http.MethodPost, "/metrics/update", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req = injectUserID(req, 1)

	rr := httptest.NewRecorder()
	a.GetRouter().ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	mockDB.AssertExpectations(t)
}
