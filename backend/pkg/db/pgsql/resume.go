package pgsql

import (
	"context"
	"database/sql"
	"vkatun/pkg/models"
)

// UploadResume загружает новое резюме в базу
func (d *DB) UploadResume(ctx context.Context, resume models.ResumeInput, userID int) (int, error) {
	var id int
	err := d.pool.QueryRow(ctx, `
        INSERT INTO resume (user_id, title, contacts, job, experience, education, skills, about)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id
    `, userID, resume.Title, resume.Contacts, resume.Job, resume.Experience, resume.Education, resume.Skills, resume.About).Scan(&id)
	if err != nil {
		return id, err
	}
	return id, nil
}

// GetResumeByID возвращает резюме по ID
func (d *DB) GetResumeByID(ctx context.Context, id int) (*models.Resume, error) {
	var resume models.Resume
	err := d.pool.QueryRow(ctx, `
        SELECT id, user_id, title, contacts, job, experience, education, skills, about, created_at, updated_at
        FROM resume WHERE id = $1
    `, id).Scan(
		&resume.ID, &resume.UserID, &resume.Title, &resume.Contacts, &resume.Job, &resume.Experience,
		&resume.Education, &resume.Skills, &resume.About, &resume.CreatedAt, &resume.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &resume, nil
}

// UpdateResume обновляет все поля резюме
func (d *DB) UpdateResume(ctx context.Context, id int, resume models.Resume) error {
	res, err := d.pool.Exec(ctx, `
        UPDATE resume SET title=$1, contacts=$2, job=$3, experience=$4, education=$5, skills=$6, about=$7, updated_at=NOW()
        WHERE id = $8
    `, resume.Title, resume.Contacts, resume.Job, resume.Experience, resume.Education, resume.Skills, resume.About, id)
	if err != nil {
		return err
	}

	rowsAffected := res.RowsAffected()
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// UpdateResumeSection обновляет одну секцию резюме
func (d *DB) UpdateResumeSection(ctx context.Context, id int, section string, content string) error {
	query := "UPDATE resume SET " + section + " = $1, updated_at = NOW() WHERE id = $2"
	res, err := d.pool.Exec(ctx, query, content, id)
	if err != nil {
		return err
	}

	rowsAffected := res.RowsAffected()
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// DeleteResume удаляет резюме по ID
func (d *DB) DeleteResume(ctx context.Context, id int) error {
	res, err := d.pool.Exec(ctx, "DELETE FROM resume WHERE id = $1", id)
	if err != nil {
		return err
	}

	rowsAffected := res.RowsAffected()
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// ListResumes возвращает список резюме пользователя
func (d *DB) ListResumes(ctx context.Context, userID int) ([]models.ResumeOutput, error) {
	rows, err := d.pool.Query(ctx, `
        SELECT id, title, created_at FROM resume WHERE user_id = $1
    `, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var resumes []models.ResumeOutput
	for rows.Next() {
		var r models.ResumeOutput
		if err := rows.Scan(&r.ID, &r.Title, &r.CreatedAt); err != nil {
			return nil, err
		}
		resumes = append(resumes, r)
	}
	return resumes, nil
}
