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
        "bigquery")
            [[ -z "${BIGQUERY_PROJECT_ID:-}" ]] && missing_vars+=("BIGQUERY_PROJECT_ID")
            [[ -z "${BIGQUERY_DATASET:-}" ]] && missing_vars+=("BIGQUERY_DATASET")
            ;;
        "alloydb")
            [[ -z "${ALLOYDB_PROJECT_ID:-}" ]] && missing_vars+=("ALLOYDB_PROJECT_ID")
            [[ -z "${ALLOYDB_REGION:-}" ]] && missing_vars+=("ALLOYDB_REGION")
            [[ -z "${ALLOYDB_CLUSTER:-}" ]] && missing_vars+=("ALLOYDB_CLUSTER")
            [[ -z "${ALLOYDB_INSTANCE:-}" ]] && missing_vars+=("ALLOYDB_INSTANCE")
            [[ -z "${ALLOYDB_DATABASE:-}" ]] && missing_vars+=("ALLOYDB_DATABASE")
            [[ -z "${ALLOYDB_USER:-}" ]] && missing_vars+=("ALLOYDB_USER")
            [[ -z "${ALLOYDB_PASSWORD:-}" ]] && missing_vars+=("ALLOYDB_PASSWORD")
            ;;
        "spanner")
            [[ -z "${SPANNER_PROJECT_ID:-}" ]] && missing_vars+=("SPANNER_PROJECT_ID")
            [[ -z "${SPANNER_INSTANCE_ID:-}" ]] && missing_vars+=("SPANNER_INSTANCE_ID")
            [[ -z "${SPANNER_DATABASE_ID:-}" ]] && missing_vars+=("SPANNER_DATABASE_ID")
            ;;
        "neo4j")
            [[ -z "${NEO4J_URI:-}" ]] && missing_vars+=("NEO4J_URI")
            [[ -z "${NEO4J_USER:-}" ]] && missing_vars+=("NEO4J_USER")
            [[ -z "${NEO4J_PASSWORD:-}" ]] && missing_vars+=("NEO4J_PASSWORD")
            ;;
        "sqlite")
            [[ -z "${SQLITE_PATH:-}" ]] && missing_vars+=("SQLITE_PATH")
            ;;
        "redis")
            [[ -z "${REDIS_HOST:-}" ]] && missing_vars+=("REDIS_HOST")
            [[ -z "${REDIS_PORT:-}" ]] && missing_vars+=("REDIS_PORT")
            ;;
        "sqlserver")
            [[ -z "${SQLSERVER_HOST:-}" ]] && missing_vars+=("SQLSERVER_HOST")
            [[ -z "${SQLSERVER_DATABASE:-}" ]] && missing_vars+=("SQLSERVER_DATABASE")
            [[ -z "${SQLSERVER_USER:-}" ]] && missing_vars+=("SQLSERVER_USER")
            [[ -z "${SQLSERVER_PASSWORD:-}" ]] && missing_vars+=("SQLSERVER_PASSWORD")
            ;;
        "firestore")
            [[ -z "${FIRESTORE_PROJECT_ID:-}" ]] && missing_vars+=("FIRESTORE_PROJECT_ID")
            ;;
        "supabase")
            [[ -z "${SUPABASE_URL:-}" ]] && missing_vars+=("SUPABASE_URL")
            [[ -z "${SUPABASE_KEY:-}" ]] && missing_vars+=("SUPABASE_KEY")
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
            
        "bigquery")
            cat > "${config_file}" << EOF
sources:
  primary-db:
    kind: bigquery
    project: ${BIGQUERY_PROJECT_ID}
    dataset: ${BIGQUERY_DATASET}
    location: ${BIGQUERY_LOCATION:-US}

tools:
  execute-sql:
    kind: bigquery-execute-sql
    source: primary-db
    description: Execute SQL queries against the BigQuery dataset
    parameters:
      - name: query
        type: string
        description: The SQL query to execute
  
  get-table-info:
    kind: bigquery-get-table-info
    source: primary-db
    description: Get information about a BigQuery table
    parameters:
      - name: table_id
        type: string
        description: The table ID to get information about

toolsets:
  default:
    - execute-sql
    - get-table-info
EOF
            ;;
            
        "alloydb")
            cat > "${config_file}" << EOF
sources:
  primary-db:
    kind: alloydb-postgres
    project: ${ALLOYDB_PROJECT_ID}
    region: ${ALLOYDB_REGION}
    cluster: ${ALLOYDB_CLUSTER}
    instance: ${ALLOYDB_INSTANCE}
    database: ${ALLOYDB_DATABASE}
    user: ${ALLOYDB_USER}
    password: ${ALLOYDB_PASSWORD}

tools:
  execute-sql:
    kind: postgres-execute-sql
    source: primary-db
    description: Execute SQL queries against the AlloyDB database
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
            
        "spanner")
            cat > "${config_file}" << EOF
sources:
  primary-db:
    kind: spanner
    project: ${SPANNER_PROJECT_ID}
    instance: ${SPANNER_INSTANCE_ID}
    database: ${SPANNER_DATABASE_ID}

tools:
  execute-sql:
    kind: spanner-execute-sql
    source: primary-db
    description: Execute SQL queries against the Spanner database
    parameters:
      - name: query
        type: string
        description: The SQL query to execute
  
  sql:
    kind: spanner-sql
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
            
        "neo4j")
            cat > "${config_file}" << EOF
sources:
  primary-db:
    kind: neo4j
    uri: ${NEO4J_URI}
    user: ${NEO4J_USER}
    password: ${NEO4J_PASSWORD}
    database: ${NEO4J_DATABASE:-neo4j}

tools:
  execute-cypher:
    kind: neo4j-cypher
    source: primary-db
    description: Execute Cypher queries against the Neo4j database
    parameters:
      - name: query
        type: string
        description: The Cypher query to execute

toolsets:
  default:
    - execute-cypher
EOF
            ;;
            
        "sqlite")
            cat > "${config_file}" << EOF
sources:
  primary-db:
    kind: sqlite
    path: ${SQLITE_PATH}

tools:
  execute-sql:
    kind: sqlite-sql
    source: primary-db
    description: Execute SQL queries against the SQLite database
    parameters:
      - name: query
        type: string
        description: The SQL query to execute

toolsets:
  default:
    - execute-sql
EOF
            ;;
            
        "redis")
            cat > "${config_file}" << EOF
sources:
  primary-db:
    kind: redis
    host: ${REDIS_HOST}
    port: ${REDIS_PORT:-6379}
    password: ${REDIS_PASSWORD:-}
    database: ${REDIS_DATABASE:-0}

tools:
  redis-command:
    kind: redis
    source: primary-db
    description: Execute Redis commands
    parameters:
      - name: command
        type: string
        description: The Redis command to execute

toolsets:
  default:
    - redis-command
EOF
            ;;
            
        "sqlserver")
            cat > "${config_file}" << EOF
sources:
  primary-db:
    kind: sqlserver
    host: ${SQLSERVER_HOST}
    port: ${SQLSERVER_PORT:-1433}
    database: ${SQLSERVER_DATABASE}
    user: ${SQLSERVER_USER}
    password: ${SQLSERVER_PASSWORD}
    encrypt: ${SQLSERVER_ENCRYPT:-true}

tools:
  execute-sql:
    kind: mssql-execute-sql
    source: primary-db
    description: Execute SQL queries against the SQL Server database
    parameters:
      - name: query
        type: string
        description: The SQL query to execute
  
  sql:
    kind: mssql-sql
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
            
        "firestore")
            cat > "${config_file}" << EOF
sources:
  primary-db:
    kind: firestore
    project: ${FIRESTORE_PROJECT_ID}

tools:
  get-documents:
    kind: firestore-get-documents
    source: primary-db
    description: Get documents from a Firestore collection
    parameters:
      - name: collection
        type: string
        description: The collection name to query
      - name: limit
        type: number
        description: Maximum number of documents to return
        required: false
  
  list-collections:
    kind: firestore-list-collections
    source: primary-db
    description: List collections in the Firestore database

toolsets:
  default:
    - get-documents
    - list-collections
EOF
            ;;
            
        "supabase")
            cat > "${config_file}" << EOF
sources:
  primary-db:
    kind: postgres
    host: ${SUPABASE_HOST:-${SUPABASE_URL#*://}}
    port: ${SUPABASE_PORT:-5432}
    database: ${SUPABASE_DATABASE:-postgres}
    user: ${SUPABASE_USER:-postgres}
    password: ${SUPABASE_PASSWORD}
    ssl_mode: ${SUPABASE_SSL_MODE:-require}

tools:
  execute-sql:
    kind: postgres-execute-sql
    source: primary-db
    description: Execute SQL queries against the Supabase database
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