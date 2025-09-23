# BigQuery MCP Wrapper Dockerfile
# This creates a wrapper image that simplifies credential management for BigQuery MCP servers

FROM alpine:latest

# Install required dependencies
RUN apk add --no-cache \
    bash \
    docker-cli \
    jq \
    coreutils

# Copy wrapper scripts
COPY wrapper-entrypoint.sh /wrapper-entrypoint.sh
COPY bigquery/bigquery-wrapper.sh /bigquery-wrapper.sh

# Make scripts executable
RUN chmod +x /wrapper-entrypoint.sh /bigquery-wrapper.sh

# Set the entrypoint to our wrapper script
ENTRYPOINT ["/bigquery-wrapper.sh"]

# Add labels for metadata
LABEL org.opencontainers.image.title="BigQuery MCP Wrapper"
LABEL org.opencontainers.image.description="Docker wrapper that simplifies credential management for BigQuery MCP servers"
LABEL org.opencontainers.image.source="https://github.com/marcosfede/toolbox-db-images"
LABEL org.opencontainers.image.vendor="Database Toolbox"