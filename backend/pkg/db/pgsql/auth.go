package pgsql

import (
	"context"
	"errors"
	"vkatun/pkg/models"
)

// RegisterUser добавляет нового пользователя
func (d *DB) RegisterUser(ctx context.Context, email, passwordHash, username string) error {
	_, err := d.pool.Exec(ctx, `
		INSERT INTO users (email, password_hash, username)
		VALUES ($1, $2, $3)
	`, email, passwordHash, username)
	if err != nil {
		return err
	}
	return nil
}

// GetUserByEmail возвращает пользователя по email
func (d *DB) GetUserByEmail(ctx context.Context, email string) (*models.User, error) {
	row := d.pool.QueryRow(ctx, `
		SELECT id, username, email, password_hash, created_at, updated_at
		FROM users
		WHERE email = $1
	`, email)

	var user models.User
	err := row.Scan(
		&user.ID,
		&user.Username,
		&user.Email,
		&user.PasswordHash,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// GetUserByID возвращает пользователя по ID
func (d *DB) GetUserByID(ctx context.Context, id int) (*models.User, error) {
	row := d.pool.QueryRow(ctx, `
		SELECT id, username, email, password_hash, created_at, updated_at
		FROM users
		WHERE id = $1
	`, id)

	var user models.User
	err := row.Scan(
		&user.ID,
		&user.Username,
		&user.Email,
		&user.PasswordHash,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// UpdateUserName обновляет имя пользователя по ID
func (d *DB) UpdateUserName(ctx context.Context, id int, name string) error {
	res, err := d.pool.Exec(ctx, `
		UPDATE users SET username = $1, updated_at = NOW()
		WHERE id = $2
	`, name, id)
	if err != nil {
		return err
	}
	if count := res.RowsAffected(); count == 0 {
		return errors.New("user not found")
	}
	return nil
}

// UpdateUserPassword обновляет пароль пользователя
func (d *DB) UpdateUserPassword(ctx context.Context, id int, newHashedPassword string) error {
	res, err := d.pool.Exec(ctx, `
		UPDATE users SET password_hash = $1, updated_at = NOW()
		WHERE id = $2
	`, newHashedPassword, id)
	if err != nil {
		return err
	}
	if count := res.RowsAffected(); count == 0 {
		return errors.New("user not found")
	}
	return nil
}
