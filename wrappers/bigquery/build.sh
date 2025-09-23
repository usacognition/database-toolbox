#!/bin/bash
set -e

# Build script for BigQuery MCP wrapper image

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Build from parent directory so Docker can access shared wrapper script
cd "$SCRIPT_DIR/../"

# Default image name and tag
IMAGE_NAME="${IMAGE_NAME:-bigquery-mcp-wrapper}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
FULL_IMAGE_NAME="$IMAGE_NAME:$IMAGE_TAG"

echo "Building BigQuery MCP wrapper image: $FULL_IMAGE_NAME"

# Build the Docker image from bigquery subdirectory
docker build -t "$FULL_IMAGE_NAME" -f bigquery/Dockerfile .

echo "✓ Successfully built $FULL_IMAGE_NAME"
echo ""
echo "Usage example:"
echo "docker run --rm -i \\"
echo "  -e BIGQUERY_PROJECT=my-project \\"
echo "  -e BIGQUERY_DATASET=my_dataset \\"
echo "  -e BIGQUERY_CREDENTIALS_JSON='{\"type\":\"service_account\",...}' \\"
echo "  -v /var/run/docker.sock:/var/run/docker.sock \\"
echo "  $FULL_IMAGE_NAME"