package handler

import (
	"go-fiber-new/modules/user/domain"
	"go-fiber-new/shared/response"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

type UserHandler struct {
	userService domain.UserService
}

func NewUserHandler(userService domain.UserService) *UserHandler {
	return &UserHandler{userService: userService}
}

func (h *UserHandler) CreateUser(c *fiber.Ctx) error {
	var req domain.CreateUserRequest
	if err := c.BodyParser(&req); err != nil {
		return response.Error(c, fiber.StatusBadRequest, "Invalid request body", err.Error())
	}

	user, err := h.userService.CreateUser(&req)
	if err != nil {
		return response.Error(c, fiber.StatusBadRequest, "Failed to create user", err.Error())
	}

	return response.Success(c, "User created successfully", user)
}

func (h *UserHandler) GetUser(c *fiber.Ctx) error {
	id := c.Params("id")
	user, err := h.userService.GetUserByID(id)
	if err != nil {
		return response.Error(c, fiber.StatusNotFound, "User not found", err.Error())
	}

	return response.Success(c, "User retrieved successfully", user)
}

func (h *UserHandler) GetUsers(c *fiber.Ctx) error {
	limitStr := c.Query("limit", "10")
	offsetStr := c.Query("offset", "0")

	limit, _ := strconv.Atoi(limitStr)
	offset, _ := strconv.Atoi(offsetStr)

	users, err := h.userService.GetAllUsers(limit, offset)
	if err != nil {
		return response.Error(c, fiber.StatusInternalServerError, "Failed to get users", err.Error())
	}

	return response.Success(c, "Users retrieved successfully", users)
}

func (h *UserHandler) GetProfile(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(string)
	user, err := h.userService.GetUserByID(userID)
	if err != nil {
		return response.Error(c, fiber.StatusNotFound, "User not found", err.Error())
	}

	return response.Success(c, "Profile retrieved successfully", user)
}
