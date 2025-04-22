package api

import (
	"bytes"
	"encoding/json"
	"github.com/gorilla/mux"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"net/http"
	"net/http/httptest"
	"testing"
	"vkatun/pkg/db/mock-db"
	"vkatun/pkg/logger"
	"vkatun/pkg/models"
)

func TestGetResumeByID(t *testing.T) {
	mockDB := new(mock_db.MockDB)
	testResume := &models.Resume{ID: 1, Title: "Test Resume"}
	mockDB.On("GetResumeByID", mock.Anything, 1).Return(testResume, nil)

	a := New(mockDB, logger.Log)
	req := httptest.NewRequest(http.MethodGet, "/resume/1", nil)
	rr := httptest.NewRecorder()

	req = mux.SetURLVars(req, map[string]string{"id": "1"})
	a.GetRouter().ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)

	var result models.Resume
	_ = json.NewDecoder(rr.Body).Decode(&result)
	assert.Equal(t, "Test Resume", result.Title)

	mockDB.AssertExpectations(t)
}

func TestDeleteResume(t *testing.T) {
	mockDB := new(mock_db.MockDB)
	mockDB.On("DeleteResume", mock.Anything, 1).Return(nil)

	a := New(mockDB, logger.Log)
	req := httptest.NewRequest(http.MethodDelete, "/resume/1/delete", nil)
	rr := httptest.NewRecorder()

	req = mux.SetURLVars(req, map[string]string{"id": "1"})
	a.GetRouter().ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	mockDB.AssertExpectations(t)
}

func TestEditResume(t *testing.T) {
	mockDB := new(mock_db.MockDB)
	updatedResume := models.Resume{
		Title:      "Updated Resume",
		Contacts:   "Email",
		Job:        "Golang Dev",
		Experience: "2 years",
		Education:  "BS",
		Skills:     "Go, Docker",
		About:      "Hardworking",
	}
	mockDB.On("UpdateResume", mock.Anything, 1, updatedResume).Return(nil)

	a := New(mockDB, logger.Log)

	body, _ := json.Marshal(updatedResume)
	req := httptest.NewRequest(http.MethodPost, "/resume/1/edit", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	req = mux.SetURLVars(req, map[string]string{"id": "1"})
	a.GetRouter().ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	mockDB.AssertExpectations(t)
}
