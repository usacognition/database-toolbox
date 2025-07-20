"""
Basic setup tests to verify the test framework is working correctly.
"""

import pytest
import os


class TestBasicSetup:
    """Test basic setup and framework functionality."""
    
    def test_pytest_working(self):
        """Test that pytest is working correctly."""
        assert True
    
    def test_environment_variables(self):
        """Test that basic environment variables are accessible."""
        # These should be set by pytest configuration
        assert os.getenv("POSTGRES_MCP_URL") is not None
        assert os.getenv("MYSQL_MCP_URL") is not None
    
    def test_python_imports(self):
        """Test that required Python modules can be imported."""
        import requests
        import json
        import time
        
        assert requests is not None
        assert json is not None
        assert time is not None
    
    def test_database_imports(self):
        """Test that database drivers can be imported."""
        try:
            import psycopg2
            assert psycopg2 is not None
        except ImportError:
            pytest.fail("psycopg2 not available")
        
        try:
            import pymysql
            assert pymysql is not None
        except ImportError:
            pytest.fail("pymysql not available")
    
    def test_optional_database_imports(self):
        """Test optional database drivers."""
        # Snowflake connector (may not always be available)
        try:
            import snowflake.connector
            print("Snowflake connector available")
        except ImportError:
            print("Snowflake connector not available")
    
    def test_conftest_imports(self):
        """Test that conftest utilities can be imported."""
        from conftest import MCPClient, POSTGRES_MCP_URL, MYSQL_MCP_URL
        
        assert MCPClient is not None
        assert POSTGRES_MCP_URL is not None
        assert MYSQL_MCP_URL is not None


class TestMCPClient:
    """Test the MCP client utility."""
    
    def test_mcp_client_creation(self):
        """Test that MCP client can be created."""
        from conftest import MCPClient
        
        client = MCPClient("http://localhost:5000")
        assert client.base_url == "http://localhost:5000"
        assert client.session is not None
    
    def test_mcp_client_url_normalization(self):
        """Test URL normalization in MCP client."""
        from conftest import MCPClient
        
        # Test trailing slash removal
        client = MCPClient("http://localhost:5000/")
        assert client.base_url == "http://localhost:5000"
        
        # Test no trailing slash
        client = MCPClient("http://localhost:5000")
        assert client.base_url == "http://localhost:5000"