#!/bin/bash
set -e

# Generic MCP database wrapper script
# This script converts credentials from environment variables to temporary files
# and launches the original MCP container with proper volume mounts

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

# Function to clean up temporary files
cleanup() {
    if [[ -n "$TEMP_CREDS_FILE" && -f "$TEMP_CREDS_FILE" ]]; then
        log "Cleaning up temporary credentials file: $TEMP_CREDS_FILE"
        rm -f "$TEMP_CREDS_FILE"
    fi
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

# Validate required environment variables
validate_env_vars() {
    local missing_vars=()
    
    for var in "$@"; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log "ERROR: Missing required environment variables: ${missing_vars[*]}"
        exit 1
    fi
}

# Create temporary credentials file from JSON environment variable
create_temp_credentials() {
    local creds_json_var="$1"
    local creds_json="${!creds_json_var:-}"
    
    if [[ -z "$creds_json" ]]; then
        log "ERROR: Credentials JSON variable $creds_json_var is empty"
        exit 1
    fi
    
    # Validate JSON format
    if ! echo "$creds_json" | jq . > /dev/null 2>&1; then
        log "ERROR: Invalid JSON format in $creds_json_var"
        exit 1
    fi
    
    # Create temporary file
    TEMP_CREDS_FILE=$(mktemp --suffix=.json)
    log "Creating temporary credentials file: $TEMP_CREDS_FILE"
    
    # Write credentials to temporary file
    echo "$creds_json" > "$TEMP_CREDS_FILE"
    chmod 600 "$TEMP_CREDS_FILE"  # Secure permissions
}

# Launch the original container with proper mounts and environment
launch_container() {
    local database_type="$1"
    shift  # Remove first argument, rest are additional docker args
    
    local docker_image="${DOCKER_IMAGE:-us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest}"
    local container_creds_path="/creds/sa.json"
    
    # Build docker command
    local docker_args=(
        "docker" "run" "--rm" "-i"
        "--name" "mcp-${database_type}-wrapper"
    )
    
    # Add volume mount for credentials
    docker_args+=(
        "-v" "$TEMP_CREDS_FILE:$container_creds_path:ro"
        "-e" "GOOGLE_APPLICATION_CREDENTIALS=$container_creds_path"
    )
    
    # Separate environment variables from Docker image arguments
    local image_args=()
    for env_var in "$@"; do
        if [[ "$env_var" =~ ^[A-Z_]+=.* ]]; then
            docker_args+=("-e" "$env_var")
        else
            image_args+=("$env_var")
        fi
    done
    
    # Add the base image
    docker_args+=("$docker_image")
    
    # Add arguments that go after the image (like --prebuilt, --stdio)
    docker_args+=("${image_args[@]}")
    
    log "Launching container with command: ${docker_args[*]}"
    exec "${docker_args[@]}"
}

# Main function - to be customized per database type
main() {
    log "ERROR: This is a generic wrapper script. Database-specific wrapper should override main() function."
    exit 1
}

# Check if we're being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi