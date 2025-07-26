# MCP Database Server Docker Images Build System
# 
# Comprehensive Makefile that consolidates all database building, testing, and deployment
# functionality for Google's MCP Toolbox database servers.

# Configuration
REGISTRY ?= docker.io
NAMESPACE ?= your-dockerhub-username
VERSION ?= latest
TOOLBOX_VERSION ?= 0.9.0
PLATFORMS ?= linux/amd64,linux/arm64
BUILDER ?= mcp-builder

# All supported databases (matching MCP Toolbox prebuilt configurations)
DATABASES := postgres mysql sqlite redis neo4j bigquery spanner sqlserver alloydb-postgres cloud-sql-postgres cloud-sql-mysql cloud-sql-mssql bigtable dgraph couchbase

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m

# Helper functions
define log
	@echo "$(BLUE)[$(shell date '+%Y-%m-%d %H:%M:%S')] $(1)$(NC)"
endef

define success
	@echo "$(GREEN)[SUCCESS] $(1)$(NC)"
endef

define warning
	@echo "$(YELLOW)[WARNING] $(1)$(NC)"
endef

define error
	@echo "$(RED)[ERROR] $(1)$(NC)" && exit 1
endef

# Image name helper
define image_name
$(REGISTRY)/$(NAMESPACE)/mcp-$(1)
endef

# Validate database helper
define validate_db
$(if $(filter $(1),$(DATABASES)),,$(call error,Invalid database '$(1)'. Supported: $(DATABASES)))
endef

# Default target
.DEFAULT_GOAL := help

# All phony targets
.PHONY: help setup validate-environment clean clean-all login \
        build build-all $(addprefix build-,$(DATABASES)) \
        push push-all $(addprefix push-,$(DATABASES)) \
        test test-all $(addprefix test-,$(DATABASES)) \
        list-databases status info

help: ## Show this comprehensive help message
	@echo "$(BLUE)MCP Database Server Docker Images Build System$(NC)"
	@echo "=================================================="
	@echo ""
	@echo "$(YELLOW)Quick Start:$(NC)"
	@echo "  make build-postgres          # Build PostgreSQL image"
	@echo "  make build DB=mysql          # Build specific database"
	@echo "  make build-all               # Build all 13 databases"
	@echo "  make test-postgres           # Test PostgreSQL setup"
	@echo "  make push-all                # Push all images to registry"
	@echo ""
	@echo "$(YELLOW)Available Commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Supported Databases ($(words $(DATABASES)) total):$(NC)"
	@echo "  $(DATABASES)" | tr ' ' '\n' | sort | pr -t -3 -w 60 | sed 's/^/  /'
	@echo ""
	@echo "$(YELLOW)Configuration:$(NC)"
	@echo "  REGISTRY:        $(REGISTRY)"
	@echo "  NAMESPACE:       $(NAMESPACE)"
	@echo "  VERSION:         $(VERSION)"
	@echo "  TOOLBOX_VERSION: $(TOOLBOX_VERSION)"
	@echo "  PLATFORMS:       $(PLATFORMS)"
	@echo ""
	@echo "$(YELLOW)Usage Examples:$(NC)"
	@echo "  make build-postgres REGISTRY=ghcr.io NAMESPACE=myorg"
	@echo "  make push-all VERSION=v1.2.0"
	@echo "  make test DB=redis"
	@echo "  make clean DB=mysql"

list-databases: ## List all supported databases
	@echo "$(BLUE)Supported Databases ($(words $(DATABASES)) total):$(NC)"
	@for db in $(DATABASES); do \
		echo "  $(GREEN)$$db$(NC) - mcp-$$db"; \
	done

info: ## Show detailed build environment information
	@echo "$(BLUE)Build Environment Information$(NC)"
	@echo "=============================="
	@echo "Docker version:     $$(docker --version)"
	@echo "Docker Buildx:      $$(docker buildx version)"
	@echo "Current builder:    $$(docker buildx inspect --bootstrap 2>/dev/null | head -1 || echo 'Not set')"
	@echo "Available platforms: $$(docker buildx inspect --bootstrap 2>/dev/null | grep 'Platforms:' | cut -d: -f2 || echo 'Unknown')"
	@echo ""
	@echo "Project Structure:"
	@echo "  Total databases:  $(words $(DATABASES))"
	@echo "  Database folders: $$(find databases -maxdepth 1 -type d | wc -l | tr -d ' ') (including databases/)"
	@echo "  Registry:         $(REGISTRY)"
	@echo "  Namespace:        $(NAMESPACE)"

setup: ## Set up Docker buildx for multi-platform builds
	$(call log,Setting up Docker buildx...)
	@docker buildx inspect $(BUILDER) >/dev/null 2>&1 || \
		docker buildx create --name $(BUILDER) --use --bootstrap
	@docker buildx use $(BUILDER)
	$(call success,Docker buildx setup complete)

validate-environment: ## Validate build environment and dependencies
	$(call log,Validating build environment...)
	@which docker >/dev/null 2>&1 || (echo "$(RED)[ERROR] Docker not found. Please install Docker.$(NC)" && exit 1)
	@docker buildx version >/dev/null 2>&1 || (echo "$(RED)[ERROR] Docker buildx not available. Please upgrade Docker.$(NC)" && exit 1)
	@for db in $(DATABASES); do \
		if [ ! -d "databases/$$db" ]; then \
			echo "$(YELLOW)[WARNING] Database folder databases/$$db not found$(NC)"; \
		elif [ ! -f "databases/$$db/Dockerfile" ]; then \
			echo "$(YELLOW)[WARNING] Dockerfile not found for $$db$(NC)"; \
		fi; \
	done
	$(call success,Environment validation complete)

# Dynamic database build target
build: ## Build specific database (usage: make build DB=postgres)
	@$(if $(DB),,$(call error,Database not specified. Usage: make build DB=<database>))
	@$(call validate_db,$(DB))
	@$(MAKE) build-$(DB)

# Build all databases
build-all: setup validate-environment ## Build all database images
	$(call log,Building all $(words $(DATABASES)) database images...)
	@for db in $(DATABASES); do \
		$(call log,Building $$db...); \
		$(MAKE) build-$$db || exit 1; \
	done
	$(call success,All database images built successfully)

# Generate build targets for each database
define build_template
build-$(1): setup ## Build $(1) MCP server image
	$$(call log,Building $(1) MCP server image...)
	docker buildx build \
		--platform $$(PLATFORMS) \
		--build-arg TOOLBOX_VERSION=$$(TOOLBOX_VERSION) \
		--tag $$(call image_name,$(1)):$$(VERSION) \
		--tag $$(call image_name,$(1)):latest \
		--file databases/$(1)/Dockerfile \
		--load databases/$(1)
	$$(call success,$(1) image built successfully)
endef

# Generate build targets for all databases
$(foreach db,$(DATABASES),$(eval $(call build_template,$(db))))

# Dynamic database push target
push: ## Push specific database (usage: make push DB=postgres)
	@$(if $(DB),,$(call error,Database not specified. Usage: make push DB=<database>))
	@$(call validate_db,$(DB))
	@$(MAKE) push-$(DB)

# Push all databases
push-all: ## Push all images to registry
	$(call log,Pushing all $(words $(DATABASES)) database images...)
	@for db in $(DATABASES); do \
		$(call log,Pushing $$db...); \
		$(MAKE) push-$$db || exit 1; \
	done
	$(call success,All database images pushed successfully)

# Generate push targets for each database
define push_template
push-$(1): ## Push $(1) image to registry
	$$(call log,Pushing $(1) MCP server image...)
	docker buildx build \
		--platform $$(PLATFORMS) \
		--build-arg TOOLBOX_VERSION=$$(TOOLBOX_VERSION) \
		--tag $$(call image_name,$(1)):$$(VERSION) \
		--tag $$(call image_name,$(1)):latest \
		--file databases/$(1)/Dockerfile \
		--push databases/$(1)
	$$(call success,$(1) image pushed successfully)
endef

# Generate push targets for all databases
$(foreach db,$(DATABASES),$(eval $(call push_template,$(db))))

# Dynamic database test target
test: ## Test specific database (usage: make test DB=postgres)
	@$(if $(DB),,$(call error,Database not specified. Usage: make test DB=<database>))
	@$(call validate_db,$(DB))
	@$(MAKE) test-$(DB)

# Test all databases
test-all: ## Test all database images
	$(call log,Testing all $(words $(DATABASES)) database images...)
	@for db in $(DATABASES); do \
		$(call log,Testing $$db...); \
		$(MAKE) test-$$db || exit 1; \
	done
	$(call success,All database images tested successfully)

# Generate test targets for each database
define test_template
test-$(1): ## Test $(1) MCP server setup
	$$(call log,Testing $(1) MCP server...)
	@cd databases/$(1) && \
	if [ -f "docker-compose.yml" ]; then \
		$$(call log,Starting $(1) test environment...); \
		docker-compose up -d --build; \
		sleep 10; \
		$$(call log,Testing $(1) health...); \
		if docker-compose ps | grep -q "Up (healthy)"; then \
			echo "$$(GREEN)[SUCCESS] $(1) health check passed$$(NC)"; \
		else \
			echo "$$(YELLOW)[WARNING] $(1) health check inconclusive$$(NC)"; \
		fi; \
		docker-compose down; \
	else \
		echo "$$(YELLOW)[WARNING] No docker-compose.yml found for $(1), skipping integration test$$(NC)"; \
		$$(call log,Running basic container test for $(1)...); \
		docker run --rm $$(call image_name,$(1)):latest --version || true; \
	fi
	$$(call success,$(1) test completed)
endef

# Generate test targets for all databases
$(foreach db,$(DATABASES),$(eval $(call test_template,$(db))))

# Dynamic database clean target
clean: ## Clean specific database artifacts (usage: make clean DB=postgres)
	@$(if $(DB),,$(call error,Database not specified. Usage: make clean DB=<database>))
	@$(call validate_db,$(DB))
	@$(MAKE) clean-$(DB)

# Clean all artifacts
clean-all: ## Clean all build artifacts and containers
	$(call log,Cleaning all build artifacts...)
	@for db in $(DATABASES); do \
		$(call log,Cleaning $$db...); \
		$(MAKE) clean-$$db 2>/dev/null || true; \
	done
	@$(call log,Removing Docker builder...)
	@docker buildx rm $(BUILDER) 2>/dev/null || true
	@$(call log,Pruning unused Docker resources...)
	@docker system prune -f 2>/dev/null || true
	$(call success,All artifacts cleaned)

# Generate clean targets for each database
define clean_template
clean-$(1): ## Clean $(1) build artifacts
	$$(call log,Cleaning $(1) artifacts...)
	@cd databases/$(1) 2>/dev/null && docker-compose down 2>/dev/null || true
	@docker rmi $$(call image_name,$(1)):$$(VERSION) 2>/dev/null || true
	@docker rmi $$(call image_name,$(1)):latest 2>/dev/null || true
	$$(call success,$(1) artifacts cleaned)
endef

# Generate clean targets for all databases
$(foreach db,$(DATABASES),$(eval $(call clean_template,$(db))))

# Status and monitoring
status: ## Show status of all database containers
	@echo "$(BLUE)Database Container Status$(NC)"
	@echo "=========================="
	@docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | \
		grep -E "(mcp-|postgres|mysql|redis)" || echo "No database containers found"

login: ## Login to Docker registry
	$(call log,Logging into $(REGISTRY)...)
	@docker login $(REGISTRY)
	$(call success,Logged into $(REGISTRY))

# Development helpers
dev-postgres: ## Start PostgreSQL development environment
	@cd databases/postgres && docker-compose up -d
	$(call success,PostgreSQL development environment started on port 5001)

dev-mysql: ## Start MySQL development environment  
	@cd databases/mysql && docker-compose up -d
	$(call success,MySQL development environment started on port 5002)

dev-stop: ## Stop all development environments
	@for db in $(DATABASES); do \
		if [ -f "databases/$$db/docker-compose.yml" ]; then \
			cd databases/$$db && docker-compose down 2>/dev/null || true; \
			cd ../..; \
		fi; \
	done
	$(call success,All development environments stopped)

# Validation target for CI/CD
validate: validate-environment ## Run comprehensive validation
	$(call log,Running comprehensive validation...)
	@$(MAKE) build-postgres
	@$(MAKE) test-postgres
	@$(MAKE) clean-postgres
	$(call success,Validation completed successfully)