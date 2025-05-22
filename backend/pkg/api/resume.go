package api

import (
	"database/sql"
	"encoding/json"
	"errors"
	"github.com/gorilla/mux"
	"go.uber.org/zap"
	"io"
	"net/http"
	"strconv"
	"strings"
	"vkatun/pkg/analyzer"
	"vkatun/pkg/models"
)

func (api *API) uploadResume(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	r.ParseMultipartForm(10 << 20) // 10MB max
	file, _, err := r.FormFile("file")
	if err != nil {
		api.logger.Error("failed to read uploaded file", zap.Error(err))
		http.Error(w, "Failed to read file", http.StatusBadRequest)
		return
	}
	defer file.Close()

	content, err := io.ReadAll(file)
	if err != nil {
		api.logger.Error("failed to read file content", zap.Error(err))
		http.Error(w, "Failed to read file content", http.StatusInternalServerError)
		return
	}

	resume, _, err := analyzer.ParseResumeFromPDF(content)
	if err != nil {
		api.logger.Error("failed to parse resume", zap.Error(err))
		http.Error(w, "Failed to parse resume", http.StatusInternalServerError)
		return
	}

	resumeID, err := api.db.UploadResume(r.Context(), resume, userID)
	if err != nil {
		api.logger.Error("failed to save parsed resume", zap.Error(err))
		http.Error(w, "Failed to save resume", http.StatusInternalServerError)
		return
	}

	_ = api.db.IncrementTotalResumes(r.Context())
	_ = api.db.IncrementActiveUsersToday(r.Context(), userID)

	json.NewEncoder(w).Encode(map[string]interface{}{
		"message":   "Resume uploaded successfully",
		"resume_id": resumeID,
	})
}

func (api *API) uploadResumeGuest(w http.ResponseWriter, r *http.Request) {
	r.ParseMultipartForm(10 << 20) // 10MB max
	file, _, err := r.FormFile("file")
	if err != nil {
		api.logger.Error("failed to read uploaded file", zap.Error(err))
		http.Error(w, "Failed to read file", http.StatusBadRequest)
		return
	}
	defer file.Close()

	content, err := io.ReadAll(file)
	if err != nil {
		api.logger.Error("failed to read file content", zap.Error(err))
		http.Error(w, "Failed to read file content", http.StatusInternalServerError)
		return
	}

	_, str, err := analyzer.ParseResumeFromPDF(content)
	if err != nil {
		api.logger.Error("failed to parse resume", zap.Error(err))
		http.Error(w, "Failed to parse resume", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"message": "Resume uploaded successfully",
		"text":    str,
	})
}

func (api *API) getResumeByID(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		api.logger.Warn("invalid resume id", zap.String("id", vars["id"]))
		http.Error(w, "Invalid resume ID", http.StatusBadRequest)
		return
	}
	resume, err := api.db.GetResumeByID(r.Context(), id)
	if err != nil {
		api.logger.Error("resume not found", zap.Int("resume_id", id), zap.Error(err))
		http.Error(w, "Resume not found", http.StatusNotFound)
		return
	}
	_ = json.NewEncoder(w).Encode(resume)
}

func (api *API) editResume(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		api.logger.Warn("unauthorized profile request: missing token")
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	user, err := api.db.GetUserByID(r.Context(), userID)
	if err != nil {
		api.logger.Error("failed to fetch user", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		api.logger.Warn("invalid resume id", zap.String("id", vars["id"]))
		http.Error(w, "Invalid resume ID", http.StatusBadRequest)
		return
	}

	var input models.Resume
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		api.logger.Warn("invalid resume input", zap.Error(err))
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	resume, err := api.db.GetResumeByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			http.Error(w, "Resume not found", http.StatusNotFound)
			return
		}
		api.logger.Error("failed to get resume", zap.Int("resume_id", id), zap.Error(err))
		http.Error(w, "Failed to get resume", http.StatusInternalServerError)
		return
	}

	isOwner := resume.UserID == userID
	isAdmin := isAdmin(user.Email)

	if !isOwner && !isAdmin {
		api.logger.Warn("forbidden: resume does not belong to user",
			zap.Int("resume_id", id),
			zap.Int("owner_id", resume.UserID),
			zap.Int("requester_id", userID),
		)
		http.Error(w, "Forbidden: not your resume", http.StatusForbidden)
		return
	}

	if err := api.db.UpdateResume(r.Context(), id, input); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			http.Error(w, "Resume not found", http.StatusNotFound)
			return
		}
		api.logger.Error("failed to update resume", zap.Int("resume_id", id), zap.Error(err))
		http.Error(w, "Failed to update resume", http.StatusInternalServerError)
		return
	}

	_ = api.db.IncrementChangesApp(r.Context())

	json.NewEncoder(w).Encode(map[string]string{"message": "Resume updated successfully"})
}

func (api *API) editResumeSection(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		api.logger.Warn("unauthorized profile request: missing token")
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	user, err := api.db.GetUserByID(r.Context(), userID)
	if err != nil {
		api.logger.Error("failed to fetch user", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	vars := mux.Vars(r)
	id, _ := strconv.Atoi(vars["id"])
	section := vars["section"]

	var payload struct {
		Content string `json:"content"`
	}
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		api.logger.Warn("invalid section update input", zap.Error(err))
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	resume, err := api.db.GetResumeByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			http.Error(w, "Resume not found", http.StatusNotFound)
			return
		}
		api.logger.Error("failed to get resume", zap.Int("resume_id", id), zap.Error(err))
		http.Error(w, "Failed to get resume", http.StatusInternalServerError)
		return
	}

	isOwner := resume.UserID == userID
	isAdmin := isAdmin(user.Email)

	if !isOwner && !isAdmin {
		api.logger.Warn("forbidden: resume does not belong to user",
			zap.Int("resume_id", id),
			zap.Int("owner_id", resume.UserID),
			zap.Int("requester_id", userID),
		)
		http.Error(w, "Forbidden: not your resume", http.StatusForbidden)
		return
	}

	if err := api.db.UpdateResumeSection(r.Context(), id, section, payload.Content); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			http.Error(w, "Resume not found", http.StatusNotFound)
			return
		}
		api.logger.Error(
			"failed to update resume section",
			zap.String("section", section),
			zap.Int("resume_id", id),
			zap.Error(err),
		)
		http.Error(w, "Failed to update section", http.StatusInternalServerError)
		return
	}

	_ = api.db.IncrementChangesApp(r.Context())

	json.NewEncoder(w).Encode(map[string]string{"message": "Section updated successfully"})
}

func (api *API) checkGrammar(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		api.logger.Warn("unauthorized profile request: missing token")
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	user, err := api.db.GetUserByID(r.Context(), userID)
	if err != nil {
		api.logger.Error("failed to fetch user", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		api.logger.Warn("invalid resume id", zap.String("id", idStr))
		http.Error(w, "Invalid resume ID", http.StatusBadRequest)
		return
	}

	resume, err := api.db.GetResumeByID(r.Context(), id)
	if err != nil {
		api.logger.Error("resume not found", zap.Int("resume_id", id), zap.Error(err))
		http.Error(w, "Resume not found", http.StatusNotFound)
		return
	}

	isOwner := resume.UserID == userID
	isAdmin := isAdmin(user.Email)

	if !isOwner && !isAdmin {
		api.logger.Warn("forbidden: resume does not belong to user",
			zap.Int("resume_id", id),
			zap.Int("owner_id", resume.UserID),
			zap.Int("requester_id", userID),
		)
		http.Error(w, "Forbidden: not your resume", http.StatusForbidden)
		return
	}

	text := "title:" + resume.Title + "\n" + "contacts:" + resume.Contacts + "\n" + "job:" + resume.Job + "\n" + "experience:" +
		resume.Experience + "\n" + "education:" + resume.Education + "\n" + "skills:" + resume.Skills + "\n" + "about:" + resume.About

	issues, err := analyzer.GrammarCheck(text)
	if err != nil {
		api.logger.Error("failed to analyze grammar", zap.Error(err))
		http.Error(w, "Failed to analyze grammar: "+err.Error(), http.StatusInternalServerError)
		return
	}

	_ = api.db.IncrementActiveUsersToday(r.Context(), userID)

	json.NewEncoder(w).Encode(map[string]interface{}{
		"issues": issues,
	})
}

func (api *API) checkGrammarGuest(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Resume string `json:"resume"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		api.logger.Warn("invalid request body", zap.Error(err))
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if strings.TrimSpace(req.Resume) == "" {
		http.Error(w, "Resume text is required", http.StatusBadRequest)
		return
	}

	issues, err := analyzer.GrammarCheck(req.Resume)
	if err != nil {
		api.logger.Error("failed to analyze grammar", zap.Error(err))
		http.Error(w, "Failed to analyze grammar: "+err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"issues": issues,
	})
}

func (api *API) checkAbout(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		api.logger.Warn("unauthorized profile request: missing token")
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	user, err := api.db.GetUserByID(r.Context(), userID)
	if err != nil {
		api.logger.Error("failed to fetch user", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		api.logger.Warn("invalid resume id", zap.String("id", idStr))
		http.Error(w, "Invalid resume ID", http.StatusBadRequest)
		return
	}

	resume, err := api.db.GetResumeByID(r.Context(), id)
	if err != nil {
		api.logger.Error("resume not found", zap.Int("resume_id", id), zap.Error(err))
		http.Error(w, "Resume not found", http.StatusNotFound)
		return
	}

	isOwner := resume.UserID == userID
	isAdmin := isAdmin(user.Email)

	if !isOwner && !isAdmin {
		api.logger.Warn("forbidden: resume does not belong to user",
			zap.Int("resume_id", id),
			zap.Int("owner_id", resume.UserID),
			zap.Int("requester_id", userID),
		)
		http.Error(w, "Forbidden: not your resume", http.StatusForbidden)
		return
	}

	rec, err := analyzer.AboutCheck(resume.About)
	if err != nil {
		api.logger.Error("failed to check about", zap.Error(err))
		http.Error(w, "Failed to check about: "+err.Error(), http.StatusInternalServerError)
		return
	}

	_ = api.db.IncrementActiveUsersToday(r.Context(), userID)

	json.NewEncoder(w).Encode(rec)
}

func (api *API) checkExperience(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		api.logger.Warn("unauthorized profile request: missing token")
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	user, err := api.db.GetUserByID(r.Context(), userID)
	if err != nil {
		api.logger.Error("failed to fetch user", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		api.logger.Warn("invalid resume id", zap.String("id", idStr))
		http.Error(w, "Invalid resume ID", http.StatusBadRequest)
		return
	}

	resume, err := api.db.GetResumeByID(r.Context(), id)
	if err != nil {
		api.logger.Error("resume not found", zap.Int("resume_id", id), zap.Error(err))
		http.Error(w, "Resume not found", http.StatusNotFound)
		return
	}

	isOwner := resume.UserID == userID
	isAdmin := isAdmin(user.Email)

	if !isOwner && !isAdmin {
		api.logger.Warn("forbidden: resume does not belong to user",
			zap.Int("resume_id", id),
			zap.Int("owner_id", resume.UserID),
			zap.Int("requester_id", userID),
		)
		http.Error(w, "Forbidden: not your resume", http.StatusForbidden)
		return
	}

	rec, err := analyzer.ExperienceCheck(resume.Experience)
	if err != nil {
		api.logger.Error("failed to check experience", zap.Error(err))
		http.Error(w, "Failed to check experience: "+err.Error(), http.StatusInternalServerError)
		return
	}

	_ = api.db.IncrementActiveUsersToday(r.Context(), userID)

	json.NewEncoder(w).Encode(rec)
}

func (api *API) checkSkills(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		api.logger.Warn("unauthorized profile request: missing token")
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	user, err := api.db.GetUserByID(r.Context(), userID)
	if err != nil {
		api.logger.Error("failed to fetch user", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		api.logger.Warn("invalid resume id", zap.String("id", idStr))
		http.Error(w, "Invalid resume ID", http.StatusBadRequest)
		return
	}

	resume, err := api.db.GetResumeByID(r.Context(), id)
	if err != nil {
		api.logger.Error("resume not found", zap.Int("resume_id", id), zap.Error(err))
		http.Error(w, "Resume not found", http.StatusNotFound)
		return
	}

	isOwner := resume.UserID == userID
	isAdmin := isAdmin(user.Email)

	if !isOwner && !isAdmin {
		api.logger.Warn("forbidden: resume does not belong to user",
			zap.Int("resume_id", id),
			zap.Int("owner_id", resume.UserID),
			zap.Int("requester_id", userID),
		)
		http.Error(w, "Forbidden: not your resume", http.StatusForbidden)
		return
	}

	issues, err := analyzer.SkillsCheck(resume.Skills)
	if err != nil {
		api.logger.Error("failed to check skills", zap.Error(err))
		http.Error(w, "Failed to check skills: "+err.Error(), http.StatusInternalServerError)
		return
	}

	_ = api.db.IncrementActiveUsersToday(r.Context(), userID)

	json.NewEncoder(w).Encode(map[string]interface{}{
		"issues": issues,
	})
}

func (api *API) deleteResume(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		api.logger.Warn("unauthorized profile request: missing token")
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	user, err := api.db.GetUserByID(r.Context(), userID)
	if err != nil {
		api.logger.Error("failed to fetch user", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil {
		http.Error(w, "Invalid resume ID", http.StatusBadRequest)
		return
	}

	resume, err := api.db.GetResumeByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			http.Error(w, "Resume not found", http.StatusNotFound)
			return
		}
		api.logger.Error("failed to get resume", zap.Int("resume_id", id), zap.Error(err))
		http.Error(w, "Failed to get resume", http.StatusInternalServerError)
		return
	}

	isOwner := resume.UserID == userID
	isAdmin := isAdmin(user.Email)

	if !isOwner && !isAdmin {
		api.logger.Warn("forbidden: resume does not belong to user",
			zap.Int("resume_id", id),
			zap.Int("owner_id", resume.UserID),
			zap.Int("requester_id", userID),
		)
		http.Error(w, "Forbidden: not your resume", http.StatusForbidden)
		return
	}

	if err := api.db.DeleteResume(r.Context(), id); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			http.Error(w, "Resume not found", http.StatusNotFound)
			return
		}
		api.logger.Error("failed to delete resume", zap.Int("resume_id", id), zap.Error(err))
		http.Error(w, "Failed to delete resume", http.StatusInternalServerError)
		return
	}

	_ = api.db.IncrementActiveUsersToday(r.Context(), userID)

	json.NewEncoder(w).Encode(map[string]string{"message": "Resume deleted successfully"})
}

func (api *API) listResumes(w http.ResponseWriter, r *http.Request) {
	userID, ok := getUserIDFromContext(r)
	if !ok {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	resumes, err := api.db.ListResumes(r.Context(), userID)
	if err != nil {
		api.logger.Error("failed to list resumes", zap.Int("user_id", userID), zap.Error(err))
		http.Error(w, "Failed to list resumes", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(resumes)
}
