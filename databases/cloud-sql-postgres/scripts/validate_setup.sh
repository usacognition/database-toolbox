#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Database types supported
DATABASES=("postgres" "mysql" "snowflake" "redshift" "bigquery" "alloydb" "spanner" "neo4j" "sqlite" "redis" "sqlserver" "firestore" "supabase")

log "🔍 Starting MCP Database Servers validation..."

# Check Dockerfiles
log "📋 Checking Dockerfiles..."
all_dockerfiles_exist=true

for db in "${DATABASES[@]}"; do
    dockerfile="Dockerfile.${db}"
    if [[ -f "$dockerfile" ]]; then
        success "Found $dockerfile"
        
        # Check if Dockerfile has required sections
        if ! grep -q "FROM alpine:3.19" "$dockerfile"; then
            error "$dockerfile: Missing correct base image"
            all_dockerfiles_exist=false
        fi
        
        if ! grep -q "ENV DB_TYPE=${db}" "$dockerfile"; then
            error "$dockerfile: Missing DB_TYPE environment variable"
            all_dockerfiles_exist=false
        fi
        
        if ! grep -q "HEALTHCHECK" "$dockerfile"; then
            warning "$dockerfile: Missing health check configuration"
        fi
        
        if ! grep -q "USER mcp" "$dockerfile"; then
            error "$dockerfile: Missing non-root user configuration"
            all_dockerfiles_exist=false
        fi
        
    else
        error "Missing $dockerfile"
        all_dockerfiles_exist=false
    fi
done

# Check entrypoint script
log "🔧 Checking entrypoint script..."
if [[ -f "scripts/entrypoint.sh" ]]; then
    success "Found scripts/entrypoint.sh"
    
    # Check if all databases are supported in entrypoint
    for db in "${DATABASES[@]}"; do
        if grep -q "\"${db}\")" scripts/entrypoint.sh; then
            success "Entrypoint supports $db"
        else
            error "Entrypoint missing support for $db"
            all_dockerfiles_exist=false
        fi
    done
else
    error "Missing scripts/entrypoint.sh"
    all_dockerfiles_exist=false
fi

# Check health check script
log "🏥 Checking health check script..."
if [[ -f "scripts/healthcheck.sh" ]]; then
    success "Found scripts/healthcheck.sh"
    
    if [[ -x "scripts/healthcheck.sh" ]]; then
        success "Health check script is executable"
    else
        warning "Health check script is not executable"
    fi
else
    error "Missing scripts/healthcheck.sh"
    all_dockerfiles_exist=false
fi

# Check build script
log "🔨 Checking build script..."
if [[ -f "build.sh" ]]; then
    success "Found build.sh"
    
    # Check if all databases are in build script
    for db in "${DATABASES[@]}"; do
        if grep -q "\"${db}\"" build.sh; then
            success "Build script includes $db"
        else
            error "Build script missing $db"
            all_dockerfiles_exist=false
        fi
    done
else
    error "Missing build.sh"
    all_dockerfiles_exist=false
fi

# Check test configurations
log "🧪 Checking test configurations..."
if [[ -f "tests/conftest.py" ]]; then
    success "Found tests/conftest.py"
    
    # Check if all MCP URLs are defined
    test_urls=(
        "POSTGRES_MCP_URL" "MYSQL_MCP_URL" "SNOWFLAKE_MCP_URL" "REDSHIFT_MCP_URL"
        "BIGQUERY_MCP_URL" "ALLOYDB_MCP_URL" "SPANNER_MCP_URL" "NEO4J_MCP_URL"
        "SQLITE_MCP_URL" "REDIS_MCP_URL" "SQLSERVER_MCP_URL" "FIRESTORE_MCP_URL"
        "SUPABASE_MCP_URL"
    )
    
    for url in "${test_urls[@]}"; do
        if grep -q "$url" tests/conftest.py; then
            success "Test config includes $url"
        else
            error "Test config missing $url"
            all_dockerfiles_exist=false
        fi
    done
else
    error "Missing tests/conftest.py"
    all_dockerfiles_exist=false
fi

# Check test requirements
log "📦 Checking test requirements..."
if [[ -f "tests/requirements.txt" ]]; then
    success "Found tests/requirements.txt"
    
    # Check for essential packages
    essential_packages=("pytest" "requests" "psycopg2-binary" "pymysql" "snowflake-connector-python")
    for package in "${essential_packages[@]}"; do
        if grep -q "$package" tests/requirements.txt; then
            success "Requirements include $package"
        else
            warning "Requirements missing $package"
        fi
    done
else
    error "Missing tests/requirements.txt"
    all_dockerfiles_exist=false
fi

# Check README
log "📖 Checking README..."
if [[ -f "README.md" ]]; then
    success "Found README.md"
    
    # Check if all databases are documented
    documented_dbs=0
    for db in "${DATABASES[@]}"; do
        if grep -qi "$db" README.md; then
            documented_dbs=$((documented_dbs + 1))
        fi
    done
    
    if [[ $documented_dbs -eq ${#DATABASES[@]} ]]; then
        success "All databases documented in README"
    else
        warning "Some databases may be missing from README documentation"
    fi
else
    error "Missing README.md"
    all_dockerfiles_exist=false
fi

# Check Docker Compose development configuration
log "🐳 Checking Docker Compose development setup..."
if [[ -f "examples/docker-compose/docker-compose.dev.yml" ]]; then
    success "Found development Docker Compose file"
else
    warning "Missing examples/docker-compose/docker-compose.dev.yml"
fi

# Summary
log "📊 Validation Summary:"

if $all_dockerfiles_exist; then
    success "All critical files and configurations are present!"
    log "🚀 Your MCP Database Servers setup appears to be complete and ready for use."
    
    echo ""
    log "📋 Supported databases:"
    for db in "${DATABASES[@]}"; do
        echo "  • $db"
    done
    
    echo ""
    log "🎯 Next steps:"
    echo "  1. Build images: ./build.sh build"
    echo "  2. Test setup: ./tests/run_tests.sh test-quick"
    echo "  3. Push to registry: ./build.sh push"
    
    exit 0
else
    error "Validation failed! Please fix the issues above before proceeding."
    exit 1
fi