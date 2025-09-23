#!/usr/bin/env python3
"""
BigQuery MCP Wrapper Test
Tests the BigQuery wrapper using Docker-in-Docker setup with real credentials.
Reuses the same MCP protocol testing logic as the regular test.
"""

import os
import subprocess
import sys
import tempfile
from pathlib import Path

# Import shared testing logic from the regular test
from test_mcp import test_mcp_protocol, load_env_file


def test_mcp_bigquery_wrapper() -> bool:
    """Test BigQuery wrapper with real credentials."""
    print("Testing BigQuery MCP wrapper (Docker-in-Docker)...")

    script_dir = Path(__file__).resolve().parent
    env_path = script_dir / ".env"
    env_file = load_env_file(env_path)

    # Required configuration
    bigquery_project = env_file.get("BIGQUERY_PROJECT", "").strip()
    bigquery_dataset = env_file.get("BIGQUERY_DATASET", "").strip()
    creds_json_inline = env_file.get("BIGQUERY_CREDENTIALS_JSON", "").strip()

    # Validate required vars
    if not bigquery_project:
        print("✗ Missing required variable in .env: BIGQUERY_PROJECT")
        return False
    if not creds_json_inline:
        print("✗ Missing required variable in .env: BIGQUERY_CREDENTIALS_JSON")
        return False

    # Hardcoded settings for wrapper
    WRAPPER_IMAGE = "bigquery-mcp-wrapper:latest"

    temp_creds_file = None
    try:
        # Create temporary credentials file on host for Docker-in-Docker mounting
        with tempfile.NamedTemporaryFile(mode="w", delete=False, prefix="bigquery-wrapper-creds-", suffix=".json") as tf:
            tf.write(creds_json_inline)
            temp_creds_file = tf.name

        # Build docker command for wrapper (Docker-in-Docker setup)
        cmd = [
            "docker", "run", "--rm", "-i",
            "-e", "BIGQUERY_PROJECT",
            "-e", "BIGQUERY_DATASET", 
            "-e", "BIGQUERY_CREDENTIALS_JSON_PATH",
            "-v", "/var/run/docker.sock:/var/run/docker.sock",
            "-v", f"{temp_creds_file}:/host-creds.json:ro",
            "-v", "/tmp:/host-tmp",
            WRAPPER_IMAGE,
        ]

        # Prepare environment for the wrapper container
        child_env = {
            **os.environ,
            "BIGQUERY_PROJECT": bigquery_project,
            "BIGQUERY_DATASET": bigquery_dataset,
            "BIGQUERY_CREDENTIALS_JSON_PATH": "/host-creds.json",
        }

        process = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env=child_env,
        )

        try:
            # Use shared MCP protocol testing logic
            return test_mcp_protocol(process, "wrapper-test-client")

        finally:
            try:
                process.terminate()
                process.wait(timeout=5)
            except Exception:
                pass
    finally:
        if temp_creds_file:
            try:
                Path(temp_creds_file).unlink(missing_ok=True)
            except Exception:
                pass


if __name__ == "__main__":
    success = test_mcp_bigquery_wrapper()
    sys.exit(0 if success else 1)