#!/bin/bash
set -eo pipefail  # Fail on errors and pipeline errors

INPUT_FILE="/data/options.json"
CONFIG_DIR="/config"
CONFIG_FILE="${CONFIG_DIR}/mcpo-config.json"

echo "=========================================="
echo "Starting MCPO Add-on"
echo "=========================================="

# Single pass processing combining both env sources
while IFS= read -r line; do
    [[ -z "$line" ]] && continue  # Skip empty lines
    key="${line%%=*}"
    value="${line#*=}"
    
    echo "Setting environment variable: $key=${value@Q}"
    export "$key"="$value"
done < <(
    < "$INPUT_FILE" jq -r \
    '(
        to_entries[] | 
        select(.key != "env_vars" and .key != "config_file_content" and .key != "mcp_command" and .key != "mcp_args" and .key != "config_mode") | 
        "\(.key)=\(.value | tostring)"
    ),
    (
        .env_vars[]? | 
        "\(.name)=\(.value | tostring)"
    )'
)

# Get configuration mode
CONFIG_MODE=$(jq -r '.config_mode // "simple"' "$INPUT_FILE")
echo "Configuration mode: $CONFIG_MODE"

# Build MCPO command arguments
MCPO_ARGS=""

# Add port
if [ -n "${port:-}" ]; then
    MCPO_ARGS="$MCPO_ARGS --port $port"
    echo "Using port: $port"
fi

# Add API key if provided
if [ -n "${api_key:-}" ]; then
    MCPO_ARGS="$MCPO_ARGS --api-key $api_key"
    echo "API key configured: ****"
else
    echo "Warning: No API key configured. Your MCPO server will be unprotected!"
fi

# Add hot-reload flag if enabled
if [ "${hot_reload:-false}" = "true" ]; then
    MCPO_ARGS="$MCPO_ARGS --hot-reload"
    echo "Hot-reload enabled"
fi

# Handle configuration based on mode
if [ "$CONFIG_MODE" = "config_file" ]; then
    echo "=========================================="
    echo "Using config file mode"
    echo "=========================================="
    
    # Create config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"
    
    # Get config file content from options
    CONFIG_CONTENT=$(jq -r '.config_file_content // "{}"' "$INPUT_FILE")
    
    # Check if config content is valid JSON
    if echo "$CONFIG_CONTENT" | jq empty 2>/dev/null; then
        echo "$CONFIG_CONTENT" > "$CONFIG_FILE"
        echo "Config file created at: $CONFIG_FILE"
        echo "Config file preview:"
        jq '.' "$CONFIG_FILE" || cat "$CONFIG_FILE"
        
        MCPO_ARGS="$MCPO_ARGS --config $CONFIG_FILE"
    else
        echo "Error: Invalid JSON in config_file_content"
        exit 1
    fi
else
    echo "=========================================="
    echo "Using simple mode"
    echo "=========================================="
    
    # Get MCP command and args
    MCP_COMMAND=$(jq -r '.mcp_command // ""' "$INPUT_FILE")
    MCP_ARGS=$(jq -r '.mcp_args // ""' "$INPUT_FILE")
    
    if [ -z "$MCP_COMMAND" ]; then
        echo "Error: mcp_command is required in simple mode"
        echo "Please configure the MCP server command in the add-on configuration"
        exit 1
    fi
    
    echo "MCP Command: $MCP_COMMAND"
    echo "MCP Args: $MCP_ARGS"
    
    # Build the full command to pass to MCPO
    if [ -n "$MCP_ARGS" ]; then
        MCPO_ARGS="$MCPO_ARGS -- $MCP_COMMAND $MCP_ARGS"
    else
        MCPO_ARGS="$MCPO_ARGS -- $MCP_COMMAND"
    fi
fi

echo "=========================================="
echo "Starting MCPO with arguments: $MCPO_ARGS"
echo "=========================================="

# Execute MCPO
exec mcpo $MCPO_ARGS

