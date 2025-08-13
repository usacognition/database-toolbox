#!/bin/bash
set -e

echo "=== SQL Server MCP Server Test ==="
echo

# Start database container
echo "1. Starting SQL Server container..."
docker-compose up -d
echo "   Waiting for SQL Server to be ready..."
sleep 30  # SQL Server takes much longer to start on ARM64

# Check if sqlserver is healthy
docker-compose ps

# Create testdb database
echo "   Creating testdb database..."
docker exec test-sqlserver-db /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong!Password123" -C -Q "CREATE DATABASE testdb"

# Test the MCP server using the exact command from README
echo -e "\n2. Testing MCP server with list_tables tool..."
python3 test_mcp.py

echo -e "\n3. Test completed!"

# Clean up
echo -e "\n4. Cleaning up..."
docker-compose down -v

echo -e "\n✅ SQL Server test passed!"
