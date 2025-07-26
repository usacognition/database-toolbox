#!/bin/bash

# MCP Database Server Docker Images Build Script
# This script builds, tests, and optionally pushes all database-specific Docker images

set -e  # Exit on any error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="${REGISTRY:-docker.io}"
NAMESPACE="${NAMESPACE:-your-dockerhub-username}"
VERSION="${VERSION:-latest}"
TOOLBOX_VERSION="${TOOLBOX_VERSION:-0.9.0}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Database types
DATABASES=("postgres" "mysql" "snowflake" "redshift" "bigquery" "alloydb" "spanner" "neo4j" "sqlite" "redis" "sqlserver" "firestore" "supabase")

# Functions
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

show_help() {
    cat << EOF
MCP Database Server Docker Build Script

Usage: $0 [OPTIONS] [COMMAND]

Commands:
    build       Build all Docker images (default)
    build-db    Build specific database image
    test        Test all built images
    push        Push all images to registry
    clean       Clean up build artifacts
    setup       Set up Docker buildx environment
    help        Show this help message

Options:
    -r, --registry REGISTRY    Docker registry (default: docker.io)
    -n, --namespace NAMESPACE  Docker namespace/username (default: your-dockerhub-username)
    -v, --version VERSION      Image version tag (default: latest)
    -t, --toolbox VERSION      MCP Toolbox version (default: 0.9.0)
    -p, --platforms PLATFORMS  Build platforms (default: linux/amd64,linux/arm64)
    -d, --database DATABASE    Specific database to build (postgres|mysql|snowflake|redshift)
    --no-cache                 Build without cache
    --push                     Push images after building
    --test                     Test images after building

Examples:
    $0 build --push                           # Build and push all images
    $0 build-db -d postgres --test           # Build and test PostgreSQL image only
    $0 push -n mydockerhub -v v1.0.0         # Push all images with specific version
    $0 clean                                  # Clean up build artifacts

Environment Variables:
    REGISTRY        Override default registry
    NAMESPACE       Override default namespace
    VERSION         Override default version
    TOOLBOX_VERSION Override MCP Toolbox version
    PLATFORMS       Override build platforms

EOF
}

setup_buildx() {
    log "Setting up Docker Buildx..."
    
    if ! docker buildx inspect mcp-builder >/dev/null 2>&1; then
        log "Creating buildx builder 'mcp-builder'..."
        docker buildx create --name mcp-builder --driver docker-container --use
        docker buildx inspect --bootstrap
    else
        log "Using existing buildx builder 'mcp-builder'..."
        docker buildx use mcp-builder
    fi
    
    success "Buildx setup complete"
}

validate_environment() {
    log "Validating environment..."
    
    # Check Docker
    if ! command -v docker >/dev/null 2>&1; then
        error "Docker is not installed or not in PATH"
    fi
    
    # Check Docker daemon
    if ! docker info >/dev/null 2>&1; then
        error "Docker daemon is not running"
    fi
    
    # Check buildx
    if ! docker buildx version >/dev/null 2>&1; then
        error "Docker buildx is not available"
    fi
    
    success "Environment validation complete"
}

build_image() {
    local database="$1"
    local database_dir="databases/${database}"
    local dockerfile="${database_dir}/Dockerfile"
    local image_name="${REGISTRY}/${NAMESPACE}/mcp-${database}"
    local build_args="--build-arg TOOLBOX_VERSION=${TOOLBOX_VERSION}"
    
    if [[ ! -f "$dockerfile" ]]; then
        error "Dockerfile not found: $dockerfile"
    fi
    
    log "Building image for $database..."
    log "Image: ${image_name}:${VERSION}"
    log "Platforms: ${PLATFORMS}"
    
    local docker_cmd="docker buildx build"
    docker_cmd+=" --platform ${PLATFORMS}"
    docker_cmd+=" --file ${dockerfile}"
    docker_cmd+=" --tag ${image_name}:${VERSION}"
    docker_cmd+=" ${build_args}"
    
    if [[ "${NO_CACHE:-false}" == "true" ]]; then
        docker_cmd+=" --no-cache"
    fi
    
    if [[ "${PUSH_IMAGES:-false}" == "true" ]]; then
        docker_cmd+=" --push"
    else
        docker_cmd+=" --load"
    fi
    
    docker_cmd+=" ${database_dir}"
    
    log "Executing: $docker_cmd"
    eval "$docker_cmd"
    
    success "Built image for $database"
}

test_image() {
    local database="$1"
    local image_name="${REGISTRY}/${NAMESPACE}/mcp-${database}:${VERSION}"
    
    log "Testing image: $image_name"
    
    # Basic functionality test
    if docker run --rm "$image_name" --version >/dev/null 2>&1; then
        success "Basic test passed for $database"
    else
        warning "Basic test failed for $database (this might be expected if --version is not supported)"
    fi
    
    # Health check test (if applicable)
    log "Testing health check for $database..."
    if docker run --rm --entrypoint="/app/scripts/healthcheck.sh" "$image_name" >/dev/null 2>&1; then
        success "Health check test passed for $database"
    else
        warning "Health check test failed for $database (expected without database connection)"
    fi
}

push_image() {
    local database="$1"
    local image_name="${REGISTRY}/${NAMESPACE}/mcp-${database}:${VERSION}"
    
    log "Pushing image: $image_name"
    docker push "$image_name"
    success "Pushed image for $database"
}

clean_artifacts() {
    log "Cleaning up build artifacts..."
    
    # Remove buildx builder
    if docker buildx inspect mcp-builder >/dev/null 2>&1; then
        docker buildx rm mcp-builder
        log "Removed buildx builder"
    fi
    
    # Clean buildx cache
    docker buildx prune -f
    
    success "Cleanup complete"
}

# Parse command line arguments
COMMAND=""
DATABASE=""
NO_CACHE="false"
PUSH_IMAGES="false"
TEST_IMAGES="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -t|--toolbox)
            TOOLBOX_VERSION="$2"
            shift 2
            ;;
        -p|--platforms)
            PLATFORMS="$2"
            shift 2
            ;;
        -d|--database)
            DATABASE="$2"
            shift 2
            ;;
        --no-cache)
            NO_CACHE="true"
            shift
            ;;
        --push)
            PUSH_IMAGES="true"
            shift
            ;;
        --test)
            TEST_IMAGES="true"
            shift
            ;;
        build|build-db|test|push|clean|setup|help)
            COMMAND="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Default command
if [[ -z "$COMMAND" ]]; then
    COMMAND="build"
fi

# Validate database if specified
if [[ -n "$DATABASE" ]] && [[ ! " ${DATABASES[@]} " =~ " $DATABASE " ]]; then
    error "Invalid database: $DATABASE. Supported: ${DATABASES[*]}"
fi

# Execute command
case $COMMAND in
    help)
        show_help
        ;;
    setup)
        validate_environment
        setup_buildx
        ;;
    build)
        validate_environment
        setup_buildx
        
        log "Building all MCP database server images..."
        log "Registry: $REGISTRY"
        log "Namespace: $NAMESPACE"
        log "Version: $VERSION"
        log "Toolbox Version: $TOOLBOX_VERSION"
        
        for db in "${DATABASES[@]}"; do
            build_image "$db"
        done
        
        if [[ "$TEST_IMAGES" == "true" ]]; then
            for db in "${DATABASES[@]}"; do
                test_image "$db"
            done
        fi
        
        success "All images built successfully"
        ;;
    build-db)
        if [[ -z "$DATABASE" ]]; then
            error "Database must be specified with -d/--database option"
        fi
        
        validate_environment
        setup_buildx
        
        build_image "$DATABASE"
        
        if [[ "$TEST_IMAGES" == "true" ]]; then
            test_image "$DATABASE"
        fi
        
        success "Image built successfully for $DATABASE"
        ;;
    test)
        log "Testing all MCP database server images..."
        
        for db in "${DATABASES[@]}"; do
            test_image "$db"
        done
        
        success "All image tests completed"
        ;;
    push)
        log "Pushing all MCP database server images..."
        
        for db in "${DATABASES[@]}"; do
            push_image "$db"
        done
        
        success "All images pushed successfully"
        ;;
    clean)
        clean_artifacts
        ;;
    *)
        error "Unknown command: $COMMAND"
        ;;
esac