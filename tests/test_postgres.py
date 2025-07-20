"""
PostgreSQL-specific tests for MCP Database Server.
"""

import pytest
import psycopg2
from conftest import POSTGRES_CONFIG


@pytest.mark.postgres
class TestPostgreSQLMCP:
    """Test PostgreSQL MCP server functionality."""
    
    def test_simple_select(self, postgres_mcp_client):
        """Test simple SELECT query."""
        response = postgres_mcp_client.execute_query("SELECT 1 as number, 'hello' as text")
        assert "result" in response
        assert "content" in response["result"]
        
        content = response["result"]["content"]
        assert len(content) == 1
        assert content[0]["number"] == 1
        assert content[0]["text"] == "hello"
    
    def test_list_tables(self, postgres_mcp_client):
        """Test listing tables in PostgreSQL."""
        response = postgres_mcp_client.list_tables()
        assert "result" in response
        assert "content" in response["result"]
        
        tables = response["result"]["content"]
        table_names = [table["table_name"] for table in tables]
        
        # Check that our test tables exist
        expected_tables = ["users", "orders", "products"]
        for table in expected_tables:
            assert table in table_names
    
    def test_describe_table(self, postgres_mcp_client):
        """Test describing a table structure."""
        response = postgres_mcp_client.describe_table("users")
        assert "result" in response
        assert "content" in response["result"]
        
        columns = response["result"]["content"]
        column_names = [col["column_name"] for col in columns]
        
        # Check expected columns
        expected_columns = ["id", "username", "email", "first_name", "last_name", "created_at", "is_active"]
        for col in expected_columns:
            assert col in column_names
    
    def test_select_from_users(self, postgres_mcp_client):
        """Test selecting data from users table."""
        response = postgres_mcp_client.execute_query("SELECT * FROM users LIMIT 5")
        assert "result" in response
        assert "content" in response["result"]
        
        users = response["result"]["content"]
        assert len(users) > 0
        
        # Check that users have expected fields
        first_user = users[0]
        assert "id" in first_user
        assert "username" in first_user
        assert "email" in first_user
    
    def test_count_users(self, postgres_mcp_client):
        """Test counting users."""
        response = postgres_mcp_client.execute_query("SELECT COUNT(*) as user_count FROM users")
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert "user_count" in result[0]
        assert result[0]["user_count"] > 0
    
    def test_join_query(self, postgres_mcp_client):
        """Test JOIN query between users and orders."""
        query = """
            SELECT u.username, u.email, COUNT(o.id) as order_count
            FROM users u
            LEFT JOIN orders o ON u.id = o.user_id
            GROUP BY u.id, u.username, u.email
            LIMIT 5
        """
        response = postgres_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        results = response["result"]["content"]
        assert len(results) > 0
        
        # Check result structure
        first_result = results[0]
        assert "username" in first_result
        assert "email" in first_result
        assert "order_count" in first_result
    
    def test_insert_and_cleanup(self, postgres_mcp_client):
        """Test inserting a new user and cleaning up."""
        # Insert a test user
        insert_query = """
            INSERT INTO users (username, email, first_name, last_name)
            VALUES ('test_user_mcp', 'test_mcp@example.com', 'Test', 'MCP')
        """
        response = postgres_mcp_client.call_tool("execute_statement", {"statement": insert_query})
        assert "result" in response
        
        # Verify the user was inserted
        select_query = "SELECT * FROM users WHERE username = 'test_user_mcp'"
        response = postgres_mcp_client.execute_query(select_query)
        assert "result" in response
        users = response["result"]["content"]
        assert len(users) == 1
        assert users[0]["email"] == "test_mcp@example.com"
        
        # Clean up - delete the test user
        delete_query = "DELETE FROM users WHERE username = 'test_user_mcp'"
        response = postgres_mcp_client.call_tool("execute_statement", {"statement": delete_query})
        assert "result" in response
        
        # Verify deletion
        response = postgres_mcp_client.execute_query(select_query)
        users = response["result"]["content"]
        assert len(users) == 0
    
    def test_postgresql_specific_features(self, postgres_mcp_client):
        """Test PostgreSQL-specific features."""
        # Test array functionality
        query = "SELECT ARRAY[1, 2, 3] as numbers"
        response = postgres_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        # Test JSON functionality
        json_query = "SELECT '{\"name\": \"test\", \"value\": 123}'::json as data"
        response = postgres_mcp_client.execute_query(json_query)
        assert "result" in response
        assert "content" in response["result"]
    
    def test_error_handling(self, postgres_mcp_client):
        """Test error handling for invalid queries."""
        # Test invalid SQL
        response = postgres_mcp_client.execute_query("SELECT * FROM non_existent_table")
        # Should return an error in the response
        assert "error" in response or ("result" in response and "error" in response["result"])
    
    def test_database_introspection(self, postgres_mcp_client):
        """Test database introspection capabilities."""
        # Test getting schema information
        schema_query = """
            SELECT table_name, column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_schema = 'public'
            ORDER BY table_name, ordinal_position
        """
        response = postgres_mcp_client.execute_query(schema_query)
        assert "result" in response
        assert "content" in response["result"]
        
        schema_info = response["result"]["content"]
        assert len(schema_info) > 0
        
        # Should have info about our test tables
        table_names = set(row["table_name"] for row in schema_info)
        expected_tables = {"users", "orders", "products"}
        assert expected_tables.issubset(table_names)


@pytest.mark.postgres
@pytest.mark.integration
class TestPostgreSQLDirectConnection:
    """Test direct PostgreSQL connection to verify test data."""
    
    def test_direct_connection(self, postgres_db):
        """Test direct connection to PostgreSQL database."""
        cursor = postgres_db.cursor()
        cursor.execute("SELECT COUNT(*) FROM users")
        count = cursor.fetchone()[0]
        assert count > 0
        cursor.close()
    
    def test_test_data_exists(self, postgres_db):
        """Verify that test data exists in the database."""
        cursor = postgres_db.cursor()
        
        # Check users table
        cursor.execute("SELECT COUNT(*) FROM users")
        user_count = cursor.fetchone()[0]
        assert user_count >= 5
        
        # Check orders table
        cursor.execute("SELECT COUNT(*) FROM orders")
        order_count = cursor.fetchone()[0]
        assert order_count >= 3
        
        # Check products table
        cursor.execute("SELECT COUNT(*) FROM products")
        product_count = cursor.fetchone()[0]
        assert product_count >= 5
        
        cursor.close()