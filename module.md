### Module Generator and Structure

This project includes a cross‑platform module generator script that scaffolds a complete CRUD-ready module, following a consistent architecture: Domain → Repository → Service → HTTP Handlers → Routes.

Use it to quickly add new resources (e.g., user, product, order) with minimal boilerplate.

---

## How to Generate a Module

Run the script from the repository root:

```bash
./scripts/create-module.sh <MODULE_NAME>
```

Examples:

```bash
./scripts/create-module.sh user
./scripts/create-module.sh product
./scripts/create-module.sh OrderItem
```

- The script normalizes naming: `MODULE_NAME` is converted to lowercase for folders and capitalized for struct names. For example, `OrderItem` → folder `modules/orderitem`, struct `Orderitem`.
- If a module folder already exists, the script will ask for confirmation before overwriting it.

After generation:

1) Wire routes in `main.go` (example below)
2) Run `go mod tidy`
3) Adjust validation and add additional fields as needed

---

## Directory Layout

Generated files live under `modules/<module>/`:

```
modules/<module>/
├── domain/
│   ├── entity.go           # GORM entity with UUID and timestamps
│   └── repository.go       # Repository and Service interfaces + DTOs
├── handler/
│   └── <module>_handler.go # Fiber HTTP handlers
├── repository/
│   └── <module>_repository.go # GORM repository implementation
├── routes/
│   └── <module>_routes.go  # Route registration and DI wiring
└── service/
    └── <module>_service.go # Business logic layer
```

---

## Generated Components

### 1) Domain (`domain/`)
- `entity.go`
  - Defines the primary entity struct with common fields and soft delete:
    - `ID string` (UUID, primary key via `BeforeCreate` hook)
    - `Name string`
    - `CreatedAt`, `UpdatedAt` (timestamps)
    - `DeletedAt gorm.DeletedAt` (soft delete index)
- `repository.go`
  - Repository interface: `Create`, `GetByID`, `GetAll(limit, offset)`, `Update`, `Delete`
  - Service interface: CRUD contracts used by handlers
  - DTOs: `Create<Struct>Request`, `Update<Struct>Request`

### 2) Repository (`repository/`)
- `<module>_repository.go`
  - GORM-backed implementation of the Domain repository interface
  - Uses `*gorm.DB` for persistence

### 3) Service (`service/`)
- `<module>_service.go`
  - Business logic on top of the repository
  - Basic validation: requires `Name` for create
  - Pagination defaults for list: `limit=10` if invalid, `offset=0` if negative

### 4) Handler (`handler/`)
- `<module>_handler.go`
  - Fiber HTTP handlers using the Service
  - Parses/validates request bodies and query parameters
  - Returns unified JSON responses via `shared/response`

### 5) Routes (`routes/`)
- `<module>_routes.go`
  - Wires Repository → Service → Handler
  - Defines public and protected routes
  - Applies `shared/middleware.AuthRequired()` to protected endpoints

---

## REST Endpoints

Assuming module name `product` and struct `Product`, the routes are mounted under `/products`:

- Public:
  - `POST /products/` → Create Product

- Protected (requires `middleware.AuthRequired()`):
  - `GET /products/` → List Products (supports `limit` and `offset` query params)
  - `GET /products/:id` → Get Product by ID

Query params:
- `limit` (default `10` if missing/invalid)
- `offset` (default `0` if missing/invalid)

---

## Wiring Routes in `main.go`

Import the routes package and call the setup function, providing your API group and `*gorm.DB`:

```go
// in main.go
import (
	// ... other imports
	"go-fiber-new/modules/product/routes"
)

func main() {
	// ... app and db setup
	api := app.Group("/api")

	routes.SetupProductRoutes(api, db)

	// ... listen, etc.
}
```

Replace `product` with your module name and `SetupProductRoutes` with the generated function (e.g., `SetupUserRoutes`).

---

## Naming Conventions

- Folder name: lowercase; e.g., `modules/product`
- Struct name: capitalized form of the provided module name; e.g., `Product`
- Service/Repository types and functions are derived from the struct name; e.g., `NewProductRepository`, `NewProductService`
- Handler fields use a lowercased identifier of the struct; e.g., `productService`

Note: The script applies simple capitalization logic. If you need precise multi-word capitalization (e.g., `OrderItem` → `OrderItem`), adjust the generated names manually or enhance the script.

---

## Entity and Persistence Details

- Primary key: `ID` is a UUID string generated in `BeforeCreate`
- Soft delete: `DeletedAt gorm.DeletedAt` with an index
- Timestamps: `CreatedAt`, `UpdatedAt`
- GORM tags are set for common constraints

You can extend `entity.go` with additional fields and relationships as needed.

---

## Middleware and Responses

- Protected routes use `shared/middleware.AuthRequired()`
- Responses use helpers in `shared/response` to standardize success and error payloads

---

## Dependencies

The generated code expects these libraries already in your `go.mod` or retrievable via `go mod tidy`:

- `github.com/gofiber/fiber/v2`
- `gorm.io/gorm`
- `github.com/google/uuid`

Run:

```bash
go mod tidy
```

---

## Customization Tips

- Add fields and validation rules to the domain DTOs and service methods
- Expand handlers with update and delete endpoints if desired
- Adjust repository queries (e.g., filters, ordering)
- Add module-specific middleware in `routes` or `handler`

---

## Troubleshooting

- Module not found at import: ensure your module path is correct (e.g., `go-fiber-new/...`) and run `go mod tidy`
- Overwrite prompt not shown on CI: the script is interactive when a module exists; use a clean workspace or remove the folder before generating
- Capitalization oddities: adjust the generated type and file names manually if needed 