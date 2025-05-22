package pgsql

import (
	"context"
	"vkatun/pkg/models"
)

// GetMetrics возвращает агрегированные метрики
func (d *DB) GetMetrics(ctx context.Context) (*models.Metrics, error) {
	var m models.Metrics
	err := d.pool.QueryRow(ctx, `
        SELECT total_users, active_users_today, total_resumes, total_changes_app, last_updated_at FROM metrics
    `).Scan(&m.TotalUsers, &m.ActiveUsersToday, &m.TotalResumes, &m.TotalChangesApp, &m.LastUpdatedAt)
	if err != nil {
		return nil, err
	}
	return &m, nil
}

// UpdateMetrics обновляет агрегированные метрики
func (d *DB) UpdateMetrics(ctx context.Context, updates models.MetricsUpdateRequest) error {
	_, err := d.pool.Exec(ctx, `
        UPDATE metrics SET total_users=$1, total_resumes=$2, total_changes_app=$3, last_updated_at=NOW()
    `, updates.Updates.TotalUsers, updates.Updates.TotalResumes, updates.Updates.TotalChangesApp)
	if err != nil {
		return err
	}
	return nil
}
