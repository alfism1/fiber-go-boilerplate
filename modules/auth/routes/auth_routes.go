package routes

import (
	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	"go-fiber-new/modules/auth/handler"
	"go-fiber-new/modules/auth/service"
	user_repository "go-fiber-new/modules/user/repository"
)

func SetupAuthRoutes(router fiber.Router, db *gorm.DB) {
	userRepo := user_repository.NewUserRepository(db)
	authService := service.NewAuthService(userRepo)
	authHandler := handler.NewAuthHandler(authService)

	auth := router.Group("/auth")
	auth.Post("/login", authHandler.Login)
}
