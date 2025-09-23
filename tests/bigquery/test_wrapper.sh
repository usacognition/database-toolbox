#!/bin/bash
set -e

# Always run from this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== BigQuery MCP Wrapper Test ==="
echo

echo "1. Testing MCP wrapper (Docker-in-Docker) with credentials from .env..."
python3 test_wrapper.py

echo -e "\n2. Test completed!"

echo -e "\n3. No containers to clean up."

echo -e "\n✅ BigQuery wrapper test passed!"