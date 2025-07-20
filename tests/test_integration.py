"""
Integration tests for MCP Database Servers.
"""

import pytest
import time
from conftest import POSTGRES_MCP_URL, MYSQL_MCP_URL


@pytest.mark.integration
class TestMCPServerIntegration:
    """Test integration between different MCP servers."""
    
    def test_multiple_servers_running(self, postgres_mcp_client, mysql_mcp_client):
        """Test that multiple MCP servers can run simultaneously."""
        # Test PostgreSQL server
        pg_health = postgres_mcp_client.health_check()
        assert pg_health["status"] in ["healthy", "ready"]
        
        # Test MySQL server
        mysql_health = mysql_mcp_client.health_check()
        assert mysql_health["status"] in ["healthy", "ready"]
    
    def test_consistent_tool_interface(self, postgres_mcp_client, mysql_mcp_client):
        """Test that all servers expose the same tool interface."""
        # Get tools from both servers
        pg_tools = postgres_mcp_client.list_tools()
        mysql_tools = mysql_mcp_client.list_tools()
        
        # Extract tool names
        pg_tool_names = set(tool["name"] for tool in pg_tools["result"]["tools"])
        mysql_tool_names = set(tool["name"] for tool in mysql_tools["result"]["tools"])
        
        # Should have common tools
        common_tools = {"execute_query", "list_tables", "describe_table"}
        assert common_tools.issubset(pg_tool_names)
        assert common_tools.issubset(mysql_tool_names)
    
    def test_parallel_queries(self, postgres_mcp_client, mysql_mcp_client):
        """Test executing queries on multiple databases in parallel."""
        # Execute similar queries on both databases
        pg_response = postgres_mcp_client.execute_query("SELECT COUNT(*) as count FROM users")
        mysql_response = mysql_mcp_client.execute_query("SELECT COUNT(*) as count FROM users")
        
        # Both should succeed
        assert "result" in pg_response
        assert "content" in pg_response["result"]
        assert "result" in mysql_response
        assert "content" in mysql_response["result"]
        
        # Both should have count data
        pg_count = pg_response["result"]["content"][0]["count"]
        mysql_count = mysql_response["result"]["content"][0]["count"]
        
        assert pg_count > 0
        assert mysql_count > 0
    
    def test_schema_comparison(self, postgres_mcp_client, mysql_mcp_client):
        """Test schema inspection across databases."""
        # Get tables from both databases
        pg_tables = postgres_mcp_client.list_tables()
        mysql_tables = mysql_mcp_client.list_tables()
        
        pg_table_names = set(table["table_name"] for table in pg_tables["result"]["content"])
        mysql_table_names = set(table["table_name"] for table in mysql_tables["result"]["content"])
        
        # Should have same test tables
        expected_tables = {"users", "orders", "products"}
        assert expected_tables.issubset(pg_table_names)
        assert expected_tables.issubset(mysql_table_names)
        
        # Compare table structures
        pg_users = postgres_mcp_client.describe_table("users")
        mysql_users = mysql_mcp_client.describe_table("users")
        
        pg_columns = set(col["column_name"] for col in pg_users["result"]["content"])
        mysql_columns = set(col["column_name"] for col in mysql_users["result"]["content"])
        
        # Should have same columns (at least the basic ones)
        expected_columns = {"id", "username", "email", "first_name", "last_name"}
        assert expected_columns.issubset(pg_columns)
        assert expected_columns.issubset(mysql_columns)
    
    @pytest.mark.slow
    def test_concurrent_operations(self, postgres_mcp_client, mysql_mcp_client):
        """Test concurrent operations on different databases."""
        import threading
        import queue
        
        results = queue.Queue()
        
        def pg_operation():
            try:
                response = postgres_mcp_client.execute_query(
                    "SELECT username, email FROM users ORDER BY created_at DESC LIMIT 3"
                )
                results.put(("postgres", response))
            except Exception as e:
                results.put(("postgres", {"error": str(e)}))
        
        def mysql_operation():
            try:
                response = mysql_mcp_client.execute_query(
                    "SELECT username, email FROM users ORDER BY created_at DESC LIMIT 3"
                )
                results.put(("mysql", response))
            except Exception as e:
                results.put(("mysql", {"error": str(e)}))
        
        # Start both operations
        pg_thread = threading.Thread(target=pg_operation)
        mysql_thread = threading.Thread(target=mysql_operation)
        
        pg_thread.start()
        mysql_thread.start()
        
        # Wait for completion
        pg_thread.join(timeout=30)
        mysql_thread.join(timeout=30)
        
        # Check results
        assert results.qsize() == 2
        
        pg_result = None
        mysql_result = None
        
        while not results.empty():
            db_type, result = results.get()
            if db_type == "postgres":
                pg_result = result
            elif db_type == "mysql":
                mysql_result = result
        
        # Both should succeed
        assert pg_result is not None
        assert mysql_result is not None
        assert "result" in pg_result
        assert "result" in mysql_result
        assert "error" not in pg_result
        assert "error" not in mysql_result


@pytest.mark.integration
class TestMCPProtocolCompliance:
    """Test MCP protocol compliance across all servers."""
    
    def test_jsonrpc_response_format(self, postgres_mcp_client, mysql_mcp_client):
        """Test that all servers return proper JSON-RPC format."""
        clients = [postgres_mcp_client, mysql_mcp_client]
        
        for client in clients:
            response = client.list_tools()
            
            # Should have JSON-RPC structure
            assert "jsonrpc" in response or "result" in response
            assert "id" in response or "result" in response
            
            if "result" in response:
                assert "tools" in response["result"]
                for tool in response["result"]["tools"]:
                    assert "name" in tool
                    assert "description" in tool
    
    def test_error_response_format(self, postgres_mcp_client, mysql_mcp_client):
        """Test error response format compliance."""
        clients = [postgres_mcp_client, mysql_mcp_client]
        
        for client in clients:
            # Execute invalid query to trigger error
            response = client.execute_query("SELECT * FROM non_existent_table_xyz")
            
            # Should contain error information
            assert "error" in response or ("result" in response and "error" in response["result"])
    
    def test_tool_parameter_validation(self, postgres_mcp_client):
        """Test tool parameter validation."""
        # Test with missing required parameters
        try:
            response = postgres_mcp_client.call_tool("execute_query", {})
            # Should either raise exception or return error
            if "error" not in response:
                assert "result" in response and "error" in response["result"]
        except Exception:
            # Exception is also acceptable for invalid parameters
            pass


@pytest.mark.integration
@pytest.mark.slow
class TestLoadAndStress:
    """Load and stress tests for MCP servers."""
    
    def test_repeated_queries(self, postgres_mcp_client):
        """Test repeated query execution."""
        for i in range(10):
            response = postgres_mcp_client.execute_query("SELECT 1 as iteration_number")
            assert "result" in response
            assert "content" in response["result"]
            assert response["result"]["content"][0]["iteration_number"] == 1
    
    def test_large_result_set(self, postgres_mcp_client):
        """Test handling of larger result sets."""
        # Create a query that returns multiple rows
        query = """
            SELECT 
                generate_series(1, 100) as number,
                'test_data_' || generate_series(1, 100) as text_data
        """
        response = postgres_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        content = response["result"]["content"]
        assert len(content) == 100
        assert content[0]["number"] == 1
        assert content[99]["number"] == 100
    
    def test_complex_query_performance(self, postgres_mcp_client):
        """Test performance with complex queries."""
        complex_query = """
            SELECT 
                u.username,
                u.email,
                COUNT(o.id) as order_count,
                SUM(o.total_amount) as total_spent,
                AVG(o.total_amount) as avg_order_value
            FROM users u
            LEFT JOIN orders o ON u.id = o.user_id
            GROUP BY u.id, u.username, u.email
            HAVING COUNT(o.id) > 0
            ORDER BY total_spent DESC
        """
        
        start_time = time.time()
        response = postgres_mcp_client.execute_query(complex_query)
        end_time = time.time()
        
        # Should complete within reasonable time
        assert end_time - start_time < 10  # 10 seconds max
        assert "result" in response
        assert "content" in response["result"]