package pgsql

import (
	"context"
	"embed"
	"fmt"
	"github.com/jackc/pgx/v5/pgxpool"
)

type DB struct {
	pool *pgxpool.Pool
}

func New(connString string) (*DB, error) {
	pool, err := pgxpool.New(context.Background(), connString)
	if err != nil {
		return nil, err
	}

	return &DB{pool: pool}, nil
}

//go:embed schema.sql
var schemaFS embed.FS

func (d *DB) Migrate(ctx context.Context) error {
	schema, err := schemaFS.ReadFile("schema.sql")
	if err != nil {
		return fmt.Errorf("failed to read schema: %w", err)
	}
	_, err = d.pool.Exec(ctx, string(schema))
	if err != nil {
		return fmt.Errorf("migration failed: %w", err)
	}
	return nil
}
