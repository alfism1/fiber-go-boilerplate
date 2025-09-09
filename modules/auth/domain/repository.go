package domain

type AuthService interface {
	Login(req *LoginRequest) (*LoginResponse, error)
}
