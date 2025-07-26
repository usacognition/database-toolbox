# MCP Server Testing Guide

This guide shows how to interact with MCP servers running through docker-compose.

## Starting MCP Servers

```bash
cd databases/postgres
docker-compose up -d
```

The MCP server will be available at `http://localhost:5001/mcp`

## MCP Protocol

The MCP server uses JSON-RPC 2.0 over HTTP POST. All requests should:
- Use `POST` method
- Set `Content-Type: application/json`
- Send to `/mcp` endpoint

## Available MCP Methods

### 1. List Available Tools

```bash
curl -X POST http://localhost:5001/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/list"
  }'
```

**Response**: List of available tools with their schemas

### 2. Call a Tool

```bash
curl -X POST http://localhost:5001/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/call",
    "params": {
      "name": "TOOL_NAME",
      "arguments": {
        "param1": "value1"
      }
    }
  }'
```

## PostgreSQL MCP Tools

### Available Tools:
1. **`execute_sql`** - Execute SQL queries
2. **`list_tables`** - Get detailed table schema information

### Example: Execute SQL Query

```bash
curl -X POST http://localhost:5001/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
      "name": "execute_sql",
      "arguments": {
        "sql": "SELECT * FROM users LIMIT 5"
      }
    }
  }'
```

### Example: List Table Schema

```bash
curl -X POST http://localhost:5001/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 4,
    "method": "tools/call",
    "params": {
      "name": "list_tables",
      "arguments": {
        "table_names": "users,orders"
      }
    }
  }'
```

## Testing from Within Docker

You can also test from within the MCP container itself:

```bash
docker exec mcp-postgres-server-local curl -X POST http://localhost:5000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}'
```

## Port Mapping

Each database uses a different port:

| Database | Port | Container Name |
|----------|------|----------------|
| PostgreSQL | 5001 | mcp-postgres-server-local |
| MySQL | 5002 | mcp-mysql-server-local |
| Redis | 5003 | mcp-redis-server-local |
| SQLite | 5004 | mcp-sqlite-server-local |
| Neo4j | 5005 | mcp-neo4j-server-local |

## Sample Test Data

The PostgreSQL setup includes realistic e-commerce test data:

- **users**: 4 users with profiles
- **products**: 5 products across categories  
- **orders**: 4 orders with different statuses
- **order_items**: 8 line items linking orders to products

This allows testing complex JOINs, aggregations, and relationships.

## Complex Query Examples

### User Order Summary
```sql
SELECT u.username, u.email, COUNT(o.id) as order_count, 
       COALESCE(SUM(o.total_amount), 0) as total_spent
FROM users u 
LEFT JOIN orders o ON u.id = o.user_id 
GROUP BY u.id, u.username, u.email 
ORDER BY total_spent DESC
```

### Product Sales Analysis
```sql
SELECT p.name, p.category, p.price,
       COUNT(oi.id) as times_ordered,
       SUM(oi.quantity) as total_quantity_sold
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name, p.category, p.price
ORDER BY total_quantity_sold DESC
```

### Order Status Report
```sql
SELECT o.status, COUNT(*) as order_count,
       AVG(o.total_amount) as avg_order_value,
       SUM(o.total_amount) as total_revenue
FROM orders o
GROUP BY o.status
ORDER BY total_revenue DESC
```

## Health Checks

Check if MCP server is healthy:
```bash
docker inspect mcp-postgres-server-local --format='{{.State.Health.Status}}'
```

Check server logs:
```bash
docker logs mcp-postgres-server-local
```