package pgsql

import (
	"context"
	"database/sql"
	"fmt"
	"strconv"
	"time"
	"vkatun/pkg/models"
)

// GetMetrics возвращает агрегированные метрики
func (d *DB) GetMetrics(ctx context.Context) (*models.Metrics, error) {
	var m models.Metrics
	err := d.pool.QueryRow(ctx, `
	SELECT total_users, active_users_today, total_resumes, total_changes_app, accepted_recommendations, last_updated_at
	FROM metrics
`).Scan(
		&m.TotalUsers,
		&m.ActiveUsersToday,
		&m.TotalResumes,
		&m.TotalChangesApp,
		&m.AcceptedRecommendations,
		&m.LastUpdatedAt,
	)
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

func (d *DB) IncrementTotalUsers(ctx context.Context) error {
	_, err := d.pool.Exec(ctx, `
        UPDATE metrics
        SET total_users = total_users + 1,
            last_updated_at = NOW()
    `)
	if err != nil {
		return err
	}
	return nil
}

func (d *DB) IncrementTotalResumes(ctx context.Context) error {
	_, err := d.pool.Exec(ctx, `
        UPDATE metrics
        SET total_resumes = total_resumes + 1,
            last_updated_at = NOW()
    `)
	if err != nil {
		return err
	}
	return nil
}

func (d *DB) IncrementActiveUsersToday(ctx context.Context, userID int) error {
	userKey := strconv.Itoa(userID)
	today := time.Now().Format("2006-01-02")

	var ns sql.NullString
	err := d.pool.QueryRow(ctx, `
        SELECT active_users_json ->> $1 FROM metrics
    `, userKey).Scan(&ns)
	if err != nil {
		return err
	}

	storedDate := ""
	if ns.Valid {
		storedDate = ns.String
	}

	if storedDate == today {
		return nil
	}

	_, err = d.pool.Exec(ctx, `
        UPDATE metrics
        SET active_users_today = active_users_today + 1,
            active_users_json = jsonb_set(COALESCE(active_users_json, '{}'::jsonb), $1, to_jsonb($2::text), true),
            last_updated_at = NOW()
    `, fmt.Sprintf("{%s}", userKey), today)
	if err != nil {
		return err
	}

	return nil
}

func (d *DB) IncrementRecommendations(ctx context.Context) error {
	_, err := d.pool.Exec(ctx, `
        UPDATE metrics
        SET total_changes_app = total_changes_app + 1,
            last_updated_at = NOW()
    `)
	if err != nil {
		return err
	}
	return nil
}

func (d *DB) IncrementAcceptedRecommendations(ctx context.Context) error {
	_, err := d.pool.Exec(ctx, `
        UPDATE metrics
        SET accepted_recommendations = accepted_recommendations + 1,
            last_updated_at = NOW()
    `)
	if err != nil {
		return err
	}
	return nil
}

func (d *DB) SaveMetricsSnapshot(ctx context.Context) error {
	_, err := d.pool.Exec(ctx, `
		INSERT INTO metrics_history (snapshot_date, total_users, total_resumes, total_changes_app, accepted_recommendations)
		SELECT CURRENT_DATE, total_users, total_resumes, total_changes_app, accepted_recommendations
		FROM metrics
	`)
	if err != nil {
		return err
	}
	return nil
}

func (d *DB) GetMetricsDelta(ctx context.Context, from time.Time) (*models.Metrics, error) {
	var m models.Metrics
	err := d.pool.QueryRow(ctx, `
		SELECT 
			MAX(total_users) - MIN(total_users),
			MAX(total_resumes) - MIN(total_resumes),
			MAX(total_changes_app) - MIN(total_changes_app),
			MAX(accepted_recommendations) - MIN(accepted_recommendations)
		FROM metrics_history
		WHERE snapshot_date >= $1
	`, from.Format("2006-01-02")).Scan(
		&m.TotalUsers,
		&m.TotalResumes,
		&m.TotalChangesApp,
		&m.AcceptedRecommendations,
	)
	if err != nil {
		return nil, err
	}
	return &m, nil
}
