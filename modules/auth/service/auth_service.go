package service

import (
	"errors"
	"go-fiber-new/modules/auth/domain"
	user_domain "go-fiber-new/modules/user/domain"
	"go-fiber-new/shared/utils"
	"go-fiber-new/shared/validator"
)

type authService struct {
	userRepo user_domain.UserRepository
}

func NewAuthService(userRepo user_domain.UserRepository) domain.AuthService {
	return &authService{userRepo: userRepo}
}

// Login implements domain.AuthService.
func (s *authService) Login(req *domain.LoginRequest) (*domain.LoginResponse, error) {
	if !validator.IsValidEmail(req.Email) {
		return nil, errors.New("invalid email format")
	}

	user, err := s.userRepo.GetByEmail(req.Email)
	if err != nil {
		return nil, errors.New("invalid email or password")
	}

	if !utils.CheckPasswordHash(req.Password, user.Password) {
		return nil, errors.New("invalid email or password")
	}

	if !user.IsActive {
		return nil, errors.New("account is deactivated")
	}

	token, err := utils.GenerateToken(user.ID, user.Email)
	if err != nil {
		return nil, errors.New("failed to generate token")
	}

	return &domain.LoginResponse{
		Token: token,
		User:  user,
	}, err
}
