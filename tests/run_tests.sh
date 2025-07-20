#!/bin/bash

# MCP Database Server Test Runner
# This script runs tests for the MCP database servers

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_ROOT/examples/docker-compose/docker-compose.dev.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
MCP Database Server Test Runner

Usage: $0 [OPTIONS] [COMMAND]

Commands:
    setup       Set up test environment
    test        Run all tests (default)
    test-quick  Run quick tests only
    test-db     Run database-specific tests
    test-integration  Run integration tests only
    clean       Clean up test environment
    logs        Show test logs
    report      Open test report in browser
    help        Show this help message

Options:
    -d, --database DATABASE    Run tests for specific database (postgres|mysql|all)
    -m, --marker MARKER        Run tests with specific pytest marker
    -v, --verbose              Verbose output
    -k, --keyword KEYWORD      Run tests matching keyword
    --no-build                 Don't rebuild images before testing
    --keep-running             Keep containers running after tests
    --html-report              Generate HTML test report

Examples:
    $0 setup                           # Set up test environment
    $0 test                           # Run all tests
    $0 test-quick -d postgres         # Run quick PostgreSQL tests
    $0 test -m integration            # Run integration tests only
    $0 test -k "test_health"          # Run health check tests
    $0 clean                          # Clean up environment

Environment Variables:
    TEST_TIMEOUT       Test timeout in seconds (default: 300)
    KEEP_CONTAINERS    Keep containers running after tests (true/false)
    BUILD_IMAGES       Build images before testing (true/false)

EOF
}

wait_for_services() {
    log "Waiting for services to be ready..."
    
    local max_attempts=60
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -f -s http://localhost:5000/health >/dev/null 2>&1 && \
           curl -f -s http://localhost:5001/health >/dev/null 2>&1; then
            success "All MCP services are ready"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo -n "."
        sleep 5
    done
    
    error "Services failed to start within timeout"
}

setup_environment() {
    log "Setting up test environment..."
    
    # Change to project root
    cd "$PROJECT_ROOT"
    
    # Build images if requested
    if [[ "${BUILD_IMAGES:-true}" == "true" ]]; then
        log "Building MCP server images..."
        ./build.sh build-db -d postgres --no-cache
        ./build.sh build-db -d mysql --no-cache
    fi
    
    # Start services
    log "Starting test environment..."
    docker-compose -f "$COMPOSE_FILE" up -d postgres pgadmin mysql phpmyadmin mcp-postgres mcp-mysql
    
    # Wait for services
    wait_for_services
    
    success "Test environment is ready"
    log "Services available at:"
    log "  PostgreSQL MCP: http://localhost:5000"
    log "  MySQL MCP: http://localhost:5001"
    log "  pgAdmin: http://localhost:8080 (admin@mcp.dev / admin123)"
    log "  phpMyAdmin: http://localhost:8081"
}

run_tests() {
    local test_args="$1"
    local pytest_args="$2"
    
    log "Running tests with args: $test_args"
    
    # Ensure test environment is running
    if ! curl -f -s http://localhost:5000/health >/dev/null 2>&1; then
        warning "Test environment not running, setting up..."
        setup_environment
    fi
    
    # Run tests in container
    docker-compose -f "$COMPOSE_FILE" run --rm \
        -e POSTGRES_MCP_URL=http://mcp-postgres:5000 \
        -e MYSQL_MCP_URL=http://mcp-mysql:5001 \
        -e TEST_TIMEOUT="${TEST_TIMEOUT:-300}" \
        mcp-tester \
        python -m pytest /app/tests $test_args $pytest_args
}

cleanup_environment() {
    log "Cleaning up test environment..."
    
    cd "$PROJECT_ROOT"
    docker-compose -f "$COMPOSE_FILE" down -v
    
    # Clean up test results
    docker volume rm $(docker volume ls -q | grep "docker-compose_test_results") 2>/dev/null || true
    
    success "Test environment cleaned up"
}

show_logs() {
    log "Showing test logs..."
    
    cd "$PROJECT_ROOT"
    docker-compose -f "$COMPOSE_FILE" logs mcp-postgres mcp-mysql mcp-tester
}

open_report() {
    log "Opening test report..."
    
    # Start test viewer if not running
    cd "$PROJECT_ROOT"
    docker-compose -f "$COMPOSE_FILE" up -d test-viewer
    
    log "Test report available at: http://localhost:8082"
    
    # Try to open in browser (Linux/macOS)
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open http://localhost:8082
    elif command -v open >/dev/null 2>&1; then
        open http://localhost:8082
    else
        log "Please open http://localhost:8082 in your browser"
    fi
}

# Parse command line arguments
COMMAND=""
DATABASE="all"
MARKER=""
VERBOSE=""
KEYWORD=""
BUILD_IMAGES="true"
KEEP_RUNNING="false"
HTML_REPORT="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--database)
            DATABASE="$2"
            shift 2
            ;;
        -m|--marker)
            MARKER="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        -k|--keyword)
            KEYWORD="$2"
            shift 2
            ;;
        --no-build)
            BUILD_IMAGES="false"
            shift
            ;;
        --keep-running)
            KEEP_RUNNING="true"
            shift
            ;;
        --html-report)
            HTML_REPORT="true"
            shift
            ;;
        setup|test|test-quick|test-db|test-integration|clean|logs|report|help)
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
    COMMAND="test"
fi

# Build pytest arguments
PYTEST_ARGS=""
if [[ -n "$VERBOSE" ]]; then
    PYTEST_ARGS="$PYTEST_ARGS $VERBOSE"
fi
if [[ -n "$MARKER" ]]; then
    PYTEST_ARGS="$PYTEST_ARGS -m $MARKER"
fi
if [[ -n "$KEYWORD" ]]; then
    PYTEST_ARGS="$PYTEST_ARGS -k $KEYWORD"
fi
if [[ "$HTML_REPORT" == "true" ]]; then
    PYTEST_ARGS="$PYTEST_ARGS --html=/app/results/report.html --self-contained-html"
fi

# Export environment variables
export BUILD_IMAGES
export KEEP_CONTAINERS="$KEEP_RUNNING"

# Execute command
case $COMMAND in
    help)
        show_help
        ;;
    setup)
        setup_environment
        ;;
    test)
        if [[ "$DATABASE" != "all" ]]; then
            run_tests "-m $DATABASE" "$PYTEST_ARGS"
        else
            run_tests "" "$PYTEST_ARGS"
        fi
        ;;
    test-quick)
        if [[ "$DATABASE" != "all" ]]; then
            run_tests "-m $DATABASE and not slow" "$PYTEST_ARGS"
        else
            run_tests "-m 'not slow'" "$PYTEST_ARGS"
        fi
        ;;
    test-db)
        if [[ "$DATABASE" == "all" ]]; then
            error "Please specify a database with -d option for test-db command"
        fi
        run_tests "-m $DATABASE" "$PYTEST_ARGS"
        ;;
    test-integration)
        run_tests "-m integration" "$PYTEST_ARGS"
        ;;
    clean)
        cleanup_environment
        ;;
    logs)
        show_logs
        ;;
    report)
        open_report
        ;;
    *)
        error "Unknown command: $COMMAND"
        ;;
esac

# Cleanup if requested
if [[ "$KEEP_RUNNING" != "true" && "$COMMAND" =~ ^test ]]; then
    log "Cleaning up test environment..."
    cleanup_environment
fi

success "Test execution completed"