#!/bin/bash
set -eo pipefail  # Fail on errors and pipeline errors

INPUT_FILE="/data/options.json"
CONFIG_DIR="/config/mcpo"

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
        select(.key != "env_vars" and .key != "config_file" and .key != "mcp_command" and .key != "mcp_args" and .key != "config_mode") | 
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

# Add port and bind to all interfaces
if [ -n "${port:-}" ]; then
    MCPO_ARGS="$MCPO_ARGS --port $port --host 0.0.0.0"
    echo "Using port: $port (binding to all interfaces)"
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

# Helper to preprocess config: envsubst and strip comment lines starting with //
process_config() {
    local source_file="$1"
    local target_file="$2"
    # Substitute environment variables, then remove full-line // comments
    # We intentionally only support full-line comments to avoid JSON parsing ambiguity
    envsubst < "$source_file" | grep -vE '^[[:space:]]*//' > "$target_file"

    # Validate processed JSON
    if ! jq empty "$target_file" 2>/dev/null; then
        echo "Error: Processed config is not valid JSON: $target_file"
        echo "Tip: Ensure only full-line // comments are used and JSON is valid after removing them."
        exit 1
    fi
}

# Handle configuration based on mode
if [ "$CONFIG_MODE" = "config_file" ]; then
    echo "=========================================="
    echo "Using config file mode"
    echo "=========================================="
    
    # Ensure config directory exists
    mkdir -p "$CONFIG_DIR"

    # Get config file name from options
    CONFIG_FILENAME=$(jq -r '.config_file // "config.json"' "$INPUT_FILE")
    CONFIG_FILE="${CONFIG_DIR}/${CONFIG_FILENAME}"
    PROCESSED_CONFIG_FILE="/tmp/mcpo-config.processed.json"
    
    # Create default config with commented examples on first run
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "No config found. Creating default at: $CONFIG_FILE"
        cat > "$CONFIG_FILE" <<'EOF'
// MCPO configuration file for Home Assistant
// Place this file at /config/mcpo/config.json (created automatically on first run).
// You can reference environment variables set in the add-on's configuration under env_vars
// using ${VAR_NAME}. Only full-line // comments are supported.
{
  // Example: enable a time server (uncomment the block and adjust timezone)
  // "mcpServers": {
  //   "time": {
  //     "command": "uvx",
  //     "args": ["mcp-server-time", "--local-timezone=${LOCAL_TZ:-UTC}"]
  //   }
  // }

  // Example: Home Assistant MCP server over SSE
  // Requires a long-lived access token provided via env_vars as HA_LONG_LIVED_TOKEN
  // "mcpServers": {
  //   "home_assistant": {
  //     "type": "sse",
  //     "url": "http://homeassistant:8123/mcp_server/sse",
  //     "headers": {
  //       "Authorization": "Bearer ${HA_LONG_LIVED_TOKEN}"
  //     }
  //   }
  // }

  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
EOF
        echo "Created default config with examples. Edit this file to add servers."
    fi

    echo "Preparing config from: $CONFIG_FILE"

    # Initial processing
    process_config "$CONFIG_FILE" "$PROCESSED_CONFIG_FILE"

    # If hot_reload is enabled, set up a watcher to reprocess on changes
    if [ "${hot_reload:-false}" = "true" ]; then
        echo "Hot-reload enabled: watching $CONFIG_FILE for changes"
        (
            command -v inotifywait >/dev/null 2>&1 || {
                echo "Warning: inotifywait not found; hot-reload processing will not auto-update."
                exit 0
            }
            inotifywait -m -e close_write "$CONFIG_FILE" | while read -r _; do
                echo "Config changed. Reprocessing..."
                if process_config "$CONFIG_FILE" "$PROCESSED_CONFIG_FILE"; then
                    echo "Config reprocessed successfully."
                else
                    echo "Warning: Failed to reprocess config after change. Keeping previous valid config."
                fi
            done
        ) &
    fi

    MCPO_ARGS="$MCPO_ARGS --config $PROCESSED_CONFIG_FILE"
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

