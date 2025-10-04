# MCPO Addon for Home Assistant

This add-on provides [MCPO](https://github.com/open-webui/mcpo) for Home Assistant, a proxy server that exposes Model Context Protocol (MCP) tools as standard OpenAPI endpoints.

## What is MCPO?

MCPO (MCP-to-OpenAPI) is a dead-simple proxy that takes an MCP server command and makes it accessible via standard RESTful OpenAPI, so your tools "just work" with LLM agents and apps expecting OpenAPI servers.

**Benefits:**
- ✅ Works instantly with OpenAPI tools, SDKs, and UIs
- 🛡 Adds security, stability, and scalability using trusted web standards
- 🧠 Auto-generates interactive docs for every tool, no config needed
- 🔌 Uses pure HTTP—no sockets, no glue code, no surprises

## Configuration

MCPO supports two configuration modes: **Simple Mode** (single MCP server) and **Config File Mode** (multiple MCP servers).

### Simple Mode (Single MCP Server)

For running a single MCP server, use simple mode:

```yaml
port: 8000
api_key: your-secret-key
config_mode: simple
mcp_command: uvx
mcp_args: mcp-server-time --local-timezone=America/New_York
hot_reload: false
env_vars: []
```

### Config File Mode (Multiple MCP Servers)

For running multiple MCP servers with advanced configuration, use config file mode.

**Step 1:** Create a config file on your Home Assistant host at:
```
/addon_configs/{REPO}_mcpo/config.json
```

**Step 2:** Add your MCPO configuration:
```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "time": {
      "command": "uvx",
      "args": ["mcp-server-time", "--local-timezone=America/New_York"]
    }
  }
}
```

**Step 3:** Configure the add-on:
```yaml
port: 8000
api_key: your-secret-key
config_mode: config_file
config_file: config.json
hot_reload: true
```

### Configuration Options

#### `port` (required)
The port that MCPO will use. Default is `8000`.

#### `api_key` (recommended)
API key for securing your MCPO endpoints. If not set, your server will be unprotected.

#### `config_mode` (required)
Choose between:
- `simple`: Single MCP server using `mcp_command` and `mcp_args`
- `config_file`: Multiple MCP servers using `config_file_content`

#### `mcp_command` (required in simple mode)
The command to run your MCP server (e.g., `uvx`, `npx`, `python`).

#### `mcp_args` (optional in simple mode)
Arguments to pass to your MCP server command.

#### `config_file` (required in config_file mode)
Filename of the config file in `/addon_configs/{REPO}_mcpo/`. The file should contain JSON configuration defining multiple MCP servers. Supports:
- **stdio servers**: Traditional MCP servers with command/args
- **SSE servers**: Server-Sent Events MCP servers with URL and headers
- **Streamable HTTP servers**: HTTP-based MCP servers

Example with all server types:
```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "sse_server": {
      "type": "sse",
      "url": "http://127.0.0.1:8001/sse",
      "headers": {
        "Authorization": "Bearer token"
      }
    },
    "http_server": {
      "type": "streamable-http",
      "url": "http://127.0.0.1:8002/mcp"
    }
  }
}
```

#### `hot_reload` (optional)
Enable automatic reloading when config file changes are detected. Only works in `config_file` mode.

#### `env_vars` (optional)
Additional environment variables to pass to MCPO:

```yaml
env_vars:
  - name: CUSTOM_VAR
    value: some_value
```

## AI-Friendly Configuration

This add-on is designed to be configured by LLMs. You can ask an AI assistant to generate the `config_file_content` JSON for you. For example:

> "Create a MCPO config with memory, time, and filesystem servers. The filesystem should have access to /config directory and timezone should be EST."

The AI can generate valid JSON configuration that you can paste directly into the `config_file_content` field.

## How to use

1. Install the add-on
2. Choose your configuration mode (simple or config_file)
3. Configure the required options
4. Set a secure API key (recommended)
5. Start the add-on
6. Access the OpenAPI documentation at `http://homeassistant.local:8000/docs`
7. Integrate with Open WebUI or other OpenAPI-compatible tools

### Accessing Your MCP Tools

After starting the add-on:

- **Simple mode**: Access at `http://homeassistant.local:8000/docs`
- **Config file mode**: Each server gets its own route:
  - `http://homeassistant.local:8000/memory`
  - `http://homeassistant.local:8000/time`
  - `http://homeassistant.local:8000/filesystem`
  - Each with dedicated docs at `/memory/docs`, `/time/docs`, etc.

### Integrating with Open WebUI

To use your MCPO servers with Open WebUI:

1. In Open WebUI, go to Settings → Tools → OpenAPI Tools
2. Add your MCPO endpoint: `http://homeassistant.local:8000`
3. If you set an API key, configure it in the authentication section
4. Your MCP tools are now available to Open WebUI!

For more information, see the [Open WebUI Integration Guide](https://docs.openwebui.com/openapi-servers/mcp#-connecting-to-open-webui).

## Popular MCP Servers

Here are some popular MCP servers you can use:

- **@modelcontextprotocol/server-memory**: Persistent memory for conversations
- **mcp-server-time**: Time and timezone utilities
- **@modelcontextprotocol/server-filesystem**: File system access
- **@modelcontextprotocol/server-brave-search**: Web search via Brave
- **@modelcontextprotocol/server-github**: GitHub integration
- **@modelcontextprotocol/server-postgres**: PostgreSQL database access

Browse more at [MCP Servers Directory](https://github.com/modelcontextprotocol).

## Support

If you have any issues or questions, please visit:

- [MCPO GitHub Repository](https://github.com/open-webui/mcpo)
- [MCPO Documentation](https://docs.openwebui.com/openapi-servers/mcp)
- [Open WebUI Documentation](https://docs.openwebui.com/)
- [Add-on GitHub Repository](https://github.com/lindehoff/addon-mcpo)

