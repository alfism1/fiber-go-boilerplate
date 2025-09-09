package domain

type UserRepository interface {
	Create(user *User) error
	GetByID(id string) (*User, error)
	GetByEmail(email string) (*User, error)
	GetAll(limit, offset int) ([]*User, error)
	Update(user *User) error
	Delete(id string) error
}

type UserService interface {
	CreateUser(req *CreateUserRequest) (*User, error)
	GetUserByID(id string) (*User, error)
	GetUserByEmail(email string) (*User, error)
	GetAllUsers(limit, offset int) ([]*User, error)
	UpdateUser(id string, req *UpdateUserRequest) (*User, error)
	DeleteUser(id string) error
}

type CreateUserRequest struct {
	Email    string `json:"email"`
	Name     string `json:"name"`
	Password string `json:"password"`
}

type UpdateUserRequest struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	IsActive *bool  `json:"is_active"`
}
