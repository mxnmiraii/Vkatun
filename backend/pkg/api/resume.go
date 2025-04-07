package api

import (
	"encoding/json"
	"github.com/gorilla/mux"
	"io"
	"net/http"
	"strconv"
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
		http.Error(w, "Failed to read file", http.StatusBadRequest)
		return
	}
	defer file.Close()

	content, err := io.ReadAll(file)
	if err != nil {
		http.Error(w, "Failed to read file content", http.StatusInternalServerError)
		return
	}

	resume, _, err := analyzer.ParseResumeFromPDF(content)
	if err != nil {
		return
	}

	resumeID, err := api.db.UploadResume(r.Context(), resume, userID)
	if err != nil {
		http.Error(w, "Failed to save resume", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"message":   "Resume uploaded successfully",
		"resume_id": resumeID,
	})
}

func (api *API) getResumeByID(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		http.Error(w, "Invalid resume ID", http.StatusBadRequest)
		return
	}
	resume, err := api.db.GetResumeByID(r.Context(), id)
	if err != nil {
		http.Error(w, "Resume not found", http.StatusNotFound)
		return
	}
	_ = json.NewEncoder(w).Encode(resume)
}

func (api *API) editResume(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		http.Error(w, "Invalid resume ID", http.StatusBadRequest)
		return
	}

	var input models.Resume
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	if err := api.db.UpdateResume(r.Context(), id, input); err != nil {
		http.Error(w, "Failed to update resume", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(map[string]string{"message": "Resume updated successfully"})
}

func (api *API) editResumeSection(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, _ := strconv.Atoi(vars["id"])
	section := vars["section"]

	var payload struct {
		Content string `json:"content"`
	}
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if err := api.db.UpdateResumeSection(r.Context(), id, section, payload.Content); err != nil {
		http.Error(w, "Failed to update section", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(map[string]string{"message": "Section updated successfully"})
}

func (api *API) checkGrammar(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid resume ID", http.StatusBadRequest)
		return
	}

	resume, err := api.db.GetResumeByID(r.Context(), id)
	if err != nil {
		http.Error(w, "Resume not found", http.StatusNotFound)
		return
	}

	text := "title:" + resume.Title + "\n" + "contacts:" + resume.Contacts + "\n" + "job:" + resume.Job + "\n" + "experience:" +
		resume.Experience + "\n" + "education:" + resume.Education + "\n" + "skills:" + resume.Skills + "\n" + "about:" + resume.About

	issues, err := analyzer.GrammarCheck(text)
	if err != nil {
		http.Error(w, "Failed to analyze grammar: "+err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"issues": issues,
	})
}

func (api *API) checkStructure(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid resume ID", http.StatusBadRequest)
		return
	}

	resume, err := api.db.GetResumeByID(r.Context(), id)
	if err != nil {
		http.Error(w, "Resume not found", http.StatusNotFound)
		return
	}

	text := "title:" + resume.Title + "\n" + "contacts:" + resume.Contacts + "\n" + "job:" + resume.Job + "\n" + "experience:" +
		resume.Experience + "\n" + "education:" + resume.Education + "\n" + "skills:" + resume.Skills + "\n" + "about:" + resume.About

	missingSections, err := analyzer.StructureCheck(text)
	if err != nil {
		http.Error(w, "Failed to check structure: "+err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"missing_sections": missingSections,
	})
}

func (api *API) checkSkills(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid resume ID", http.StatusBadRequest)
		return
	}

	resume, err := api.db.GetResumeByID(r.Context(), id)
	if err != nil {
		http.Error(w, "Resume not found", http.StatusNotFound)
		return
	}

	trashSkills := analyzer.SkillsCheck(*resume)

	json.NewEncoder(w).Encode(map[string]interface{}{
		"skills": trashSkills,
	})
}

func (api *API) deleteResume(w http.ResponseWriter, r *http.Request) {
	id, _ := strconv.Atoi(mux.Vars(r)["id"])
	if err := api.db.DeleteResume(r.Context(), id); err != nil {
		http.Error(w, "Failed to delete resume", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(map[string]string{"message": "Resume deleted successfully"})
}

func (api *API) listResumes(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])

	resumes, err := api.db.ListResumes(r.Context(), id)
	if err != nil {
		http.Error(w, "Failed to list resumes", http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(resumes)
}
