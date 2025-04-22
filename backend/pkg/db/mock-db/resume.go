package mock_db

import (
	"context"
	"vkatun/pkg/models"
)

func (m *MockDB) UploadResume(ctx context.Context, resume models.ResumeInput, userID int) (int, error) {
	args := m.Called(ctx, resume, userID)
	return args.Int(0), args.Error(1)
}

func (m *MockDB) GetResumeByID(ctx context.Context, id int) (*models.Resume, error) {
	args := m.Called(ctx, id)
	return args.Get(0).(*models.Resume), args.Error(1)
}

func (m *MockDB) UpdateResume(ctx context.Context, id int, resume models.Resume) error {
	args := m.Called(ctx, id, resume)
	return args.Error(0)
}

func (m *MockDB) UpdateResumeSection(ctx context.Context, id int, section string, content string) error {
	args := m.Called(ctx, id, section, content)
	return args.Error(0)
}

func (m *MockDB) DeleteResume(ctx context.Context, id int) error {
	args := m.Called(ctx, id)
	return args.Error(0)
}

func (m *MockDB) ListResumes(ctx context.Context, userID int) ([]models.Resume, error) {
	args := m.Called(ctx, userID)
	return args.Get(0).([]models.Resume), args.Error(1)
}
