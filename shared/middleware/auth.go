package middleware

import (
	"log"
	"strings"

	"go-fiber-new/shared/response"
	"go-fiber-new/shared/utils"

	"github.com/gofiber/fiber/v2"
)

func AuthRequired() fiber.Handler {
	return func(c *fiber.Ctx) error {
		authHeader := c.Get("Authorization")
		if authHeader == "" {
			return response.Error(c, fiber.StatusUnauthorized, "Authorization header required", "missing_token")
		}

		tokenParts := strings.Split(authHeader, " ")
		if len(tokenParts) != 2 || tokenParts[0] != "Bearer" {
			return response.Error(c, fiber.StatusUnauthorized, "Invalid authorization format", "invalid_format")
		}

		claims, err := utils.ValidateToken(tokenParts[1])
		if err != nil {
			return response.Error(c, fiber.StatusUnauthorized, "Invalid token", err.Error())
		}

		c.Locals("user_id", claims.UserID)
		return c.Next()
	}
}

func ErrorHandler(c *fiber.Ctx, err error) error {
	// Default error code & message
	code := fiber.StatusInternalServerError
	message := "Internal Server Error"

	// Jika error dari Fiber
	if e, ok := err.(*fiber.Error); ok {
		code = e.Code
		message = e.Message
	}

	// Logging untuk debugging (bisa diganti dengan logger lebih advanced)
	log.Printf("[ERROR] %s %s | %d | %v", c.Method(), c.Path(), code, err)

	// Response JSON standar
	return response.Error(c, code, message, err.Error())
}
