package mock_db

import (
	"context"
	"time"
	"vkatun/pkg/models"
)

func (m *MockDB) GetMetrics(ctx context.Context) (*models.Metrics, error) {
	args := m.Called(ctx)
	return args.Get(0).(*models.Metrics), args.Error(1)
}

func (m *MockDB) UpdateMetrics(ctx context.Context, updates models.MetricsUpdateRequest) error {
	args := m.Called(ctx, updates)
	return args.Error(0)
}

func (d *MockDB) IncrementTotalUsers(ctx context.Context) error {
	return nil
}

func (d *MockDB) IncrementTotalResumes(ctx context.Context) error {
	return nil
}

func (d *MockDB) IncrementActiveUsersToday(ctx context.Context, userID int) error {
	return nil
}

func (d *MockDB) IncrementRecommendations(ctx context.Context) error {
	return nil
}
func (d *MockDB) IncrementAcceptedRecommendations(ctx context.Context) error {
	return nil
}

func (d *MockDB) SaveMetricsSnapshot(ctx context.Context) error {
	return nil
}

func (d *MockDB) GetMetricsDelta(ctx context.Context, from time.Time) (*models.Metrics, error) {
	return &models.Metrics{}, nil
}
