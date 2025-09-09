package main

import (
	"go-fiber-new/config"
	auth_routes "go-fiber-new/modules/auth/routes"
	user_routes "go-fiber-new/modules/user/routes"
	"go-fiber-new/shared/database"
	"go-fiber-new/shared/middleware"
	"log"

	"github.com/gofiber/fiber/v2"
)

func main() {
	// Load config
	cfg := config.Load()

	// Initialize database
	db := database.InitDB(cfg)

	// Create Fiber app
	app := fiber.New(fiber.Config{
		ErrorHandler: middleware.ErrorHandler,
	})

	// Global middleware
	app.Use(middleware.Logger())
	app.Use(middleware.CORS())

	// Health check endpoint
	app.Get("/", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"message": "API is running!!!!",
			"version": "1.0.0",
		})
	})

	// API routes
	api := app.Group("/api/v1")

	// Module routes
	user_routes.SetupUserRoutes(api, db)
	auth_routes.SetupAuthRoutes(api, db)

	// Start server
	log.Printf("Server starting on port %s", cfg.Port)
	log.Fatal(app.Listen(":" + cfg.Port))
}
