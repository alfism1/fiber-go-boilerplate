package service

import (
	"errors"
	"go-fiber-new/modules/user/domain"
	"go-fiber-new/shared/utils"
	"go-fiber-new/shared/validator"
)

type userService struct {
	userRepo domain.UserRepository
}

func NewUserService(userRepo domain.UserRepository) domain.UserService {
	return &userService{userRepo: userRepo}
}

func (s *userService) CreateUser(req *domain.CreateUserRequest) (*domain.User, error) {
	if !validator.IsValidEmail(req.Email) {
		return nil, errors.New("invalid email format")
	}

	if !validator.IsValidPassword(req.Password) {
		return nil, errors.New("password must be at least 6 characters")
	}

	// Check if user exists
	_, err := s.userRepo.GetByEmail(req.Email)
	if err == nil {
		return nil, errors.New("email already exists")
	}

	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		return nil, err
	}

	user := &domain.User{
		Email:    req.Email,
		Name:     req.Name,
		Password: hashedPassword,
		IsActive: true,
	}

	err = s.userRepo.Create(user)
	if err != nil {
		return nil, err
	}

	return user, nil
}

func (s *userService) GetUserByID(id string) (*domain.User, error) {
	return s.userRepo.GetByID(id)
}

func (s *userService) GetUserByEmail(email string) (*domain.User, error) {
	return s.userRepo.GetByEmail(email)
}

func (s *userService) GetAllUsers(limit, offset int) ([]*domain.User, error) {
	if limit <= 0 {
		limit = 10
	}
	if offset < 0 {
		offset = 0
	}
	return s.userRepo.GetAll(limit, offset)
}

func (s *userService) UpdateUser(id string, req *domain.UpdateUserRequest) (*domain.User, error) {
	user, err := s.userRepo.GetByID(id)
	if err != nil {
		return nil, err
	}

	if req.Name != "" {
		user.Name = req.Name
	}
	if req.Email != "" && validator.IsValidEmail(req.Email) {
		user.Email = req.Email
	}
	if req.IsActive != nil {
		user.IsActive = *req.IsActive
	}

	err = s.userRepo.Update(user)
	if err != nil {
		return nil, err
	}

	return user, nil
}

func (s *userService) DeleteUser(id string) error {
	_, err := s.userRepo.GetByID(id)
	if err != nil {
		return err
	}
	return s.userRepo.Delete(id)
}
