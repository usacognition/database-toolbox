# MCP Database Server Docker Images

Ready-to-use Docker images for Google's MCP (Model Context Protocol) Toolbox for Databases, supporting PostgreSQL, MySQL, Snowflake, and Redshift connections.

## Overview

This repository provides production-ready Docker images that package Google's MCP Toolbox for Databases with pre-configured support for major database systems. Each image includes all necessary drivers and tools to connect AI agents to databases through the standardized MCP protocol.

## Supported Databases

- **PostgreSQL** - Full PostgreSQL support with psycopg2 driver
- **MySQL** - MySQL and MariaDB support with PyMySQL driver  
- **Snowflake** - Snowflake Data Cloud connectivity
- **Redshift** - Amazon Redshift data warehouse support

## Features

✅ **Unified Interface** - Same tools and capabilities across all database types  
✅ **Runtime Configuration** - Pass connection parameters at runtime  
✅ **Production Ready** - Optimized for production deployments  
✅ **MCP Compatible** - Full Model Context Protocol support  
✅ **Secure** - Environment-based credential management  
✅ **Observability** - Built-in OpenTelemetry support  

## Quick Start

### 1. Build Images (Optional - Pre-built images available on DockerHub)
```bash
# Clone this repository
git clone <repository-url>
cd mcp-database-servers

# Build all images
./build.sh build --test

# Or build and push to your DockerHub account
./build.sh build --push -n your-dockerhub-username
```

### 2. Run Individual Database Servers

#### PostgreSQL
```bash
docker run -d \
  -p 5000:5000 \
  -e DB_TYPE=postgres \
  -e DB_HOST=your-postgres-host \
  -e DB_PORT=5432 \
  -e DB_NAME=your-database \
  -e DB_USER=your-username \
  -e DB_PASSWORD=your-password \
  your-dockerhub-username/mcp-postgres:latest
```

#### MySQL
```bash
docker run -d \
  -p 5000:5000 \
  -e DB_TYPE=mysql \
  -e DB_HOST=your-mysql-host \
  -e DB_PORT=3306 \
  -e DB_NAME=your-database \
  -e DB_USER=your-username \
  -e DB_PASSWORD=your-password \
  your-dockerhub-username/mcp-mysql:latest
```

#### Snowflake
```bash
docker run -d \
  -p 5000:5000 \
  -e DB_TYPE=snowflake \
  -e SNOWFLAKE_ACCOUNT=your-account \
  -e SNOWFLAKE_USER=your-username \
  -e SNOWFLAKE_PASSWORD=your-password \
  -e SNOWFLAKE_DATABASE=your-database \
  -e SNOWFLAKE_SCHEMA=your-schema \
  -e SNOWFLAKE_WAREHOUSE=your-warehouse \
  your-dockerhub-username/mcp-snowflake:latest
```

#### Redshift
```bash
docker run -d \
  -p 5000:5000 \
  -e DB_TYPE=redshift \
  -e REDSHIFT_HOST=your-redshift-cluster.region.redshift.amazonaws.com \
  -e REDSHIFT_PORT=5439 \
  -e REDSHIFT_DATABASE=your-database \
  -e REDSHIFT_USER=your-username \
  -e REDSHIFT_PASSWORD=your-password \
  your-dockerhub-username/mcp-redshift:latest
```

### 3. Docker Compose (Recommended for Development)
```bash
# Start PostgreSQL and MySQL with their MCP servers
cd examples/docker-compose
docker-compose -f docker-compose.all.yml up postgres mcp-postgres mysql mcp-mysql

# Or start all services including external databases (requires .env file)
cp ../configs/.env.snowflake.example .env
# Edit .env with your credentials
docker-compose -f docker-compose.all.yml --profile snowflake --profile redshift up
```

### 4. Test the Connection
```bash
# Check if the server is running
curl http://localhost:5000/health

# View logs
docker logs mcp-postgres

# Test MCP protocol (if you have an MCP client)
# The server exposes both HTTP and stdio interfaces
```

## Available Tools

Each MCP server provides the following standardized tools:

### Query Tools
- **execute-sql** - Execute arbitrary SQL queries
- **sql** - Execute SQL with parameter binding

### Schema Inspection
- **list-tables** - List all tables in the database
- **describe-table** - Get detailed table schema information
- **get-table-info** - Retrieve table metadata

### Database Management
- **get-connection-info** - Verify database connectivity
- **list-schemas** - List available schemas/databases

## MCP Client Configuration

### Claude Desktop
Add to your `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "postgres-db": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "-e", "DB_HOST=your-host",
        "-e", "DB_USER=your-user", 
        "-e", "DB_PASSWORD=your-password",
        "-e", "DB_NAME=your-database",
        "your-dockerhub-username/mcp-postgres:latest",
        "--stdio"
      ]
    }
  }
}
```

### Cursor IDE
Add to your `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "database": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "-e", "DB_HOST=localhost",
        "-e", "DB_USER=myuser",
        "-e", "DB_PASSWORD=mypassword", 
        "-e", "DB_NAME=mydatabase",
        "your-dockerhub-username/mcp-mysql:latest",
        "--stdio"
      ]
    }
  }
}
```

## Environment Variables

### PostgreSQL
- `DB_HOST` - Database host (required)
- `DB_PORT` - Database port (default: 5432)
- `DB_NAME` - Database name (required)
- `DB_USER` - Database username (required)
- `DB_PASSWORD` - Database password (required)
- `DB_SSL_MODE` - SSL mode (default: prefer)

### MySQL
- `DB_HOST` - Database host (required)
- `DB_PORT` - Database port (default: 3306)
- `DB_NAME` - Database name (required)
- `DB_USER` - Database username (required)
- `DB_PASSWORD` - Database password (required)
- `DB_CHARSET` - Character set (default: utf8mb4)

### Snowflake
- `SNOWFLAKE_ACCOUNT` - Snowflake account identifier (required)
- `SNOWFLAKE_USER` - Username (required)
- `SNOWFLAKE_PASSWORD` - Password (required)
- `SNOWFLAKE_DATABASE` - Database name (required)
- `SNOWFLAKE_SCHEMA` - Schema name (default: PUBLIC)
- `SNOWFLAKE_WAREHOUSE` - Warehouse name (required)
- `SNOWFLAKE_ROLE` - Role name (optional)

### Redshift
- `REDSHIFT_HOST` - Redshift cluster endpoint (required)
- `REDSHIFT_PORT` - Port (default: 5439)
- `REDSHIFT_DATABASE` - Database name (required)
- `REDSHIFT_USER` - Username (required)
- `REDSHIFT_PASSWORD` - Password (required)
- `REDSHIFT_SSL` - Use SSL (default: true)

## Docker Images

All images are based on the official Google MCP Toolbox and include:

- Latest MCP Toolbox binary
- Database-specific drivers and dependencies
- Optimized for production use
- Multi-architecture support (amd64, arm64)
- Minimal attack surface

## Building from Source

```bash
# Build all images
make build-all

# Build specific database
make build-postgres
make build-mysql  
make build-snowflake
make build-redshift

# Push to registry
make push-all
```

## Example Usage

### Connect to PostgreSQL and Query Data
```bash
# Start the MCP server
docker run -d --name mcp-postgres \
  -p 5000:5000 \
  -e DB_HOST=localhost \
  -e DB_NAME=mydb \
  -e DB_USER=myuser \
  -e DB_PASSWORD=mypassword \
  your-dockerhub-username/mcp-postgres:latest

# The server exposes MCP endpoints at:
# - HTTP: http://localhost:5000/mcp
# - SSE: http://localhost:5000/mcp/sse  
# - STDIO: docker exec -i mcp-postgres /app/toolbox --stdio
```

### Use with AI Agents
The MCP server can be used with any MCP-compatible AI client:

```python
# Python example using MCP client
from mcp import Client

async with Client("http://localhost:5000/mcp") as client:
    # List available tools
    tools = await client.list_tools()
    
    # Execute a query
    result = await client.call_tool("execute-sql", {
        "query": "SELECT * FROM users WHERE active = true"
    })
```

## Security Considerations

- Never hardcode credentials in Docker images
- Use environment variables or secrets management
- Run containers with non-root users in production
- Enable SSL/TLS for database connections
- Use network policies to restrict access
- Regularly update base images and dependencies

## Monitoring and Observability

Each image includes built-in observability features:

- **Health Checks** - Kubernetes-ready health endpoints
- **Metrics** - Prometheus-compatible metrics
- **Tracing** - OpenTelemetry distributed tracing
- **Logging** - Structured JSON logging

Access metrics at: `http://localhost:5000/metrics`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if needed
5. Submit a pull request

## License

This project is licensed under the Apache 2.0 License - see the LICENSE file for details.

## Support

For issues and questions:
- Check the [Google MCP Toolbox documentation](https://googleapis.github.io/genai-toolbox/)
- Open an issue in this repository
- Join the MCP community discussions
