package mock_db

import (
	"context"
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
