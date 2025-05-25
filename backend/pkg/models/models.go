package models

import "time"

type Resume struct {
	ID         int       `json:"id"`
	UserID     int       `json:"user_id,omitempty"`
	Title      string    `json:"title"`
	Contacts   string    `json:"contacts"`
	Job        string    `json:"job"`
	Experience string    `json:"experience"`
	Education  string    `json:"education"`
	Skills     string    `json:"skills"`
	About      string    `json:"about"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

type ResumeInput struct {
	Title      string `json:"title"`
	Contacts   string `json:"contacts"`
	Job        string `json:"job"`
	Experience string `json:"experience"`
	Education  string `json:"education"`
	Skills     string `json:"skills"`
	About      string `json:"about"`
}

type ResumeOutput struct {
	ID        int       `json:"id"`
	Title     string    `json:"title"`
	CreatedAt time.Time `json:"created_at"`
}

type Metrics struct {
	TotalUsers              int       `json:"total_users"`
	ActiveUsersToday        int       `json:"active_users_today"`
	TotalResumes            int       `json:"total_resumes"`
	TotalChangesApp         int       `json:"total_changes_app"`
	AcceptedRecommendations int       `json:"-"`
	LastUpdatedAt           time.Time `json:"last_updated_at"`
}

type MetricsUpdate struct {
	TotalUsers      int `json:"total_users"`
	TotalResumes    int `json:"total_resumes"`
	TotalChangesApp int `json:"total_changes_app"`
}

type MetricsUpdateRequest struct {
	Source  string        `json:"source"`
	Updates MetricsUpdate `json:"updates"`
}

type DeepSeekRequest struct {
	Model    string    `json:"model"`
	Messages []Message `json:"messages"`
}

type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type DeepSeekResponse struct {
	Choices []struct {
		Message struct {
			Content string `json:"content"`
		} `json:"message"`
	} `json:"choices"`
}

type User struct {
	ID           int       `json:"id"`
	Username     string    `json:"username"`
	Email        string    `json:"email"`
	PasswordHash string    `json:"-"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}
