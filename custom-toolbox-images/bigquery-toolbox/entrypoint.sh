#!/bin/bash

# Custom entrypoint for Google AI Toolbox with environment variable authentication
# This script handles Google Cloud service account credentials passed via environment variables

set -euo pipefail

# Constants
readonly TEMP_SA_FILE="/tmp/sa.json"
readonly ORIGINAL_ENTRYPOINT="/toolbox"

# Function to log messages with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

# Function to cleanup temporary files
cleanup() {
    if [[ -f "$TEMP_SA_FILE" ]]; then
        log "Cleaning up temporary service account file"
        rm -f "$TEMP_SA_FILE"
    fi
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

# Function to validate JSON format (basic check)
validate_json() {
    local json_content="$1"
    # Basic check for JSON structure - starts with { and ends with }
    if [[ "$json_content" =~ ^\{.*\}$ ]]; then
        return 0
    else
        log "ERROR: Invalid JSON format in GOOGLE_SERVICE_ACCOUNT_JSON - must be a JSON object"
        return 1
    fi
}

# Function to setup Google Cloud credentials
setup_credentials() {
    if [[ -n "${GOOGLE_SERVICE_ACCOUNT_JSON:-}" ]]; then
        log "Setting up Google Cloud credentials from environment variable"
        
        # Validate JSON format
        if ! validate_json "$GOOGLE_SERVICE_ACCOUNT_JSON"; then
            log "ERROR: Failed to validate service account JSON"
            exit 1
        fi
        
        # Write JSON to temporary file with restrictive permissions
        echo "$GOOGLE_SERVICE_ACCOUNT_JSON" > "$TEMP_SA_FILE"
        
        # Set restrictive permissions (readable only by owner)
        chmod 600 "$TEMP_SA_FILE"
        
        # Set the Google Application Credentials environment variable
        export GOOGLE_APPLICATION_CREDENTIALS="$TEMP_SA_FILE"
        
        log "Google Cloud credentials configured successfully"
        log "GOOGLE_APPLICATION_CREDENTIALS set to: $GOOGLE_APPLICATION_CREDENTIALS"
    else
        log "No GOOGLE_SERVICE_ACCOUNT_JSON environment variable found"
        log "Proceeding with existing authentication configuration"
        
        # Check if GOOGLE_APPLICATION_CREDENTIALS is already set
        if [[ -n "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]]; then
            log "Using existing GOOGLE_APPLICATION_CREDENTIALS: $GOOGLE_APPLICATION_CREDENTIALS"
        else
            log "No Google Cloud credentials configured - relying on default authentication"
        fi
    fi
}

# Function to check if original toolbox exists
check_original_toolbox() {
    if [[ ! -x "$ORIGINAL_ENTRYPOINT" ]]; then
        log "ERROR: Original toolbox entrypoint not found at $ORIGINAL_ENTRYPOINT"
        exit 1
    fi
}

# Main execution
main() {
    log "Starting custom BigQuery Toolbox entrypoint"
    
    # Check if original toolbox exists
    check_original_toolbox
    
    # Setup Google Cloud credentials if provided
    setup_credentials
    
    # Execute the original toolbox with BigQuery prebuilt and passed arguments
    log "Executing BigQuery toolbox with arguments: $*"
    exec "$ORIGINAL_ENTRYPOINT" "--prebuilt" "bigquery" "$@"
}

# Handle edge cases
handle_errors() {
    local exit_code=$?
    log "ERROR: Script failed with exit code $exit_code"
    cleanup
    exit $exit_code
}

# Set error trap
trap handle_errors ERR

# Execute main function
main "$@"