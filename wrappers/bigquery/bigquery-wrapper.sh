#!/bin/bash
set -e

# BigQuery MCP wrapper script
# This script converts BigQuery credentials from environment variables to temporary files
# and launches the original MCP container with proper volume mounts

# Source the generic wrapper functions
source /wrapper-entrypoint.sh

# BigQuery-specific main function
main() {
    log "Starting BigQuery MCP wrapper..."
    
    # Define required environment variables for BigQuery
    local required_vars=(
        "BIGQUERY_PROJECT"
    )
    
    # Optional environment variables (will be passed if present)
    local optional_vars=(
        "BIGQUERY_DATASET"
        "BIGQUERY_LOCATION"
    )
    
    # Validate required environment variables
    validate_env_vars "${required_vars[@]}"
    
    # Handle credentials - either from JSON env var or pre-existing file
    if [[ -n "${BIGQUERY_CREDENTIALS_JSON_PATH:-}" && -f "$BIGQUERY_CREDENTIALS_JSON_PATH" ]]; then
        log "Using pre-existing credentials file: $BIGQUERY_CREDENTIALS_JSON_PATH"
        # Copy credentials to shared /host-tmp so Docker-in-Docker can access it
        local creds_filename="bigquery-creds-$$.json"
        TEMP_CREDS_FILE="/host-tmp/$creds_filename"
        cp "$BIGQUERY_CREDENTIALS_JSON_PATH" "$TEMP_CREDS_FILE"
        chmod 600 "$TEMP_CREDS_FILE"
        log "Copied credentials to shared temp location: $TEMP_CREDS_FILE"
        # For Docker-in-Docker, we need to use the host path (/tmp not /host-tmp)
        TEMP_CREDS_FILE="/tmp/$creds_filename"
    elif [[ -n "${BIGQUERY_CREDENTIALS_JSON:-}" ]]; then
        log "Creating credentials file from BIGQUERY_CREDENTIALS_JSON environment variable"
        create_temp_credentials "BIGQUERY_CREDENTIALS_JSON"
    else
        log "ERROR: Either BIGQUERY_CREDENTIALS_JSON or BIGQUERY_CREDENTIALS_JSON_PATH must be provided"
        exit 1
    fi
    
    # Build environment variables to pass to container
    local container_env_vars=(
        "BIGQUERY_PROJECT=$BIGQUERY_PROJECT"
    )
    
    # Add optional environment variables if they exist
    for var in "${optional_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            container_env_vars+=("$var=${!var}")
        fi
    done
    
    # Launch the container with BigQuery-specific configuration
    launch_container "bigquery" \
        "${container_env_vars[@]}" \
        "--prebuilt" "bigquery" \
        "--stdio"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi