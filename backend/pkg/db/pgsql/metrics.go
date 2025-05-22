package pgsql

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"strconv"
	"time"
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

func (d *DB) IncrementTotalUsers(ctx context.Context) error {
	_, err := d.pool.Exec(ctx, `
        UPDATE metrics
        SET total_users = total_users + 1,
            last_updated_at = NOW()
    `)
	return err
}

func (d *DB) IncrementTotalResumes(ctx context.Context) error {
	_, err := d.pool.Exec(ctx, `
        UPDATE metrics
        SET total_resumes = total_resumes + 1,
            last_updated_at = NOW()
    `)
	return err
}

func (d *DB) IncrementChangesApp(ctx context.Context) error {
	_, err := d.pool.Exec(ctx, `
        UPDATE metrics
        SET total_changes_app = total_changes_app + 1,
            last_updated_at = NOW()
    `)
	return err
}

func (d *DB) IncrementActiveUsersToday(ctx context.Context, userID int) error {
	userKey := strconv.Itoa(userID)
	today := time.Now().Format("2006-01-02")

	log.Println("[DEBUG] IncrementActiveUsersToday called with userID =", userID, "today =", today)

	var storedDate string
	err := d.pool.QueryRow(ctx, `
        SELECT active_users_json ->> $1 FROM metrics
    `, userKey).Scan(&storedDate)
	if err != nil && err != sql.ErrNoRows {
		return err
	}

	log.Println("[DEBUG] storedDate =", storedDate)

	if storedDate == today {
		log.Println("[DEBUG] already counted today, skipping")
		return nil
	}

	log.Println("[DEBUG] running UPDATE for new active user")
	_, err = d.pool.Exec(ctx, `
        UPDATE metrics
        SET active_users_today = active_users_today + 1,
            active_users_json = jsonb_set(active_users_json, $1, to_jsonb($2::text), true),
            last_updated_at = NOW()
    `, fmt.Sprintf("{%s}", userKey), today)

	if err != nil {
		log.Println("[DEBUG] UPDATE failed:", err)
	}
	return err
}
