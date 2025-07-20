#!/bin/bash
set -e

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to validate required environment variables
validate_env() {
    local missing_vars=()
    
    # Check for database type
    if [[ -z "${DB_TYPE:-}" ]]; then
        missing_vars+=("DB_TYPE")
    fi
    
    # Validate based on database type
    case "${DB_TYPE}" in
        "postgres")
            [[ -z "${DB_HOST:-}" ]] && missing_vars+=("DB_HOST")
            [[ -z "${DB_NAME:-}" ]] && missing_vars+=("DB_NAME")
            [[ -z "${DB_USER:-}" ]] && missing_vars+=("DB_USER")
            [[ -z "${DB_PASSWORD:-}" ]] && missing_vars+=("DB_PASSWORD")
            ;;
        "mysql")
            [[ -z "${DB_HOST:-}" ]] && missing_vars+=("DB_HOST")
            [[ -z "${DB_NAME:-}" ]] && missing_vars+=("DB_NAME")
            [[ -z "${DB_USER:-}" ]] && missing_vars+=("DB_USER")
            [[ -z "${DB_PASSWORD:-}" ]] && missing_vars+=("DB_PASSWORD")
            ;;
        "snowflake")
            [[ -z "${SNOWFLAKE_ACCOUNT:-}" ]] && missing_vars+=("SNOWFLAKE_ACCOUNT")
            [[ -z "${SNOWFLAKE_USER:-}" ]] && missing_vars+=("SNOWFLAKE_USER")
            [[ -z "${SNOWFLAKE_PASSWORD:-}" ]] && missing_vars+=("SNOWFLAKE_PASSWORD")
            [[ -z "${SNOWFLAKE_DATABASE:-}" ]] && missing_vars+=("SNOWFLAKE_DATABASE")
            [[ -z "${SNOWFLAKE_WAREHOUSE:-}" ]] && missing_vars+=("SNOWFLAKE_WAREHOUSE")
            ;;
        "redshift")
            [[ -z "${REDSHIFT_HOST:-}" ]] && missing_vars+=("REDSHIFT_HOST")
            [[ -z "${REDSHIFT_DATABASE:-}" ]] && missing_vars+=("REDSHIFT_DATABASE")
            [[ -z "${REDSHIFT_USER:-}" ]] && missing_vars+=("REDSHIFT_USER")
            [[ -z "${REDSHIFT_PASSWORD:-}" ]] && missing_vars+=("REDSHIFT_PASSWORD")
            ;;
        *)
            log "ERROR: Unsupported DB_TYPE: ${DB_TYPE}"
            exit 1
            ;;
    esac
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log "ERROR: Missing required environment variables: ${missing_vars[*]}"
        exit 1
    fi
}

# Function to generate tools.yaml configuration
generate_config() {
    local config_file="/app/config/tools.yaml"
    
    log "Generating configuration for ${DB_TYPE}..."
    
    case "${DB_TYPE}" in
        "postgres")
            cat > "${config_file}" << EOF
sources:
  primary-db:
    kind: postgres
    host: ${DB_HOST}
    port: ${DB_PORT:-5432}
    database: ${DB_NAME}
    user: ${DB_USER}
    password: ${DB_PASSWORD}
    ssl_mode: ${DB_SSL_MODE:-prefer}

tools:
  execute-sql:
    kind: postgres-execute-sql
    source: primary-db
    description: Execute SQL queries against the PostgreSQL database
    parameters:
      - name: query
        type: string
        description: The SQL query to execute
  
  sql:
    kind: postgres-sql
    source: primary-db
    description: Execute parameterized SQL queries
    parameters:
      - name: query
        type: string
        description: The SQL query with parameter placeholders
      - name: parameters
        type: array
        description: Parameters for the SQL query
        required: false

toolsets:
  default:
    - execute-sql
    - sql
EOF
            ;;
            
        "mysql")
            cat > "${config_file}" << EOF
sources:
  primary-db:
    kind: mysql
    host: ${DB_HOST}
    port: ${DB_PORT:-3306}
    database: ${DB_NAME}
    user: ${DB_USER}
    password: ${DB_PASSWORD}
    charset: ${DB_CHARSET:-utf8mb4}

tools:
  execute-sql:
    kind: mysql-execute-sql
    source: primary-db
    description: Execute SQL queries against the MySQL database
    parameters:
      - name: query
        type: string
        description: The SQL query to execute
  
  sql:
    kind: mysql-sql
    source: primary-db
    description: Execute parameterized SQL queries
    parameters:
      - name: query
        type: string
        description: The SQL query with parameter placeholders
      - name: parameters
        type: array
        description: Parameters for the SQL query
        required: false

toolsets:
  default:
    - execute-sql
    - sql
EOF
            ;;
            
        "snowflake")
            cat > "${config_file}" << EOF
sources:
  primary-db:
    kind: snowflake
    account: ${SNOWFLAKE_ACCOUNT}
    user: ${SNOWFLAKE_USER}
    password: ${SNOWFLAKE_PASSWORD}
    database: ${SNOWFLAKE_DATABASE}
    schema: ${SNOWFLAKE_SCHEMA:-PUBLIC}
    warehouse: ${SNOWFLAKE_WAREHOUSE}
    role: ${SNOWFLAKE_ROLE:-}

tools:
  execute-sql:
    kind: snowflake-sql
    source: primary-db
    description: Execute SQL queries against the Snowflake database
    parameters:
      - name: query
        type: string
        description: The SQL query to execute

toolsets:
  default:
    - execute-sql
EOF
            ;;
            
        "redshift")
            cat > "${config_file}" << EOF
sources:
  primary-db:
    kind: redshift
    host: ${REDSHIFT_HOST}
    port: ${REDSHIFT_PORT:-5439}
    database: ${REDSHIFT_DATABASE}
    user: ${REDSHIFT_USER}
    password: ${REDSHIFT_PASSWORD}
    ssl: ${REDSHIFT_SSL:-true}

tools:
  execute-sql:
    kind: postgres-execute-sql
    source: primary-db
    description: Execute SQL queries against the Redshift database
    parameters:
      - name: query
        type: string
        description: The SQL query to execute
  
  sql:
    kind: postgres-sql
    source: primary-db
    description: Execute parameterized SQL queries
    parameters:
      - name: query
        type: string
        description: The SQL query with parameter placeholders
      - name: parameters
        type: array
        description: Parameters for the SQL query
        required: false

toolsets:
  default:
    - execute-sql
    - sql
EOF
            ;;
    esac
    
    log "Configuration generated successfully"
}

# Function to test database connection
test_connection() {
    log "Testing database connection..."
    
    # Use a simple timeout for connection test
    timeout 10 /app/toolbox --tools-file /app/config/tools.yaml --test-connection 2>/dev/null || {
        log "WARNING: Database connection test failed, but continuing startup..."
    }
}

# Main execution
main() {
    log "Starting MCP Toolbox for ${DB_TYPE:-unknown}"
    
    # Validate environment variables
    validate_env
    
    # Generate configuration
    generate_config
    
    # Test connection (non-blocking)
    test_connection
    
    # Set default arguments if none provided
    if [[ $# -eq 0 ]]; then
        set -- "--tools-file" "/app/config/tools.yaml"
    fi
    
    # Add stdio flag if requested
    if [[ "${ENABLE_STDIO:-}" == "true" ]]; then
        set -- "$@" "--stdio"
    fi
    
    # Add port configuration
    if [[ "${ENABLE_STDIO:-}" != "true" ]]; then
        set -- "$@" "--port" "${TOOLBOX_PORT:-5000}"
    fi
    
    # Add log level
    set -- "$@" "--log-level" "${TOOLBOX_LOG_LEVEL:-info}"
    
    log "Starting toolbox with arguments: $*"
    
    # Execute the toolbox with provided arguments
    exec /app/toolbox "$@"
}

# Run main function with all arguments
main "$@"