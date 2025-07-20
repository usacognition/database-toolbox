# Development Guide

This guide explains how to set up a development environment, run tests, and contribute to the MCP Database Servers project.

## 🚀 Quick Start for Developers

### Prerequisites

- Docker and Docker Compose
- Git
- Bash shell (Linux/macOS/WSL)

### Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/mcp-database-servers.git
   cd mcp-database-servers
   ```

2. **Set up development environment:**
   ```bash
   # Set up and start all services
   ./tests/run_tests.sh setup
   ```

3. **Access development services:**
   - **PostgreSQL MCP Server**: http://localhost:5000
   - **MySQL MCP Server**: http://localhost:5001
   - **pgAdmin**: http://localhost:8080 (admin@mcp.dev / admin123)
   - **phpMyAdmin**: http://localhost:8081
   - **Test Reports**: http://localhost:8082

## 🧪 Testing

### Test Framework Overview

The project uses a comprehensive testing framework with:
- **pytest** for test execution
- **Docker Compose** for test environment
- **Database inspectors** (pgAdmin, phpMyAdmin) for manual verification
- **Automated test reports** with HTML output
- **Integration tests** across multiple databases

### Running Tests

#### Basic Test Commands

```bash
# Run all tests
./tests/run_tests.sh test

# Run quick tests only (exclude slow/integration tests)
./tests/run_tests.sh test-quick

# Run PostgreSQL tests only
./tests/run_tests.sh test-db -d postgres

# Run MySQL tests only  
./tests/run_tests.sh test-db -d mysql

# Run integration tests
./tests/run_tests.sh test-integration

# Run specific test by keyword
./tests/run_tests.sh test -k "health_check"

# Run with verbose output and HTML report
./tests/run_tests.sh test -v --html-report
```

#### Advanced Test Options

```bash
# Keep environment running after tests
./tests/run_tests.sh test --keep-running

# Don't rebuild images before testing
./tests/run_tests.sh test --no-build

# Run tests with specific pytest marker
./tests/run_tests.sh test -m "integration and not slow"

# Show test logs
./tests/run_tests.sh logs

# Clean up test environment
./tests/run_tests.sh clean
```

### Test Categories

#### 1. Health Check Tests (`test_health_checks.py`)
- MCP server health endpoints
- Basic connectivity tests
- Tool availability verification

#### 2. Database-Specific Tests
- **PostgreSQL** (`test_postgres.py`): PostgreSQL-specific features and SQL
- **MySQL** (`test_mysql.py`): MySQL-specific features and SQL
- Direct database connection tests
- Database-specific function testing

#### 3. Integration Tests (`test_integration.py`)
- Multi-database operations
- Concurrent query execution
- MCP protocol compliance
- Load and stress testing

### Test Environment Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │    │      MySQL      │    │  Test Runner    │
│    Database     │    │    Database     │    │   Container     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       │
┌─────────────────┐    ┌─────────────────┐               │
│ MCP PostgreSQL  │    │   MCP MySQL     │               │
│     Server      │    │    Server       │               │
└─────────────────┘    └─────────────────┘               │
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                                 ▼
                    ┌─────────────────┐
                    │   Test Reports  │
                    │   (Web Viewer)  │
                    └─────────────────┘
```

## 🔧 Development Workflow

### 1. Making Changes

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** to Dockerfiles, scripts, or tests

3. **Test your changes:**
   ```bash
   # Test specific database if you changed database-specific code
   ./tests/run_tests.sh test-db -d postgres
   
   # Run integration tests
   ./tests/run_tests.sh test-integration
   
   # Run all tests
   ./tests/run_tests.sh test
   ```

### 2. Adding New Database Support

To add support for a new database (e.g., Snowflake):

1. **Create Dockerfile:**
   ```bash
   cp Dockerfile.postgres Dockerfile.snowflake
   # Modify for Snowflake-specific dependencies
   ```

2. **Update scripts:**
   - Add Snowflake support to `scripts/entrypoint.sh`
   - Add health check logic to `scripts/healthcheck.sh`

3. **Add to build system:**
   - Update `build.sh` DATABASES array
   - Update `Makefile` targets
   - Update GitHub Actions workflow

4. **Create tests:**
   ```bash
   cp tests/test_postgres.py tests/test_snowflake.py
   # Modify for Snowflake-specific features
   ```

5. **Update Docker Compose:**
   - Add Snowflake MCP service to development compose file
   - Add any required configuration

### 3. Testing Changes

```bash
# Build and test your changes
./build.sh build-db -d your-database --test

# Run comprehensive tests
./tests/run_tests.sh test --html-report

# Check test coverage
./tests/run_tests.sh test --html-report -v
```

## 🏗️ Project Structure

```
mcp-database-servers/
├── Dockerfile.{postgres,mysql,snowflake,redshift}  # Database-specific images
├── scripts/
│   ├── entrypoint.sh                               # Container entrypoint
│   └── healthcheck.sh                              # Health check script
├── tests/
│   ├── Dockerfile.test                             # Test runner image
│   ├── conftest.py                                 # Pytest configuration
│   ├── test_health_checks.py                      # Health check tests
│   ├── test_postgres.py                           # PostgreSQL tests
│   ├── test_mysql.py                              # MySQL tests
│   ├── test_integration.py                        # Integration tests
│   ├── requirements.txt                           # Test dependencies
│   └── run_tests.sh                               # Test runner script
├── examples/
│   ├── docker-compose/
│   │   ├── docker-compose.dev.yml                 # Development environment
│   │   ├── docker-compose.all.yml                 # All databases
│   │   ├── pgadmin-servers.json                   # pgAdmin configuration
│   │   └── nginx.conf                             # Test viewer config
│   └── configs/                                   # Configuration examples
├── .github/workflows/                             # CI/CD pipelines
├── build.sh                                       # Build automation
├── Makefile                                       # Alternative build system
└── README.md                                      # User documentation
```

## 🐛 Debugging

### Viewing Logs

```bash
# MCP server logs
docker logs dev-mcp-postgres
docker logs dev-mcp-mysql

# Database logs
docker logs dev-postgres
docker logs dev-mysql

# All logs
./tests/run_tests.sh logs
```

### Connecting to Containers

```bash
# Connect to MCP server container
docker exec -it dev-mcp-postgres /bin/bash

# Connect to database container
docker exec -it dev-postgres psql -U testuser -d testdb

# Run test container interactively
docker-compose -f examples/docker-compose/docker-compose.dev.yml run --rm -it mcp-tester bash
```

### Manual Testing

```bash
# Test MCP endpoints directly
curl http://localhost:5000/health
curl -X POST http://localhost:5000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "tools/list", "params": {}}'

# Test database connectivity
docker exec -it dev-postgres pg_isready -U testuser -d testdb
docker exec -it dev-mysql mysqladmin ping -u testuser -ptestpass
```

## 📊 Performance Testing

### Load Testing

```bash
# Run performance tests
./tests/run_tests.sh test -m slow

# Run specific performance test
./tests/run_tests.sh test -k "performance"
```

### Monitoring

Monitor containers during development:

```bash
# Resource usage
docker stats dev-mcp-postgres dev-mcp-mysql

# Container health
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

## 🚢 Release Process

1. **Update version numbers** in build scripts and Dockerfiles
2. **Run full test suite:**
   ```bash
   ./tests/run_tests.sh test --html-report
   ```
3. **Build and tag images:**
   ```bash
   ./build.sh build --push -v v1.0.0
   ```
4. **Create git tag:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
5. **GitHub Actions** will automatically build and push to DockerHub

## 🤝 Contributing

### Code Style

- Follow existing patterns in Dockerfiles and scripts
- Use clear, descriptive variable names
- Add comments for complex logic
- Include error handling and logging

### Testing Requirements

- All new features must include tests
- Tests must pass in CI/CD pipeline
- Include both unit and integration tests
- Add database-specific tests for new database support

### Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Run the full test suite
5. Update documentation if needed
6. Submit a pull request with clear description

### Review Criteria

- Code quality and style
- Test coverage
- Documentation updates
- Security considerations
- Performance impact

## 📚 Additional Resources

- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [Google MCP Toolbox Documentation](https://googleapis.github.io/genai-toolbox/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [pytest Documentation](https://docs.pytest.org/)

## 🆘 Getting Help

- **Issues**: [GitHub Issues](https://github.com/your-username/mcp-database-servers/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/mcp-database-servers/discussions)
- **Contributing**: See [CONTRIBUTING.md](CONTRIBUTING.md)