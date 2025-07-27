#!/usr/bin/env python3
"""
Unified MCP Database Server Test Suite

Single script that tests all MCP database functionality:
- Health checks
- MCP tool calls with SELECT statements  
- Basic functionality validation

Usage: python test_all.py [database]
"""

import json
import requests
import time
import sys
import os
from typing import Dict, List, Optional, Any

# Test configuration
MCP_SERVERS = {
    'postgres': {
        'url': 'http://mcp-postgres:5000',
        'test_queries': [
            'SELECT COUNT(*) as user_count FROM users;',
            'SELECT username, email FROM users LIMIT 2;',
            'SELECT p.name, p.price FROM products p WHERE p.category = \'Electronics\' LIMIT 3;',
            'SELECT u.username, COUNT(o.id) as order_count FROM users u LEFT JOIN orders o ON u.id = o.user_id GROUP BY u.id, u.username;'
        ]
    },
    'mysql': {
        'url': 'http://mcp-mysql:5000', 
        'test_queries': [
            'SELECT COUNT(*) as user_count FROM users;',
            'SELECT username, email FROM users LIMIT 2;',
            'SELECT p.name, p.price FROM products p WHERE p.category = \'Electronics\' LIMIT 3;',
            'SELECT u.username, COUNT(o.id) as order_count FROM users u LEFT JOIN orders o ON u.id = o.user_id GROUP BY u.id, u.username;'
        ]
    },
    'sqlite': {
        'url': 'http://mcp-sqlite:5000',
        'test_queries': [
            'SELECT COUNT(*) as user_count FROM users;',
            'SELECT username, email FROM users LIMIT 2;',
            'SELECT p.name, p.price FROM products p WHERE p.category = \'Electronics\' LIMIT 3;',
            'SELECT sqlite_version();',
            'SELECT name FROM sqlite_master WHERE type=\'table\';'
        ]
    },
    'redis': {
        'url': 'http://mcp-redis:5000',
        'test_queries': [
            'INFO server',
            'PING'
        ]
    }
}

class MCPTester:
    def __init__(self, database: str):
        self.database = database
        self.config = MCP_SERVERS.get(database)
        if not self.config:
            raise ValueError(f"Database {database} not supported")
        
        self.base_url = self.config['url']
        self.test_queries = self.config['test_queries']
        self.results = []
        
    def log(self, message: str, level: str = "INFO"):
        """Log message with timestamp"""
        timestamp = time.strftime('%H:%M:%S')
        color_codes = {
            "INFO": "\033[0;34m",     # Blue
            "SUCCESS": "\033[0;32m",  # Green
            "WARNING": "\033[1;33m",  # Yellow
            "ERROR": "\033[0;31m",    # Red
        }
        reset = "\033[0m"
        color = color_codes.get(level, "")
        print(f"{color}[{timestamp}] [{level}] {message}{reset}")
    
    def wait_for_server(self, timeout: int = 60) -> bool:
        """Wait for MCP server to be ready"""
        self.log(f"Waiting for {self.database} MCP server at {self.base_url}...")
        
        start_time = time.time()
        while time.time() - start_time < timeout:
            try:
                # Try both health endpoint and root endpoint
                for endpoint in ['/health', '/']:
                    try:
                        response = requests.get(f"{self.base_url}{endpoint}", timeout=5)
                        if response.status_code == 200:
                            self.log(f"{self.database} MCP server is ready", "SUCCESS")
                            return True
                    except requests.exceptions.RequestException:
                        continue
            except Exception:
                pass
            
            time.sleep(2)
        
        self.log(f"{self.database} MCP server failed to start within {timeout}s", "ERROR")
        return False
    
    def test_health_check(self) -> bool:
        """Test basic health endpoint"""
        self.log(f"Testing {self.database} health endpoint...")
        
        try:
            response = requests.get(f"{self.base_url}/", timeout=10)
            if response.status_code == 200:
                self.log("Health check passed", "SUCCESS")
                return True
            else:
                self.log(f"Health check failed: HTTP {response.status_code}", "ERROR")
                return False
        except requests.exceptions.RequestException as e:
            self.log(f"Health check failed: {e}", "ERROR")
            return False
    
    def test_mcp_tool_call(self, query: str) -> Dict[str, Any]:
        """Test a single MCP tool call"""
        self.log(f"Testing query: {query[:50]}..." if len(query) > 50 else f"Testing query: {query}")
        
        # Prepare MCP tool call payload
        if self.database in ['postgres', 'mysql', 'sqlite']:
            payload = {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "tools/call",
                "params": {
                    "name": "execute-sql",
                    "arguments": {
                        "query": query
                    }
                }
            }
        elif self.database == 'redis':
            payload = {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "tools/call", 
                "params": {
                    "name": "execute-command",
                    "arguments": {
                        "command": query
                    }
                }
            }
        else:
            raise ValueError(f"Unknown database type: {self.database}")
        
        try:
            response = requests.post(
                f"{self.base_url}/mcp",
                json=payload,
                headers={'Content-Type': 'application/json'},
                timeout=15
            )
            
            result = {
                'query': query,
                'status_code': response.status_code,
                'success': response.status_code == 200,
                'response': None,
                'error': None
            }
            
            if response.status_code == 200:
                try:
                    result['response'] = response.json()
                    self.log(f"  ✅ Success: {response.status_code}", "SUCCESS")
                    
                    # Print result summary
                    if 'result' in result['response']:
                        data = result['response']['result']
                        if isinstance(data, dict) and 'content' in data:
                            if isinstance(data['content'], list):
                                self.log(f"  📊 Returned {len(data['content'])} rows")
                            else:
                                self.log(f"  📊 Result: {str(data['content'])[:100]}...")
                        else:
                            self.log(f"  📊 Result: {str(data)[:100]}...")
                    
                except json.JSONDecodeError:
                    result['response'] = response.text
                    self.log(f"  ✅ Success: {response.status_code} (non-JSON response)")
            else:
                result['error'] = response.text
                self.log(f"  ❌ Failed: {response.status_code} - {response.text[:100]}...", "ERROR")
                
        except requests.exceptions.RequestException as e:
            result = {
                'query': query,
                'status_code': None,
                'success': False,
                'response': None,
                'error': str(e)
            }
            self.log(f"  ❌ Request failed: {e}", "ERROR")
        
        return result
    
    def test_mcp_tools_list(self) -> bool:
        """Test MCP tools/list endpoint"""
        self.log("Testing MCP tools/list endpoint...")
        
        payload = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/list"
        }
        
        try:
            response = requests.post(
                f"{self.base_url}/mcp",
                json=payload,
                headers={'Content-Type': 'application/json'},
                timeout=10
            )
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    if 'result' in data and 'tools' in data['result']:
                        tools = data['result']['tools']
                        self.log(f"Found {len(tools)} available tools", "SUCCESS")
                        for tool in tools:
                            self.log(f"  - {tool.get('name', 'unnamed')}: {tool.get('description', 'no description')}")
                        return True
                    else:
                        self.log("Invalid tools/list response format", "ERROR")
                        return False
                except json.JSONDecodeError:
                    self.log("Failed to parse tools/list response", "ERROR")
                    return False
            else:
                self.log(f"tools/list failed: HTTP {response.status_code}", "ERROR")
                return False
                
        except requests.exceptions.RequestException as e:
            self.log(f"tools/list request failed: {e}", "ERROR")
            return False
    
    def run_all_tests(self) -> Dict[str, Any]:
        """Run complete test suite for this database"""
        self.log(f"Starting {self.database.upper()} MCP test suite")
        print("=" * 60)
        
        # Wait for server
        if not self.wait_for_server():
            return {
                'database': self.database,
                'server_ready': False,
                'health_check': False,
                'tools_list': False,
                'query_tests': [],
                'success_count': 0,
                'total_count': 0,
                'success_rate': 0.0,
                'overall_success': False
            }
        
        # Test health check
        health_ok = self.test_health_check()
        
        # Test tools list
        tools_ok = self.test_mcp_tools_list()
        
        # Test queries
        query_results = []
        query_success_count = 0
        
        self.log("Testing MCP tool calls with SQL queries...")
        for query in self.test_queries:
            result = self.test_mcp_tool_call(query)
            query_results.append(result)
            if result['success']:
                query_success_count += 1
            time.sleep(1)  # Brief pause between tests
        
        total_queries = len(self.test_queries)
        query_success_rate = (query_success_count / total_queries) * 100 if total_queries > 0 else 0
        
        # Overall success calculation
        overall_success = health_ok and tools_ok and (query_success_count == total_queries)
        
        self.log(f"Query Results: {query_success_count}/{total_queries} successful ({query_success_rate:.1f}%)")
        
        result_summary = {
            'database': self.database,
            'server_ready': True,
            'health_check': health_ok,
            'tools_list': tools_ok,
            'query_tests': query_results,
            'success_count': query_success_count,
            'total_count': total_queries,
            'success_rate': query_success_rate,
            'overall_success': overall_success
        }
        
        if overall_success:
            self.log(f"{self.database} test suite PASSED", "SUCCESS")
        else:
            self.log(f"{self.database} test suite FAILED", "ERROR")
        
        return result_summary

def test_database(database: str) -> Dict[str, Any]:
    """Test a specific database"""
    try:
        tester = MCPTester(database)
        return tester.run_all_tests()
    except Exception as e:
        print(f"❌ Failed to test {database}: {e}")
        return {
            'database': database,
            'server_ready': False,
            'health_check': False,
            'tools_list': False,
            'query_tests': [],
            'success_count': 0,
            'total_count': 0,
            'success_rate': 0.0,
            'overall_success': False,
            'error': str(e)
        }

def main():
    """Main test runner"""
    print("🚀 Unified MCP Database Test Suite")
    print("Testing health checks + MCP tool calls + SELECT statements")
    print("=" * 70)
    
    # Get database from command line argument or test all
    if len(sys.argv) > 1:
        databases_to_test = [sys.argv[1]]
    else:
        databases_to_test = list(MCP_SERVERS.keys())
    
    all_results = []
    
    for database in databases_to_test:
        if database not in MCP_SERVERS:
            print(f"❌ Unknown database: {database}")
            continue
            
        result = test_database(database)
        all_results.append(result)
        print()  # Spacing between database tests
    
    # Final Summary
    print("=" * 70)
    print("📊 FINAL TEST SUMMARY")
    print("=" * 70)
    
    total_success = 0
    total_tests = 0
    all_passed = True
    
    for result in all_results:
        status_health = "✅" if result['health_check'] else "❌"
        status_tools = "✅" if result['tools_list'] else "❌" 
        status_queries = f"{result['success_count']}/{result['total_count']}"
        
        overall_status = "✅ PASS" if result['overall_success'] else "❌ FAIL"
        
        print(f"{result['database']:12} | Health:{status_health} Tools:{status_tools} Queries:{status_queries:>5} | {overall_status}")
        
        total_success += result['success_count']
        total_tests += result['total_count']
        
        if not result['overall_success']:
            all_passed = False
    
    overall_rate = (total_success / total_tests) * 100 if total_tests > 0 else 0
    print("-" * 70)
    print(f"{'OVERALL':12} | Total Queries: {total_success:>2}/{total_tests:2} ({overall_rate:5.1f}%) | {'✅ PASS' if all_passed else '❌ FAIL'}")
    
    # Exit with appropriate code
    if all_passed:
        print(f"\n🎉 All tests passed! Overall success rate: {overall_rate:.1f}%")
        sys.exit(0)
    else:
        print(f"\n⚠️  Some tests failed. Overall success rate: {overall_rate:.1f}%")
        sys.exit(1)

if __name__ == "__main__":
    main() 