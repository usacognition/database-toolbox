#!/bin/bash
set -e

echo -e "\n=== Firestore MCP Server Test ==="

# 1. Start Firestore emulator
echo -e "\n1. Starting Firestore emulator..."
docker-compose up -d
sleep 10  # Give emulator time to start

# Check if emulator is running
docker-compose ps

# 2. Start MCP server - for emulator we set FIRESTORE_EMULATOR_HOST
echo -e "\n2. Testing MCP server with list_tables tool..."
FIRESTORE_PROJECT=test-project \
FIRESTORE_DATABASE="(default)" \
FIRESTORE_EMULATOR_HOST=localhost:8080 \
docker run --rm -d \
  --name test-mcp-firestore-server \
  --network host \
  -e FIRESTORE_PROJECT \
  -e FIRESTORE_DATABASE \
  -e FIRESTORE_EMULATOR_HOST \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --prebuilt firestore

# Give MCP server a moment to start
sleep 5

# Run the Python test script
python3 test_mcp.py

echo -e "\n3. Test completed!"

# 4. Clean up
echo -e "\n4. Cleaning up..."
docker-compose down -v
docker rm -f test-mcp-firestore-server 2>/dev/null || true

echo -e "\n✅ Firestore test passed!"
