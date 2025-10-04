# MCPO

## Overview

MCPO (MCP-to-OpenAPI) is a proxy server that exposes Model Context Protocol (MCP) tools as standard OpenAPI endpoints. It bridges the gap between MCP servers and applications expecting standard RESTful APIs.

## Installation

Follow these steps to install the add-on:

1. Navigate to the Home Assistant Add-on Store
2. Click on the three dots in the upper right corner and select "Repositories"
3. Add the repository URL: `https://github.com/lindehoff/addon-mcpo`
4. Find the "MCPO" add-on in the list and click on it
5. Click "Install"

## Configuration Modes

MCPO supports two configuration modes to suit different use cases.

### Simple Mode

Use simple mode when you want to run a single MCP server. This is the easiest way to get started.

**Example Configuration:**
```yaml
port: 8000
api_key: my-secret-key
config_mode: simple
mcp_command: uvx
mcp_args: mcp-server-time --local-timezone=America/New_York
```

This will start a single time server accessible at `http://homeassistant.local:8000`.

### Config File Mode

Use config file mode when you want to run multiple MCP servers simultaneously or need advanced configuration options like SSE or HTTP-based MCP servers.

**Example Configuration:**
```yaml
port: 8000
api_key: my-secret-key
config_mode: config_file
hot_reload: true
config_file_content: |
  {
    "mcpServers": {
      "memory": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-memory"]
      },
      "time": {
        "command": "uvx",
        "args": ["mcp-server-time", "--local-timezone=America/New_York"]
      },
      "brave_search": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-brave-search"],
        "env": {
          "BRAVE_API_KEY": "your-brave-api-key"
        }
      }
    }
  }
```

Each server will be accessible at its own route:
- `http://homeassistant.local:8000/memory`
- `http://homeassistant.local:8000/time`
- `http://homeassistant.local:8000/brave_search`

## Configuration Options

### Required Options

#### `port`
**Type:** `port`  
**Default:** `8000`

The port MCPO will listen on. Make sure this port is not used by another service.

#### `config_mode`
**Type:** `list(simple|config_file)`  
**Default:** `simple`

Determines how MCPO is configured:
- `simple`: Single MCP server using command/args
- `config_file`: Multiple MCP servers using JSON configuration

### Optional Options

#### `api_key`
**Type:** `password`  
**Default:** (empty)

API key for securing your MCPO endpoints. Highly recommended for production use. If not set, your MCPO server will be accessible without authentication.

**Security Note:** Always set an API key when exposing MCPO to your network.

#### `mcp_command`
**Type:** `string`  
**Required in simple mode**

The command to execute your MCP server. Common values:
- `uvx`: For Python-based MCP servers
- `npx`: For Node.js-based MCP servers
- `python`: For direct Python execution
- Custom commands for your own MCP servers

#### `mcp_args`
**Type:** `string`  
**Optional in simple mode**

Arguments to pass to the MCP server command. Can include multiple space-separated arguments.

Example: `mcp-server-time --local-timezone=America/New_York`

#### `config_file_content`
**Type:** `string` (JSON)  
**Required in config_file mode**

JSON configuration for multiple MCP servers. Follows the Claude Desktop configuration format.

**Structure:**
```json
{
  "mcpServers": {
    "server_name": {
      "command": "command",
      "args": ["arg1", "arg2"],
      "env": {
        "VAR": "value"
      }
    }
  }
}
```

**Supported Server Types:**

1. **stdio servers** (default):
```json
{
  "server_name": {
    "command": "uvx",
    "args": ["mcp-server-time"]
  }
}
```

2. **SSE servers**:
```json
{
  "sse_server": {
    "type": "sse",
    "url": "http://127.0.0.1:8001/sse",
    "headers": {
      "Authorization": "Bearer token"
    }
  }
}
```

3. **Streamable HTTP servers**:
```json
{
  "http_server": {
    "type": "streamable-http",
    "url": "http://127.0.0.1:8002/mcp"
  }
}
```

#### `hot_reload`
**Type:** `boolean`  
**Default:** `false`

Enable automatic reloading when the config file changes. Only works in `config_file` mode.

When enabled, MCPO will watch for changes to the configuration and automatically reload servers without downtime.

#### `env_vars`
**Type:** `list`

Additional environment variables to pass to MCPO or MCP servers.

**Example:**
```yaml
env_vars:
  - name: DEBUG
    value: "1"
  - name: LOG_LEVEL
    value: INFO
```

## AI-Assisted Configuration

This add-on is designed to work seamlessly with AI assistants. You can ask an LLM to generate configuration for you.

**Example prompts:**

> "Create a MCPO configuration with memory and time servers"

> "Generate a config with GitHub, filesystem, and Brave search servers. Use /config for filesystem access."

> "Add a Postgres server to my MCPO config with connection to localhost:5432"

The AI can generate valid JSON that you can paste directly into `config_file_content`.

## Usage Examples

### Example 1: Single Time Server

```yaml
port: 8000
api_key: secure-random-key
config_mode: simple
mcp_command: uvx
mcp_args: mcp-server-time --local-timezone=Europe/London
```

Access at: `http://homeassistant.local:8000`

### Example 2: Multiple Servers with Hot Reload

```yaml
port: 8000
api_key: secure-random-key
config_mode: config_file
hot_reload: true
config_file_content: |
  {
    "mcpServers": {
      "memory": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-memory"]
      },
      "time": {
        "command": "uvx",
        "args": ["mcp-server-time", "--local-timezone=Europe/London"]
      },
      "filesystem": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "/config"]
      }
    }
  }
```

Access at:
- `http://homeassistant.local:8000/memory`
- `http://homeassistant.local:8000/time`
- `http://homeassistant.local:8000/filesystem`

### Example 3: GitHub Integration

```yaml
port: 8000
api_key: secure-random-key
config_mode: config_file
config_file_content: |
  {
    "mcpServers": {
      "github": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"],
        "env": {
          "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token_here"
        }
      }
    }
  }
```

## Integrating with Open WebUI

1. Start the MCPO add-on
2. In Open WebUI, navigate to **Settings → Tools → OpenAPI Tools**
3. Click **"Add OpenAPI Tool"**
4. Enter the MCPO URL: `http://homeassistant.local:8000`
5. If you configured an API key, add it in the authentication section
6. Save and your MCP tools are now available!

For detailed integration instructions, see [Open WebUI MCPO Integration](https://docs.openwebui.com/openapi-servers/mcp).

## Troubleshooting

### Add-on won't start

1. Check the logs for error messages
2. Verify your configuration syntax (especially JSON in config_file mode)
3. Ensure the port is not in use by another service
4. Verify MCP server commands are available (uvx, npx, etc.)

### Can't access MCPO endpoints

1. Verify the add-on is running
2. Check that you're using the correct port
3. Ensure your API key matches if configured
4. Try accessing from the Home Assistant host first

### MCP server not responding

1. Check add-on logs for MCP server errors
2. Verify the MCP server command and arguments are correct
3. Test the MCP server command manually
4. Check environment variables are properly set

### Hot reload not working

1. Ensure `hot_reload: true` is set
2. Verify you're in `config_file` mode (hot reload only works in this mode)
3. Check logs for reload messages
4. Try restarting the add-on

## Available MCP Servers

Here are some popular MCP servers you can use:

### Official MCP Servers

- `@modelcontextprotocol/server-memory`: Persistent memory
- `@modelcontextprotocol/server-filesystem`: File system access
- `@modelcontextprotocol/server-github`: GitHub integration
- `@modelcontextprotocol/server-brave-search`: Web search
- `@modelcontextprotocol/server-postgres`: PostgreSQL access
- `@modelcontextprotocol/server-sqlite`: SQLite database access
- `@modelcontextprotocol/server-slack`: Slack integration

### Community MCP Servers

- `mcp-server-time`: Time and timezone utilities
- Many more at [MCP Servers](https://github.com/modelcontextprotocol)

## Security Considerations

1. **Always set an API key** when exposing MCPO to your network
2. **Be careful with filesystem access** - only grant access to necessary directories
3. **Protect API keys and tokens** in environment variables
4. **Use network segmentation** to limit access to your MCPO instance
5. **Review MCP server permissions** before deploying

## Support and Resources

- [MCPO GitHub Repository](https://github.com/open-webui/mcpo)
- [MCPO Documentation](https://docs.openwebui.com/openapi-servers/mcp)
- [Open WebUI Documentation](https://docs.openwebui.com/)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
- [Add-on Issues](https://github.com/lindehoff/addon-mcpo/issues)

