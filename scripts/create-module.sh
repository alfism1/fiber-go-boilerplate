#!/bin/bash

# Cross-platform Go module generator script
# Works on Windows (Git Bash/WSL), Linux, and macOS

set -e  # Exit on error

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to capitalize first letter
capitalize() {
    local input="$1"
    # Convert to lowercase first
    local lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    
    # Try multiple methods for capitalization
    if command -v python3 >/dev/null 2>&1; then
        echo "$lower" | python3 -c "import sys; print(sys.stdin.read().strip().capitalize())"
    elif command -v python >/dev/null 2>&1; then
        echo "$lower" | python -c "import sys; print(sys.stdin.read().strip().capitalize())"
    else
        # Fallback to awk (most compatible)
        echo "$lower" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}'
    fi
}

# Function to show help
show_help() {
    echo "Go Module Generator"
    echo ""
    echo "Usage:"
    echo "  ./create-module.sh <MODULE_NAME>"
    echo "  ./create-module.sh -h|--help"
    echo ""
    echo "Examples:"
    echo "  ./create-module.sh user"
    echo "  ./create-module.sh product"
    echo "  ./create-module.sh OrderItem"
    echo ""
    echo "This will create a complete CRUD module with:"
    echo "  - Domain entities and interfaces"
    echo "  - Repository implementation"
    echo "  - Service layer"
    echo "  - HTTP handlers"
    echo "  - Route setup"
}

# Function to create directory structure
create_directories() {
    local module_name="$1"
    
    print_info "Creating directory structure..."
    
    mkdir -p "modules/${module_name}/domain"
    mkdir -p "modules/${module_name}/handler"
    mkdir -p "modules/${module_name}/repository"
    mkdir -p "modules/${module_name}/routes"
    mkdir -p "modules/${module_name}/service"
}

# Function to create entity file
create_entity() {
    local module_name="$1"
    local struct_name="$2"
    local file="modules/${module_name}/domain/entity.go"
    
    print_info "Creating entity file..."
    
    cat > "$file" << EOF
package domain

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ${struct_name} struct {
	ID        string         \`json:"id" gorm:"type:uuid;primary_key"\`
	Name      string         \`json:"name" gorm:"not null"\`
	CreatedAt time.Time      \`json:"created_at"\`
	UpdatedAt time.Time      \`json:"updated_at"\`
	DeletedAt gorm.DeletedAt \`json:"-" gorm:"index"\`
}

func (u *${struct_name}) BeforeCreate(tx *gorm.DB) error {
	if u.ID == "" {
		u.ID = uuid.New().String()
	}
	return nil
}
EOF
}

# Function to create repository interface file
create_repository_interface() {
    local module_name="$1"
    local struct_name="$2"
    local lower_name="$3"
    local file="modules/${module_name}/domain/repository.go"
    
    print_info "Creating repository interface file..."
    
    cat > "$file" << EOF
package domain

type ${struct_name}Repository interface {
	Create(${lower_name} *${struct_name}) error
	GetByID(id string) (*${struct_name}, error)
	GetAll(limit, offset int) ([]*${struct_name}, error)
	Update(${lower_name} *${struct_name}) error
	Delete(id string) error
}

type ${struct_name}Service interface {
	Create${struct_name}(req *Create${struct_name}Request) (*${struct_name}, error)
	Get${struct_name}ByID(id string) (*${struct_name}, error)
	GetAll${struct_name}s(limit, offset int) ([]*${struct_name}, error)
	Update${struct_name}(id string, req *Update${struct_name}Request) (*${struct_name}, error)
	Delete${struct_name}(id string) error
}

type Create${struct_name}Request struct {
	Name string \`json:"name"\`
}

type Update${struct_name}Request struct {
	Name string \`json:"name"\`
}
EOF
}

# Function to create handler file
create_handler() {
    local module_name="$1"
    local struct_name="$2"
    local lower_name="$3"
    local file="modules/${module_name}/handler/${module_name}_handler.go"
    
    print_info "Creating handler file..."
    
    cat > "$file" << EOF
package handler

import (
	"go-fiber-new/modules/${module_name}/domain"
	"go-fiber-new/shared/response"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

type ${struct_name}Handler struct {
	${lower_name}Service domain.${struct_name}Service
}

func New${struct_name}Handler(${lower_name}Service domain.${struct_name}Service) *${struct_name}Handler {
	return &${struct_name}Handler{${lower_name}Service: ${lower_name}Service}
}

func (h *${struct_name}Handler) Create${struct_name}(c *fiber.Ctx) error {
	var req domain.Create${struct_name}Request
	if err := c.BodyParser(&req); err != nil {
		return response.Error(c, fiber.StatusBadRequest, "Invalid request body", err.Error())
	}

	${lower_name}, err := h.${lower_name}Service.Create${struct_name}(&req)
	if err != nil {
		return response.Error(c, fiber.StatusBadRequest, "Failed to create ${lower_name}", err.Error())
	}

	return response.Success(c, "${struct_name} created successfully", ${lower_name})
}

func (h *${struct_name}Handler) Get${struct_name}(c *fiber.Ctx) error {
	id := c.Params("id")
	${lower_name}, err := h.${lower_name}Service.Get${struct_name}ByID(id)
	if err != nil {
		return response.Error(c, fiber.StatusNotFound, "${struct_name} not found", err.Error())
	}

	return response.Success(c, "${struct_name} retrieved successfully", ${lower_name})
}

func (h *${struct_name}Handler) Get${struct_name}s(c *fiber.Ctx) error {
	limitStr := c.Query("limit", "10")
	offsetStr := c.Query("offset", "0")

	limit, _ := strconv.Atoi(limitStr)
	offset, _ := strconv.Atoi(offsetStr)

	${lower_name}s, err := h.${lower_name}Service.GetAll${struct_name}s(limit, offset)
	if err != nil {
		return response.Error(c, fiber.StatusInternalServerError, "Failed to get ${lower_name}s", err.Error())
	}

	return response.Success(c, "${struct_name}s retrieved successfully", ${lower_name}s)
}
EOF
}

# Function to create repository implementation
create_repository() {
    local module_name="$1"
    local struct_name="$2"
    local lower_name="$3"
    local file="modules/${module_name}/repository/${module_name}_repository.go"
    
    print_info "Creating repository implementation..."
    
    cat > "$file" << EOF
package repository

import (
	"go-fiber-new/modules/${module_name}/domain"

	"gorm.io/gorm"
)

type ${lower_name}Repository struct {
	db *gorm.DB
}

func New${struct_name}Repository(db *gorm.DB) domain.${struct_name}Repository {
	return &${lower_name}Repository{db: db}
}

func (r *${lower_name}Repository) Create(${lower_name} *domain.${struct_name}) error {
	return r.db.Create(${lower_name}).Error
}

func (r *${lower_name}Repository) GetByID(id string) (*domain.${struct_name}, error) {
	var ${lower_name} domain.${struct_name}
	err := r.db.Where("id = ?", id).First(&${lower_name}).Error
	if err != nil {
		return nil, err
	}
	return &${lower_name}, nil
}

func (r *${lower_name}Repository) GetAll(limit, offset int) ([]*domain.${struct_name}, error) {
	var ${lower_name}s []*domain.${struct_name}
	err := r.db.Limit(limit).Offset(offset).Find(&${lower_name}s).Error
	return ${lower_name}s, err
}

func (r *${lower_name}Repository) Update(${lower_name} *domain.${struct_name}) error {
	return r.db.Save(${lower_name}).Error
}

func (r *${lower_name}Repository) Delete(id string) error {
	return r.db.Where("id = ?", id).Delete(&domain.${struct_name}{}).Error
}
EOF
}

# Function to create routes
create_routes() {
    local module_name="$1"
    local struct_name="$2"
    local lower_name="$3"
    local file="modules/${module_name}/routes/${module_name}_routes.go"
    
    print_info "Creating routes file..."
    
    cat > "$file" << EOF
package routes

import (
	"go-fiber-new/modules/${module_name}/handler"
	"go-fiber-new/modules/${module_name}/repository"
	"go-fiber-new/modules/${module_name}/service"
	"go-fiber-new/shared/middleware"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

func Setup${struct_name}Routes(router fiber.Router, db *gorm.DB) {
	// Initialize dependencies
	${lower_name}Repo := repository.New${struct_name}Repository(db)
	${lower_name}Service := service.New${struct_name}Service(${lower_name}Repo)
	${lower_name}Handler := handler.New${struct_name}Handler(${lower_name}Service)

	// Public routes
	${lower_name}s := router.Group("/${lower_name}s")
	${lower_name}s.Post("/", ${lower_name}Handler.Create${struct_name})

	// Protected routes
	${lower_name}s.Use(middleware.AuthRequired())
	${lower_name}s.Get("/", ${lower_name}Handler.Get${struct_name}s)
	${lower_name}s.Get("/:id", ${lower_name}Handler.Get${struct_name})
}
EOF
}

# Function to create service
create_service() {
    local module_name="$1"
    local struct_name="$2"
    local lower_name="$3"
    local file="modules/${module_name}/service/${module_name}_service.go"
    
    print_info "Creating service file..."
    
    cat > "$file" << EOF
package service

import (
	"errors"
	"go-fiber-new/modules/${module_name}/domain"
)

type ${lower_name}Service struct {
	${lower_name}Repo domain.${struct_name}Repository
}

func New${struct_name}Service(${lower_name}Repo domain.${struct_name}Repository) domain.${struct_name}Service {
	return &${lower_name}Service{${lower_name}Repo: ${lower_name}Repo}
}

func (s *${lower_name}Service) Create${struct_name}(req *domain.Create${struct_name}Request) (*domain.${struct_name}, error) {
	if req.Name == "" {
		return nil, errors.New("name is required")
	}

	${lower_name} := &domain.${struct_name}{
		Name: req.Name,
	}

	err := s.${lower_name}Repo.Create(${lower_name})
	if err != nil {
		return nil, err
	}

	return ${lower_name}, nil
}

func (s *${lower_name}Service) Get${struct_name}ByID(id string) (*domain.${struct_name}, error) {
	return s.${lower_name}Repo.GetByID(id)
}

func (s *${lower_name}Service) GetAll${struct_name}s(limit, offset int) ([]*domain.${struct_name}, error) {
	if limit <= 0 {
		limit = 10
	}
	if offset < 0 {
		offset = 0
	}
	return s.${lower_name}Repo.GetAll(limit, offset)
}

func (s *${lower_name}Service) Update${struct_name}(id string, req *domain.Update${struct_name}Request) (*domain.${struct_name}, error) {
	${lower_name}, err := s.${lower_name}Repo.GetByID(id)
	if err != nil {
		return nil, err
	}

	if req.Name != "" {
		${lower_name}.Name = req.Name
	}

	err = s.${lower_name}Repo.Update(${lower_name})
	if err != nil {
		return nil, err
	}

	return ${lower_name}, nil
}

func (s *${lower_name}Service) Delete${struct_name}(id string) error {
	_, err := s.${lower_name}Repo.GetByID(id)
	if err != nil {
		return err
	}
	return s.${lower_name}Repo.Delete(id)
}
EOF
}

# Function to show next steps
show_next_steps() {
    local module_name="$1"
    local struct_name="$2"
    
    echo ""
    print_success "Module ${module_name} created successfully with struct: ${struct_name}!"
    
    echo ""
    echo "📁 Created directory structure:"
    echo "   modules/${module_name}/"
    echo "   ├── domain/"
    echo "   │   ├── entity.go"
    echo "   │   └── repository.go"
    echo "   ├── handler/"
    echo "   │   └── ${module_name}_handler.go"
    echo "   ├── repository/"
    echo "   │   └── ${module_name}_repository.go"
    echo "   ├── routes/"
    echo "   │   └── ${module_name}_routes.go"
    echo "   └── service/"
    echo "       └── ${module_name}_service.go"
    
    echo ""
    echo "📝 Next steps:"
    echo "1. Add the module routes to main.go:"
    echo "   import \"go-fiber-new/modules/${module_name}/routes\""
    echo "   routes.Setup${struct_name}Routes(api, db)"
    echo ""
    echo "2. Run 'go mod tidy' to update dependencies"
    echo "3. Update validation logic as needed"
    echo "4. Add any additional fields to the entity struct"
    echo ""
}

# Main function
main() {
    # Check for help flag
    if [[ "$1" == "-h" || "$1" == "--help" || $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    # Get module name from argument
    MODULE_NAME="$1"
    
    if [[ -z "$MODULE_NAME" ]]; then
        print_error "MODULE_NAME is required!"
        echo ""
        show_help
        exit 1
    fi
    
    # Generate names
    LOWER_NAME=$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')
    STRUCT_NAME=$(capitalize "$MODULE_NAME")
    
    print_info "Creating module: $MODULE_NAME with struct: $STRUCT_NAME"
    
    # Check if module already exists
    if [[ -d "modules/$LOWER_NAME" ]]; then
        print_warning "Module 'modules/$LOWER_NAME' already exists!"
        echo -n "Do you want to overwrite it? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "Operation cancelled."
            exit 0
        fi
        rm -rf "modules/$LOWER_NAME"
    fi
    
    # Create the module
    create_directories "$LOWER_NAME"
    create_entity "$LOWER_NAME" "$STRUCT_NAME"
    create_repository_interface "$LOWER_NAME" "$STRUCT_NAME" "$LOWER_NAME"
    create_handler "$LOWER_NAME" "$STRUCT_NAME" "$LOWER_NAME"
    create_repository "$LOWER_NAME" "$STRUCT_NAME" "$LOWER_NAME"
    create_routes "$LOWER_NAME" "$STRUCT_NAME" "$LOWER_NAME"
    create_service "$LOWER_NAME" "$STRUCT_NAME" "$LOWER_NAME"
    
    show_next_steps "$LOWER_NAME" "$STRUCT_NAME"
}

# Run main function with all arguments
main "$@"