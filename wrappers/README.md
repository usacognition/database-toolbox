# MCP Database Wrapper Images

Wrapper Docker images that simplify credential and environment variable management for MCP database servers.

## Quick Start

```bash
# Test BigQuery wrapper
cd bigquery/
./test.sh
```

## What It Does

Each wrapper:
1. Accepts credentials and configuration as environment variables
2. Creates temporary credential files when needed
3. Launches the original MCP container with proper mounts and environment
4. Maintains the **exact same MCP protocol interface** as original containers
5. Cleans up temporary files automatically

## Structure

```
wrappers/
├── wrapper-entrypoint.sh   # Shared credential handling logic
└── bigquery/
    ├── Dockerfile          # BigQuery wrapper image
    ├── build.sh           # Build the wrapper image
    ├── bigquery-wrapper.sh # BigQuery-specific wrapper script
    ├── test.sh            # Test runner script
    └── test_mcp.py        # Python script to test MCP protocol
```

## Requirements

- Docker and docker-compose
- Python 3.x (for test scripts)
- Network access to `us-central1-docker.pkg.dev`

## Adding New Database Wrappers

1. Create a new directory: `wrappers/[database]/`
2. Copy and adapt wrapper script from `bigquery/bigquery-wrapper.sh`
3. Create `Dockerfile`, `build.sh`, `test.sh`, and `test_mcp.py`
4. Update this README

## Complete List of Wrapper Databases

### Successfully Implemented ✅
- **bigquery** - Handles service account JSON as environment variable

### Planned 📋
- **spanner** - Works with Google's official Spanner emulator
- **alloydb** - Google Cloud AlloyDB wrapper
- **cloud-sql-mysql** - Cloud SQL MySQL wrapper  
- **cloud-sql-postgres** - Cloud SQL PostgreSQL wrapper
- **cloud-sql-mssql** - Cloud SQL SQL Server wrapper
- **firestore** - Firestore wrapper
- **dataplex** - Dataplex wrapper

## Key Benefits

### Before (Original Method)
Users had to manage complex Docker commands with volume mounts and credential files:

```bash
# Create temporary credential file and manage Docker mounts
docker run --rm -i \
  -e BIGQUERY_PROJECT=my-project \
  -e BIGQUERY_DATASET=my-dataset \
  -e GOOGLE_APPLICATION_CREDENTIALS=/creds/sa.json \
  -v "/path/to/service-account.json:/creds/sa.json:ro" \
  us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest \
  --prebuilt bigquery \
  --stdio
```

### After (Wrapper Method)
Users get simplified credential management with inline JSON:

```bash
# Wrapper handles credential file creation and container launching
docker run --rm -i \
  -e BIGQUERY_PROJECT=my-project \
  -e BIGQUERY_DATASET=my-dataset \
  -e BIGQUERY_CREDENTIALS_JSON='{"type":"service_account",...}' \
  -v /var/run/docker.sock:/var/run/docker.sock \
  bigquery-mcp-wrapper:latest
```

## Architecture

Each wrapper uses a Docker-in-Docker pattern:

1. **Wrapper Container**: Lightweight Alpine Linux container with wrapper logic
2. **Original Container**: The actual MCP server launched by the wrapper
3. **Shared Resources**: Temporary credential files, Docker socket access

This design ensures:
- ✅ **Full Compatibility**: Identical MCP protocol behavior
- ✅ **No Modification**: Original Google containers remain unchanged  
- ✅ **Easy Updates**: When Google updates containers, wrappers still work
- ✅ **Secure**: Proper credential file permissions and cleanup