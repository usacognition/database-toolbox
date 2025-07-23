# MCP Database Server Docker Images

[![CI](https://github.com/marcosfede/toolbox-db-images/actions/workflows/ci.yml/badge.svg)](https://github.com/marcosfede/toolbox-db-images/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Docker images that provide database connectivity through the **Model Context Protocol (MCP)**. These images enable AI agents and applications to connect to database systems with minimal configuration.

## 📑 Table of Contents

- [Features](#-features)
- [Database Support Status](#-database-support-status)
- [Database Configurations](#-database-configurations)
  - [PostgreSQL](#postgresql)
  - [MySQL](#mysql)
  - [Redis](#redis)
  - [SQLite](#sqlite)
  - [Amazon Redshift](#amazon-redshift)
  - [Snowflake](#snowflake)
  - [Google BigQuery](#google-bigquery)
- [Security Best Practices](#-security-best-practices)
- [Development](#-development)
- [License](#-license)

## ✨ Features

- 🚀 **Ready-to-Use**: Pre-built Docker images
- 🔗 **Universal Interface**: Consistent API across database types
- 🔐 **Secure**: Environment-based credential management
- 📊 **Database Tools**: Query execution and schema inspection
- 🐳 **Container Native**: Optimized for containerized environments

## 📋 Database Support Status

### 🟢 Production Ready (Fully Tested)
| Database | Image Name | CI Tested |
|----------|------------|-----------|
| PostgreSQL | `toolbox-images/postgres` | ✅ |
| MySQL | `toolbox-images/mysql` | ✅ |
| Redis | `toolbox-images/redis` | ✅ |
| SQLite | `toolbox-images/sqlite` | ✅ |

### 🟡 Available (Community Maintained)
| Database | Image Name | Type |
|----------|------------|------|
| Amazon Redshift | `toolbox-images/redshift` | Analytics |
| Snowflake | `toolbox-images/snowflake` | Analytics |
| Google BigQuery | `toolbox-images/bigquery` | Analytics |
| Google AlloyDB | `toolbox-images/alloydb` | SQL |
| Google Cloud Spanner | `toolbox-images/spanner` | SQL |
| Google Firestore | `toolbox-images/firestore` | NoSQL |
| Microsoft SQL Server | `toolbox-images/sqlserver` | SQL |
| Neo4j | `toolbox-images/neo4j` | Graph |
| Supabase | `toolbox-images/supabase` | SQL |

## 🗄️ Database Configurations

---

## PostgreSQL

Connect to PostgreSQL databases, including compatible databases like CockroachDB.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-postgres \
  -p 5000:5000 \
  -e DB_HOST=your-postgres-host.com \
  -e DB_NAME=your_database \
  -e DB_USER=your_username \
  -e DB_PASSWORD=your_password \
  -e DB_PORT=5432 \
  -e DB_SSL_MODE=prefer \
  toolbox-images/postgres:latest
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `DB_HOST` | ✅ | Database hostname | - | `localhost`, `db.example.com` |
| `DB_NAME` | ✅ | Database name | - | `myapp_production` |
| `DB_USER` | ✅ | Database username | - | `postgres` |
| `DB_PASSWORD` | ✅ | Database password | - | `your_secure_password` |
| `DB_PORT` | ❌ | Database port | `5432` | `5432` |
| `DB_SSL_MODE` | ❌ | SSL connection mode | `prefer` | `disable`, `allow`, `prefer`, `require`, `verify-ca`, `verify-full` |

### MCP Tools Available
- `execute_query` - Execute SQL queries with results
- `execute_statement` - Execute SQL statements (INSERT, UPDATE, DELETE)
- `list_tables` - List all tables in the database
- `describe_table` - Get detailed table schema
- `list_columns` - List columns for a specific table
- `get_schema` - Get complete database schema

---

## MySQL

Connect to MySQL and MariaDB databases.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-mysql \
  -p 5000:5000 \
  -e DB_HOST=your-mysql-host.com \
  -e DB_NAME=your_database \
  -e DB_USER=your_username \
  -e DB_PASSWORD=your_password \
  -e DB_PORT=3306 \
  -e DB_CHARSET=utf8mb4 \
  toolbox-images/mysql:latest
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `DB_HOST` | ✅ | Database hostname | - | `localhost`, `mysql.example.com` |
| `DB_NAME` | ✅ | Database name | - | `myapp_production` |
| `DB_USER` | ✅ | Database username | - | `root`, `app_user` |
| `DB_PASSWORD` | ✅ | Database password | - | `your_secure_password` |
| `DB_PORT` | ❌ | Database port | `3306` | `3306` |
| `DB_CHARSET` | ❌ | Connection charset | `utf8mb4` | `utf8mb4` |

### MCP Tools Available
- `execute_query` - Execute SQL queries with results
- `execute_statement` - Execute SQL statements (INSERT, UPDATE, DELETE)
- `list_tables` - List all tables in the database
- `describe_table` - Get detailed table schema
- `list_columns` - List columns for a specific table
- `get_schema` - Get complete database schema

---

## Redis

Connect to Redis key-value stores and caching systems.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-redis \
  -p 5000:5000 \
  -e REDIS_HOST=your-redis-host.com \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=your_password \
  -e REDIS_DB=0 \
  -e REDIS_SSL=false \
  toolbox-images/redis:latest
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `REDIS_HOST` | ✅ | Redis hostname | - | `localhost`, `redis.example.com` |
| `REDIS_PORT` | ❌ | Redis port | `6379` | `6379` |
| `REDIS_PASSWORD` | ❌ | Redis password | None | `your_password` |
| `REDIS_DB` | ❌ | Redis database number | `0` | `0`, `1`, `2` |
| `REDIS_SSL` | ❌ | Enable SSL connection | `false` | `true`, `false` |
| `REDIS_USERNAME` | ❌ | Redis username (Redis 6+) | None | `username` |

### MCP Tools Available
- `get` - Get value by key
- `set` - Set key-value pair
- `delete` - Delete key
- `list_keys` - List all keys matching pattern
- `get_info` - Get Redis server information
- `ping` - Test connection

---

## SQLite

Connect to SQLite database files for local development and testing.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-sqlite \
  -p 5000:5000 \
  -e SQLITE_DATABASE_PATH=/data/database.db \
  -e SQLITE_READ_ONLY=false \
  -v /host/path/to/database:/data \
  toolbox-images/sqlite:latest
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `SQLITE_DATABASE_PATH` | ✅ | Path to SQLite database file | - | `/data/database.db` |
| `SQLITE_READ_ONLY` | ❌ | Open database in read-only mode | `false` | `true`, `false` |

### Volume Mounts
- `-v /host/path/to/database:/data` - Mount directory containing SQLite database file

### MCP Tools Available
- `execute_query` - Execute SQL queries with results
- `execute_statement` - Execute SQL statements (INSERT, UPDATE, DELETE)
- `list_tables` - List all tables in the database
- `describe_table` - Get detailed table schema
- `list_columns` - List columns for a specific table
- `get_schema` - Get complete database schema

---

## Amazon Redshift

Connect to Amazon Redshift data warehouse clusters.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-redshift \
  -p 5000:5000 \
  -e REDSHIFT_HOST=your-cluster.abc123.us-west-2.redshift.amazonaws.com \
  -e REDSHIFT_PORT=5439 \
  -e REDSHIFT_DATABASE=your_database \
  -e REDSHIFT_USER=your_username \
  -e REDSHIFT_PASSWORD=your_password \
  -e REDSHIFT_SSL_MODE=require \
  toolbox-images/redshift:latest
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `REDSHIFT_HOST` | ✅ | Redshift cluster endpoint | - | `cluster.abc123.us-west-2.redshift.amazonaws.com` |
| `REDSHIFT_DATABASE` | ✅ | Database name | - | `analytics` |
| `REDSHIFT_USER` | ✅ | Database username | - | `admin` |
| `REDSHIFT_PASSWORD` | ✅ | Database password | - | `your_secure_password` |
| `REDSHIFT_PORT` | ❌ | Database port | `5439` | `5439` |
| `REDSHIFT_SSL_MODE` | ❌ | SSL mode | `require` | `require`, `prefer` |

### MCP Tools Available
- `execute_query` - Execute SQL queries with results
- `execute_statement` - Execute SQL statements
- `list_tables` - List all tables
- `describe_table` - Get table schema
- `get_schema` - Get complete schema

---

## Snowflake

Connect to Snowflake Data Cloud for analytics and data warehousing.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-snowflake \
  -p 5000:5000 \
  -e SNOWFLAKE_ACCOUNT=your-account.snowflakecomputing.com \
  -e SNOWFLAKE_USER=your_username \
  -e SNOWFLAKE_PASSWORD=your_password \
  -e SNOWFLAKE_DATABASE=your_database \
  -e SNOWFLAKE_SCHEMA=PUBLIC \
  -e SNOWFLAKE_WAREHOUSE=your_warehouse \
  -e SNOWFLAKE_ROLE=your_role \
  toolbox-images/snowflake:latest
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `SNOWFLAKE_ACCOUNT` | ✅ | Snowflake account URL | - | `abc12345.snowflakecomputing.com` |
| `SNOWFLAKE_USER` | ✅ | Snowflake username | - | `john.doe@company.com` |
| `SNOWFLAKE_PASSWORD` | ✅ | Snowflake password | - | `your_secure_password` |
| `SNOWFLAKE_DATABASE` | ✅ | Database name | - | `ANALYTICS_DB` |
| `SNOWFLAKE_WAREHOUSE` | ✅ | Compute warehouse | - | `COMPUTE_WH` |
| `SNOWFLAKE_SCHEMA` | ❌ | Schema name | `PUBLIC` | `PUBLIC`, `STAGING` |
| `SNOWFLAKE_ROLE` | ❌ | User role | User's default role | `ANALYST`, `ADMIN` |

### MCP Tools Available
- `execute_query` - Execute SQL queries
- `list_databases` - List available databases
- `list_schemas` - List schemas in database
- `list_tables` - List tables in schema
- `describe_table` - Get table structure

---

## Google BigQuery

Connect to Google BigQuery for analytics and data processing.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-bigquery \
  -p 5000:5000 \
  -e BIGQUERY_PROJECT_ID=your-project-id \
  -e BIGQUERY_DATASET_ID=your_dataset \
  -e BIGQUERY_LOCATION=US \
  -e GOOGLE_APPLICATION_CREDENTIALS=/credentials/service-account.json \
  -v /host/path/to/credentials:/credentials \
  toolbox-images/bigquery:latest
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `BIGQUERY_PROJECT_ID` | ✅ | Google Cloud project ID | - | `my-analytics-project` |
| `GOOGLE_APPLICATION_CREDENTIALS` | ✅ | Path to service account JSON | - | `/credentials/service-account.json` |
| `BIGQUERY_DATASET_ID` | ❌ | Default dataset ID | None | `my_dataset` |
| `BIGQUERY_LOCATION` | ❌ | BigQuery location | `US` | `US`, `EU` |

### Volume Mounts
- `-v /host/path/to/credentials:/credentials` - Mount Google Cloud service account credentials

### MCP Tools Available
- `execute_query` - Execute BigQuery SQL
- `list_datasets` - List available datasets
- `list_tables` - List tables in dataset
- `describe_table` - Get table schema
- `get_job_status` - Check query job status

---

## 🛡️ Security Best Practices

### Use Environment Files
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
  -d, --database DATABASE      Specific database (postgres|mysql|redis|sqlite|...)
  --push                       Push after build
  --test                       Test after build
```

### Project Structure

```
├── Dockerfile.{postgres,mysql,redis,sqlite,...}  # Database-specific Dockerfiles
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

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.