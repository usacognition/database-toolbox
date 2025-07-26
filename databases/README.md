# Database-Specific Configurations

This directory contains database-specific configurations organized by database type. Each database has its own folder with:

- `Dockerfile` - Database-specific Docker image configuration
- `docker-compose.yml` - Local development setup (builds image locally)
- `docker-compose-hub.yml` - Production setup (pulls from DockerHub)
- `init.sql` - Initial database schema and test data (where applicable)
- `scripts/` - Shared scripts for health checks and entry points

## Available Databases

| Database | Port | Status |
|----------|------|---------|
| [postgres](./postgres/) | 5001 | ✅ Complete |
| [mysql](./mysql/) | 5002 | ✅ Complete |
| [redis](./redis/) | 5003 | ✅ Complete |
| [sqlite](./sqlite/) | 5004 | ✅ Complete |
| [neo4j](./neo4j/) | 5005 | ✅ Complete |
| [snowflake](./snowflake/) | 5006 | 🚧 Dockerfile only |
| [redshift](./redshift/) | 5007 | 🚧 Dockerfile only |
| [bigquery](./bigquery/) | 5008 | 🚧 Dockerfile only |
| [alloydb](./alloydb/) | 5009 | 🚧 Dockerfile only |
| [spanner](./spanner/) | 5010 | 🚧 Dockerfile only |
| [firestore](./firestore/) | 5011 | 🚧 Dockerfile only |
| [sqlserver](./sqlserver/) | 5012 | 🚧 Dockerfile only |
| [supabase](./supabase/) | 5013 | 🚧 Dockerfile only |

## Usage

### Local Development (Build from source)
```bash
cd databases/postgres
docker-compose up -d
```

### Production (Pull from DockerHub)
```bash
cd databases/postgres
docker-compose -f docker-compose-hub.yml up -d
```

### Build Individual Database
```bash
# From project root
./build.sh build-db -d postgres -n toolbox-images
```

## Project Structure

```
databases/
├── README.md
├── postgres/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── docker-compose-hub.yml
│   ├── init.sql
│   └── scripts/
├── mysql/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── docker-compose-hub.yml
│   ├── init.sql
│   └── scripts/
└── [other databases...]
```

## Testing

Each database includes comprehensive test data and schemas in their `init.sql` files, allowing for realistic end-to-end testing of MCP functionality.