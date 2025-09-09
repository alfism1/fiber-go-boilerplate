SHELL := /bin/zsh

# Project settings
MODULE := go-fiber-new
BINARY := go-fiber-new
MAIN_PKG := .
BUILD_DIR := bin
COVER_FILE := coverage.out
COVER_HTML := coverage.html

# Metadata
GIT_COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_TIME := $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
LDFLAGS := -X main.commit=$(GIT_COMMIT) -X main.date=$(BUILD_TIME)

# Live-reload config
AIR_CONFIG ?= .air.toml

.PHONY: help
help: ## Show available targets
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: make \033[36m<TARGET>\033[0m\n\nTargets:\n"} /^[a-zA-Z0-9_%\-]+:.*##/ { printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: run
run: ## Run the app
	go run $(MAIN_PKG)

.PHONY: build
build: ## Build the binary
	mkdir -p $(BUILD_DIR)
	go build -ldflags "$(LDFLAGS)" -o $(BUILD_DIR)/$(BINARY) $(MAIN_PKG)

.PHONY: clean
clean: ## Clean build and coverage artifacts
	rm -rf $(BUILD_DIR) $(COVER_FILE) $(COVER_HTML)

.PHONY: test
test: ## Run unit tests
	go test ./...

.PHONY: cover
cover: ## Run tests with coverage and HTML report
	go test ./... -coverprofile=$(COVER_FILE)
	go tool cover -html=$(COVER_FILE) -o $(COVER_HTML)
	@echo "Coverage report: $(COVER_HTML)"

.PHONY: fmt
fmt: ## Format code
	go fmt ./...

.PHONY: vet
vet: ## Go vet static analysis
	go vet ./...

.PHONY: tidy
tidy: ## Sync and tidy go.mod/go.sum
	go mod tidy

.PHONY: deps
deps: ## Download dependencies
	go mod download

.PHONY: verify
verify: ## Verify dependencies
	go mod verify

.PHONY: ci
ci: fmt vet tidy test cover build ## Run common CI steps
	@echo "CI OK"

# --- Live reload ---

.PHONY: dev
dev: ## Live-reload with air (installs if missing)
	@command -v air >/dev/null 2>&1 || { echo "Installing air..."; go install github.com/air-verse/air@latest; }
	@if [ -f "$(AIR_CONFIG)" ]; then echo "Using $(AIR_CONFIG)"; air -c "$(AIR_CONFIG)"; else air; fi

.PHONY: dev-reflex
dev-reflex: ## Live-reload with reflex (installs if missing)
	@command -v reflex >/dev/null 2>&1 || { echo "Installing reflex..."; go install github.com/cespare/reflex@latest; }
	reflex -r '\.go$$' -s -- sh -c 'go run $(MAIN_PKG)'

.PHONY: install-air
install-air: ## Install air hot-reload tool
	go install github.com/air-verse/air@latest

.PHONY: install-reflex
install-reflex: ## Install reflex hot-reload tool
	go install github.com/cespare/reflex@latest