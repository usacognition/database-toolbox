# MCP Database Server Docker Images

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Docker images that provide database connectivity through the **Model Context Protocol (MCP)**. These images enable AI agents and applications to connect to database systems with minimal configuration.

## ✨ Features

- 🚀 **Ready-to-Use**: Pre-built Docker images for each database type
- 🔗 **Universal Interface**: Consistent API across all database types
- 🔐 **Secure**: Environment-based credential management
- 📊 **Extensive Database Support**: 20+ database systems supported
- 🐳 **Container Native**: Optimized for containerized environments

## 🐳 About These Images

All database images use the official Google Database Toolbox as the base:
```
us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest
```

Each database configuration runs this image with the appropriate source type and the `--prebuilt` flag to automatically load the necessary tools.

## 📋 Supported Databases

| Database | Type | Description |
|----------|------|-------------|
| [AlloyDB for PostgreSQL](#alloydb-for-postgresql) | SQL | Fully-managed PostgreSQL-compatible database |
| [BigQuery](#bigquery) | Analytics | Petabyte-scale analytics data warehouse |
| [Bigtable](#bigtable) | NoSQL | Low-latency wide-column store |
| [Cloud SQL for MySQL](#cloud-sql-for-mysql) | SQL | Fully-managed MySQL database service |
| [Cloud SQL for PostgreSQL](#cloud-sql-for-postgresql) | SQL | Fully-managed PostgreSQL database service |
| [Cloud SQL for SQL Server](#cloud-sql-for-sql-server) | SQL | Fully-managed SQL Server database service |
| [Couchbase](#couchbase) | NoSQL | Distributed document database |
| [Dataplex](#dataplex) | Catalog | Unified data governance solution |
| [Dgraph](#dgraph) | Graph | Distributed graph database |
| [Firestore](#firestore) | NoSQL | Serverless document database |
| [Looker](#looker) | BI | Business intelligence platform |
| [MongoDB](#mongodb) | NoSQL | Document-oriented database |
| [MySQL](#mysql) | SQL | Open-source relational database |
| [Neo4j](#neo4j) | Graph | Graph database management system |
| [PostgreSQL](#postgresql) | SQL | Open-source object-relational database |
| [Redis](#redis) | Cache/NoSQL | In-memory data structure store |
| [Spanner](#spanner) | SQL | Globally distributed relational database |
| [SQL Server](#sql-server) | SQL | Microsoft relational database |
| [SQLite](#sqlite) | SQL | Lightweight file-based database |
| [TiDB](#tidb) | SQL | Distributed SQL database |
| [Valkey](#valkey) | Cache/NoSQL | Open-source Redis fork |

## 🗄️ Database Configurations

---

## AlloyDB for PostgreSQL

AlloyDB for PostgreSQL is a fully-managed, PostgreSQL-compatible database for demanding transactional workloads.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-alloydb \
  -p 3000:3000 \
  -e ALLOYDB_PROJECT=my-project \
  -e ALLOYDB_REGION=us-central1 \
  -e ALLOYDB_CLUSTER=my-cluster \
  -e ALLOYDB_INSTANCE=my-instance \
  -e ALLOYDB_DATABASE=mydb \
  -e ALLOYDB_USER=postgres \
  -e ALLOYDB_PASSWORD=your-password \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source alloydb \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "alloydb": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "ALLOYDB_PROJECT=my-project",
        "-e", "ALLOYDB_REGION=us-central1", 
        "-e", "ALLOYDB_CLUSTER=my-cluster",
        "-e", "ALLOYDB_INSTANCE=my-instance",
        "-e", "ALLOYDB_DATABASE=mydb",
        "-e", "ALLOYDB_USER=postgres",
        "-e", "ALLOYDB_PASSWORD=your-password",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "alloydb",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `ALLOYDB_PROJECT` | Yes | GCP project ID | - | `my-project` |
| `ALLOYDB_REGION` | Yes | GCP region | - | `us-central1` |
| `ALLOYDB_CLUSTER` | Yes | AlloyDB cluster ID | - | `my-cluster` |
| `ALLOYDB_INSTANCE` | Yes | AlloyDB instance ID | - | `my-instance` |
| `ALLOYDB_DATABASE` | Yes | Database name | - | `mydb` |
| `ALLOYDB_USER` | Yes | Database username | - | `postgres` |
| `ALLOYDB_PASSWORD` | Yes | Database password | - | `your-password` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all AlloyDB-specific tools, including query execution, schema inspection, and AI-powered natural language capabilities.

---

## BigQuery

BigQuery is Google Cloud's fully managed, petabyte-scale analytics data warehouse.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-bigquery \
  -p 3000:3000 \
  -e BIGQUERY_PROJECT=my-project \
  -e BIGQUERY_DATASET=my_dataset \
  -e GOOGLE_APPLICATION_CREDENTIALS=/creds/sa.json \
  -v /path/to/service-account.json:/creds/sa.json \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source bigquery \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "bigquery": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "BIGQUERY_PROJECT=my-project",
        "-e", "BIGQUERY_DATASET=my_dataset",
        "-v", "/path/to/service-account.json:/creds/sa.json",
        "-e", "GOOGLE_APPLICATION_CREDENTIALS=/creds/sa.json",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "bigquery",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `BIGQUERY_PROJECT` | Yes | GCP project ID | - | `my-project` |
| `BIGQUERY_DATASET` | No | Default dataset | - | `my_dataset` |
| `BIGQUERY_LOCATION` | No | BigQuery location | `US` | `US`, `EU` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Yes* | Path to service account JSON | - | `/creds/sa.json` |

*Either provide `GOOGLE_APPLICATION_CREDENTIALS` or ensure the container has access to GCP credentials through other means.

### MCP Tools Available
The `--prebuilt` flag automatically loads all BigQuery-specific tools, including SQL execution, dataset management, and table operations.

---

## Bigtable

Bigtable is a low-latency NoSQL database service for machine learning and operational analytics.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-bigtable \
  -p 3000:3000 \
  -e BIGTABLE_PROJECT=my-project \
  -e BIGTABLE_INSTANCE=my-instance \
  -e BIGTABLE_TABLE=my-table \
  -e GOOGLE_APPLICATION_CREDENTIALS=/creds/sa.json \
  -v /path/to/service-account.json:/creds/sa.json \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source bigtable \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "bigtable": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "BIGTABLE_PROJECT=my-project",
        "-e", "BIGTABLE_INSTANCE=my-instance",
        "-e", "BIGTABLE_TABLE=my-table",
        "-v", "/path/to/service-account.json:/creds/sa.json",
        "-e", "GOOGLE_APPLICATION_CREDENTIALS=/creds/sa.json",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "bigtable",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `BIGTABLE_PROJECT` | Yes | GCP project ID | - | `my-project` |
| `BIGTABLE_INSTANCE` | Yes | Bigtable instance ID | - | `my-instance` |
| `BIGTABLE_TABLE` | Yes | Bigtable table name | - | `my-table` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Yes* | Path to service account JSON | - | `/creds/sa.json` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all Bigtable-specific tools, including data operations and table management.

---

## Cloud SQL for MySQL

Cloud SQL for MySQL is a fully-managed database service for MySQL.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-cloudsql-mysql \
  -p 3000:3000 \
  -e CLOUDSQL_MYSQL_PROJECT=my-project \
  -e CLOUDSQL_MYSQL_REGION=us-central1 \
  -e CLOUDSQL_MYSQL_INSTANCE=my-instance \
  -e CLOUDSQL_MYSQL_DATABASE=mydb \
  -e CLOUDSQL_MYSQL_USER=root \
  -e CLOUDSQL_MYSQL_PASSWORD=your-password \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source cloud-sql-mysql \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "cloudsql-mysql": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "CLOUDSQL_MYSQL_PROJECT=my-project",
        "-e", "CLOUDSQL_MYSQL_REGION=us-central1",
        "-e", "CLOUDSQL_MYSQL_INSTANCE=my-instance",
        "-e", "CLOUDSQL_MYSQL_DATABASE=mydb",
        "-e", "CLOUDSQL_MYSQL_USER=root",
        "-e", "CLOUDSQL_MYSQL_PASSWORD=your-password",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "cloud-sql-mysql",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `CLOUDSQL_MYSQL_PROJECT` | Yes | GCP project ID | - | `my-project` |
| `CLOUDSQL_MYSQL_REGION` | Yes | GCP region | - | `us-central1` |
| `CLOUDSQL_MYSQL_INSTANCE` | Yes | Cloud SQL instance name | - | `my-instance` |
| `CLOUDSQL_MYSQL_DATABASE` | Yes | Database name | - | `mydb` |
| `CLOUDSQL_MYSQL_USER` | Yes | Database username | - | `root` |
| `CLOUDSQL_MYSQL_PASSWORD` | Yes | Database password | - | `your-password` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all Cloud SQL MySQL-specific tools, including query execution and schema management.

---

## Cloud SQL for PostgreSQL

Cloud SQL for PostgreSQL is a fully-managed database service for PostgreSQL.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-cloudsql-postgres \
  -p 3000:3000 \
  -e CLOUDSQL_POSTGRES_PROJECT=my-project \
  -e CLOUDSQL_POSTGRES_REGION=us-central1 \
  -e CLOUDSQL_POSTGRES_INSTANCE=my-instance \
  -e CLOUDSQL_POSTGRES_DATABASE=mydb \
  -e CLOUDSQL_POSTGRES_USER=postgres \
  -e CLOUDSQL_POSTGRES_PASSWORD=your-password \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source cloud-sql-postgres \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "cloudsql-postgres": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "CLOUDSQL_POSTGRES_PROJECT=my-project",
        "-e", "CLOUDSQL_POSTGRES_REGION=us-central1",
        "-e", "CLOUDSQL_POSTGRES_INSTANCE=my-instance",
        "-e", "CLOUDSQL_POSTGRES_DATABASE=mydb",
        "-e", "CLOUDSQL_POSTGRES_USER=postgres",
        "-e", "CLOUDSQL_POSTGRES_PASSWORD=your-password",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "cloud-sql-postgres",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `CLOUDSQL_POSTGRES_PROJECT` | Yes | GCP project ID | - | `my-project` |
| `CLOUDSQL_POSTGRES_REGION` | Yes | GCP region | - | `us-central1` |
| `CLOUDSQL_POSTGRES_INSTANCE` | Yes | Cloud SQL instance name | - | `my-instance` |
| `CLOUDSQL_POSTGRES_DATABASE` | Yes | Database name | - | `mydb` |
| `CLOUDSQL_POSTGRES_USER` | Yes | Database username | - | `postgres` |
| `CLOUDSQL_POSTGRES_PASSWORD` | Yes | Database password | - | `your-password` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all Cloud SQL PostgreSQL-specific tools, including query execution and schema management.

---

## Cloud SQL for SQL Server

Cloud SQL for SQL Server is a fully-managed database service for SQL Server.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-cloudsql-sqlserver \
  -p 3000:3000 \
  -e CLOUDSQL_SQLSERVER_PROJECT=my-project \
  -e CLOUDSQL_SQLSERVER_REGION=us-central1 \
  -e CLOUDSQL_SQLSERVER_INSTANCE=my-instance \
  -e CLOUDSQL_SQLSERVER_DATABASE=mydb \
  -e CLOUDSQL_SQLSERVER_USER=sqlserver \
  -e CLOUDSQL_SQLSERVER_PASSWORD=your-password \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source cloud-sql-mssql \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "cloudsql-sqlserver": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "CLOUDSQL_SQLSERVER_PROJECT=my-project",
        "-e", "CLOUDSQL_SQLSERVER_REGION=us-central1",
        "-e", "CLOUDSQL_SQLSERVER_INSTANCE=my-instance",
        "-e", "CLOUDSQL_SQLSERVER_DATABASE=mydb",
        "-e", "CLOUDSQL_SQLSERVER_USER=sqlserver",
        "-e", "CLOUDSQL_SQLSERVER_PASSWORD=your-password",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "cloud-sql-mssql",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `CLOUDSQL_SQLSERVER_PROJECT` | Yes | GCP project ID | - | `my-project` |
| `CLOUDSQL_SQLSERVER_REGION` | Yes | GCP region | - | `us-central1` |
| `CLOUDSQL_SQLSERVER_INSTANCE` | Yes | Cloud SQL instance name | - | `my-instance` |
| `CLOUDSQL_SQLSERVER_DATABASE` | Yes | Database name | - | `mydb` |
| `CLOUDSQL_SQLSERVER_USER` | Yes | Database username | - | `sqlserver` |
| `CLOUDSQL_SQLSERVER_PASSWORD` | Yes | Database password | - | `your-password` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all Cloud SQL SQL Server-specific tools, including query execution and schema management.

---

## Couchbase

Couchbase is a distributed NoSQL database.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-couchbase \
  -p 3000:3000 \
  -e COUCHBASE_HOST=localhost \
  -e COUCHBASE_BUCKET=my-bucket \
  -e COUCHBASE_USERNAME=Administrator \
  -e COUCHBASE_PASSWORD=your-password \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source couchbase \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "couchbase": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "COUCHBASE_HOST=localhost",
        "-e", "COUCHBASE_BUCKET=my-bucket",
        "-e", "COUCHBASE_USERNAME=Administrator",
        "-e", "COUCHBASE_PASSWORD=your-password",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "couchbase",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `COUCHBASE_HOST` | Yes | Couchbase host | - | `localhost` |
| `COUCHBASE_PORT` | No | Couchbase port | `8091` | `8091` |
| `COUCHBASE_BUCKET` | Yes | Bucket name | - | `my-bucket` |
| `COUCHBASE_USERNAME` | Yes | Username | - | `Administrator` |
| `COUCHBASE_PASSWORD` | Yes | Password | - | `your-password` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all Couchbase-specific tools, including document operations and bucket management.

---

## Dataplex

Dataplex Universal Catalog is a unified governance solution for data and AI assets in Google Cloud.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-dataplex \
  -p 3000:3000 \
  -e DATAPLEX_PROJECT=my-project \
  -e DATAPLEX_LOCATION=us-central1 \
  -e GOOGLE_APPLICATION_CREDENTIALS=/creds/sa.json \
  -v /path/to/service-account.json:/creds/sa.json \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source dataplex \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "dataplex": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "DATAPLEX_PROJECT=my-project",
        "-e", "DATAPLEX_LOCATION=us-central1",
        "-v", "/path/to/service-account.json:/creds/sa.json",
        "-e", "GOOGLE_APPLICATION_CREDENTIALS=/creds/sa.json",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "dataplex",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `DATAPLEX_PROJECT` | Yes | GCP project ID | - | `my-project` |
| `DATAPLEX_LOCATION` | Yes | Dataplex location | - | `us-central1` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Yes* | Path to service account JSON | - | `/creds/sa.json` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all Dataplex-specific tools, including entry lookup and search capabilities.

---

## Dgraph

Dgraph is a distributed graph database built for production.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-dgraph \
  -p 3000:3000 \
  -e DGRAPH_HOST=localhost \
  -e DGRAPH_PORT=9080 \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source dgraph \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "dgraph": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "DGRAPH_HOST=localhost",
        "-e", "DGRAPH_PORT=9080",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "dgraph",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `DGRAPH_HOST` | Yes | Dgraph host | - | `localhost` |
| `DGRAPH_PORT` | No | Dgraph gRPC port | `9080` | `9080` |
| `DGRAPH_API_KEY` | No | API key if using Dgraph Cloud | - | `your-api-key` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all Dgraph-specific tools, including DQL query execution and schema management.

---

## Firestore

Firestore is a NoSQL document database built for automatic scaling and ease of development.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-firestore \
  -p 3000:3000 \
  -e FIRESTORE_PROJECT=my-project \
  -e FIRESTORE_DATABASE=(default) \
  -e GOOGLE_APPLICATION_CREDENTIALS=/creds/sa.json \
  -v /path/to/service-account.json:/creds/sa.json \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source firestore \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "firestore": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "FIRESTORE_PROJECT=my-project",
        "-e", "FIRESTORE_DATABASE=(default)",
        "-v", "/path/to/service-account.json:/creds/sa.json",
        "-e", "GOOGLE_APPLICATION_CREDENTIALS=/creds/sa.json",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "firestore",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `FIRESTORE_PROJECT` | Yes | GCP project ID | - | `my-project` |
| `FIRESTORE_DATABASE` | No | Database ID | `(default)` | `(default)` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Yes* | Path to service account JSON | - | `/creds/sa.json` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all Firestore-specific tools, including document operations, collection management, and query capabilities.

---

## Looker

Looker is a business intelligence and data platform.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-looker \
  -p 3000:3000 \
  -e LOOKER_BASE_URL=https://mycompany.looker.com \
  -e LOOKER_CLIENT_ID=your-client-id \
  -e LOOKER_CLIENT_SECRET=your-client-secret \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source looker \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "looker": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "LOOKER_BASE_URL=https://mycompany.looker.com",
        "-e", "LOOKER_CLIENT_ID=your-client-id",
        "-e", "LOOKER_CLIENT_SECRET=your-client-secret",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "looker",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|  
| `LOOKER_BASE_URL` | Yes | Looker instance URL | - | `https://mycompany.looker.com` |
| `LOOKER_CLIENT_ID` | Yes | API client ID | - | `your-client-id` |
| `LOOKER_CLIENT_SECRET` | Yes | API client secret | - | `your-client-secret` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all Looker-specific tools, including query execution, model exploration, and dashboard operations.

---

## MongoDB

MongoDB is a document-oriented NoSQL database.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-mongodb \
  -p 3000:3000 \
  -e MONGODB_URI=mongodb://localhost:27017 \
  -e MONGODB_DATABASE=mydb \
  -e MONGODB_USERNAME=admin \
  -e MONGODB_PASSWORD=your-password \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source mongodb \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "mongodb": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "MONGODB_URI=mongodb://localhost:27017",
        "-e", "MONGODB_DATABASE=mydb",
        "-e", "MONGODB_USERNAME=admin",
        "-e", "MONGODB_PASSWORD=your-password",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "mongodb",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `MONGODB_URI` | Yes | MongoDB connection URI | - | `mongodb://localhost:27017` |
| `MONGODB_DATABASE` | Yes | Database name | - | `mydb` |
| `MONGODB_USERNAME` | No | Username | - | `admin` |
| `MONGODB_PASSWORD` | No | Password | - | `your-password` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all MongoDB-specific tools, including document operations, aggregation, and collection management.

---

## MySQL

MySQL is an open-source relational database management system.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-mysql \
  -p 3000:3000 \
  -e MYSQL_HOST=localhost \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USER=root \
  -e MYSQL_PASSWORD=your-password \
  -e MYSQL_PORT=3306 \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source mysql \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "mysql": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "MYSQL_HOST=localhost",
        "-e", "MYSQL_DATABASE=mydb",
        "-e", "MYSQL_USER=root",
        "-e", "MYSQL_PASSWORD=your-password",
        "-e", "MYSQL_PORT=3306",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "mysql",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|  
| `MYSQL_HOST` | Yes | MySQL host | - | `localhost` |
| `MYSQL_PORT` | No | MySQL port | `3306` | `3306` |
| `MYSQL_DATABASE` | Yes | Database name | - | `mydb` |
| `MYSQL_USER` | Yes | Username | - | `root` |
| `MYSQL_PASSWORD` | Yes | Password | - | `your-password` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all MySQL-specific tools, including query execution and schema management.

---

## Neo4j

Neo4j is a graph database management system.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-neo4j \
  -p 3000:3000 \
  -e NEO4J_URI=bolt://localhost:7687 \
  -e NEO4J_USERNAME=neo4j \
  -e NEO4J_PASSWORD=your-password \
  -e NEO4J_DATABASE=neo4j \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source neo4j \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "neo4j": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "NEO4J_URI=bolt://localhost:7687",
        "-e", "NEO4J_USERNAME=neo4j",
        "-e", "NEO4J_PASSWORD=your-password",
        "-e", "NEO4J_DATABASE=neo4j",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "neo4j",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `NEO4J_URI` | Yes | Neo4j connection URI | - | `bolt://localhost:7687` |
| `NEO4J_USERNAME` | Yes | Username | - | `neo4j` |
| `NEO4J_PASSWORD` | Yes | Password | - | `your-password` |
| `NEO4J_DATABASE` | No | Database name | `neo4j` | `neo4j` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all Neo4j-specific tools, including Cypher query execution and schema operations.

---

## PostgreSQL

PostgreSQL is a powerful, open-source object-relational database system.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-postgres \
  -p 3000:3000 \
  -e POSTGRES_HOST=localhost \
  -e POSTGRES_DATABASE=mydb \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=your-password \
  -e POSTGRES_PORT=5432 \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source postgres \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "postgres": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "POSTGRES_HOST=localhost",
        "-e", "POSTGRES_DATABASE=mydb",
        "-e", "POSTGRES_USER=postgres",
        "-e", "POSTGRES_PASSWORD=your-password",
        "-e", "POSTGRES_PORT=5432",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "postgres",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|
| `POSTGRES_HOST` | Yes | PostgreSQL host | - | `localhost` |
| `POSTGRES_PORT` | No | PostgreSQL port | `5432` | `5432` |
| `POSTGRES_DATABASE` | Yes | Database name | - | `mydb` |
| `POSTGRES_USER` | Yes | Username | - | `postgres` |
| `POSTGRES_PASSWORD` | Yes | Password | - | `your-password` |
| `POSTGRES_SSL_MODE` | No | SSL mode | `prefer` | `disable`, `require` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all PostgreSQL-specific tools, including query execution, schema inspection, and transaction management.

---

## Redis

Redis is an in-memory data structure store.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-redis \
  -p 3000:3000 \
  -e REDIS_HOST=localhost \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=your-password \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source redis \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "redis": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "REDIS_HOST=localhost",
        "-e", "REDIS_PORT=6379",
        "-e", "REDIS_PASSWORD=your-password",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "redis",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|  
| `REDIS_HOST` | Yes | Redis host | - | `localhost` |
| `REDIS_PORT` | No | Redis port | `6379` | `6379` |
| `REDIS_PASSWORD` | No | Password | - | `your-password` |
| `REDIS_DB` | No | Database number | `0` | `0` |
| `REDIS_USERNAME` | No | Username (Redis 6+) | - | `default` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all Redis-specific tools, including key-value operations and server management.

---

## Spanner

Spanner is Google's globally distributed relational database service.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-spanner \
  -p 3000:3000 \
  -e SPANNER_PROJECT=my-project \
  -e SPANNER_INSTANCE=my-instance \
  -e SPANNER_DATABASE=mydb \
  -e GOOGLE_APPLICATION_CREDENTIALS=/creds/sa.json \
  -v /path/to/service-account.json:/creds/sa.json \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source spanner \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "spanner": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "SPANNER_PROJECT=my-project",
        "-e", "SPANNER_INSTANCE=my-instance",
        "-e", "SPANNER_DATABASE=mydb",
        "-v", "/path/to/service-account.json:/creds/sa.json",
        "-e", "GOOGLE_APPLICATION_CREDENTIALS=/creds/sa.json",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "spanner",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|  
| `SPANNER_PROJECT` | Yes | GCP project ID | - | `my-project` |
| `SPANNER_INSTANCE` | Yes | Spanner instance ID | - | `my-instance` |
| `SPANNER_DATABASE` | Yes | Database name | - | `mydb` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Yes* | Path to service account JSON | - | `/creds/sa.json` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all Spanner-specific tools, including SQL execution and schema management.

---

## SQL Server

Microsoft SQL Server is a relational database management system.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-sqlserver \
  -p 3000:3000 \
  -e SQLSERVER_HOST=localhost \
  -e SQLSERVER_DATABASE=mydb \
  -e SQLSERVER_USER=sa \
  -e SQLSERVER_PASSWORD=your-password \
  -e SQLSERVER_PORT=1433 \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source mssql \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "sqlserver": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "SQLSERVER_HOST=localhost",
        "-e", "SQLSERVER_DATABASE=mydb",
        "-e", "SQLSERVER_USER=sa",
        "-e", "SQLSERVER_PASSWORD=your-password",
        "-e", "SQLSERVER_PORT=1433",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "mssql",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|  
| `SQLSERVER_HOST` | Yes | SQL Server host | - | `localhost` |
| `SQLSERVER_PORT` | No | SQL Server port | `1433` | `1433` |
| `SQLSERVER_DATABASE` | Yes | Database name | - | `mydb` |
| `SQLSERVER_USER` | Yes | Username | - | `sa` |
| `SQLSERVER_PASSWORD` | Yes | Password | - | `your-password` |
| `SQLSERVER_TRUST_CERT` | No | Trust server certificate | `false` | `true`, `false` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all SQL Server-specific tools, including query execution and schema management.

---

## SQLite

SQLite is a lightweight, file-based relational database.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-sqlite \
  -p 3000:3000 \
  -v /path/to/mydb.sqlite:/data/mydb.sqlite \
  -e SQLITE_FILE=/data/mydb.sqlite \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source sqlite \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "sqlite": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-v", "/path/to/mydb.sqlite:/data/mydb.sqlite",
        "-e", "SQLITE_FILE=/data/mydb.sqlite",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "sqlite",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|  
| `SQLITE_FILE` | Yes | Path to SQLite file | - | `/data/mydb.sqlite` |
| `SQLITE_READONLY` | No | Open in read-only mode | `false` | `true`, `false` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all SQLite-specific tools, including SQL execution and schema operations.

---

## TiDB

TiDB is a distributed SQL database.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-tidb \
  -p 3000:3000 \
  -e TIDB_HOST=localhost \
  -e TIDB_DATABASE=mydb \
  -e TIDB_USER=root \
  -e TIDB_PASSWORD=your-password \
  -e TIDB_PORT=4000 \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source tidb \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "tidb": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "TIDB_HOST=localhost",
        "-e", "TIDB_DATABASE=mydb",
        "-e", "TIDB_USER=root",
        "-e", "TIDB_PASSWORD=your-password",
        "-e", "TIDB_PORT=4000",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "tidb",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|  
| `TIDB_HOST` | Yes | TiDB host | - | `localhost` |
| `TIDB_PORT` | No | TiDB port | `4000` | `4000` |
| `TIDB_DATABASE` | Yes | Database name | - | `mydb` |
| `TIDB_USER` | Yes | Username | - | `root` |
| `TIDB_PASSWORD` | No | Password | - | `your-password` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all TiDB-specific tools, including SQL execution and schema management.

---

## Valkey

Valkey is an open-source in-memory data store, forked from Redis.

### Docker Command
```bash
docker run --rm -d \
  --name mcp-valkey \
  -p 3000:3000 \
  -e VALKEY_HOST=localhost \
  -e VALKEY_PORT=6379 \
  -e VALKEY_PASSWORD=your-password \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --source valkey \
  --prebuilt
```

### MCP Client Configuration
```json
{
  "mcpServers": {
    "valkey": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "-e", "VALKEY_HOST=localhost",
        "-e", "VALKEY_PORT=6379",
        "-e", "VALKEY_PASSWORD=your-password",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "valkey",
        "--prebuilt"
      ]
    }
  }
}
```

### Environment Variables
| Variable | Required | Description | Default | Example |
|----------|----------|-------------|---------|---------|  
| `VALKEY_HOST` | Yes | Valkey host | - | `localhost` |
| `VALKEY_PORT` | No | Valkey port | `6379` | `6379` |
| `VALKEY_PASSWORD` | No | Password | - | `your-password` |
| `VALKEY_DB` | No | Database number | `0` | `0` |
| `VALKEY_USERNAME` | No | Username | - | `default` |

### MCP Tools Available
The `--prebuilt` flag automatically loads all Valkey-specific tools, including key-value operations and server management.

---

## 🛡️ Security Best Practices

### Use Environment Files
Instead of passing sensitive credentials directly in the command line, use environment files:

```bash
# Create .env file
cat > .env << EOF
POSTGRES_HOST=localhost
POSTGRES_DATABASE=mydb
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-secure-password
EOF

# Use in MCP config
{
  "mcpServers": {
    "postgres": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull", "always",
        "--env-file", ".env",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--source", "postgres",
        "--prebuilt"
      ]
    }
  }
}
```

### Use Docker Secrets
For production environments, consider using Docker secrets or a secret management service.

## 📚 Additional Resources

- [Google Database Toolbox Documentation](https://googleapis.github.io/genai-toolbox/)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [MCP Server Examples](https://github.com/modelcontextprotocol/servers)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.