#!/usr/bin/env python3
"""
Simple MCP test for SQL Server
Tests the exact docker command from the README
"""

import json
import subprocess
import sys

def test_mcp_sqlserver():
    """Test SQL Server MCP server with a simple list_tables call"""
    print("Testing SQL Server MCP server...")
    
    # Environment variables for SQL Server connection
    # Note: The MCP server expects MSSQL_* variables, not SQLSERVER_*
    env = {
        "MSSQL_HOST": "localhost",
        "MSSQL_DATABASE": "testdb",  # Use testdb instead of master
        "MSSQL_USER": "sa",
        "MSSQL_PASSWORD": "YourStrong!Password123",
        "MSSQL_PORT": "1433",
        "MSSQL_TRUST_CERT": "true",  # Trust self-signed certificate
        "MSSQL_ENCRYPT": "false"  # Try disabling encryption due to certificate issues
    }
    
    # Docker command - using MSSQL_* variables that the server expects
    cmd = [
        "docker", "run", "--rm", "-i",
        "--network", "host",
        "-e", "MSSQL_HOST",
        "-e", "MSSQL_DATABASE",
        "-e", "MSSQL_USER",
        "-e", "MSSQL_PASSWORD",
        "-e", "MSSQL_PORT",
        "-e", "MSSQL_TRUST_CERT",
        "-e", "MSSQL_ENCRYPT",
        "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest",
        "--prebuilt", "mssql",
        "--stdio"
    ]
    
    # Start the process
    process = subprocess.Popen(
        cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        env={**env, **subprocess.os.environ}
    )
    
    try:
        # Send initialize request
        initialize_request = {
            "jsonrpc": "2.0",
            "method": "initialize",
            "params": {
                "protocolVersion": "1.0.0",
                "capabilities": {},
                "clientInfo": {
                    "name": "test-client",
                    "version": "1.0.0"
                }
            },
            "id": 1
        }
        
        process.stdin.write(json.dumps(initialize_request) + "\n")
        process.stdin.flush()
        
        # Read initialize response
        response_line = process.stdout.readline()
        if response_line:
            try:
                response = json.loads(response_line)
                print(f"✓ Initialize response: {response.get('result', {}).get('serverInfo', {}).get('name', 'Unknown')}")
            except json.JSONDecodeError:
                # Check stderr for errors
                stderr_output = process.stderr.read()
                print(f"✗ Failed to parse response. Raw output: {response_line}")
                if stderr_output:
                    print(f"✗ Stderr: {stderr_output}")
                return False
        
        # List available tools
        list_tools_request = {
            "jsonrpc": "2.0",
            "method": "tools/list",
            "params": {},
            "id": 2
        }
        
        process.stdin.write(json.dumps(list_tools_request) + "\n")
        process.stdin.flush()
        
        # Read tools list response
        response_line = process.stdout.readline()
        if response_line:
            response = json.loads(response_line)
            if "result" in response:
                tools = response.get("result", {}).get("tools", [])
                print(f"✓ Available tools: {', '.join([tool.get('name', 'unknown') for tool in tools])}")
            else:
                print(f"✗ Failed to list tools: {response.get('error', 'Unknown error')}")
        
        # Send list_tables call
        list_tables_request = {
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {
                "name": "list_tables",
                "arguments": {
                    "table_names": ""  # Empty string to list all tables
                }
            },
            "id": 3
        }
        
        process.stdin.write(json.dumps(list_tables_request) + "\n")
        process.stdin.flush()
        
        # Read response
        response_line = process.stdout.readline()
        if response_line:
            response = json.loads(response_line)
            if "result" in response:
                print("✓ list_tables call successful")
            else:
                print(f"✗ list_tables call failed: {response.get('error', 'Unknown error')}")
                return False
        
        # Test execute_sql with a simple query
        execute_sql_request = {
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {
                "name": "execute_sql",
                "arguments": {
                    "sql": "SELECT @@VERSION;"
                }
            },
            "id": 4
        }
        
        process.stdin.write(json.dumps(execute_sql_request) + "\n")
        process.stdin.flush()
        
        # Read response
        response_line = process.stdout.readline()
        if response_line:
            response = json.loads(response_line)
            if "result" in response:
                print("✓ execute_sql call successful")
                result_data = response.get("result", [])
                # Try to extract version info from the result
                if isinstance(result_data, list) and len(result_data) > 0:
                    for item in result_data:
                        if isinstance(item, dict) and item.get("type") == "text":
                            text = item.get("text", "")
                            if text and "microsoft" in text.lower():
                                # Just print first non-empty text result
                                lines = text.strip().split('\n')
                                if lines:
                                    print(f"  Database info: {lines[0][:80]}")
                                break
                return True
            else:
                print(f"✗ execute_sql call failed: {response.get('error', 'Unknown error')}")
                return False
        
    except Exception as e:
        print(f"✗ Error: {e}")
        return False
    finally:
        # Terminate the process
        process.terminate()
        process.wait()

if __name__ == "__main__":
    success = test_mcp_sqlserver()
    sys.exit(0 if success else 1)
