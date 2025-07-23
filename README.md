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

## 📑 Table of Contents

- [Supported Databases](#-supported-databases)
- [Database Configurations](#-database-configurations)
  - [PostgreSQL](#postgresql)
  - [MySQL](#mysql)
  - [Redis](#redis)
  - [SQLite](#sqlite)
  - [Amazon Redshift](#amazon-redshift)
  - [Snowflake](#snowflake)
  - [Google BigQuery](#google-bigquery)
  - [Google AlloyDB](#google-alloydb)
  - [Google Cloud Spanner](#google-cloud-spanner)
  - [Google Firestore](#google-firestore)
  - [Microsoft SQL Server](#microsoft-sql-server)
  - [Neo4j](#neo4j)
  - [Supabase](#supabase)
- [Security Best Practices](#-security-best-practices)
- [Development](#-development)
- [License](#-license)

## 📋 Supported Databases

| Database | Image Name | Type |
|----------|------------|------|
| [PostgreSQL](#postgresql) | `toolbox-images/postgres` | SQL |
| [MySQL](#mysql) | `toolbox-images/mysql` | SQL |
| [Redis](#redis) | `toolbox-images/redis` | Cache/NoSQL |
| [SQLite](#sqlite) | `toolbox-images/sqlite` | SQL |
| [Amazon Redshift](#amazon-redshift) | `toolbox-images/redshift` | Analytics |
| [Snowflake](#snowflake) | `toolbox-images/snowflake` | Analytics |
| [Google BigQuery](#google-bigquery) | `toolbox-images/bigquery` | Analytics |
| [Google AlloyDB](#google-alloydb) | `toolbox-images/alloydb` | SQL |
| [Google Cloud Spanner](#google-cloud-spanner) | `toolbox-images/spanner` | SQL |
| [Google Firestore](#google-firestore) | `toolbox-images/firestore` | NoSQL |
| [Microsoft SQL Server](#microsoft-sql-server) | `toolbox-images/sqlserver` | SQL |
| [Neo4j](#neo4j) | `toolbox-images/neo4j` | Graph |
| [Supabase](#supabase) | `toolbox-images/supabase` | SQL |

## 🗄️ Database Configurations

---

## PostgreSQL

Connect to PostgreSQL databases, including compatible databases like CockroachDB.

### Docker Command
```shell
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

### MCP Client Configuration
```json
{
  "mcpServers": {
    "postgres": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "mcp-postgres",
        "-e", "DB_HOST=your-postgres-host.com",
        "-e", "DB_NAME=your_database",
        "-e", "DB_USER=your_username",
        "-e", "DB_PASSWORD=your_password",
        "-e", "DB_PORT=5432",
        "-e", "DB_SSL_MODE=prefer",
        "toolbox-images/postgres"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `DB_HOST` | Yes | Database hostname | - | `localhost`, `db.example.com` |
| `DB_NAME` | Yes | Database name | - | `myapp_production` |
| `DB_USER` | Yes | Database username | - | `postgres` |
| `DB_PASSWORD` | Yes | Database password | - | `your_secure_password` |
| `DB_PORT` | No | Database port | `5432` | `5432` |
| `DB_SSL_MODE` | No | SSL connection mode | `prefer` | `disable`, `allow`, `prefer`, `require`, `verify-ca`, `verify-full` |

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
```shell
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

### MCP Client Configuration
```json
{
  "mcpServers": {
    "mysql": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "mcp-mysql",
        "-e", "DB_HOST=your-mysql-host.com",
        "-e", "DB_NAME=your_database",
        "-e", "DB_USER=your_username",
        "-e", "DB_PASSWORD=your_password",
        "-e", "DB_PORT=3306",
        "-e", "DB_CHARSET=utf8mb4",
        "toolbox-images/mysql"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `DB_HOST` | Yes | Database hostname | - | `localhost`, `mysql.example.com` |
| `DB_NAME` | Yes | Database name | - | `myapp_production` |
| `DB_USER` | Yes | Database username | - | `root`, `app_user` |
| `DB_PASSWORD` | Yes | Database password | - | `your_secure_password` |
| `DB_PORT` | No | Database port | `3306` | `3306` |
| `DB_CHARSET` | No | Connection charset | `utf8mb4` | `utf8mb4` |

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
```shell
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

### MCP Client Configuration
```json
{
  "mcpServers": {
    "redis": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "mcp-redis",
        "-e", "REDIS_HOST=your-redis-host.com",
        "-e", "REDIS_PORT=6379",
        "-e", "REDIS_PASSWORD=your_password",
        "-e", "REDIS_DB=0",
        "-e", "REDIS_SSL=false",
        "toolbox-images/redis"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `REDIS_HOST` | Yes | Redis hostname | - | `localhost`, `redis.example.com` |
| `REDIS_PORT` | No | Redis port | `6379` | `6379` |
| `REDIS_PASSWORD` | No | Redis password | None | `your_password` |
| `REDIS_DB` | No | Redis database number | `0` | `0`, `1`, `2` |
| `REDIS_SSL` | No | Enable SSL connection | `false` | `true`, `false` |
| `REDIS_USERNAME` | No | Redis username (Redis 6+) | None | `username` |

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
```shell
docker run --rm -d \
  --name mcp-sqlite \
  -p 5000:5000 \
  -e SQLITE_DATABASE_PATH=/data/database.db \
  -e SQLITE_READ_ONLY=false \
  -v /host/path/to/database:/data \
  toolbox-images/sqlite:latest
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "sqlite": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "mcp-sqlite",
        "-e", "SQLITE_DATABASE_PATH=/data/database.db",
        "-e", "SQLITE_READ_ONLY=false",
        "-v", "/host/path/to/database:/data",
        "toolbox-images/sqlite"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `SQLITE_DATABASE_PATH` | Yes | Path to SQLite database file | - | `/data/database.db` |
| `SQLITE_READ_ONLY` | No | Open database in read-only mode | `false` | `true`, `false` |

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
```shell
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

### MCP Client Configuration
```json
{
  "mcpServers": {
    "redshift": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "mcp-redshift",
        "-e", "REDSHIFT_HOST=your-cluster.abc123.us-west-2.redshift.amazonaws.com",
        "-e", "REDSHIFT_PORT=5439",
        "-e", "REDSHIFT_DATABASE=your_database",
        "-e", "REDSHIFT_USER=your_username",
        "-e", "REDSHIFT_PASSWORD=your_password",
        "-e", "REDSHIFT_SSL_MODE=require",
        "toolbox-images/redshift"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `REDSHIFT_HOST` | Yes | Redshift cluster endpoint | - | `cluster.abc123.us-west-2.redshift.amazonaws.com` |
| `REDSHIFT_DATABASE` | Yes | Database name | - | `analytics` |
| `REDSHIFT_USER` | Yes | Database username | - | `admin` |
| `REDSHIFT_PASSWORD` | Yes | Database password | - | `your_secure_password` |
| `REDSHIFT_PORT` | No | Database port | `5439` | `5439` |
| `REDSHIFT_SSL_MODE` | No | SSL mode | `require` | `require`, `prefer` |

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
```shell
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

### MCP Client Configuration
```json
{
  "mcpServers": {
    "snowflake": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "mcp-snowflake",
        "-e", "SNOWFLAKE_ACCOUNT=your-account.snowflakecomputing.com",
        "-e", "SNOWFLAKE_USER=your_username",
        "-e", "SNOWFLAKE_PASSWORD=your_password",
        "-e", "SNOWFLAKE_DATABASE=your_database",
        "-e", "SNOWFLAKE_SCHEMA=PUBLIC",
        "-e", "SNOWFLAKE_WAREHOUSE=your_warehouse",
        "-e", "SNOWFLAKE_ROLE=your_role",
        "toolbox-images/snowflake"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `SNOWFLAKE_ACCOUNT` | Yes | Snowflake account URL | - | `abc12345.snowflakecomputing.com` |
| `SNOWFLAKE_USER` | Yes | Snowflake username | - | `john.doe@company.com` |
| `SNOWFLAKE_PASSWORD` | Yes | Snowflake password | - | `your_secure_password` |
| `SNOWFLAKE_DATABASE` | Yes | Database name | - | `ANALYTICS_DB` |
| `SNOWFLAKE_WAREHOUSE` | Yes | Compute warehouse | - | `COMPUTE_WH` |
| `SNOWFLAKE_SCHEMA` | No | Schema name | `PUBLIC` | `PUBLIC`, `STAGING` |
| `SNOWFLAKE_ROLE` | No | User role | User's default role | `ANALYST`, `ADMIN` |

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
```shell
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

### MCP Client Configuration
```json
{
  "mcpServers": {
    "bigquery": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "mcp-bigquery",
        "-e", "BIGQUERY_PROJECT_ID=your-project-id",
        "-e", "BIGQUERY_DATASET_ID=your_dataset",
        "-e", "BIGQUERY_LOCATION=US",
        "-e", "GOOGLE_APPLICATION_CREDENTIALS=/credentials/service-account.json",
        "-v", "/host/path/to/credentials:/credentials",
        "toolbox-images/bigquery"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `BIGQUERY_PROJECT_ID` | Yes | Google Cloud project ID | - | `my-analytics-project` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Yes | Path to service account JSON | - | `/credentials/service-account.json` |
| `BIGQUERY_DATASET_ID` | No | Default dataset ID | None | `my_dataset` |
| `BIGQUERY_LOCATION` | No | BigQuery location | `US` | `US`, `EU` |

### Volume Mounts
- `-v /host/path/to/credentials:/credentials` - Mount Google Cloud service account credentials

### MCP Tools Available
- `execute_query` - Execute BigQuery SQL
- `list_datasets` - List available datasets
- `list_tables` - List tables in dataset
- `describe_table` - Get table schema
- `get_job_status` - Check query job status

---

## Google AlloyDB

Connect to Google AlloyDB instances for PostgreSQL-compatible cloud databases.

### Docker Command
```shell
docker run --rm -d \
  --name mcp-alloydb \
  -p 5000:5000 \
  -e ALLOYDB_INSTANCE=projects/your-project/locations/region/clusters/cluster-id/instances/instance-id \
  -e DB_NAME=your_database \
  -e DB_USER=your_username \
  -e DB_PASSWORD=your_password \
  -e GOOGLE_APPLICATION_CREDENTIALS=/credentials/service-account.json \
  -v /host/path/to/credentials:/credentials \
  toolbox-images/alloydb:latest
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "alloydb": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "mcp-alloydb",
        "-e", "ALLOYDB_INSTANCE=projects/your-project/locations/region/clusters/cluster-id/instances/instance-id",
        "-e", "DB_NAME=your_database",
        "-e", "DB_USER=your_username",
        "-e", "DB_PASSWORD=your_password",
        "-e", "GOOGLE_APPLICATION_CREDENTIALS=/credentials/service-account.json",
        "-v", "/host/path/to/credentials:/credentials",
        "toolbox-images/alloydb"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `ALLOYDB_INSTANCE` | Yes | AlloyDB instance path | - | `projects/my-project/locations/us-central1/clusters/my-cluster/instances/my-instance` |
| `DB_NAME` | Yes | Database name | - | `myapp_production` |
| `DB_USER` | Yes | Database username | - | `postgres` |
| `DB_PASSWORD` | Yes | Database password | - | `your_secure_password` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Yes | Path to service account JSON | - | `/credentials/service-account.json` |

### Volume Mounts
- `-v /host/path/to/credentials:/credentials` - Mount Google Cloud service account credentials

### MCP Tools Available
- `execute_query` - Execute SQL queries with results
- `execute_statement` - Execute SQL statements
- `list_tables` - List all tables
- `describe_table` - Get table schema
- `get_schema` - Get complete schema

---

## Google Cloud Spanner

Connect to Google Cloud Spanner for globally distributed, strongly consistent databases.

### Docker Command
```shell
docker run --rm -d \
  --name mcp-spanner \
  -p 5000:5000 \
  -e SPANNER_PROJECT_ID=your-project-id \
  -e SPANNER_INSTANCE_ID=your-instance-id \
  -e SPANNER_DATABASE_ID=your-database-id \
  -e GOOGLE_APPLICATION_CREDENTIALS=/credentials/service-account.json \
  -v /host/path/to/credentials:/credentials \
  toolbox-images/spanner:latest
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "spanner": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "mcp-spanner",
        "-e", "SPANNER_PROJECT_ID=your-project-id",
        "-e", "SPANNER_INSTANCE_ID=your-instance-id",
        "-e", "SPANNER_DATABASE_ID=your-database-id",
        "-e", "GOOGLE_APPLICATION_CREDENTIALS=/credentials/service-account.json",
        "-v", "/host/path/to/credentials:/credentials",
        "toolbox-images/spanner"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `SPANNER_PROJECT_ID` | Yes | Google Cloud project ID | - | `my-project` |
| `SPANNER_INSTANCE_ID` | Yes | Spanner instance ID | - | `my-instance` |
| `SPANNER_DATABASE_ID` | Yes | Spanner database ID | - | `my-database` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Yes | Path to service account JSON | - | `/credentials/service-account.json` |

### Volume Mounts
- `-v /host/path/to/credentials:/credentials` - Mount Google Cloud service account credentials

### MCP Tools Available
- `execute_query` - Execute SQL queries
- `list_tables` - List tables in database
- `describe_table` - Get table schema
- `get_schema` - Get complete schema

---

## Google Firestore

Connect to Google Firestore NoSQL document databases.

### Docker Command
```shell
docker run --rm -d \
  --name mcp-firestore \
  -p 5000:5000 \
  -e FIRESTORE_PROJECT_ID=your-project-id \
  -e FIRESTORE_DATABASE_ID=(default) \
  -e GOOGLE_APPLICATION_CREDENTIALS=/credentials/service-account.json \
  -v /host/path/to/credentials:/credentials \
  toolbox-images/firestore:latest
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "firestore": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "mcp-firestore",
        "-e", "FIRESTORE_PROJECT_ID=your-project-id",
        "-e", "FIRESTORE_DATABASE_ID=(default)",
        "-e", "GOOGLE_APPLICATION_CREDENTIALS=/credentials/service-account.json",
        "-v", "/host/path/to/credentials:/credentials",
        "toolbox-images/firestore"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `FIRESTORE_PROJECT_ID` | Yes | Google Cloud project ID | - | `my-project` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Yes | Path to service account JSON | - | `/credentials/service-account.json` |
| `FIRESTORE_DATABASE_ID` | No | Firestore database ID | `(default)` | `(default)`, `my-database` |

### Volume Mounts
- `-v /host/path/to/credentials:/credentials` - Mount Google Cloud service account credentials

### MCP Tools Available
- `get_document` - Get document by path
- `set_document` - Create or update document
- `delete_document` - Delete document
- `list_collections` - List collections
- `query_collection` - Query documents in collection

---

## Microsoft SQL Server

Connect to Microsoft SQL Server databases.

### Docker Command
```shell
docker run --rm -d \
  --name mcp-sqlserver \
  -p 5000:5000 \
  -e SQLSERVER_HOST=your-sqlserver-host.com \
  -e SQLSERVER_PORT=1433 \
  -e SQLSERVER_DATABASE=your_database \
  -e SQLSERVER_USER=your_username \
  -e SQLSERVER_PASSWORD=your_password \
  -e SQLSERVER_ENCRYPT=true \
  -e SQLSERVER_TRUST_SERVER_CERTIFICATE=false \
  toolbox-images/sqlserver:latest
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "sqlserver": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "mcp-sqlserver",
        "-e", "SQLSERVER_HOST=your-sqlserver-host.com",
        "-e", "SQLSERVER_PORT=1433",
        "-e", "SQLSERVER_DATABASE=your_database",
        "-e", "SQLSERVER_USER=your_username",
        "-e", "SQLSERVER_PASSWORD=your_password",
        "-e", "SQLSERVER_ENCRYPT=true",
        "-e", "SQLSERVER_TRUST_SERVER_CERTIFICATE=false",
        "toolbox-images/sqlserver"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `SQLSERVER_HOST` | Yes | SQL Server hostname | - | `localhost`, `sql.example.com` |
| `SQLSERVER_DATABASE` | Yes | Database name | - | `myapp_production` |
| `SQLSERVER_USER` | Yes | Database username | - | `sa`, `app_user` |
| `SQLSERVER_PASSWORD` | Yes | Database password | - | `your_secure_password` |
| `SQLSERVER_PORT` | No | Database port | `1433` | `1433` |
| `SQLSERVER_ENCRYPT` | No | Enable encryption | `true` | `true`, `false` |
| `SQLSERVER_TRUST_SERVER_CERTIFICATE` | No | Trust server certificate | `false` | `true`, `false` |

### MCP Tools Available
- `execute_query` - Execute SQL queries with results
- `execute_statement` - Execute SQL statements
- `list_tables` - List all tables
- `describe_table` - Get table schema
- `get_schema` - Get complete schema

---

## Neo4j

Connect to Neo4j graph databases for relationship-based data modeling.

### Docker Command
```shell
docker run --rm -d \
  --name mcp-neo4j \
  -p 5000:5000 \
  -e NEO4J_URI=bolt://your-neo4j-host.com:7687 \
  -e NEO4J_USER=neo4j \
  -e NEO4J_PASSWORD=your_password \
  -e NEO4J_DATABASE=neo4j \
  toolbox-images/neo4j:latest
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "neo4j": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "mcp-neo4j",
        "-e", "NEO4J_URI=bolt://your-neo4j-host.com:7687",
        "-e", "NEO4J_USER=neo4j",
        "-e", "NEO4J_PASSWORD=your_password",
        "-e", "NEO4J_DATABASE=neo4j",
        "toolbox-images/neo4j"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `NEO4J_URI` | Yes | Neo4j connection URI | - | `bolt://localhost:7687`, `neo4j://localhost:7687` |
| `NEO4J_USER` | Yes | Neo4j username | - | `neo4j` |
| `NEO4J_PASSWORD` | Yes | Neo4j password | - | `your_secure_password` |
| `NEO4J_DATABASE` | No | Database name | `neo4j` | `neo4j`, `movies` |
| `NEO4J_MAX_CONNECTION_LIFETIME` | No | Max connection lifetime | `3600` | `3600` |
| `NEO4J_MAX_CONNECTION_POOL_SIZE` | No | Max connection pool size | `100` | `100` |

### MCP Tools Available
- `execute_cypher` - Execute Cypher queries
- `list_labels` - List node labels
- `list_relationships` - List relationship types
- `get_schema` - Get graph schema
- `count_nodes` - Count nodes by label
- `count_relationships` - Count relationships by type

---

## Supabase

Connect to Supabase PostgreSQL databases with additional Supabase-specific features.

### Docker Command
```shell
docker run --rm -d \
  --name mcp-supabase \
  -p 5000:5000 \
  -e SUPABASE_URL=https://your-project.supabase.co \
  -e SUPABASE_SERVICE_ROLE_KEY=your_service_role_key \
  -e DB_NAME=postgres \
  toolbox-images/supabase:latest
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "supabase": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "mcp-supabase",
        "-e", "SUPABASE_URL=https://your-project.supabase.co",
        "-e", "SUPABASE_SERVICE_ROLE_KEY=your_service_role_key",
        "-e", "DB_NAME=postgres",
        "toolbox-images/supabase"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `SUPABASE_URL` | Yes | Supabase project URL | - | `https://abcd1234.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | Yes | Service role key | - | `eyJ...` |
| `DB_NAME` | No | Database name | `postgres` | `postgres` |
| `SUPABASE_SCHEMA` | No | Default schema | `public` | `public`, `auth` |

### MCP Tools Available
- `execute_query` - Execute SQL queries with results
- `execute_statement` - Execute SQL statements
- `list_tables` - List all tables
- `describe_table` - Get table schema
- `get_schema` - Get complete schema
- `list_rls_policies` - List Row Level Security policies
- `get_auth_users` - Get authentication users (admin only)

---

## 🛡️ Security Best Practices

### Use Environment Files
```shell
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

```shell
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

```shell
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
   ```shell
   git clone https://github.com/marcosfede/toolbox-db-images.git
   cd toolbox-db-images
   ```

2. **Build and test a specific image:**
   ```shell
   ./build.sh build-db -d postgres --test
   ```

3. **Test with Docker Compose:**
   ```shell
   cd examples/docker-compose
   docker-compose -f docker-compose.postgres.yml up
   ```

### Running Tests

```shell
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