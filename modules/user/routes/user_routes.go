package routes

import (
	"go-fiber-new/modules/user/handler"
	"go-fiber-new/modules/user/repository"
	"go-fiber-new/modules/user/service"
	"go-fiber-new/shared/middleware"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

func SetupUserRoutes(router fiber.Router, db *gorm.DB) {
	// Initialize dependencies
	userRepo := repository.NewUserRepository(db)
	userService := service.NewUserService(userRepo)
	userHandler := handler.NewUserHandler(userService)

	// Public routes
	users := router.Group("/users")
	users.Post("/", userHandler.CreateUser)

	// Protected routes
	users.Use(middleware.AuthRequired())
	users.Get("/profile", userHandler.GetProfile)
	users.Get("/", userHandler.GetUsers)
	users.Get("/:id", userHandler.GetUser)
}
