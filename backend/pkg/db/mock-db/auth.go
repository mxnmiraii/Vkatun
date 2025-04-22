package mock_db

import (
	"context"
	"vkatun/pkg/models"
)

func (m *MockDB) RegisterUser(ctx context.Context, email, passwordHash, username string) error {
	args := m.Called(ctx, email, passwordHash, username)
	return args.Error(0)
}

func (m *MockDB) GetUserByEmail(ctx context.Context, email string) (*models.User, error) {
	args := m.Called(ctx, email)
	return args.Get(0).(*models.User), args.Error(1)
}

func (m *MockDB) GetUserByID(ctx context.Context, id int) (*models.User, error) {
	args := m.Called(ctx, id)
	return args.Get(0).(*models.User), args.Error(1)
}

func (m *MockDB) UpdateUserName(ctx context.Context, id int, name string) error {
	args := m.Called(ctx, id, name)
	return args.Error(0)
}

func (m *MockDB) UpdateUserPassword(ctx context.Context, id int, newHashedPassword string) error {
	args := m.Called(ctx, id, newHashedPassword)
	return args.Error(0)
}
