package handler

import (
	"go-fiber-new/modules/auth/domain"
	"go-fiber-new/shared/response"

	"github.com/gofiber/fiber/v2"
)

type AuthHandler struct {
	authService domain.AuthService
}

func NewAuthHandler(authService domain.AuthService) *AuthHandler {
	return &AuthHandler{authService: authService}
}

func (h *AuthHandler) Login(c *fiber.Ctx) error {
	var req domain.LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return response.Error(c, fiber.StatusBadRequest, "Invalid request body", err.Error())
	}

	result, err := h.authService.Login(&req)
	if err != nil {
		return response.Error(c, fiber.StatusUnauthorized, "Login failed", err.Error())
	}

	return response.Success(c, "Login successfull", result)
}
