# MCP Database Server Docker Images

[![CI/CD Pipeline](https://github.com/your-username/mcp-database-servers/actions/workflows/ci.yml/badge.svg)](https://github.com/your-username/mcp-database-servers/actions/workflows/ci.yml)
[![Security Scan](https://github.com/your-username/mcp-database-servers/actions/workflows/security.yml/badge.svg)](https://github.com/your-username/mcp-database-servers/actions/workflows/security.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/toolbox-images/postgres)](https://hub.docker.com/r/toolbox-images/postgres)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub Release](https://img.shields.io/github/release/your-username/mcp-database-servers.svg)](https://github.com/your-username/mcp-database-servers/releases)

Production-ready Docker images that provide instant access to database systems through the **Model Context Protocol (MCP)**. These images enable AI agents and applications to seamlessly connect to **13 major database systems** including PostgreSQL, MySQL, Snowflake, BigQuery, AlloyDB, Spanner, Neo4j, SQLite, Redis, SQL Server, Firestore, Supabase, and Amazon Redshift with zero configuration overhead.

## ✨ Features

- 🚀 **Ready-to-Use**: Pre-built images available on Docker Hub
- 🔗 **Universal Interface**: Same API across all database types
- 🔐 **Secure**: Environment-based credential management
- 📊 **Complete Toolset**: Query execution, schema inspection, and database introspection
- 🐳 **Container Native**: Optimized for containerized environments
- 🌍 **Multi-Architecture**: Supports both AMD64 and ARM64 platforms
- 🛡️ **Production Ready**: Health checks, logging, and error handling included

## 📋 Supported Databases

| Database | Image Name | Default Port | Type | Status |
|----------|------------|--------------|------|--------|
| **Relational Databases** | | | | |
| PostgreSQL | `@toolbox-images/postgres` | 5000 | SQL | ✅ Ready |
| MySQL | `@toolbox-images/mysql` | 5000 | SQL | ✅ Ready |
| Microsoft SQL Server | `@toolbox-images/sqlserver` | 5000 | SQL | ✅ Ready |
| SQLite | `@toolbox-images/sqlite` | 5000 | SQL | ✅ Ready |
| **Cloud Databases** | | | | |
| Google BigQuery | `@toolbox-images/bigquery` | 5000 | Analytics | ✅ Ready |
| Google AlloyDB | `@toolbox-images/alloydb` | 5000 | SQL | ✅ Ready |
| Google Cloud Spanner | `@toolbox-images/spanner` | 5000 | SQL | ✅ Ready |
| Google Firestore | `@toolbox-images/firestore` | 5000 | NoSQL | ✅ Ready |
| Snowflake | `@toolbox-images/snowflake` | 5000 | Analytics | ✅ Ready |
| Amazon Redshift | `@toolbox-images/redshift` | 5000 | Analytics | ✅ Ready |
| Supabase | `@toolbox-images/supabase` | 5000 | SQL | ✅ Ready |
| **NoSQL & Graph** | | | | |
| Neo4j | `@toolbox-images/neo4j` | 5000 | Graph | ✅ Ready |
| Redis | `@toolbox-images/redis` | 5000 | Cache/NoSQL | ✅ Ready |

## 🚀 Quick Start

### Prerequisites

- Docker installed and running
- Access to a database instance
- Network connectivity between the container and your database

### Basic Usage

Each image can be run with a simple `docker run` command. The containers expose the MCP server on port 5000 by default and accept database connection parameters via environment variables.

```bash
# Generic pattern
docker run -d \
  --name mcp-{database} \
  -p 5000:5000 \
  -e [DATABASE_PARAMETERS] \
  @toolbox-images/{database}:latest
```

## 🗄️ Database-Specific Configuration

### PostgreSQL

Connect to PostgreSQL databases (including compatible databases like CockroachDB).

```bash
docker run -d \
  --name mcp-postgres \
  -p 5000:5000 \
  -e DB_HOST=your-postgres-host.com \
  -e DB_PORT=5432 \
  -e DB_NAME=your_database \
  -e DB_USER=your_username \
  -e DB_PASSWORD=your_password \
  -e DB_SSL_MODE=prefer \
  @toolbox-images/postgres:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `DB_HOST` | Database hostname | `localhost` or `db.example.com` |
| `DB_NAME` | Database name | `myapp_production` |
| `DB_USER` | Database username | `postgres` |
| `DB_PASSWORD` | Database password | `your_secure_password` |

#### Optional Environment Variables
| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `DB_PORT` | Database port | `5432` | Any valid port |
| `DB_SSL_MODE` | SSL mode | `prefer` | `disable`, `allow`, `prefer`, `require`, `verify-ca`, `verify-full` |

### MySQL

Connect to MySQL and MariaDB databases.

```bash
docker run -d \
  --name mcp-mysql \
  -p 5000:5000 \
  -e DB_HOST=your-mysql-host.com \
  -e DB_PORT=3306 \
  -e DB_NAME=your_database \
  -e DB_USER=your_username \
  -e DB_PASSWORD=your_password \
  @toolbox-images/mysql:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `DB_HOST` | Database hostname | `localhost` or `mysql.example.com` |
| `DB_NAME` | Database name | `myapp_production` |
| `DB_USER` | Database username | `root` or `app_user` |
| `DB_PASSWORD` | Database password | `your_secure_password` |

#### Optional Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `DB_PORT` | Database port | `3306` |
| `DB_CHARSET` | Connection charset | `utf8mb4` |

### Snowflake

Connect to Snowflake Data Cloud.

```bash
docker run -d \
  --name mcp-snowflake \
  -p 5000:5000 \
  -e SNOWFLAKE_ACCOUNT=your-account.snowflakecomputing.com \
  -e SNOWFLAKE_USER=your_username \
  -e SNOWFLAKE_PASSWORD=your_password \
  -e SNOWFLAKE_DATABASE=your_database \
  -e SNOWFLAKE_SCHEMA=PUBLIC \
  -e SNOWFLAKE_WAREHOUSE=your_warehouse \
  -e SNOWFLAKE_ROLE=your_role \
  @toolbox-images/snowflake:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `SNOWFLAKE_ACCOUNT` | Snowflake account URL | `abc12345.snowflakecomputing.com` |
| `SNOWFLAKE_USER` | Snowflake username | `john.doe@company.com` |
| `SNOWFLAKE_PASSWORD` | Snowflake password | `your_secure_password` |
| `SNOWFLAKE_DATABASE` | Database name | `ANALYTICS_DB` |
| `SNOWFLAKE_WAREHOUSE` | Compute warehouse | `COMPUTE_WH` |

#### Optional Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `SNOWFLAKE_SCHEMA` | Schema name | `PUBLIC` |
| `SNOWFLAKE_ROLE` | User role | User's default role |

### Amazon Redshift

Connect to Amazon Redshift data warehouse.

```bash
docker run -d \
  --name mcp-redshift \
  -p 5000:5000 \
  -e REDSHIFT_HOST=your-cluster.abc123.us-west-2.redshift.amazonaws.com \
  -e REDSHIFT_PORT=5439 \
  -e REDSHIFT_DATABASE=your_database \
  -e REDSHIFT_USER=your_username \
  -e REDSHIFT_PASSWORD=your_password \
  -e REDSHIFT_SSL_MODE=require \
  @toolbox-images/redshift:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `REDSHIFT_HOST` | Redshift cluster endpoint | `cluster.abc123.us-west-2.redshift.amazonaws.com` |
| `REDSHIFT_DATABASE` | Database name | `analytics` |
| `REDSHIFT_USER` | Database username | `admin` |
| `REDSHIFT_PASSWORD` | Database password | `your_secure_password` |

#### Optional Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `REDSHIFT_PORT` | Database port | `5439` |
| `REDSHIFT_SSL_MODE` | SSL mode | `require` |

### Microsoft SQL Server

Connect to Microsoft SQL Server databases.

```bash
docker run -d \
  --name mcp-sqlserver \
  -p 5000:5000 \
  -e SQLSERVER_HOST=your-sqlserver-host.com \
  -e SQLSERVER_PORT=1433 \
  -e SQLSERVER_DATABASE=your_database \
  -e SQLSERVER_USER=your_username \
  -e SQLSERVER_PASSWORD=your_password \
  -e SQLSERVER_ENCRYPT=true \
  -e SQLSERVER_TRUST_SERVER_CERTIFICATE=false \
  @toolbox-images/sqlserver:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `SQLSERVER_HOST` | SQL Server hostname | `localhost` or `sql.example.com` |
| `SQLSERVER_DATABASE` | Database name | `myapp_production` |
| `SQLSERVER_USER` | Database username | `sa` or `app_user` |
| `SQLSERVER_PASSWORD` | Database password | `your_secure_password` |

#### Optional Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `SQLSERVER_PORT` | Database port | `1433` |
| `SQLSERVER_ENCRYPT` | Enable encryption | `true` |
| `SQLSERVER_TRUST_SERVER_CERTIFICATE` | Trust server certificate | `false` |

### SQLite

Connect to SQLite database files.

```bash
docker run -d \
  --name mcp-sqlite \
  -p 5000:5000 \
  -e SQLITE_DATABASE_PATH=/data/database.db \
  -v /host/path/to/database:/data \
  @toolbox-images/sqlite:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `SQLITE_DATABASE_PATH` | Path to SQLite database file | `/data/database.db` |

#### Optional Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `SQLITE_READ_ONLY` | Open database in read-only mode | `false` |

### Google BigQuery

Connect to Google BigQuery using service account credentials.

```bash
docker run -d \
  --name mcp-bigquery \
  -p 5000:5000 \
  -e BIGQUERY_PROJECT_ID=your-project-id \
  -e BIGQUERY_DATASET_ID=your_dataset \
  -e GOOGLE_APPLICATION_CREDENTIALS=/credentials/service-account.json \
  -v /host/path/to/credentials:/credentials \
  @toolbox-images/bigquery:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `BIGQUERY_PROJECT_ID` | Google Cloud project ID | `my-analytics-project` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to service account JSON | `/credentials/service-account.json` |

#### Optional Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `BIGQUERY_DATASET_ID` | Default dataset ID | None |
| `BIGQUERY_LOCATION` | BigQuery location | `US` |

### Google AlloyDB

Connect to Google AlloyDB instances.

```bash
docker run -d \
  --name mcp-alloydb \
  -p 5000:5000 \
  -e ALLOYDB_INSTANCE=projects/your-project/locations/region/clusters/cluster-id/instances/instance-id \
  -e DB_NAME=your_database \
  -e DB_USER=your_username \
  -e DB_PASSWORD=your_password \
  -e GOOGLE_APPLICATION_CREDENTIALS=/credentials/service-account.json \
  -v /host/path/to/credentials:/credentials \
  @toolbox-images/alloydb:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `ALLOYDB_INSTANCE` | AlloyDB instance path | `projects/my-project/locations/us-central1/clusters/my-cluster/instances/my-instance` |
| `DB_NAME` | Database name | `myapp_production` |
| `DB_USER` | Database username | `postgres` |
| `DB_PASSWORD` | Database password | `your_secure_password` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to service account JSON | `/credentials/service-account.json` |

### Google Cloud Spanner

Connect to Google Cloud Spanner databases.

```bash
docker run -d \
  --name mcp-spanner \
  -p 5000:5000 \
  -e SPANNER_PROJECT_ID=your-project-id \
  -e SPANNER_INSTANCE_ID=your-instance-id \
  -e SPANNER_DATABASE_ID=your-database-id \
  -e GOOGLE_APPLICATION_CREDENTIALS=/credentials/service-account.json \
  -v /host/path/to/credentials:/credentials \
  @toolbox-images/spanner:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `SPANNER_PROJECT_ID` | Google Cloud project ID | `my-project` |
| `SPANNER_INSTANCE_ID` | Spanner instance ID | `my-instance` |
| `SPANNER_DATABASE_ID` | Spanner database ID | `my-database` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to service account JSON | `/credentials/service-account.json` |

### Google Firestore

Connect to Google Firestore databases.

```bash
docker run -d \
  --name mcp-firestore \
  -p 5000:5000 \
  -e FIRESTORE_PROJECT_ID=your-project-id \
  -e FIRESTORE_DATABASE_ID=(default) \
  -e GOOGLE_APPLICATION_CREDENTIALS=/credentials/service-account.json \
  -v /host/path/to/credentials:/credentials \
  @toolbox-images/firestore:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `FIRESTORE_PROJECT_ID` | Google Cloud project ID | `my-project` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to service account JSON | `/credentials/service-account.json` |

#### Optional Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `FIRESTORE_DATABASE_ID` | Firestore database ID | `(default)` |

### Supabase

Connect to Supabase PostgreSQL databases.

```bash
docker run -d \
  --name mcp-supabase \
  -p 5000:5000 \
  -e SUPABASE_URL=https://your-project.supabase.co \
  -e SUPABASE_SERVICE_ROLE_KEY=your_service_role_key \
  -e DB_NAME=postgres \
  @toolbox-images/supabase:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `SUPABASE_URL` | Supabase project URL | `https://abcd1234.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key | `eyJ...` |

#### Optional Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `DB_NAME` | Database name | `postgres` |
| `SUPABASE_SCHEMA` | Default schema | `public` |

### Neo4j

Connect to Neo4j graph databases.

```bash
docker run -d \
  --name mcp-neo4j \
  -p 5000:5000 \
  -e NEO4J_URI=bolt://your-neo4j-host.com:7687 \
  -e NEO4J_USER=neo4j \
  -e NEO4J_PASSWORD=your_password \
  -e NEO4J_DATABASE=neo4j \
  @toolbox-images/neo4j:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `NEO4J_URI` | Neo4j connection URI | `bolt://localhost:7687` or `neo4j://localhost:7687` |
| `NEO4J_USER` | Neo4j username | `neo4j` |
| `NEO4J_PASSWORD` | Neo4j password | `your_secure_password` |

#### Optional Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `NEO4J_DATABASE` | Database name | `neo4j` |
| `NEO4J_MAX_CONNECTION_LIFETIME` | Max connection lifetime | `3600` |
| `NEO4J_MAX_CONNECTION_POOL_SIZE` | Max connection pool size | `100` |

### Redis

Connect to Redis key-value stores.

```bash
docker run -d \
  --name mcp-redis \
  -p 5000:5000 \
  -e REDIS_HOST=your-redis-host.com \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=your_password \
  -e REDIS_DB=0 \
  @toolbox-images/redis:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `REDIS_HOST` | Redis hostname | `localhost` or `redis.example.com` |

#### Optional Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `REDIS_PORT` | Redis port | `6379` |
| `REDIS_PASSWORD` | Redis password | None |
| `REDIS_DB` | Redis database number | `0` |
| `REDIS_SSL` | Enable SSL connection | `false` |
| `REDIS_USERNAME` | Redis username (Redis 6+) | None |

## 🔧 Common Configuration

All images support these common environment variables:

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `TOOLBOX_PORT` | MCP server port | `5000` | Any valid port |
| `TOOLBOX_LOG_LEVEL` | Logging level | `info` | `debug`, `info`, `warn`, `error` |
| `ENABLE_STDIO` | Enable stdio mode | `false` | `true`, `false` |
| `TOOLBOX_HEALTH_CHECK_TIMEOUT` | Health check timeout | `30s` | Duration string |

## 🛡️ Security Best Practices

### 1. Use Environment Files

Instead of passing credentials via command line, use environment files:

```bash
# Create .env file
cat > .env << EOF
DB_HOST=your-database-host.com
DB_NAME=production_db
DB_USER=app_user
DB_PASSWORD=your_secure_password
EOF

# Run with environment file
docker run -d \
  --name mcp-postgres \
  -p 5000:5000 \
  --env-file .env \
  @toolbox-images/postgres:latest
```

### 2. Use Docker Secrets (Production)

For production deployments, use Docker secrets:

```bash
# Create password secret
echo "your_secure_password" | docker secret create db_password -

# Use in Docker service
docker service create \
  --name mcp-postgres \
  --secret db_password \
  -e DB_PASSWORD_FILE=/run/secrets/db_password \
  @toolbox-images/postgres:latest
```

### 3. Network Security

Run containers in isolated networks:

```bash
# Create dedicated network
docker network create mcp-network

# Run database and MCP server in same network
docker run -d \
  --name postgres-db \
  --network mcp-network \
  postgres:15

docker run -d \
  --name mcp-postgres \
  --network mcp-network \
  -p 5000:5000 \
  -e DB_HOST=postgres-db \
  # ... other variables
  @toolbox-images/postgres:latest
```

## 🔍 Health Checks and Monitoring

### Health Check Endpoint

All containers expose a health check endpoint:

```bash
# Check if the MCP server is healthy
curl http://localhost:5000/health

# Expected response
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Viewing Logs

```bash
# View real-time logs
docker logs -f mcp-postgres

# View last 100 lines
docker logs --tail 100 mcp-postgres
```

### Container Status

```bash
# Check container status
docker ps

# Inspect container details
docker inspect mcp-postgres
```

## 🛠️ Available MCP Tools

Each database server provides a standardized set of MCP tools:

### Query Execution
- **`execute_query`** - Execute SQL queries with results
- **`execute_statement`** - Execute SQL statements (INSERT, UPDATE, DELETE)

### Schema Inspection
- **`list_tables`** - List all tables in the database
- **`describe_table`** - Get detailed table schema
- **`list_columns`** - List columns for a specific table

### Database Introspection
- **`get_schema`** - Get complete database schema
- **`list_databases`** - List available databases (if supported)
- **`get_connection_info`** - Get current connection details

## 🚨 Troubleshooting

### Common Issues

**Container fails to start:**
```bash
# Check logs for error details
docker logs mcp-postgres

# Common causes:
# - Missing required environment variables
# - Network connectivity issues
# - Invalid database credentials
```

**Cannot connect to database:**
```bash
# Test database connectivity from container
docker exec mcp-postgres ping your-database-host

# Verify environment variables
docker exec mcp-postgres printenv | grep DB_
```

**Health check fails:**
```bash
# Manual health check
docker exec mcp-postgres /app/scripts/healthcheck.sh

# Check if database is accessible
docker exec mcp-postgres nc -zv your-database-host 5432
```

### Error Codes

| Exit Code | Description | Solution |
|-----------|-------------|----------|
| 1 | Missing environment variables | Check required variables for your database type |
| 2 | Database connection failed | Verify host, port, and credentials |
| 3 | Health check timeout | Check database performance and network |

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🧪 Testing and Development

### Development Environment

For developers who want to contribute or test the MCP servers, we provide a comprehensive development environment with integrated testing.

```bash
# Clone and set up development environment
git clone https://github.com/your-username/mcp-database-servers.git
cd mcp-database-servers

# Start development environment with databases, MCP servers, and web interfaces
./tests/run_tests.sh setup
```

**Development Services:**
- **PostgreSQL MCP Server**: http://localhost:5000
- **MySQL MCP Server**: http://localhost:5001  
- **Test Reports**: http://localhost:8082

### Running Tests

```bash
# Run all tests
./tests/run_tests.sh test

# Run PostgreSQL tests only
./tests/run_tests.sh test-db -d postgres

# Run with HTML test report
./tests/run_tests.sh test --html-report

# Keep environment running for development
./tests/run_tests.sh test --keep-running
```

**Test Categories:**
- ✅ **Health Checks**: Verify all services are running correctly
- ✅ **Database-Specific Tests**: PostgreSQL and MySQL functionality tests  
- ✅ **Integration Tests**: Cross-database operations and MCP protocol compliance
- ✅ **Performance Tests**: Load testing and stress testing

For detailed development instructions, see [DEVELOPMENT.md](DEVELOPMENT.md).

---

## 👨‍💻 For Contributors

<details>
<summary>🔧 Development Setup</summary>

### Prerequisites

- Docker with buildx support
- Make (optional)
- Git

### Local Development

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/mcp-database-servers.git
   cd mcp-database-servers
   ```

2. **Build all images:**
   ```bash
   ./build.sh build --test
   ```

3. **Build specific database:**
   ```bash
   ./build.sh build-db -d postgres --test
   ```

4. **Test with Docker Compose:**
   ```bash
   cd examples/docker-compose
   docker-compose -f docker-compose.postgres.yml up
   ```

### Build Script Options

```bash
./build.sh [COMMAND] [OPTIONS]

Commands:
  build       Build all images
  build-db    Build specific database image
  test        Test all images
  push        Push images to registry
  clean       Clean build artifacts

Options:
  -n, --namespace NAMESPACE    Docker namespace (default: toolbox-images)
  -v, --version VERSION        Image version (default: latest)
  -d, --database DATABASE      Specific database (postgres|mysql|snowflake|redshift)
  --push                       Push after build
  --test                       Test after build
```

### Project Structure

```
├── Dockerfile.{postgres,mysql,snowflake,redshift}  # Database-specific Dockerfiles
├── scripts/
│   ├── entrypoint.sh           # Container entrypoint with validation
│   └── healthcheck.sh          # Health check script
├── examples/
│   ├── docker-compose/         # Docker Compose examples
│   └── configs/               # Configuration examples
├── .github/workflows/         # CI/CD pipelines
├── build.sh                  # Build automation script
└── Makefile                  # Alternative build system
```

### Contributing Guidelines

1. **Fork the repository**
2. **Create a feature branch:** `git checkout -b feature/amazing-feature`
3. **Make your changes** and test thoroughly
4. **Run tests:** `./build.sh test`
5. **Commit your changes:** `git commit -m 'Add amazing feature'`
6. **Push to the branch:** `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Testing

```bash
# Test all images
./build.sh test

# Test specific database
./build.sh build-db -d postgres --test

# Integration testing with Docker Compose
cd examples/docker-compose
docker-compose -f docker-compose.all.yml up --abort-on-container-exit
```

## 🔄 CI/CD Pipeline

This project features a comprehensive CI/CD pipeline that automatically builds, tests, and deploys all 13 database Docker images.

### 🚀 Automated Workflows

- **Main CI/CD Pipeline** - Builds and tests all images on every push
- **Security Scanning** - Daily vulnerability scans and dependency checks  
- **Release Automation** - Automated versioning and GitHub releases
- **Multi-Architecture Builds** - AMD64 and ARM64 support

### 📊 Pipeline Features

- ✅ **Automated Testing** - Comprehensive test suite for all databases
- 🛡️ **Security Scanning** - Trivy vulnerability scanning and compliance checks
- 🐳 **Multi-Platform Builds** - Docker images for AMD64 and ARM64
- 📦 **Automated Releases** - Semantic versioning and release notes
- 🔍 **Quality Gates** - Code quality and security compliance enforcement

### 🏷️ Image Tags

Images are automatically tagged and pushed to Docker Hub:

- `latest` - Latest stable release
- `v1.2.3` - Semantic version tags
- `main-{sha}` - Development builds
- `pr-{number}` - Pull request builds

### 🔐 Security & Compliance

- Daily security vulnerability scans
- Automated dependency updates
- Security policy compliance checks
- SARIF integration with GitHub Security tab

### Release Process

The release process is now fully automated:

1. **Automatic Releases**: Push to main branch triggers builds
2. **Manual Releases**: Use GitHub Actions "Release" workflow
3. **Version Management**: Semantic versioning with automated tagging
4. **Release Notes**: Auto-generated changelogs and Docker image lists

For detailed CI/CD documentation, see [CI/CD Guide](.github/CICD_GUIDE.md).

</details>
