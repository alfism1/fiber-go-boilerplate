package utils

import (
	"database/sql"
	"log"
	"time"

	"github.com/gofiber/fiber/v2"
)

// DBStats represents database connection statistics
type DBStats struct {
	MaxOpenConnections int           `json:"max_open_connections"`
	OpenConnections    int           `json:"open_connections"`
	InUse              int           `json:"in_use"`
	Idle               int           `json:"idle"`
	WaitCount          int64         `json:"wait_count"`
	WaitDuration       time.Duration `json:"wait_duration"`
	MaxIdleClosed      int64         `json:"max_idle_closed"`
	MaxIdleTimeClosed  int64         `json:"max_idle_time_closed"`
	MaxLifetimeClosed  int64         `json:"max_lifetime_closed"`
}

// GetDBStats returns current database connection statistics
func GetDBStats(sqlDB *sql.DB) DBStats {
	stats := sqlDB.Stats()
	return DBStats{
		MaxOpenConnections: stats.MaxOpenConnections,
		OpenConnections:    stats.OpenConnections,
		InUse:              stats.InUse,
		Idle:               stats.Idle,
		WaitCount:          stats.WaitCount,
		WaitDuration:       stats.WaitDuration,
		MaxIdleClosed:      stats.MaxIdleClosed,
		MaxIdleTimeClosed:  stats.MaxIdleTimeClosed,
		MaxLifetimeClosed:  stats.MaxLifetimeClosed,
	}
}

// DBStatsHandler creates a handler to expose database statistics
func DBStatsHandler(sqlDB *sql.DB) fiber.Handler {
	return func(c *fiber.Ctx) error {
		stats := GetDBStats(sqlDB)
		return c.JSON(fiber.Map{
			"database_stats": stats,
			"timestamp":      time.Now(),
		})
	}
}

// LogDBStats logs database statistics periodically
func LogDBStats(sqlDB *sql.DB, interval time.Duration) {
	ticker := time.NewTicker(interval)
	go func() {
		for range ticker.C {
			stats := GetDBStats(sqlDB)
			log.Printf("📊 DB Stats - Open: %d/%d, InUse: %d, Idle: %d, Waiting: %d",
				stats.OpenConnections, stats.MaxOpenConnections,
				stats.InUse, stats.Idle, stats.WaitCount)

			// Alert if connection usage is high
			if stats.OpenConnections > stats.MaxOpenConnections*8/10 {
				log.Printf("⚠️  High connection usage: %d/%d (%.1f%%)",
					stats.OpenConnections, stats.MaxOpenConnections,
					float64(stats.OpenConnections)/float64(stats.MaxOpenConnections)*100)
			}
		}
	}()
}
