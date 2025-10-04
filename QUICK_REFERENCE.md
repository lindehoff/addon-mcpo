# MCPO Add-on Quick Reference

Quick reference guide for the MCPO Home Assistant Add-on.

## Configuration Templates

### Simple Mode (Single Server)
```yaml
port: 8000
api_key: your-secret-key
config_mode: simple
mcp_command: uvx
mcp_args: mcp-server-time --local-timezone=America/New_York
hot_reload: false
env_vars: []
```

### Config File Mode (Multiple Servers)
```yaml
port: 8000
api_key: your-secret-key
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
      }
    }
  }
env_vars: []
```

## Configuration Options

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `port` | port | Yes | 8000 | MCPO server port |
| `api_key` | password | No* | "" | API authentication key |
| `config_mode` | list | Yes | simple | `simple` or `config_file` |
| `mcp_command` | string | If simple | "" | MCP server command |
| `mcp_args` | string | No | "" | MCP server arguments |
| `config_file_content` | string | If config_file | "{}" | JSON configuration |
| `hot_reload` | bool | No | false | Enable hot reload |
| `env_vars` | list | No | [] | Environment variables |

\* Recommended for production

## Common MCP Servers

| Server | Command | Args | Purpose |
|--------|---------|------|---------|
| Time | `uvx` | `mcp-server-time` | Time/timezone utilities |
| Memory | `npx` | `-y @modelcontextprotocol/server-memory` | Persistent memory |
| Filesystem | `npx` | `-y @modelcontextprotocol/server-filesystem /path` | File access |
| GitHub | `npx` | `-y @modelcontextprotocol/server-github` | GitHub API |
| Brave Search | `npx` | `-y @modelcontextprotocol/server-brave-search` | Web search |
| PostgresSQL | `npx` | `-y @modelcontextprotocol/server-postgres connection_string` | PostgreSQL |
| SQLite | `npx` | `-y @modelcontextprotocol/server-sqlite` | SQLite |
| Slack | `npx` | `-y @modelcontextprotocol/server-slack` | Slack API |

## Access URLs

### Simple Mode
- API: `http://homeassistant.local:8000`
- Docs: `http://homeassistant.local:8000/docs`

### Config File Mode
- Server: `http://homeassistant.local:8000/[server_name]`
- Docs: `http://homeassistant.local:8000/[server_name]/docs`

Examples:
- `http://homeassistant.local:8000/memory`
- `http://homeassistant.local:8000/memory/docs`

## AI Prompt Templates

### Basic Setup
```
"Create a MCPO config with memory and time servers. 
Use America/New_York timezone."
```

### With Filesystem
```
"Generate MCPO config with memory, time, and filesystem servers. 
Filesystem should access /config directory. Timezone EST."
```

### Production Setup
```
"Build a production MCPO config with:
- Memory server
- Time server (America/New_York)
- Filesystem server (/config)
- GitHub server (needs GITHUB_PERSONAL_ACCESS_TOKEN env var)
- Brave search (needs BRAVE_API_KEY env var)"
```

## Troubleshooting Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| Won't start | Check logs, validate YAML/JSON |
| Can't access | Verify port, check add-on running |
| 401 errors | Check API key matches |
| Hot reload fails | Ensure config_file mode + hot_reload: true |
| MCP server error | Test command manually, check env vars |

## Commit Message Format

```shell
feat: add new feature
fix: bug fix
docs: documentation update
chore: maintenance
refactor: code refactoring
test: test additions
style: code style
perf: performance improvement
ci: CI/CD changes
build: build system changes
```

## File Structure

```
addon-mcpo/
├── mcpo/                    # Add-on files
│   ├── config.yaml         # Configuration
│   ├── Dockerfile          # Container
│   ├── run.sh              # Startup script
│   └── *.md                # Documentation
├── .github/workflows/      # GitHub Actions
├── README.md               # Overview
├── SETUP.md                # Setup guide
├── DEPLOYMENT.md           # Deploy guide
└── PROJECT_SUMMARY.md      # Complete summary
```

## Useful Commands

### Git
```shell
# Commit with conventional format
git commit -m "feat: add new feature"

# Push to trigger release
git push origin main
```

### Testing
```shell
# Install pre-commit hooks
pre-commit install

# Run pre-commit checks
pre-commit run --all-files
```

## Version Bumping

| Commit Type | Version Change | Example |
|-------------|----------------|---------|
| `feat:` | Minor | 0.1.0 → 0.2.0 |
| `fix:` | Patch | 0.1.0 → 0.1.1 |
| `feat!:` | Major | 0.1.0 → 1.0.0 |
| `BREAKING CHANGE:` | Major | 0.1.0 → 1.0.0 |

## Environment Variables

Add custom environment variables:

```yaml
env_vars:
  - name: VARIABLE_NAME
    value: "value"
  - name: ANOTHER_VAR
    value: "123"
```

In config_file_content:

```json
{
  "mcpServers": {
    "server_name": {
      "command": "npx",
      "args": ["..."],
      "env": {
        "API_KEY": "value"
      }
    }
  }
}
```

## Links

- [MCPO GitHub](https://github.com/open-webui/mcpo)
- [MCPO Docs](https://docs.openwebui.com/openapi-servers/mcp)
- [MCP Protocol](https://modelcontextprotocol.io/)
- [Home Assistant Add-ons](https://developers.home-assistant.io/docs/add-ons)
- [Semantic Release](https://semantic-release.gitbook.io/)

## Support

- Check `SETUP.md` for detailed setup
- Check `DEPLOYMENT.md` for deployment
- Check `CONTRIBUTING.md` for development
- Check `PROJECT_SUMMARY.md` for overview

---

**Quick Start:** Copy a template above → Paste in add-on config → Start → Done! ✅

