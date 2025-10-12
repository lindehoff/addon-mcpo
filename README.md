# Home Assistant MCPO Add-on Repository

This repository contains a Home Assistant add-on for [MCPO](https://github.com/open-webui/mcpo) - a proxy server that exposes Model Context Protocol (MCP) tools as standard OpenAPI endpoints.

## What is MCPO?

MCPO (MCP-to-OpenAPI) bridges the gap between MCP servers and applications expecting standard RESTful APIs. It provides:

- ✅ Standard OpenAPI endpoints for MCP tools
- 🛡 Built-in security with API key authentication
- 🧠 Auto-generated interactive documentation
- 🔌 Support for multiple MCP server types (stdio, SSE, HTTP)
- 🔄 Hot-reload configuration support

## Installation

### Add Repository to Home Assistant

1. Navigate to **Settings** → **Add-ons** → **Add-on Store**
2. Click the **⋮** menu in the top right → **Repositories**
3. Add this repository URL:
   ```
   https://github.com/lindehoff/addon-mcpo
   ```
4. Click **Add**

### Install the Add-on

1. Find "MCPO" in the add-on store
2. Click on it
3. Click **Install**
4. Configure the add-on (see below)
5. Click **Start**

## Quick Start

### Simple Mode (Single MCP Server)

```yaml
port: 8000
api_key: your-secret-key
config_mode: simple
mcp_command: uvx
mcp_args: mcp-server-time --local-timezone=America/New_York
```

### Config File Mode (Multiple MCP Servers)

```yaml
port: 8000
api_key: your-secret-key
config_mode: config_file
hot_reload: true
config_file: config.json  # stored in /config/mcpo
env_vars:
  - name: HA_LONG_LIVED_TOKEN
    value: "<your-token>"
```

Create or edit `/config/mcpo/config.json` on the Home Assistant host:

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

## Features

### 🎯 Two Configuration Modes

- **Simple Mode**: Quick setup for single MCP servers
- **Config File Mode**: Advanced setup for multiple servers with hot-reload support

### 🤖 AI-Friendly Configuration

Ask an LLM to generate your configuration! The add-on is designed to work seamlessly with AI assistants:

> "Create a MCPO config with memory, time, and GitHub servers"

The AI can generate valid JSON configuration that you paste directly into the add-on.

### 🔄 Hot Reload

Enable `hot_reload: true` in config file mode to automatically reload when configuration changes - no restart required!

### 🔐 Built-in Security

Set an API key to protect your MCPO endpoints from unauthorized access.

### 📚 Auto-Generated Documentation

Access interactive OpenAPI documentation at `http://homeassistant.local:8000/docs`

## Configuration Options

| Option | Type | Description |
|--------|------|-------------|
| `port` | port | Port for MCPO server (default: 8000) |
| `api_key` | password | API key for authentication (recommended) |
| `config_mode` | list | `simple` or `config_file` |
| `mcp_command` | string | MCP server command (simple mode) |
| `mcp_args` | string | MCP server arguments (simple mode) |
| `config_file_content` | string | JSON config (config_file mode) |
| `hot_reload` | bool | Auto-reload on config changes |
| `env_vars` | list | Additional environment variables |

## Popular MCP Servers

- **@modelcontextprotocol/server-memory**: Persistent memory for conversations
- **mcp-server-time**: Time and timezone utilities
- **@modelcontextprotocol/server-filesystem**: File system access
- **@modelcontextprotocol/server-brave-search**: Web search via Brave
- **@modelcontextprotocol/server-github**: GitHub integration
- **@modelcontextprotocol/server-postgres**: PostgreSQL database access

Browse more at the [MCP Servers Directory](https://github.com/modelcontextprotocol).

## Integration with Open WebUI

1. Start the MCPO add-on
2. In Open WebUI, go to **Settings** → **Tools** → **OpenAPI Tools**
3. Add your MCPO endpoint: `http://homeassistant.local:8000`
4. Configure API key if set
5. Your MCP tools are now available to Open WebUI!

For detailed instructions, see the [Integration Guide](https://docs.openwebui.com/openapi-servers/mcp).

## Documentation

- [Add-on Documentation](mcpo/DOCS.md)
- [MCPO Documentation](https://docs.openwebui.com/openapi-servers/mcp)
- [MCPO GitHub](https://github.com/open-webui/mcpo)
- [MCP Protocol](https://modelcontextprotocol.io/)

## Support

If you encounter issues or have questions:

1. Check the [add-on documentation](mcpo/DOCS.md)
2. Review the [MCPO documentation](https://docs.openwebui.com/openapi-servers/mcp)
3. Open an issue on [GitHub](https://github.com/lindehoff/addon-mcpo/issues)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [MCPO](https://github.com/open-webui/mcpo) by Open WebUI team
- [Home Assistant](https://www.home-assistant.io/) community
- [Model Context Protocol](https://modelcontextprotocol.io/) specification

