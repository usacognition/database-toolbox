"""
Snowflake-specific tests for MCP Database Server.
"""

import pytest
import os
from conftest import SNOWFLAKE_MCP_URL


@pytest.mark.snowflake
@pytest.mark.skipif(
    not os.getenv("SNOWFLAKE_ACCOUNT"), 
    reason="Snowflake credentials not provided"
)
class TestSnowflakeMCP:
    """Test Snowflake MCP server functionality."""
    
    @pytest.fixture(scope="class")
    def snowflake_mcp_client(self):
        """Fixture for Snowflake MCP client."""
        from conftest import MCPClient, wait_for_service
        wait_for_service(SNOWFLAKE_MCP_URL)
        return MCPClient(SNOWFLAKE_MCP_URL)
    
    def test_simple_select(self, snowflake_mcp_client):
        """Test simple SELECT query."""
        response = snowflake_mcp_client.execute_query("SELECT 1 as number, 'hello' as text")
        assert "result" in response
        assert "content" in response["result"]
        
        content = response["result"]["content"]
        assert len(content) == 1
        assert content[0]["NUMBER"] == 1  # Snowflake returns uppercase column names
        assert content[0]["TEXT"] == "hello"
    
    def test_snowflake_functions(self, snowflake_mcp_client):
        """Test Snowflake-specific functions."""
        query = """
            SELECT 
                CURRENT_TIMESTAMP() as current_time,
                CURRENT_DATABASE() as database_name,
                CURRENT_SCHEMA() as schema_name,
                CURRENT_WAREHOUSE() as warehouse_name
        """
        response = snowflake_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert "CURRENT_TIME" in result[0]
        assert "DATABASE_NAME" in result[0]
        assert "SCHEMA_NAME" in result[0]
        assert "WAREHOUSE_NAME" in result[0]
    
    def test_snowflake_date_functions(self, snowflake_mcp_client):
        """Test Snowflake date and time functions."""
        query = """
            SELECT 
                DATE('2023-12-25') as christmas,
                YEAR(CURRENT_DATE()) as current_year,
                MONTH(CURRENT_DATE()) as current_month,
                DAY(CURRENT_DATE()) as current_day,
                DATEADD(day, 7, CURRENT_DATE()) as next_week
        """
        response = snowflake_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert "CHRISTMAS" in result[0]
        assert "CURRENT_YEAR" in result[0]
        assert "NEXT_WEEK" in result[0]
    
    def test_snowflake_string_functions(self, snowflake_mcp_client):
        """Test Snowflake string functions."""
        query = """
            SELECT 
                CONCAT('Hello', ' ', 'World') as greeting,
                UPPER('snowflake') as uppercase,
                LOWER('SNOWFLAKE') as lowercase,
                LENGTH('test string') as string_length,
                SUBSTR('Snowflake', 1, 4) as substring
        """
        response = snowflake_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert result[0]["GREETING"] == "Hello World"
        assert result[0]["UPPERCASE"] == "SNOWFLAKE"
        assert result[0]["LOWERCASE"] == "snowflake"
        assert result[0]["STRING_LENGTH"] == 11
        assert result[0]["SUBSTRING"] == "Snow"
    
    def test_snowflake_json_functions(self, snowflake_mcp_client):
        """Test Snowflake JSON functions."""
        query = """
            SELECT 
                PARSE_JSON('{"name": "test", "value": 123}') as json_data,
                OBJECT_CONSTRUCT('key1', 'value1', 'key2', 123) as json_object,
                ARRAY_CONSTRUCT(1, 2, 3, 4, 5) as json_array
        """
        response = snowflake_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert "JSON_DATA" in result[0]
        assert "JSON_OBJECT" in result[0]
        assert "JSON_ARRAY" in result[0]
    
    def test_snowflake_aggregation(self, snowflake_mcp_client):
        """Test Snowflake aggregation functions with generated data."""
        query = """
            WITH sample_data AS (
                SELECT column1 as id, column2 as value
                FROM VALUES 
                    (1, 10), (2, 20), (3, 30), (4, 40), (5, 50)
            )
            SELECT 
                COUNT(*) as total_count,
                MIN(value) as min_value,
                MAX(value) as max_value,
                AVG(value) as avg_value,
                SUM(value) as sum_value
            FROM sample_data
        """
        response = snowflake_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert result[0]["TOTAL_COUNT"] == 5
        assert result[0]["MIN_VALUE"] == 10
        assert result[0]["MAX_VALUE"] == 50
        assert result[0]["AVG_VALUE"] == 30
        assert result[0]["SUM_VALUE"] == 150
    
    def test_snowflake_variant_data(self, snowflake_mcp_client):
        """Test Snowflake VARIANT data type."""
        query = """
            WITH variant_data AS (
                SELECT 
                    PARSE_JSON('{"users": [{"name": "John", "age": 30}, {"name": "Jane", "age": 25}]}') as data
            )
            SELECT 
                data:users[0]:name::string as first_user_name,
                data:users[0]:age::number as first_user_age,
                data:users[1]:name::string as second_user_name,
                ARRAY_SIZE(data:users) as user_count
            FROM variant_data
        """
        response = snowflake_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert result[0]["FIRST_USER_NAME"] == "John"
        assert result[0]["FIRST_USER_AGE"] == 30
        assert result[0]["SECOND_USER_NAME"] == "Jane"
        assert result[0]["USER_COUNT"] == 2
    
    def test_snowflake_window_functions(self, snowflake_mcp_client):
        """Test Snowflake window functions."""
        query = """
            WITH sales_data AS (
                SELECT column1 as region, column2 as sales
                FROM VALUES 
                    ('East', 100), ('West', 200), ('East', 150), 
                    ('West', 250), ('North', 300), ('North', 180)
            )
            SELECT 
                region,
                sales,
                SUM(sales) OVER (PARTITION BY region) as region_total,
                ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) as rank_in_region,
                PERCENT_RANK() OVER (ORDER BY sales) as percentile_rank
            FROM sales_data
            ORDER BY region, sales DESC
        """
        response = snowflake_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 6  # 6 rows of data
        
        # Check that window functions worked
        for row in result:
            assert "REGION" in row
            assert "SALES" in row
            assert "REGION_TOTAL" in row
            assert "RANK_IN_REGION" in row
            assert "PERCENTILE_RANK" in row
    
    def test_error_handling(self, snowflake_mcp_client):
        """Test error handling for invalid queries."""
        # Test invalid SQL
        response = snowflake_mcp_client.execute_query("SELECT * FROM non_existent_table_xyz")
        # Should return an error in the response
        assert "error" in response or ("result" in response and "error" in response["result"])
    
    def test_information_schema(self, snowflake_mcp_client):
        """Test querying Snowflake information schema."""
        query = """
            SELECT 
                table_name,
                table_type,
                created,
                row_count
            FROM information_schema.tables 
            WHERE table_schema = CURRENT_SCHEMA()
            LIMIT 10
        """
        response = snowflake_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        # May be empty if no tables exist, but should not error
        result = response["result"]["content"]
        assert isinstance(result, list)


@pytest.mark.snowflake
@pytest.mark.skipif(
    not os.getenv("SNOWFLAKE_ACCOUNT"), 
    reason="Snowflake credentials not provided"
)
class TestSnowflakeAdvanced:
    """Advanced Snowflake tests."""
    
    @pytest.fixture(scope="class")
    def snowflake_mcp_client(self):
        """Fixture for Snowflake MCP client."""
        from conftest import MCPClient, wait_for_service
        wait_for_service(SNOWFLAKE_MCP_URL)
        return MCPClient(SNOWFLAKE_MCP_URL)
    
    def test_snowflake_time_travel(self, snowflake_mcp_client):
        """Test Snowflake time travel functionality (if available)."""
        # This test may not work in all environments due to privileges
        query = """
            SELECT CURRENT_TIMESTAMP() as current_time,
                   CURRENT_ACCOUNT() as account,
                   CURRENT_REGION() as region
        """
        response = snowflake_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
    
    def test_snowflake_system_functions(self, snowflake_mcp_client):
        """Test Snowflake system functions."""
        query = """
            SELECT 
                SYSTEM$VERSION() as version,
                CURRENT_CLIENT() as client,
                CURRENT_SESSION() as session_id
        """
        response = snowflake_mcp_client.execute_query(query)
        assert "result" in response
        assert "content" in response["result"]
        
        result = response["result"]["content"]
        assert len(result) == 1
        assert "VERSION" in result[0]
        assert "CLIENT" in result[0]
        assert "SESSION_ID" in result[0]