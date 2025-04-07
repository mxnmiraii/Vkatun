package db

import (
	"context"
	"vkatun/pkg/models"
)

type DB interface {
	UploadResume(ctx context.Context, resume models.ResumeInput, userID int) (int, error)
	GetResumeByID(ctx context.Context, id int) (*models.Resume, error)
	UpdateResume(ctx context.Context, id int, resume models.Resume) error
	UpdateResumeSection(ctx context.Context, id int, section string, content string) error
	DeleteResume(ctx context.Context, id int) error
	ListResumes(ctx context.Context, userID int) ([]models.Resume, error)

	GetMetrics(ctx context.Context) (*models.Metrics, error)
	UpdateMetrics(ctx context.Context, updates models.MetricsUpdateRequest) error

	RegisterUser(ctx context.Context, email, passwordHash, username string) error
	GetUserByEmail(ctx context.Context, email string) (*models.User, error)
	GetUserByID(ctx context.Context, id int) (*models.User, error)
	UpdateUserName(ctx context.Context, id int, name string) error
	UpdateUserPassword(ctx context.Context, id int, newHashedPassword string) error
}
