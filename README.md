# MCP Database Server Docker Images

[![CI](https://github.com/marcosfede/toolbox-db-images/actions/workflows/ci.yml/badge.svg)](https://github.com/marcosfede/toolbox-db-images/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Docker images that provide database connectivity through the **Model Context Protocol (MCP)**. These images enable AI agents and applications to connect to database systems with minimal configuration.

## ✨ Features

- 🚀 **Ready-to-Use**: Pre-built Docker images
- 🔗 **Universal Interface**: Consistent API across database types
- 🔐 **Secure**: Environment-based credential management
- 📊 **Database Tools**: Query execution and schema inspection
- 🐳 **Container Native**: Optimized for containerized environments

## 📋 Supported Databases

| Database | Image Name | Status |
|----------|------------|--------|
| PostgreSQL | `toolbox-images/postgres` | ✅ Ready |
| MySQL | `toolbox-images/mysql` | ✅ Ready |
| Redis | `toolbox-images/redis` | ✅ Ready |
| SQLite | `toolbox-images/sqlite` | ✅ Ready |

## 🚀 Quick Start

### Prerequisites

- Docker installed and running
- Access to a database instance
- Network connectivity between the container and your database

### Basic Usage

Each image can be run with a simple `docker run` command. The containers expose the MCP server on port 5000 by default.

```bash
# Run PostgreSQL MCP server
docker run --rm -d \
  --name mcp-postgres \
  -p 5000:5000 \
  -e DB_HOST=your-postgres-host.com \
  -e DB_NAME=your_database \
  -e DB_USER=your_username \
  -e DB_PASSWORD=your_password \
  toolbox-images/postgres:latest

# Run MySQL MCP server
docker run --rm -d \
  --name mcp-mysql \
  -p 5000:5000 \
  -e DB_HOST=your-mysql-host.com \
  -e DB_NAME=your_database \
  -e DB_USER=your_username \
  -e DB_PASSWORD=your_password \
  toolbox-images/mysql:latest

# Run Redis MCP server
docker run --rm -d \
  --name mcp-redis \
  -p 5000:5000 \
  -e REDIS_HOST=your-redis-host.com \
  -e REDIS_PASSWORD=your_password \
  toolbox-images/redis:latest

# Run SQLite MCP server
docker run --rm -d \
  --name mcp-sqlite \
  -p 5000:5000 \
  -e SQLITE_DATABASE_PATH=/data/database.db \
  -v /host/path/to/database:/data \
  toolbox-images/sqlite:latest
```

## 🗄️ Database Configuration

### PostgreSQL

Connect to PostgreSQL databases (including compatible databases like CockroachDB).

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `DB_HOST` | Database hostname | `localhost` or `db.example.com` |
| `DB_NAME` | Database name | `myapp_production` |
| `DB_USER` | Database username | `postgres` |
| `DB_PASSWORD` | Database password | `your_secure_password` |

#### Optional Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `DB_PORT` | Database port | `5432` |
| `DB_SSL_MODE` | SSL mode | `prefer` |

### MySQL

Connect to MySQL and MariaDB databases.

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

### Redis

Connect to Redis key-value stores.

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

### SQLite

Connect to SQLite database files.

#### Required Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `SQLITE_DATABASE_PATH` | Path to SQLite database file | `/data/database.db` |

#### Optional Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `SQLITE_READ_ONLY` | Open database in read-only mode | `false` |

## 🔧 Common Configuration

All images support these common environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `TOOLBOX_PORT` | MCP server port | `5000` |
| `TOOLBOX_LOG_LEVEL` | Logging level | `info` |

## 🛡️ Security Best Practices

### Use Environment Files

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
docker run --rm -d \
  --name mcp-postgres \
  -p 5000:5000 \
  --env-file .env \
  toolbox-images/postgres:latest
```

### Network Security

Run containers in isolated networks:

```bash
# Create dedicated network
docker network create mcp-network

# Run database and MCP server in same network
docker run --rm -d \
  --name postgres-db \
  --network mcp-network \
  postgres:15

docker run --rm -d \
  --name mcp-postgres \
  --network mcp-network \
  -p 5000:5000 \
  -e DB_HOST=postgres-db \
  -e DB_NAME=mydb \
  -e DB_USER=postgres \
  -e DB_PASSWORD=password \
  toolbox-images/postgres:latest
```

## 🛠️ Available MCP Tools

Each database server provides a set of MCP tools for database operations:

### Query Execution
- **`execute_query`** - Execute SQL queries with results
- **`execute_statement`** - Execute SQL statements (INSERT, UPDATE, DELETE)

### Schema Inspection
- **`list_tables`** - List all tables in the database
- **`describe_table`** - Get detailed table schema
- **`list_columns`** - List columns for a specific table

### Database Introspection
- **`get_schema`** - Get complete database schema
- **`get_connection_info`** - Get current connection details

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🧪 Development

### Prerequisites

- Docker with buildx support
- Make (optional)
- Git

### Building Images

```bash
# Build all images
./build.sh build

# Build specific database
./build.sh build-db -d postgres

# Build with testing
./build.sh build --test

# Test existing images
./build.sh test
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
  -d, --database DATABASE      Specific database (postgres|mysql|redis|sqlite)
  --push                       Push after build
  --test                       Test after build
```

### Project Structure

```
├── Dockerfile.{postgres,mysql,redis,sqlite}  # Database-specific Dockerfiles
├── scripts/
│   ├── entrypoint.sh           # Container entrypoint
│   └── validate_setup.sh       # Setup validation
├── examples/
│   └── docker-compose/         # Docker Compose examples
├── tests/                      # Test suite
│   ├── run_tests.sh           # Test runner script
│   ├── test_*.py              # Test files
│   └── requirements.txt       # Test dependencies
├── build.sh                   # Build automation script
└── Makefile                   # Alternative build system
```

### Local Development

1. **Clone the repository:**
   ```bash
   git clone https://github.com/marcosfede/toolbox-db-images.git
   cd toolbox-db-images
   ```

2. **Build and test a specific image:**
   ```bash
   ./build.sh build-db -d postgres --test
   ```

3. **Test with Docker Compose:**
   ```bash
   cd examples/docker-compose
   docker-compose -f docker-compose.postgres.yml up
   ```

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

### Contributing

1. **Fork the repository**
2. **Create a feature branch:** `git checkout -b feature/amazing-feature`
3. **Make your changes** and test thoroughly
4. **Run tests:** `./build.sh test`
5. **Commit your changes:** `git commit -m 'Add amazing feature'`
6. **Push to the branch:** `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### CI/CD

This project uses GitHub Actions for continuous integration:

- **Build & Test**: Automatically builds and tests Docker images for all supported databases
- **Simple Pipeline**: Focused on core functionality without complex security scanning

The CI pipeline builds images for: PostgreSQL, MySQL, Redis, and SQLite.