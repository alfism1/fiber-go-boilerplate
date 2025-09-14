# Go Fiber API

A clean, modular REST API built with Go Fiber framework featuring authentication, user management, and a well-structured architecture.

## 🚀 Features

- **Clean Architecture**: Modular design with separation of concerns
- **Authentication**: JWT-based authentication system
- **User Management**: Complete CRUD operations for users
- **Database**: PostgreSQL with GORM ORM
- **Middleware**: CORS, logging, and authentication middleware
- **Validation**: Input validation and error handling
- **Hot Reload**: Development with live reload support
- **Module Generator**: Script to generate new modules quickly

## 📋 Prerequisites

- Go 1.25.0 or higher
- PostgreSQL database
- Make (optional, for using Makefile commands)

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd go-fiber-new
   ```

2. **Install dependencies**
   ```bash
   go mod download
   ```

3. **Set up environment variables**
   Create a `.env` file in the root directory:
   ```env
   PORT=8080
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=password
   DB_NAME=mydb
   JWT_SECRET=your-secret-key-change-this
   ```

4. **Set up PostgreSQL database**
   ```sql
   CREATE DATABASE mydb;
   ```

## 🏃‍♂️ Running the Application

### Development Mode (with hot reload)
```bash
# Using Air (recommended)
make dev

# Or using Reflex
make dev-reflex

# Or manually install and run Air
go install github.com/air-verse/air@latest
air
```

### Production Mode
```bash
# Build the application
make build

# Run the binary
./bin/go-fiber-new
```

### Using Make Commands
```bash
# Run the application
make run

# Build binary
make build

# Run tests
make test

# Run tests with coverage
make cover

# Format code
make fmt

# Clean build artifacts
make clean

# Show all available commands
make help
```

## 📁 Project Structure

```
go-fiber-new/
├── config/                 # Configuration management
│   └── config.go
├── modules/                # Feature modules
│   ├── auth/              # Authentication module
│   └── user/              # User management module
├── shared/                 # Shared utilities
│   ├── database/          # Database connection
│   ├── middleware/        # HTTP middleware
│   ├── response/          # Response helpers
│   ├── utils/             # Utility functions
│   └── validator/         # Input validation
├── scripts/               # Helper scripts
│   └── create-module.sh   # Module generator
├── main.go                # Application entry point
├── Makefile              # Build automation
└── go.mod                # Go module file
```

## 🏗️ Architecture

The project follows a clean architecture pattern with clear separation of concerns:

- **Domain Layer**: Entities and interfaces
- **Repository Layer**: Data access abstraction
- **Service Layer**: Business logic
- **Handler Layer**: HTTP request/response handling
- **Routes Layer**: Route definitions and middleware setup

## 📚 API Endpoints

### Health Check
- `GET /` - API health check

### Authentication
- `POST /api/v1/auth/login` - User login

### Users
- `POST /api/v1/users/` - Create user (public)
- `GET /api/v1/users/profile` - Get current user profile (protected)
- `GET /api/v1/users/` - Get all users (protected)
- `GET /api/v1/users/:id` - Get user by ID (protected)

### Authentication
All protected endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## 🔧 Creating New Modules

Use the provided script to generate new modules quickly:

```bash
# Make the script executable
chmod +x scripts/create-module.sh

# Create a new module
./scripts/create-module.sh product

# This will create a complete CRUD module with:
# - Domain entities and interfaces
# - Repository implementation
# - Service layer
# - HTTP handlers
# - Route setup
```

After creating a module, add it to `main.go`:
```go
import "go-fiber-new/modules/product/routes"

// In main function
product_routes.SetupProductRoutes(api, db)
```

## 🧪 Testing

```bash
# Run all tests
make test

# Run tests with coverage
make cover

# View coverage report
open coverage.html
```

## 📦 Dependencies

### Core Dependencies
- **Fiber v2**: High-performance HTTP framework
- **GORM**: ORM library for database operations
- **PostgreSQL Driver**: Database connectivity
- **JWT**: JSON Web Token implementation
- **bcrypt**: Password hashing
- **godotenv**: Environment variable management

### Development Dependencies
- **Air**: Live reload for development
- **Reflex**: Alternative live reload tool

## 🔒 Security Features

- Password hashing with bcrypt
- JWT token authentication
- CORS middleware
- Input validation
- Error handling middleware

## 🚀 Deployment

1. **Build the application**
   ```bash
   make build
   ```

2. **Set production environment variables**
   ```bash
   export PORT=8080
   export DB_HOST=your-db-host
   export DB_USER=your-db-user
   export DB_PASSWORD=your-db-password
   export DB_NAME=your-db-name
   export JWT_SECRET=your-production-secret
   ```

3. **Run the binary**
   ```bash
   ./bin/go-fiber-new
   ```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure they pass
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

If you encounter any issues or have questions, please open an issue in the repository.

---

**Happy coding! 🎉**
