# MCPO Home Assistant Add-on Setup Guide

This guide will help you set up, configure, and use the MCPO Home Assistant add-on.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Configuration Examples](#configuration-examples)
4. [AI-Assisted Configuration](#ai-assisted-configuration)
5. [Integration with Open WebUI](#integration-with-open-webui)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

Before installing the MCPO add-on, ensure you have:

- Home Assistant OS or Supervised installation
- Basic understanding of YAML configuration
- (Optional) Node.js or Python-based MCP servers you want to expose

## Installation

### Step 1: Add the Repository

1. Open Home Assistant
2. Navigate to **Settings** → **Add-ons** → **Add-on Store**
3. Click the **⋮** menu (top right) → **Repositories**
4. Add this repository URL:
   ```
   https://github.com/lindehoff/addon-mcpo
   ```
5. Click **Add**

### Step 2: Install the Add-on

1. Refresh the Add-on Store page
2. Find "MCPO" in the list
3. Click on it
4. Click **Install**
5. Wait for installation to complete

## Configuration Examples

### Example 1: Single Time Server (Simple Mode)

Perfect for beginners or single-server setups.

```yaml
port: 8000
api_key: my-super-secret-key
config_mode: simple
mcp_command: uvx
mcp_args: mcp-server-time --local-timezone=America/New_York
hot_reload: false
env_vars: []
```

**What this does:**
- Runs a single MCP time server
- Accessible at `http://homeassistant.local:8000`
- Protected with API key authentication
- Time zone set to America/New_York

**Access:**
- API: `http://homeassistant.local:8000`
- Docs: `http://homeassistant.local:8000/docs`

### Example 2: Memory Server (Simple Mode)

```yaml
port: 8000
api_key: secure-password-123
config_mode: simple
mcp_command: npx
mcp_args: "-y @modelcontextprotocol/server-memory"
```

**What this does:**
- Runs the MCP memory server
- Provides persistent memory for AI conversations
- Protected with API key

### Example 3: Multiple Servers (Config File Mode)

For advanced users running multiple MCP servers.

```yaml
port: 8000
api_key: my-super-secret-key
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
      "filesystem": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "/config"]
      }
    }
  }
env_vars: []
```

**What this does:**
- Runs three MCP servers simultaneously
- Each server has its own endpoint
- Hot reload enabled - configuration changes apply automatically
- Filesystem server has access to `/config` directory

**Access:**
- Memory: `http://homeassistant.local:8000/memory` (docs at `/memory/docs`)
- Time: `http://homeassistant.local:8000/time` (docs at `/time/docs`)
- Filesystem: `http://homeassistant.local:8000/filesystem` (docs at `/filesystem/docs`)

### Example 4: GitHub Integration

```yaml
port: 8000
api_key: github-mcpo-key
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

**What this does:**
- Provides GitHub API access through MCPO
- Requires GitHub Personal Access Token
- Allows AI to interact with GitHub repos

### Example 5: Brave Search Integration

```yaml
port: 8000
api_key: brave-search-key
config_mode: config_file
config_file_content: |
  {
    "mcpServers": {
      "brave_search": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-brave-search"],
        "env": {
          "BRAVE_API_KEY": "your-brave-api-key-here"
        }
      }
    }
  }
```

**What this does:**
- Enables web search through Brave Search API
- Requires Brave API key (get one at [brave.com/search/api](https://brave.com/search/api))

### Example 6: Complete Production Setup

```yaml
port: 8000
api_key: ultra-secure-production-key-change-me
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
      "filesystem": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "/config"]
      },
      "github": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"],
        "env": {
          "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token"
        }
      },
      "brave_search": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-brave-search"],
        "env": {
          "BRAVE_API_KEY": "your_brave_key"
        }
      },
      "postgres": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://user:pass@localhost/db"]
      }
    }
  }
env_vars:
  - name: LOG_LEVEL
    value: INFO
```

**What this does:**
- Production-ready setup with multiple services
- Memory, time, filesystem, GitHub, search, and database access
- Hot reload for easy updates
- Logging configured

## AI-Assisted Configuration

One of the most powerful features of this add-on is its AI-friendly configuration format. You can ask an AI assistant (like Claude, ChatGPT, or any LLM) to generate your configuration.

### How to Use AI for Configuration

1. **Ask the AI to generate a config**

Example prompts:

```
"Create a MCPO config with memory, time, and filesystem servers. 
Timezone should be Pacific/Auckland and filesystem should access /config"
```

```
"Generate a MCPO configuration for GitHub integration with a PostgreSQL 
database connection to localhost:5432, database name 'homeassistant'"
```

```
"Build me a config with Brave search, GitHub, and memory servers. 
I want hot reload enabled and port 8080"
```

2. **The AI will generate the JSON configuration**

The AI will provide valid JSON that looks like:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "time": {
      "command": "uvx",
      "args": ["mcp-server-time", "--local-timezone=Pacific/Auckland"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/config"]
    }
  }
}
```

3. **Copy and paste into your add-on configuration**

In the Home Assistant add-on configuration:

```yaml
port: 8000
api_key: your-secure-key
config_mode: config_file
hot_reload: true
config_file_content: |
  # Paste the AI-generated JSON here
  {
    "mcpServers": {
      ...
    }
  }
```

4. **Save and restart the add-on**

### Benefits of AI-Assisted Configuration

- ✅ No need to remember exact syntax
- ✅ Quickly generate complex configurations
- ✅ Get suggestions for optimal setups
- ✅ Easily modify and iterate on configs
- ✅ Learn about available MCP servers

## Integration with Open WebUI

Once your MCPO add-on is running, you can integrate it with Open WebUI.

### Step 1: Note Your MCPO Details

- URL: `http://homeassistant.local:8000` (or your custom port)
- API Key: The `api_key` you set in configuration

### Step 2: Configure Open WebUI

1. Open `Open WebUI`
2. Navigate to **Settings** (click your profile icon)
3. Go to **Tools** → **OpenAPI Tools**
4. Click **"Add OpenAPI Tool"**

### Step 3: Add MCPO Endpoint

**For Simple Mode (single server):**
- URL: `http://homeassistant.local:8000`
- API Key: Your configured API key
- Name: "MCPO" or descriptive name

**For Config File Mode (multiple servers):**

Add each server separately:
- Memory Server: `http://homeassistant.local:8000/memory`
- Time Server: `http://homeassistant.local:8000/time`
- Etc.

For each, use the same API key.

### Step 4: Test the Integration

1. Start a new conversation in Open WebUI
2. Your MCPO tools should appear in the available tools
3. Test with a simple query like "What time is it?"

### Advanced: Using MCPO Tools in Conversations

Once integrated, your AI can:
- Store and recall information (memory server)
- Get current time and dates (time server)
- Read/write files (filesystem server)
- Search the web (Brave search server)
- Interact with GitHub (GitHub server)
- Query databases (Postgres server)

Example conversation:
```
User: What time is it in New York right now?
AI: [Uses time server] It's currently 3:45 PM EST in New York.

User: Remember that I prefer meeting times in the afternoon.
AI: [Uses memory server] I've noted that you prefer afternoon meeting times.

User: Search for the latest news on AI.
AI: [Uses Brave search] Here are the latest AI news articles...
```

## Troubleshooting

### Add-on Won't Start

**Symptoms:** Add-on shows error state or crashes immediately

**Solutions:**
1. Check the add-on logs for error messages
2. Verify your YAML syntax (use a YAML validator)
3. Ensure your `config_file_content` is valid JSON
4. Check that the port isn't in use by another service
5. Verify MCP server commands are correct (npx, uvx)

### Can't Access MCPO Endpoints

**Symptoms:** Can't reach `http://homeassistant.local:8000`

**Solutions:**
1. Verify the add-on is running (check status)
2. Check you're using the correct port
3. Try accessing from the Home Assistant host itself: `http://localhost:8000`
4. Verify network connectivity
5. Check firewall settings

### API Key Authentication Failing

**Symptoms:** Getting 401 Unauthorized errors

**Solutions:**
1. Verify the API key matches exactly
2. Check for extra spaces or newlines in the API key
3. Try accessing without authentication first (temporarily remove `api_key` to test)
4. Check the HTTP Authorization header format

### Hot Reload Not Working

**Symptoms:** Config changes don't apply without restart

**Solutions:**
1. Ensure `hot_reload: true` is set
2. Verify you're in `config_file` mode (hot reload only works in this mode)
3. Check logs for reload messages
4. Ensure config file JSON is valid
5. Try manual restart

### MCP Server Errors

**Symptoms:** Logs show MCP server errors

**Solutions:**
1. Test the MCP server command manually in a terminal
2. Verify all required environment variables are set
3. Check MCP server documentation for requirements
4. Ensure dependencies (Node.js, Python) are available
5. Try a simpler MCP server first (like time server)

### Out of Memory

**Symptoms:** Add-on crashes after running for a while

**Solutions:**
1. Reduce the number of simultaneous MCP servers
2. Check MCP server logs for memory leaks
3. Restart the add-on periodically
4. Increase Home Assistant system resources

## Next Steps

Now that your MCPO add-on is configured:

1. **Explore MCP Servers**: Browse [MCP Servers Directory](https://github.com/modelcontextprotocol)
2. **Integrate with Open WebUI**: Follow the integration guide above
3. **Customize**: Use AI to generate custom configurations
4. **Monitor**: Check logs regularly for issues
5. **Update**: Enable Renovate bot for automatic updates

## Support

Need help? Check these resources:

- [Add-on Documentation](mcpo/DOCS.md)
- [MCPO Documentation](https://docs.openwebui.com/openapi-servers/mcp)
- [MCPO GitHub Issues](https://github.com/open-webui/mcpo/issues)
- [Home Assistant Community](https://community.home-assistant.io/)

## Contributing

Found a bug or have a feature request? Please [open an issue](https://github.com/lindehoff/addon-mcpo/issues)!

