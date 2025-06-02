package pgsql

import (
	"context"
	"embed"
	"fmt"
	"time"

	"github.com/avast/retry-go"
	"github.com/jackc/pgx/v5/pgxpool"
)

type DB struct {
	pool *pgxpool.Pool
}

func New(connString string) (*DB, error) {
	var pool *pgxpool.Pool

	err := retry.Do(
		func() error {
			var err error
			pool, err = pgxpool.New(context.Background(), connString)
			if err != nil {
				return err
			}
			return pool.Ping(context.Background())
		},
		retry.Attempts(10),
		retry.Delay(2*time.Second),
		retry.DelayType(retry.FixedDelay),
		retry.OnRetry(func(n uint, err error) {
			fmt.Printf("Retry %d: waiting for DB... (%v)\n", n+1, err)
		}),
	)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
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
