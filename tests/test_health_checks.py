"""
Health check tests for MCP Database Servers.
"""

import pytest
import requests
import os
from conftest import POSTGRES_MCP_URL, MYSQL_MCP_URL, SNOWFLAKE_MCP_URL, REDSHIFT_MCP_URL


class TestHealthChecks:
    """Test health check endpoints for all MCP servers."""
    
    def test_postgres_health(self):
        """Test PostgreSQL MCP server health endpoint."""
        response = requests.get(f"{POSTGRES_MCP_URL}/", timeout=30)
        assert response.status_code == 200
        assert "Hello, World!" in response.text
    
    def test_mysql_health(self):
        """Test MySQL MCP server health endpoint."""
        response = requests.get(f"{MYSQL_MCP_URL}/", timeout=30)
        assert response.status_code == 200
        assert "Hello, World!" in response.text
    
    @pytest.mark.postgres
    def test_postgres_mcp_tools_available(self, postgres_mcp_client):
        """Test that PostgreSQL MCP server has tools available."""
        response = postgres_mcp_client.list_tools()
        assert "result" in response
        assert "tools" in response["result"]
        assert len(response["result"]["tools"]) > 0
        
        # Check for expected tools
        tool_names = [tool["name"] for tool in response["result"]["tools"]]
        expected_tools = ["execute_query", "list_tables", "describe_table"]
        for tool in expected_tools:
            assert tool in tool_names
    
    @pytest.mark.mysql
    def test_mysql_mcp_tools_available(self, mysql_mcp_client):
        """Test that MySQL MCP server has tools available."""
        response = mysql_mcp_client.list_tools()
        assert "result" in response
        assert "tools" in response["result"]
        assert len(response["result"]["tools"]) > 0
        
        # Check for expected tools
        tool_names = [tool["name"] for tool in response["result"]["tools"]]
        expected_tools = ["execute_query", "list_tables", "describe_table"]
        for tool in expected_tools:
            assert tool in tool_names
    
    @pytest.mark.postgres
    def test_postgres_database_connectivity(self, postgres_mcp_client):
        """Test PostgreSQL database connectivity through MCP."""
        response = postgres_mcp_client.execute_query("SELECT 1 as test")
        assert "result" in response
        assert "content" in response["result"]
        
        # Should have one row with value 1
        content = response["result"]["content"]
        assert len(content) > 0
    
    @pytest.mark.mysql
    def test_mysql_database_connectivity(self, mysql_mcp_client):
        """Test MySQL database connectivity through MCP."""
        response = mysql_mcp_client.execute_query("SELECT 1 as test")
        assert "result" in response
        assert "content" in response["result"]
        
        # Should have one row with value 1
        content = response["result"]["content"]
        assert len(content) > 0
    
    @pytest.mark.snowflake
    @pytest.mark.skipif(
        not os.getenv("SNOWFLAKE_ACCOUNT") and not os.getenv("TEST_SNOWFLAKE_MOCK"), 
        reason="Snowflake not available"
    )
    def test_snowflake_health(self):
        """Test Snowflake MCP server health endpoint."""
        response = requests.get(f"{SNOWFLAKE_MCP_URL}/", timeout=30)
        assert response.status_code == 200
        assert "Hello, World!" in response.text
    
    @pytest.mark.redshift
    @pytest.mark.skipif(
        not os.getenv("REDSHIFT_HOST") and not os.getenv("TEST_REDSHIFT_MOCK"), 
        reason="Redshift not available"
    )
    def test_redshift_health(self):
        """Test Redshift MCP server health endpoint."""
        response = requests.get(f"{REDSHIFT_MCP_URL}/", timeout=30)
        assert response.status_code == 200
        assert "Hello, World!" in response.text
