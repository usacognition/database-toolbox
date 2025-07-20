"""
MySQL-specific tests for MCP Database Server.
"""

import pytest
import pymysql
from conftest import MYSQL_CONFIG


@pytest.mark.mysql
class TestMySQLMCP:
    """Test MySQL MCP server functionality."""
    
    def test_simple_select(self, mysql_mcp_client):
        """Test simple SELECT query."""
        response = mysql_mcp_client.execute_query("SELECT 1 as number, 'hello' as text")
        assert "result" in response
        assert "content" in response["result"]
        
        content = response["result"]["content"]
        assert len(content) == 1
        assert content[0]["number"] == 1
        assert content[0]["text"] == "hello"
    
    def test_list_tables(self, mysql_mcp_client):
        """Test listing tables in MySQL."""
        response = mysql_mcp_client.list_tables()
        assert "result" in response
        assert "content" in response["result"]
        
        tables = response["result"]["content"]
        table_names = [table["table_name"] for table in tables]
        
        # Check that our test tables exist
        expected_tables = ["users", "orders", "products"]
        for table in expected_tables:
            assert table in table_names
    
    def test_describe_table(self, mysql_mcp_client):
        """Test describing a table structure."""
        response = mysql_mcp_client.describe_table("users")
        assert "result" in response
        assert "content" in response["result"]
        
        columns = response["result"]["content"]
        column_names = [col["column_name"] for col in columns]
        
        # Check expected columns
        expected_columns = ["id", "username", "email", "first_name", "last_name", "created_at", "is_active"]
        for col in expected_columns:
            assert col in column_names
    
    def test_select_from_users(self, mysql_mcp_client):
        """Test selecting data from users table."""
        response = mysql_mcp_client.execute_query("SELECT * FROM users LIMIT 5")
        assert "result" in response
        assert "content" in response["result"]
        
        users = response["result"]["content"]
        assert len(users) > 0
        
        # Check that users have expected fields
        first_user = users[0]
        assert "id" in first_user
        assert "username" in first_user
        assert "email" in first_user
    
    def test_count_users(self, mysql_mcp_client):
        """Test counting users."""
        response = mysql_mcp_client.execute_query("SELECT COUNT(*) as user_count FROM users")
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert "user_count" in result[0]
        assert result[0]["user_count"] > 0
    
    def test_join_query(self, mysql_mcp_client):
        """Test JOIN query between users and orders."""
        query = """
            SELECT u.username, u.email, COUNT(o.id) as order_count
            FROM users u
            LEFT JOIN orders o ON u.id = o.user_id
            GROUP BY u.id, u.username, u.email
            LIMIT 5
        """
        response = mysql_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        results = response["result"]["content"]
        assert len(results) > 0
        
        # Check result structure
        first_result = results[0]
        assert "username" in first_result
        assert "email" in first_result
        assert "order_count" in first_result
    
    def test_insert_and_cleanup(self, mysql_mcp_client):
        """Test inserting a new user and cleaning up."""
        # Insert a test user
        insert_query = """
            INSERT INTO users (username, email, first_name, last_name)
            VALUES ('test_user_mysql', 'test_mysql@example.com', 'Test', 'MySQL')
        """
        response = mysql_mcp_client.call_tool("execute_statement", {"statement": insert_query})
        assert "result" in response
        
        # Verify the user was inserted
        select_query = "SELECT * FROM users WHERE username = 'test_user_mysql'"
        response = mysql_mcp_client.execute_query(select_query)
        assert "result" in response
        users = response["result"]["content"]
        assert len(users) == 1
        assert users[0]["email"] == "test_mysql@example.com"
        
        # Clean up - delete the test user
        delete_query = "DELETE FROM users WHERE username = 'test_user_mysql'"
        response = mysql_mcp_client.call_tool("execute_statement", {"statement": delete_query})
        assert "result" in response
        
        # Verify deletion
        response = mysql_mcp_client.execute_query(select_query)
        users = response["result"]["content"]
        assert len(users) == 0
    
    def test_mysql_specific_features(self, mysql_mcp_client):
        """Test MySQL-specific features."""
        # Test MySQL functions
        query = "SELECT NOW() as current_time, VERSION() as mysql_version"
        response = mysql_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert "current_time" in result[0]
        assert "mysql_version" in result[0]
        
        # Test LIMIT with OFFSET
        limit_query = "SELECT * FROM users ORDER BY id LIMIT 2 OFFSET 1"
        response = mysql_mcp_client.execute_query(limit_query)
        assert "result" in response
        assert "content" in response["result"]
    
    def test_mysql_date_functions(self, mysql_mcp_client):
        """Test MySQL date and time functions."""
        query = """
            SELECT 
                DATE('2023-12-25') as christmas,
                YEAR(NOW()) as current_year,
                MONTH(NOW()) as current_month,
                DAY(NOW()) as current_day
        """
        response = mysql_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert "christmas" in result[0]
        assert "current_year" in result[0]
    
    def test_mysql_string_functions(self, mysql_mcp_client):
        """Test MySQL string functions."""
        query = """
            SELECT 
                CONCAT('Hello', ' ', 'World') as greeting,
                UPPER('mysql') as uppercase,
                LOWER('MySQL') as lowercase,
                LENGTH('test string') as string_length
        """
        response = mysql_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert result[0]["greeting"] == "Hello World"
        assert result[0]["uppercase"] == "MYSQL"
        assert result[0]["lowercase"] == "mysql"
        assert result[0]["string_length"] == 11
    
    def test_mysql_aggregation(self, mysql_mcp_client):
        """Test MySQL aggregation functions."""
        query = """
            SELECT 
                COUNT(*) as total_users,
                MIN(id) as min_id,
                MAX(id) as max_id,
                AVG(id) as avg_id
            FROM users
        """
        response = mysql_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert "total_users" in result[0]
        assert "min_id" in result[0]
        assert "max_id" in result[0]
        assert "avg_id" in result[0]
    
    def test_error_handling(self, mysql_mcp_client):
        """Test error handling for invalid queries."""
        # Test invalid SQL
        response = mysql_mcp_client.execute_query("SELECT * FROM non_existent_table")
        # Should return an error in the response
        assert "error" in response or ("result" in response and "error" in response["result"])
    
    def test_database_introspection(self, mysql_mcp_client):
        """Test database introspection capabilities."""
        # Test getting schema information
        schema_query = """
            SELECT table_name, column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_schema = DATABASE()
            ORDER BY table_name, ordinal_position
        """
        response = mysql_mcp_client.execute_query(schema_query)
        assert "result" in response
        assert "content" in response["result"]
        
        schema_info = response["result"]["content"]
        assert len(schema_info) > 0
        
        # Should have info about our test tables
        table_names = set(row["table_name"] for row in schema_info)
        expected_tables = {"users", "orders", "products"}
        assert expected_tables.issubset(table_names)
    
    def test_show_tables(self, mysql_mcp_client):
        """Test MySQL SHOW TABLES command."""
        response = mysql_mcp_client.execute_query("SHOW TABLES")
        assert "result" in response
        assert "content" in response["result"]
        
        tables = response["result"]["content"]
        assert len(tables) > 0
        
        # Extract table names (column name varies in MySQL)
        table_names = [list(table.values())[0] for table in tables]
        expected_tables = ["users", "orders", "products"]
        for table in expected_tables:
            assert table in table_names
    
    def test_show_columns(self, mysql_mcp_client):
        """Test MySQL SHOW COLUMNS command."""
        response = mysql_mcp_client.execute_query("SHOW COLUMNS FROM users")
        assert "result" in response
        assert "content" in response["result"]
        
        columns = response["result"]["content"]
        assert len(columns) > 0
        
        # Check that we have column information
        first_column = columns[0]
        assert "Field" in first_column
        assert "Type" in first_column
        assert "Null" in first_column


@pytest.mark.mysql
@pytest.mark.integration
class TestMySQLDirectConnection:
    """Test direct MySQL connection to verify test data."""
    
    def test_direct_connection(self, mysql_db):
        """Test direct connection to MySQL database."""
        cursor = mysql_db.cursor()
        cursor.execute("SELECT COUNT(*) FROM users")
        count = cursor.fetchone()[0]
        assert count > 0
        cursor.close()
    
    def test_test_data_exists(self, mysql_db):
        """Verify that test data exists in the database."""
        cursor = mysql_db.cursor()
        
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
    
    def test_mysql_charset(self, mysql_db):
        """Test MySQL charset and collation."""
        cursor = mysql_db.cursor()
        cursor.execute("SELECT @@character_set_database, @@collation_database")
        charset_info = cursor.fetchone()
        assert charset_info[0] in ['utf8mb4', 'utf8']  # Should be UTF-8 based
        cursor.close()