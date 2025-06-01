package db

import (
	"context"
	"time"
	"vkatun/pkg/models"
)

type DB interface {
	UploadResume(ctx context.Context, resume models.ResumeInput, userID int) (int, error)
	GetResumeByID(ctx context.Context, id int) (*models.Resume, error)
	UpdateResume(ctx context.Context, id int, resume models.Resume) error
	UpdateResumeSection(ctx context.Context, id int, section string, content string) error
	DeleteResume(ctx context.Context, id int) error
	ListResumes(ctx context.Context, userID int) ([]models.ResumeOutput, error)

	GetMetrics(ctx context.Context) (*models.Metrics, error)
	UpdateMetrics(ctx context.Context, updates models.MetricsUpdateRequest) error

	IncrementTotalUsers(ctx context.Context) error
	IncrementTotalResumes(ctx context.Context) error
	IncrementActiveUsersToday(ctx context.Context, userID int) error
	IncrementRecommendations(ctx context.Context) error
	IncrementAcceptedRecommendations(ctx context.Context) error
	SaveMetricsSnapshot(ctx context.Context) error
	GetMetricsDelta(ctx context.Context, from time.Time) (*models.Metrics, error)

	RegisterUser(ctx context.Context, email, passwordHash, username string) error
	GetUserByEmail(ctx context.Context, email string) (*models.User, error)
	GetUserByID(ctx context.Context, id int) (*models.User, error)
	UpdateUserName(ctx context.Context, id int, name string) error
	UpdateUserPassword(ctx context.Context, id int, newHashedPassword string) error
}
