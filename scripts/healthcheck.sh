#!/bin/bash
set -e

# Health check script for MCP Toolbox
# This script verifies that the MCP server is healthy and responsive

HEALTH_CHECK_URL="http://localhost:${TOOLBOX_PORT:-5000}/health"
TIMEOUT="${TOOLBOX_HEALTH_CHECK_TIMEOUT:-30s}"

# Function to log messages
log() {
    echo "[HEALTH] $1" >&2
}

# Function to check if running in stdio mode
is_stdio_mode() {
    [[ "${ENABLE_STDIO:-}" == "true" ]]
}

# Function to check HTTP endpoint
check_http_health() {
    local url="$1"
    local timeout="$2"
    
    if command -v curl >/dev/null 2>&1; then
        curl -f -s --max-time "${timeout%s}" "$url" >/dev/null 2>&1
    elif command -v wget >/dev/null 2>&1; then
        wget -q -T "${timeout%s}" -O /dev/null "$url" >/dev/null 2>&1
    else
        log "ERROR: Neither curl nor wget available for health check"
        return 1
    fi
}

# Function to check if process is running
check_process() {
    pgrep -f "toolbox" >/dev/null 2>&1
}

# Function to check MCP endpoints
check_mcp_endpoints() {
    local base_url="http://localhost:${TOOLBOX_PORT:-5000}"
    
    # Check if MCP HTTP endpoint is accessible
    if check_http_health "${base_url}/mcp" "5s"; then
        return 0
    fi
    
    # Fallback: check if any HTTP endpoint is responding
    if check_http_health "$base_url" "5s"; then
        return 0
    fi
    
    return 1
}

# Function to perform stdio health check
check_stdio_health() {
    # In stdio mode, we can only check if the process is running
    if check_process; then
        log "Process is running in stdio mode"
        return 0
    else
        log "Process not found"
        return 1
    fi
}

# Function to perform HTTP health check
check_http_health_full() {
    # Check if process is running
    if ! check_process; then
        log "Toolbox process not running"
        return 1
    fi
    
    # Check if HTTP endpoints are accessible
    if check_mcp_endpoints; then
        log "HTTP endpoints are healthy"
        return 0
    else
        log "HTTP endpoints not responding"
        return 1
    fi
}

# Main health check logic
main() {
    if is_stdio_mode; then
        check_stdio_health
    else
        check_http_health_full
    fi
}

# Execute health check
if main; then
    log "Health check passed"
    exit 0
else
    log "Health check failed"
    exit 1
fi