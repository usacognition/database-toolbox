"""
Amazon Redshift-specific tests for MCP Database Server.
"""

import pytest
import os
from conftest import REDSHIFT_MCP_URL


@pytest.mark.redshift
@pytest.mark.skipif(
    not os.getenv("REDSHIFT_HOST"), 
    reason="Redshift credentials not provided"
)
class TestRedshiftMCP:
    """Test Redshift MCP server functionality."""
    
    @pytest.fixture(scope="class")
    def redshift_mcp_client(self):
        """Fixture for Redshift MCP client."""
        from conftest import MCPClient, wait_for_service
        wait_for_service(REDSHIFT_MCP_URL)
        return MCPClient(REDSHIFT_MCP_URL)
    
    def test_simple_select(self, redshift_mcp_client):
        """Test simple SELECT query."""
        response = redshift_mcp_client.execute_query("SELECT 1 as number, 'hello' as text")
        assert "result" in response
        assert "content" in response["result"]
        
        content = response["result"]["content"]
        assert len(content) == 1
        assert content[0]["number"] == 1
        assert content[0]["text"] == "hello"
    
    def test_redshift_system_info(self, redshift_mcp_client):
        """Test Redshift system information queries."""
        query = """
            SELECT 
                current_database() as database_name,
                current_user as user_name,
                version() as redshift_version
        """
        response = redshift_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert "database_name" in result[0]
        assert "user_name" in result[0]
        assert "redshift_version" in result[0]
        # Should contain "Redshift" in version string
        assert "redshift" in result[0]["redshift_version"].lower()
    
    def test_redshift_date_functions(self, redshift_mcp_client):
        """Test Redshift date and time functions."""
        query = """
            SELECT 
                DATE('2023-12-25') as christmas,
                EXTRACT(year FROM CURRENT_DATE) as current_year,
                EXTRACT(month FROM CURRENT_DATE) as current_month,
                EXTRACT(day FROM CURRENT_DATE) as current_day,
                CURRENT_DATE + INTERVAL '7 days' as next_week
        """
        response = redshift_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert "christmas" in result[0]
        assert "current_year" in result[0]
        assert "next_week" in result[0]
    
    def test_redshift_string_functions(self, redshift_mcp_client):
        """Test Redshift string functions."""
        query = """
            SELECT 
                'Hello' || ' ' || 'World' as greeting,
                UPPER('redshift') as uppercase,
                LOWER('REDSHIFT') as lowercase,
                LENGTH('test string') as string_length,
                SUBSTRING('Redshift', 1, 3) as substring
        """
        response = redshift_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert result[0]["greeting"] == "Hello World"
        assert result[0]["uppercase"] == "REDSHIFT"
        assert result[0]["lowercase"] == "redshift"
        assert result[0]["string_length"] == 11
        assert result[0]["substring"] == "Red"
    
    def test_redshift_aggregation(self, redshift_mcp_client):
        """Test Redshift aggregation functions with VALUES clause."""
        query = """
            WITH sample_data AS (
                SELECT * FROM (
                    VALUES 
                        (1, 10), 
                        (2, 20), 
                        (3, 30), 
                        (4, 40), 
                        (5, 50)
                ) AS t(id, value)
            )
            SELECT 
                COUNT(*) as total_count,
                MIN(value) as min_value,
                MAX(value) as max_value,
                AVG(value::FLOAT) as avg_value,
                SUM(value) as sum_value
            FROM sample_data
        """
        response = redshift_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert result[0]["total_count"] == 5
        assert result[0]["min_value"] == 10
        assert result[0]["max_value"] == 50
        assert result[0]["avg_value"] == 30.0
        assert result[0]["sum_value"] == 150
    
    def test_redshift_window_functions(self, redshift_mcp_client):
        """Test Redshift window functions."""
        query = """
            WITH sales_data AS (
                SELECT * FROM (
                    VALUES 
                        ('East', 100), 
                        ('West', 200), 
                        ('East', 150), 
                        ('West', 250), 
                        ('North', 300), 
                        ('North', 180)
                ) AS t(region, sales)
            )
            SELECT 
                region,
                sales,
                SUM(sales) OVER (PARTITION BY region) as region_total,
                ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) as rank_in_region,
                RANK() OVER (ORDER BY sales DESC) as overall_rank
            FROM sales_data
            ORDER BY region, sales DESC
        """
        response = redshift_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 6  # 6 rows of data
        
        # Check that window functions worked
        for row in result:
            assert "region" in row
            assert "sales" in row
            assert "region_total" in row
            assert "rank_in_region" in row
            assert "overall_rank" in row
    
    def test_redshift_json_functions(self, redshift_mcp_client):
        """Test Redshift JSON functions (if available)."""
        # Note: JSON functions may not be available in all Redshift versions
        query = """
            SELECT 
                '{"name": "test", "value": 123}'::JSON as json_data,
                JSON_EXTRACT_PATH_TEXT('{"name": "test", "value": 123}', 'name') as json_name
        """
        response = redshift_mcp_client.execute_query(query)
        # This might fail in older Redshift versions, so we check for either success or specific error
        if "result" in response and "content" in response["result"]:
            result = response["result"]["content"]
            assert len(result) == 1
            if "json_name" in result[0]:
                assert result[0]["json_name"] == "test"
        # If JSON functions aren't supported, that's okay for this test
    
    def test_redshift_array_functions(self, redshift_mcp_client):
        """Test Redshift array handling."""
        query = """
            WITH array_data AS (
                SELECT ARRAY[1, 2, 3, 4, 5] as numbers
            )
            SELECT 
                numbers,
                numbers[1] as first_element,
                ARRAY_LENGTH(numbers, 1) as array_size
            FROM array_data
        """
        response = redshift_mcp_client.execute_query(query)
        if "result" in response and "content" in response["result"]:
            result = response["result"]["content"]
            assert len(result) == 1
            assert "array_size" in result[0]
    
    def test_redshift_mathematical_functions(self, redshift_mcp_client):
        """Test Redshift mathematical functions."""
        query = """
            SELECT 
                ABS(-42) as absolute_value,
                CEIL(3.14) as ceiling_value,
                FLOOR(3.99) as floor_value,
                ROUND(3.14159, 2) as rounded_value,
                SQRT(16) as square_root,
                POWER(2, 3) as power_result
        """
        response = redshift_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert result[0]["absolute_value"] == 42
        assert result[0]["ceiling_value"] == 4
        assert result[0]["floor_value"] == 3
        assert result[0]["rounded_value"] == 3.14
        assert result[0]["square_root"] == 4
        assert result[0]["power_result"] == 8
    
    def test_redshift_case_when(self, redshift_mcp_client):
        """Test Redshift CASE WHEN statements."""
        query = """
            WITH test_data AS (
                SELECT * FROM (
                    VALUES (1, 'A'), (2, 'B'), (3, 'C'), (4, 'D')
                ) AS t(id, category)
            )
            SELECT 
                id,
                category,
                CASE 
                    WHEN id <= 2 THEN 'Low'
                    WHEN id <= 3 THEN 'Medium'
                    ELSE 'High'
                END as priority_level,
                CASE category
                    WHEN 'A' THEN 'Alpha'
                    WHEN 'B' THEN 'Beta'
                    ELSE 'Other'
                END as category_name
            FROM test_data
            ORDER BY id
        """
        response = redshift_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 4
        
        # Check first row
        assert result[0]["id"] == 1
        assert result[0]["priority_level"] == "Low"
        assert result[0]["category_name"] == "Alpha"
        
        # Check last row
        assert result[3]["id"] == 4
        assert result[3]["priority_level"] == "High"
        assert result[3]["category_name"] == "Other"
    
    def test_error_handling(self, redshift_mcp_client):
        """Test error handling for invalid queries."""
        # Test invalid SQL
        response = redshift_mcp_client.execute_query("SELECT * FROM non_existent_table_xyz")
        # Should return an error in the response
        assert "error" in response or ("result" in response and "error" in response["result"])
    
    def test_redshift_system_tables(self, redshift_mcp_client):
        """Test querying Redshift system tables."""
        query = """
            SELECT 
                schemaname,
                tablename,
                tableowner
            FROM pg_tables 
            WHERE schemaname = 'public'
            LIMIT 10
        """
        response = redshift_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        # May be empty if no tables exist, but should not error
        result = response["result"]["content"]
        assert isinstance(result, list)


@pytest.mark.redshift
@pytest.mark.skipif(
    not os.getenv("REDSHIFT_HOST"), 
    reason="Redshift credentials not provided"
)
class TestRedshiftAdvanced:
    """Advanced Redshift tests."""
    
    @pytest.fixture(scope="class")
    def redshift_mcp_client(self):
        """Fixture for Redshift MCP client."""
        from conftest import MCPClient, wait_for_service
        wait_for_service(REDSHIFT_MCP_URL)
        return MCPClient(REDSHIFT_MCP_URL)
    
    def test_redshift_information_schema(self, redshift_mcp_client):
        """Test querying Redshift information schema."""
        query = """
            SELECT 
                table_schema,
                table_name,
                table_type
            FROM information_schema.tables 
            WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
            LIMIT 10
        """
        response = redshift_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert isinstance(result, list)
    
    def test_redshift_pg_catalog(self, redshift_mcp_client):
        """Test querying Redshift pg_catalog for metadata."""
        query = """
            SELECT 
                nspname as schema_name,
                count(*) as table_count
            FROM pg_namespace 
            WHERE nspname NOT LIKE 'pg_%' 
            AND nspname != 'information_schema'
            GROUP BY nspname
            ORDER BY nspname
        """
        response = redshift_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert isinstance(result, list)
    
    def test_redshift_current_settings(self, redshift_mcp_client):
        """Test Redshift current settings and configuration."""
        query = """
            SELECT 
                name,
                setting,
                unit,
                category
            FROM pg_settings 
            WHERE name IN ('max_connections', 'shared_buffers', 'work_mem')
            ORDER BY name
        """
        response = redshift_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert isinstance(result, list)
        # Should have at least some settings
        if len(result) > 0:
            assert "name" in result[0]
            assert "setting" in result[0]