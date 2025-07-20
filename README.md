# MCP Database Server Docker Images

[![Docker Pulls](https://img.shields.io/docker/pulls/your-dockerhub-username/mcp-postgres)](https://hub.docker.com/r/your-dockerhub-username/mcp-postgres)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Release](https://img.shields.io/github/release/your-username/mcp-database-servers.svg)](https://github.com/your-username/mcp-database-servers/releases)

Production-ready Docker images that provide instant access to database systems through Google's **Model Context Protocol (MCP)**. These images enable AI agents and applications to seamlessly connect to **13 major database systems** including PostgreSQL, MySQL, Snowflake, BigQuery, AlloyDB, Spanner, Neo4j, SQLite, Redis, SQL Server, Firestore, Supabase, and Amazon Redshift with zero configuration overhead.

## 🎯 What is MCP?

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) is an open standard that enables AI models to securely connect to external data sources and tools. These Docker images package Google's MCP Toolbox for Databases, providing a standardized interface for AI applications to interact with databases.

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
| PostgreSQL | `your-dockerhub-username/mcp-postgres` | 5000 | SQL | ✅ Ready |
| MySQL | `your-dockerhub-username/mcp-mysql` | 5000 | SQL | ✅ Ready |
| Microsoft SQL Server | `your-dockerhub-username/mcp-sqlserver` | 5000 | SQL | ✅ Ready |
| SQLite | `your-dockerhub-username/mcp-sqlite` | 5000 | SQL | ✅ Ready |
| **Cloud Databases** | | | | |
| Google BigQuery | `your-dockerhub-username/mcp-bigquery` | 5000 | Analytics | ✅ Ready |
| Google AlloyDB | `your-dockerhub-username/mcp-alloydb` | 5000 | SQL | ✅ Ready |
| Google Cloud Spanner | `your-dockerhub-username/mcp-spanner` | 5000 | SQL | ✅ Ready |
| Google Firestore | `your-dockerhub-username/mcp-firestore` | 5000 | NoSQL | ✅ Ready |
| Snowflake | `your-dockerhub-username/mcp-snowflake` | 5000 | Analytics | ✅ Ready |
| Amazon Redshift | `your-dockerhub-username/mcp-redshift` | 5000 | Analytics | ✅ Ready |
| Supabase | `your-dockerhub-username/mcp-supabase` | 5000 | SQL | ✅ Ready |
| **NoSQL & Graph** | | | | |
| Neo4j | `your-dockerhub-username/mcp-neo4j` | 5000 | Graph | ✅ Ready |
| Redis | `your-dockerhub-username/mcp-redis` | 5000 | Cache/NoSQL | ✅ Ready |

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
  your-dockerhub-username/mcp-{database}:latest
```

## 🗄️ Database-Specific Configuration

### PostgreSQL

Connect to PostgreSQL databases (including compatible databases like CockroachDB).

```bash
docker run -d \
  --name mcp-postgres \
  -p 5000:5000 \
  -e DB_TYPE=postgres \
  -e DB_HOST=your-postgres-host.com \
  -e DB_PORT=5432 \
  -e DB_NAME=your_database \
  -e DB_USER=your_username \
  -e DB_PASSWORD=your_password \
  -e DB_SSL_MODE=prefer \
  your-dockerhub-username/mcp-postgres:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `DB_TYPE` | Database type | `postgres` |
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
  -e DB_TYPE=mysql \
  -e DB_HOST=your-mysql-host.com \
  -e DB_PORT=3306 \
  -e DB_NAME=your_database \
  -e DB_USER=your_username \
  -e DB_PASSWORD=your_password \
  your-dockerhub-username/mcp-mysql:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `DB_TYPE` | Database type | `mysql` |
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
  -e DB_TYPE=snowflake \
  -e SNOWFLAKE_ACCOUNT=your-account.snowflakecomputing.com \
  -e SNOWFLAKE_USER=your_username \
  -e SNOWFLAKE_PASSWORD=your_password \
  -e SNOWFLAKE_DATABASE=your_database \
  -e SNOWFLAKE_SCHEMA=PUBLIC \
  -e SNOWFLAKE_WAREHOUSE=your_warehouse \
  -e SNOWFLAKE_ROLE=your_role \
  your-dockerhub-username/mcp-snowflake:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `DB_TYPE` | Database type | `snowflake` |
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
  -e DB_TYPE=redshift \
  -e REDSHIFT_HOST=your-cluster.abc123.us-west-2.redshift.amazonaws.com \
  -e REDSHIFT_PORT=5439 \
  -e REDSHIFT_DATABASE=your_database \
  -e REDSHIFT_USER=your_username \
  -e REDSHIFT_PASSWORD=your_password \
  -e REDSHIFT_SSL_MODE=require \
  your-dockerhub-username/mcp-redshift:latest
```

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `DB_TYPE` | Database type | `redshift` |
| `REDSHIFT_HOST` | Redshift cluster endpoint | `cluster.abc123.us-west-2.redshift.amazonaws.com` |
| `REDSHIFT_DATABASE` | Database name | `analytics` |
| `REDSHIFT_USER` | Database username | `admin` |
| `REDSHIFT_PASSWORD` | Database password | `your_secure_password` |

#### Optional Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `REDSHIFT_PORT` | Database port | `5439` |
| `REDSHIFT_SSL_MODE` | SSL mode | `require` |

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
  -e DB_TYPE=postgres \
  your-dockerhub-username/mcp-postgres:latest
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
  your-dockerhub-username/mcp-postgres:latest
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
  -e DB_TYPE=postgres \
  # ... other variables
  your-dockerhub-username/mcp-postgres:latest
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

## 📞 Support

- **Documentation**: [Full documentation](https://github.com/your-username/mcp-database-servers)
- **Issues**: [GitHub Issues](https://github.com/your-username/mcp-database-servers/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/mcp-database-servers/discussions)

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

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
- **pgAdmin** (PostgreSQL UI): http://localhost:8080 (admin@mcp.dev / admin123)
- **phpMyAdmin** (MySQL UI): http://localhost:8081
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
  -n, --namespace NAMESPACE    Docker namespace (default: your-dockerhub-username)
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

### Release Process

1. Update version in build scripts
2. Update CHANGELOG.md
3. Create a git tag: `git tag v1.0.0`
4. Push the tag: `git push origin v1.0.0`
5. GitHub Actions will automatically build and push images

</details>
