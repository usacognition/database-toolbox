# Supported Databases

This document provides a comprehensive overview of all databases supported by the MCP Database Server Docker images.

## 🌐 Complete Database Support Matrix

We now support **13 major database systems** across different categories, making this the most comprehensive MCP database server collection available.

### Relational Databases (SQL)

| Database | Image | Port | Features | Status |
|----------|-------|------|----------|--------|
| **PostgreSQL** | `mcp-postgres` | 5000 | Full SQL, Extensions, Arrays, JSON | ✅ Production Ready |
| **MySQL** | `mcp-mysql` | 5000 | Full SQL, Full-Text Search, JSON | ✅ Production Ready |
| **Microsoft SQL Server** | `mcp-sqlserver` | 5000 | T-SQL, Procedures, Functions | ✅ Production Ready |
| **SQLite** | `mcp-sqlite` | 5000 | Embedded DB, File-based | ✅ Production Ready |

### Cloud Analytics Platforms

| Database | Image | Port | Features | Status |
|----------|-------|------|----------|--------|
| **Google BigQuery** | `mcp-bigquery` | 5000 | Serverless Analytics, ML | ✅ Production Ready |
| **Snowflake** | `mcp-snowflake` | 5000 | Data Warehouse, Time Travel | ✅ Production Ready |
| **Amazon Redshift** | `mcp-redshift` | 5000 | Data Warehouse, Columnar | ✅ Production Ready |

### Google Cloud Platform

| Database | Image | Port | Features | Status |
|----------|-------|------|----------|--------|
| **Google AlloyDB** | `mcp-alloydb` | 5000 | PostgreSQL-compatible, AI | ✅ Production Ready |
| **Google Cloud Spanner** | `mcp-spanner` | 5000 | Global Distribution, ACID | ✅ Production Ready |
| **Google Firestore** | `mcp-firestore` | 5000 | NoSQL Document DB | ✅ Production Ready |

### Graph & NoSQL Databases

| Database | Image | Port | Features | Status |
|----------|-------|------|----------|--------|
| **Neo4j** | `mcp-neo4j` | 5000 | Graph DB, Cypher Queries | ✅ Production Ready |
| **Redis** | `mcp-redis` | 5000 | Key-Value, Caching, Pub/Sub | ✅ Production Ready |

### Developer Platforms

| Database | Image | Port | Features | Status |
|----------|-------|------|----------|--------|
| **Supabase** | `mcp-supabase` | 5000 | PostgreSQL + APIs, Real-time | ✅ Production Ready |

## 🏗️ Architecture Overview

Each Docker image includes:

- **Google MCP Toolbox** (v0.9.0) - The core MCP server engine
- **Database-specific drivers** - Native clients optimized for each database
- **Health monitoring** - Built-in health checks and observability
- **Security hardening** - Non-root user, minimal attack surface
- **Multi-architecture support** - AMD64 and ARM64 platforms

## 📊 Supported Operations by Database Type

### SQL Databases (PostgreSQL, MySQL, SQL Server, SQLite, AlloyDB, Supabase)
- `execute-sql` - Execute any SQL query
- `sql` - Parameterized SQL queries with prepared statements
- Schema introspection
- Transaction support
- Connection pooling

### Analytics Platforms (BigQuery, Snowflake, Redshift)
- `execute-sql` - Execute analytics queries
- `get-table-info` - Table metadata and schema
- `list-datasets` - Browse available datasets
- Optimized for large-scale data processing
- Built-in query optimization

### Google Cloud Services (Spanner, Firestore)
- **Spanner**: Globally distributed SQL with strong consistency
- **Firestore**: Document operations, real-time listeners, security rules

### Graph Database (Neo4j)
- `execute-cypher` - Native Cypher query execution
- Graph traversal operations
- Relationship mapping
- Path finding algorithms

### Key-Value Store (Redis)
- `redis-command` - Execute any Redis command
- Data structure operations (strings, lists, sets, hashes)
- Pub/Sub messaging
- Caching and session management

## 🔧 Configuration Examples

### Environment Variables by Database

Each database type requires specific environment variables:

#### PostgreSQL / AlloyDB / Supabase
```bash
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mydb
DB_USER=postgres
DB_PASSWORD=password
```

#### MySQL
```bash
DB_HOST=localhost
DB_PORT=3306
DB_NAME=mydb
DB_USER=root
DB_PASSWORD=password
```

#### Snowflake
```bash
SNOWFLAKE_ACCOUNT=myaccount.snowflakecomputing.com
SNOWFLAKE_USER=myuser
SNOWFLAKE_PASSWORD=password
SNOWFLAKE_DATABASE=MYDB
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
```

#### BigQuery
```bash
BIGQUERY_PROJECT_ID=my-project
BIGQUERY_DATASET=my_dataset
GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```

#### Neo4j
```bash
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password
```

#### Redis
```bash
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=optional_password
```

## 🧪 Testing Support

Our comprehensive test suite includes:

- **Unit tests** for each database type
- **Integration tests** across multiple databases
- **Health check validation**
- **Connection testing**
- **Query execution verification**
- **Error handling validation**

### Test Markers
```bash
# Test specific databases
pytest -m postgres
pytest -m mysql
pytest -m snowflake
pytest -m bigquery
pytest -m neo4j
pytest -m redis

# Test categories
pytest -m integration
pytest -m health_checks
```

## 🚀 Performance Characteristics

| Database Type | Query Latency | Throughput | Scalability |
|---------------|---------------|-------------|-------------|
| **PostgreSQL** | Low | High | Vertical + Read Replicas |
| **MySQL** | Low | High | Vertical + Read Replicas |
| **BigQuery** | Medium | Very High | Serverless Auto-scaling |
| **Snowflake** | Medium | Very High | Auto-scaling Clusters |
| **Spanner** | Low | High | Global Horizontal |
| **Neo4j** | Variable | Medium | Clustering |
| **Redis** | Very Low | Very High | Clustering + Sharding |

## 📈 Use Cases by Database

### PostgreSQL / MySQL / SQL Server
- **Web applications** - User data, content management
- **E-commerce** - Orders, inventory, customer data
- **Financial systems** - Transactions, accounting
- **Enterprise applications** - ERP, CRM systems

### BigQuery / Snowflake / Redshift
- **Business intelligence** - Reporting and dashboards
- **Data analytics** - Large-scale data processing
- **Machine learning** - Training data preparation
- **Data warehousing** - Historical data analysis

### Neo4j
- **Social networks** - Friend relationships, recommendations
- **Fraud detection** - Pattern recognition in transactions
- **Knowledge graphs** - Connected information systems
- **Network analysis** - Infrastructure and dependency mapping

### Redis
- **Session management** - User session storage
- **Caching** - Application performance optimization
- **Real-time messaging** - Chat applications, notifications
- **Rate limiting** - API throttling and control

### Firestore
- **Mobile applications** - Real-time data synchronization
- **Web applications** - User profiles, application state
- **IoT applications** - Device data collection
- **Collaborative tools** - Real-time document editing

## 🔒 Security Features

All images include:

- **Non-root execution** - Containers run as unprivileged user
- **Minimal base images** - Alpine Linux for reduced attack surface
- **Environment-based secrets** - No hardcoded credentials
- **Network isolation** - Configurable network policies
- **Audit logging** - Request and query logging
- **TLS/SSL support** - Encrypted connections to databases

## 🌍 Multi-Architecture Support

All images are built for:
- **AMD64** (x86_64) - Intel/AMD processors
- **ARM64** (aarch64) - Apple Silicon, AWS Graviton, ARM servers

This ensures compatibility across:
- Development laptops (Intel/Apple Silicon)
- Cloud instances (AWS, GCP, Azure)
- Edge devices and ARM servers
- Kubernetes clusters with mixed architectures

## 🎯 Getting Started

1. **Choose your database** from the supported list above
2. **Pull the image**: `docker pull your-registry/mcp-{database}`
3. **Set environment variables** according to your database type
4. **Run the container**: `docker run --rm -d -p 5000:5000 [env-vars] your-registry/mcp-{database}` (use `--rm -it` for interactive testing)
5. **Connect your AI application** to `http://localhost:5000`

For detailed examples and configuration, see the main README.md file.