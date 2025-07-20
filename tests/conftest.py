"""
Pytest configuration and shared fixtures for MCP Database Server tests.
"""

import os
import time
import pytest
import requests
import psycopg2
import pymysql
from typing import Dict, Any, Optional
from tenacity import retry, stop_after_attempt, wait_exponential


# Test configuration
POSTGRES_MCP_URL = os.getenv("POSTGRES_MCP_URL", "http://localhost:5000")
MYSQL_MCP_URL = os.getenv("MYSQL_MCP_URL", "http://localhost:5001")
SNOWFLAKE_MCP_URL = os.getenv("SNOWFLAKE_MCP_URL", "http://localhost:5002")
REDSHIFT_MCP_URL = os.getenv("REDSHIFT_MCP_URL", "http://localhost:5003")

TEST_TIMEOUT = int(os.getenv("TEST_TIMEOUT", "60"))

# Database connection details
POSTGRES_CONFIG = {
    "host": "postgres",
    "port": 5432,
    "database": "testdb",
    "user": "testuser",
    "password": "testpass"
}

MYSQL_CONFIG = {
    "host": "mysql",
    "port": 3306,
    "database": "testdb",
    "user": "testuser",
    "password": "testpass"
}


@retry(stop=stop_after_attempt(10), wait=wait_exponential(multiplier=1, min=1, max=10))
def wait_for_service(url: str, timeout: int = 30) -> bool:
    """Wait for a service to become available."""
    try:
        response = requests.get(f"{url}/health", timeout=timeout)
        return response.status_code == 200
    except requests.RequestException:
        raise Exception(f"Service at {url} not ready")


@pytest.fixture(scope="session")
def postgres_mcp_client():
    """Fixture for PostgreSQL MCP client."""
    wait_for_service(POSTGRES_MCP_URL)
    return MCPClient(POSTGRES_MCP_URL)


@pytest.fixture(scope="session")
def mysql_mcp_client():
    """Fixture for MySQL MCP client."""
    wait_for_service(MYSQL_MCP_URL)
    return MCPClient(MYSQL_MCP_URL)


@pytest.fixture(scope="session")
def postgres_db():
    """Fixture for direct PostgreSQL database connection."""
    connection = psycopg2.connect(**POSTGRES_CONFIG)
    yield connection
    connection.close()


@pytest.fixture(scope="session")
def mysql_db():
    """Fixture for direct MySQL database connection."""
    connection = pymysql.connect(**MYSQL_CONFIG)
    yield connection
    connection.close()


class MCPClient:
    """Simple MCP client for testing."""
    
    def __init__(self, base_url: str):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        })
    
    def health_check(self) -> Dict[str, Any]:
        """Check MCP server health."""
        response = self.session.get(f"{self.base_url}/health")
        response.raise_for_status()
        return response.json()
    
    def list_tools(self) -> Dict[str, Any]:
        """List available MCP tools."""
        response = self.session.post(f"{self.base_url}/mcp", json={
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/list",
            "params": {}
        })
        response.raise_for_status()
        return response.json()
    
    def call_tool(self, tool_name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """Call an MCP tool."""
        response = self.session.post(f"{self.base_url}/mcp", json={
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/call",
            "params": {
                "name": tool_name,
                "arguments": arguments
            }
        })
        response.raise_for_status()
        return response.json()
    
    def execute_query(self, query: str) -> Dict[str, Any]:
        """Execute a SQL query through MCP."""
        return self.call_tool("execute_query", {"query": query})
    
    def list_tables(self) -> Dict[str, Any]:
        """List database tables through MCP."""
        return self.call_tool("list_tables", {})
    
    def describe_table(self, table_name: str) -> Dict[str, Any]:
        """Describe a table through MCP."""
        return self.call_tool("describe_table", {"table_name": table_name})


@pytest.fixture
def sample_queries():
    """Sample SQL queries for testing."""
    return {
        "select_simple": "SELECT 1 as test_column",
        "select_users": "SELECT * FROM users LIMIT 5",
        "count_users": "SELECT COUNT(*) as user_count FROM users",
        "insert_user": """
            INSERT INTO users (username, email, first_name, last_name) 
            VALUES ('test_user', 'test@example.com', 'Test', 'User')
        """,
        "update_user": """
            UPDATE users 
            SET first_name = 'Updated' 
            WHERE username = 'test_user'
        """,
        "delete_user": "DELETE FROM users WHERE username = 'test_user'"
    }


@pytest.fixture(autouse=True)
def setup_test_environment():
    """Setup test environment before each test."""
    # Add any test setup logic here
    yield
    # Add any test cleanup logic here


def pytest_configure(config):
    """Configure pytest with custom markers."""
    config.addinivalue_line(
        "markers", "integration: marks tests as integration tests"
    )
    config.addinivalue_line(
        "markers", "postgres: marks tests specific to PostgreSQL"
    )
    config.addinivalue_line(
        "markers", "mysql: marks tests specific to MySQL"
    )
    config.addinivalue_line(
        "markers", "snowflake: marks tests specific to Snowflake"
    )
    config.addinivalue_line(
        "markers", "redshift: marks tests specific to Redshift"
    )
    config.addinivalue_line(
        "markers", "slow: marks tests as slow running"
    )


def pytest_collection_modifyitems(config, items):
    """Modify test collection to add markers."""
    for item in items:
        # Add integration marker to all tests in integration/ directory
        if "integration" in str(item.fspath):
            item.add_marker(pytest.mark.integration)
        
        # Add database-specific markers based on test file names
        if "postgres" in str(item.fspath):
            item.add_marker(pytest.mark.postgres)
        elif "mysql" in str(item.fspath):
            item.add_marker(pytest.mark.mysql)
        elif "snowflake" in str(item.fspath):
            item.add_marker(pytest.mark.snowflake)
        elif "redshift" in str(item.fspath):
            item.add_marker(pytest.mark.redshift)