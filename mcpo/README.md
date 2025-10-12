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

Configuration lives on the Home Assistant host at `/config/mcpo/<filename>`. On first run, the add-on will create `/config/mcpo/config.json` with examples and a default memory server.

**Step 1:** Edit `/config/mcpo/config.json` on your Home Assistant host and add your MCPO configuration. You can reference environment variables as `${VAR}` which are substituted at runtime.
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

**Step 2:** Configure the add-on:
```yaml
port: 8000
api_key: your-secret-key
config_mode: config_file
config_file: config.json
hot_reload: true
env_vars:
  - name: HA_LONG_LIVED_TOKEN
    value: "<your-token>"
```

### Configuration Options

#### `port` (required)
The port that MCPO will use. Default is `8000`.

#### `api_key` (recommended)
API key for securing your MCPO endpoints. If not set, your server will be unprotected.

### Generate a secure API key

Create a random, high-entropy API key locally and paste it into the add-on configuration under `api_key`.

macOS/Linux (OpenSSL):
```bash
openssl rand -base64 32
```

Cross-platform (Python 3):
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

Windows PowerShell:
```powershell
powershell -NoProfile -Command "[Convert]::ToBase64String((1..32 | ForEach-Object { [byte](Get-Random -Min 0 -Max 256) }))"
```

Keep this key secret. Do not commit it to version control or share it.

#### `config_mode` (required)
Choose between:
- `simple`: Single MCP server using `mcp_command` and `mcp_args`
- `config_file`: Multiple MCP servers using `config_file_content`

#### `mcp_command` (required in simple mode)
The command to run your MCP server (e.g., `uvx`, `npx`, `python`).

#### `mcp_args` (optional in simple mode)
Arguments to pass to your MCP server command.

#### `config_file` (required in config_file mode)
Filename of the config file in `/config/mcpo/`. The file should contain JSON configuration defining multiple MCP servers. Supports:
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
Enable automatic reloading when config file changes are detected. Only works in `config_file` mode. The add-on will reprocess the file (env var substitution and comment stripping) on save.

#### `env_vars` (optional)
Environment variables exported to MCPO and available for substitution in your config file using `${VAR}` syntax:

```yaml
env_vars:
  - name: CUSTOM_VAR
    value: some_value
```

### Environment variables and secrets (examples)

Define secrets under `env_vars` and reference them in `/config/mcpo/config.json` with `${VAR}`. Examples:

Brave Search:
```yaml
env_vars:
  - name: BRAVE_API_KEY
    value: "<your-brave-key>"
```
```json
{
  "mcpServers": {
    "brave_search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": { "BRAVE_API_KEY": "${BRAVE_API_KEY}" }
    }
  }
}
```

GitHub:
```yaml
env_vars:
  - name: GITHUB_TOKEN
    value: "<ghp_xxx>"
```
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}" }
    }
  }
}
```

Postgres:
```yaml
env_vars:
  - name: PG_URI
    value: "postgres://user:pass@host:5432/db"
```
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": { "DATABASE_URL": "${PG_URI}" }
    }
  }
}
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
2. Add your MCPO endpoint, for example `http://homeassistant.local:8000` or `https://mcpo.example.com`
3. If you set an API key, configure it in the authentication section
4. Your MCP tools are now available to Open WebUI!

For more information, see the [Open WebUI Integration Guide](https://docs.openwebui.com/openapi-servers/mcp#-connecting-to-open-webui).

### HTTPS, Cloudflare, and mixed content

If Open WebUI is served over HTTPS but MCPO is only HTTP, browsers block requests as mixed content. Expose MCPO over HTTPS as well:

Nginx:
```nginx
server {
  listen 443 ssl;
  server_name mcpo.example.com;
  ssl_certificate     /etc/letsencrypt/live/mcpo.example.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/mcpo.example.com/privkey.pem;

  location / {
    proxy_pass http://homeassistant.local:8000;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
```

Caddy:
```caddy
mcpo.example.com {
  reverse_proxy homeassistant.local:8000
}
```

### Using the Home Assistant MCP server

Create a long-lived access token in your Home Assistant user profile, add it under `env_vars`, and reference it in `/config/mcpo/config.json`:

Add-on options (excerpt):
```yaml
env_vars:
  - name: HA_LONG_LIVED_TOKEN
    value: "<your-token>"
```

Config (excerpt):
```json
{
  "mcpServers": {
    "home_assistant": {
      "type": "sse",
      "url": "http://localhost:8123/mcp_server/sse",
      "headers": { "Authorization": "Bearer ${HA_LONG_LIVED_TOKEN}" }
    }
  }
}
```

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

