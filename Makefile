# MCP Database Server Docker Images Build System
# 
# This Makefile automates the building, tagging, and pushing of Docker images
# for Google's MCP Toolbox database servers.

# Configuration
REGISTRY ?= docker.io
NAMESPACE ?= your-dockerhub-username
VERSION ?= latest
TOOLBOX_VERSION ?= 0.9.0

# Image names
POSTGRES_IMAGE = $(REGISTRY)/$(NAMESPACE)/mcp-postgres
MYSQL_IMAGE = $(REGISTRY)/$(NAMESPACE)/mcp-mysql
SNOWFLAKE_IMAGE = $(REGISTRY)/$(NAMESPACE)/mcp-snowflake
REDSHIFT_IMAGE = $(REGISTRY)/$(NAMESPACE)/mcp-redshift

# Build platforms
PLATFORMS = linux/amd64,linux/arm64

# Docker buildx builder name
BUILDER = mcp-builder

.PHONY: help setup build-all build-postgres build-mysql build-snowflake build-redshift \
        push-all push-postgres push-mysql push-snowflake push-redshift \
        test-all test-postgres test-mysql test-snowflake test-redshift \
        clean login

# Default target
help: ## Show this help message
	@echo "MCP Database Server Docker Images"
	@echo "=================================="
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Configuration:"
	@echo "  REGISTRY=$(REGISTRY)"
	@echo "  NAMESPACE=$(NAMESPACE)"
	@echo "  VERSION=$(VERSION)"
	@echo "  TOOLBOX_VERSION=$(TOOLBOX_VERSION)"

setup: ## Set up Docker buildx for multi-platform builds
	@echo "Setting up Docker buildx..."
	docker buildx inspect $(BUILDER) >/dev/null 2>&1 || \
		docker buildx create --name $(BUILDER) --use --bootstrap
	docker buildx use $(BUILDER)

# Build targets
build-all: build-postgres build-mysql build-snowflake build-redshift ## Build all database images

build-postgres: setup ## Build PostgreSQL MCP server image
	@echo "Building PostgreSQL MCP server image..."
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg TOOLBOX_VERSION=$(TOOLBOX_VERSION) \
		--tag $(POSTGRES_IMAGE):$(VERSION) \
		--tag $(POSTGRES_IMAGE):latest \
		--file databases/postgres/Dockerfile \
		--context databases/postgres .
	@echo "✅ PostgreSQL image built successfully"

build-mysql: setup ## Build MySQL MCP server image
	@echo "Building MySQL MCP server image..."
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg TOOLBOX_VERSION=$(TOOLBOX_VERSION) \
		--tag $(MYSQL_IMAGE):$(VERSION) \
		--tag $(MYSQL_IMAGE):latest \
		--file databases/mysql/Dockerfile \
		--context databases/mysql .
	@echo "✅ MySQL image built successfully"

build-snowflake: setup ## Build Snowflake MCP server image
	@echo "Building Snowflake MCP server image..."
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg TOOLBOX_VERSION=$(TOOLBOX_VERSION) \
		--tag $(SNOWFLAKE_IMAGE):$(VERSION) \
		--tag $(SNOWFLAKE_IMAGE):latest \
		--file databases/snowflake/Dockerfile \
		--context databases/snowflake .
	@echo "✅ Snowflake image built successfully"

build-redshift: setup ## Build Redshift MCP server image
	@echo "Building Redshift MCP server image..."
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg TOOLBOX_VERSION=$(TOOLBOX_VERSION) \
		--tag $(REDSHIFT_IMAGE):$(VERSION) \
		--tag $(REDSHIFT_IMAGE):latest \
		--file databases/redshift/Dockerfile \
		--context databases/redshift .
	@echo "✅ Redshift image built successfully"

# Push targets
push-all: push-postgres push-mysql push-snowflake push-redshift ## Push all images to registry

push-postgres: ## Push PostgreSQL image to registry
	@echo "Pushing PostgreSQL MCP server image..."
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg TOOLBOX_VERSION=$(TOOLBOX_VERSION) \
		--tag $(POSTGRES_IMAGE):$(VERSION) \
		--tag $(POSTGRES_IMAGE):latest \
		--file databases/postgres/Dockerfile \
		--context databases/postgres --push .
	@echo "✅ PostgreSQL image pushed successfully"

push-mysql: ## Push MySQL image to registry
	@echo "Pushing MySQL MCP server image..."
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg TOOLBOX_VERSION=$(TOOLBOX_VERSION) \
		--tag $(MYSQL_IMAGE):$(VERSION) \
		--tag $(MYSQL_IMAGE):latest \
		--file databases/mysql/Dockerfile \
		--context databases/mysql --push .
	@echo "✅ MySQL image pushed successfully"

push-snowflake: ## Push Snowflake image to registry
	@echo "Pushing Snowflake MCP server image..."
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg TOOLBOX_VERSION=$(TOOLBOX_VERSION) \
		--tag $(SNOWFLAKE_IMAGE):$(VERSION) \
		--tag $(SNOWFLAKE_IMAGE):latest \
		--file databases/snowflake/Dockerfile \
		--context databases/snowflake --push .
	@echo "✅ Snowflake image pushed successfully"

push-redshift: ## Push Redshift image to registry
	@echo "Pushing Redshift MCP server image..."
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg TOOLBOX_VERSION=$(TOOLBOX_VERSION) \
		--tag $(REDSHIFT_IMAGE):$(VERSION) \
		--tag $(REDSHIFT_IMAGE):latest \
		--file databases/redshift/Dockerfile \
		--context databases/redshift --push .
	@echo "✅ Redshift image pushed successfully"

# Test targets
test-all: test-postgres test-mysql test-snowflake test-redshift ## Test all images

test-postgres: ## Test PostgreSQL image
	@echo "Testing PostgreSQL MCP server image..."
	docker run --rm \
		-e DB_TYPE=postgres \
		-e DB_HOST=test \
		-e DB_NAME=test \
		-e DB_USER=test \
		-e DB_PASSWORD=test \
		$(POSTGRES_IMAGE):$(VERSION) \
		--help
	@echo "✅ PostgreSQL image test passed"

test-mysql: ## Test MySQL image
	@echo "Testing MySQL MCP server image..."
	docker run --rm \
		-e DB_TYPE=mysql \
		-e DB_HOST=test \
		-e DB_NAME=test \
		-e DB_USER=test \
		-e DB_PASSWORD=test \
		$(MYSQL_IMAGE):$(VERSION) \
		--help
	@echo "✅ MySQL image test passed"

test-snowflake: ## Test Snowflake image
	@echo "Testing Snowflake MCP server image..."
	docker run --rm \
		-e DB_TYPE=snowflake \
		-e SNOWFLAKE_ACCOUNT=test \
		-e SNOWFLAKE_USER=test \
		-e SNOWFLAKE_PASSWORD=test \
		-e SNOWFLAKE_DATABASE=test \
		-e SNOWFLAKE_WAREHOUSE=test \
		$(SNOWFLAKE_IMAGE):$(VERSION) \
		--help
	@echo "✅ Snowflake image test passed"

test-redshift: ## Test Redshift image
	@echo "Testing Redshift MCP server image..."
	docker run --rm \
		-e DB_TYPE=redshift \
		-e REDSHIFT_HOST=test \
		-e REDSHIFT_DATABASE=test \
		-e REDSHIFT_USER=test \
		-e REDSHIFT_PASSWORD=test \
		$(REDSHIFT_IMAGE):$(VERSION) \
		--help
	@echo "✅ Redshift image test passed"

# Utility targets
login: ## Login to Docker registry
	@echo "Logging into Docker registry..."
	@echo "Make sure to set DOCKER_PASSWORD environment variable"
	@echo "$$DOCKER_PASSWORD" | docker login $(REGISTRY) -u "$$DOCKER_USERNAME" --password-stdin

clean: ## Clean up Docker buildx builder and unused images
	@echo "Cleaning up..."
	docker buildx rm $(BUILDER) 2>/dev/null || true
	docker system prune -f
	@echo "✅ Cleanup completed"

# Development targets
dev-postgres: ## Run PostgreSQL server in development mode
	docker run --rm -it \
		-p 5000:5000 \
		-e DB_HOST=host.docker.internal \
		-e DB_NAME=postgres \
		-e DB_USER=postgres \
		-e DB_PASSWORD=postgres \
		-e TOOLBOX_LOG_LEVEL=debug \
		$(POSTGRES_IMAGE):$(VERSION)

dev-mysql: ## Run MySQL server in development mode
	docker run --rm -it \
		-p 5000:5000 \
		-e DB_HOST=host.docker.internal \
		-e DB_NAME=mysql \
		-e DB_USER=root \
		-e DB_PASSWORD=password \
		-e TOOLBOX_LOG_LEVEL=debug \
		$(MYSQL_IMAGE):$(VERSION)

# Release targets
release: build-all push-all ## Build and push all images for release
	@echo "🚀 Release completed successfully!"
	@echo "Images available at:"
	@echo "  - $(POSTGRES_IMAGE):$(VERSION)"
	@echo "  - $(MYSQL_IMAGE):$(VERSION)"
	@echo "  - $(SNOWFLAKE_IMAGE):$(VERSION)"
	@echo "  - $(REDSHIFT_IMAGE):$(VERSION)"

# Show image sizes
sizes: ## Show sizes of built images
	@echo "Image sizes:"
	@docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep mcp- || echo "No MCP images found"