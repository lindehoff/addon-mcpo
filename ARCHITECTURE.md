# MCPO Add-on Architecture

## Build Approach

This add-on uses a custom build approach rather than relying on MCPO's Docker images directly.

### Why Custom Build?

**Problem:** MCPO doesn't publish version-tagged Docker images to GitHub Container Registry. They only publish commit-based tags like `git-47d6f7a` or `main`, which makes it impossible to track stable releases.

**Solution:** We build our own Docker image by:
1. Starting from Home Assistant's official Python base image
2. Installing MCPO via pip from PyPI (where they do publish versioned packages)
3. Adding necessary dependencies (Node.js, npm for MCP servers)

### Build Process

```dockerfile
# Start with Home Assistant base Python image
FROM ghcr.io/home-assistant/amd64-base-python:3.12-alpine3.20

# Install system dependencies
RUN apk add --no-cache bash jq nodejs npm curl

# Install uv (provides uvx for Python MCP servers)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install MCPO from PyPI
RUN pip3 install --no-cache-dir mcpo==0.0.17

# Add startup script
COPY run.sh /
CMD [ "/run.sh" ]
```

### Dependency Tracking

- **MCPO Version**: Tracked from [PyPI](https://pypi.org/project/mcpo/)
- **Base Image**: Home Assistant's official Python base images
- **System Packages**: Alpine Linux packages (bash, jq, nodejs, npm, curl)
- **Python Tools**: uv (provides uvx command for running Python MCP servers)

### Renovate Bot Configuration

Renovate monitors:
1. `mcpo/config.yaml` - Add-on version tracking
2. `mcpo/Dockerfile` - MCPO pip package version
3. PyPI for new MCPO releases

When a new MCPO version is published to PyPI:
1. Renovate creates a PR updating both files
2. GitHub Actions builds and tests
3. Auto-merge (if configured)
4. Semantic-release creates new add-on version

### Benefits of This Approach

✅ **Stable Versions**: Track official PyPI releases  
✅ **Reproducible Builds**: Fixed versions, not floating tags  
✅ **Better Compatibility**: Use Home Assistant's tested base images  
✅ **Automatic Updates**: Renovate tracks PyPI releases  
✅ **Full Control**: Install exactly what's needed  

### Image Size

The final image includes:
- Python 3.12
- MCPO and its dependencies
- Node.js and npm (for Node.js-based MCP servers)
- uv/uvx (for Python-based MCP servers)
- Bash and jq (for configuration processing)
- Total size: ~250-350MB (depending on architecture)

### Build Caching

Docker BuildKit caching is used to speed up builds:
- System package installation is cached
- Python package installation is cached
- Only changed layers are rebuilt

### Multi-Architecture Support

Both architectures use the same build process:
- **amd64**: Intel/AMD 64-bit processors
- **aarch64**: ARM 64-bit processors (Raspberry Pi 4+)

Home Assistant automatically selects the correct architecture during installation.

## Runtime Architecture

### Startup Flow

1. **Home Assistant starts the add-on**
   ```
   Container starts → run.sh executes
   ```

2. **run.sh processes configuration**
   ```bash
   Read /data/options.json
   Parse config_mode (simple vs config_file)
   Build MCPO command arguments
   Export environment variables
   ```

3. **MCPO starts with config**
   ```bash
   exec mcpo --port 8000 --api-key xxx [--config file | -- command args]
   ```

4. **MCPO initializes MCP servers**
   ```
   Load configuration
   Spawn MCP server processes
   Create OpenAPI routes
   Start HTTP server
   ```

5. **Ready to accept requests**
   ```
   http://homeassistant.local:8000/docs
   ```

### Process Tree

```
Container (PID 1: bash)
  └── mcpo (Python process)
      ├── MCP Server 1 (stdio)
      │   └── subprocess (npx/uvx)
      ├── MCP Server 2 (stdio)
      │   └── subprocess (npx/uvx)
      └── MCP Server 3 (SSE/HTTP)
          └── HTTP client connection
```

### Configuration Flow

#### Simple Mode
```
options.json → run.sh → MCPO CLI arguments → Single MCP server
```

#### Config File Mode
```
options.json → run.sh → /config/mcpo-config.json → MCPO → Multiple MCP servers
```

### Data Persistence

- **Configuration**: Stored in `/data/options.json` (managed by Home Assistant)
- **MCP Config File**: Generated at `/config/mcpo-config.json` (persistent)
- **Add-on Config Dir**: Mounted at `/config` (persistent across restarts)

### Network Architecture

```
Client Request
  ↓
http://homeassistant.local:8000
  ↓
Home Assistant Host Network
  ↓
MCPO Container (host network mode)
  ↓
MCPO FastAPI Server
  ↓
OpenAPI Endpoint Routing
  ↓
MCP Protocol Translation
  ↓
MCP Server (stdio/SSE/HTTP)
  ↓
Response
```

### Security Layers

1. **API Key Authentication**: MCPO validates requests
2. **Home Assistant Network**: Firewall-protected
3. **Container Isolation**: Separate process space
4. **Volume Mounts**: Limited filesystem access

### Resource Usage

Typical resource consumption:
- **CPU**: Low (idle), Medium (during requests)
- **Memory**: 100-300MB (depending on MCP servers)
- **Disk**: Minimal (logs and config only)
- **Network**: Depends on MCP server usage

### Logging

Logs are captured by Home Assistant:
```bash
# View logs
ha addons logs mcpo

# Real-time logs
ha addons logs mcpo -f
```

Log levels:
- INFO: Startup, configuration, requests
- WARNING: Non-fatal issues
- ERROR: Failures, exceptions
- DEBUG: Detailed tracing (if enabled)

## Development Architecture

### Local Development

```bash
# Edit files
vim mcpo/Dockerfile

# Test locally (requires Home Assistant)
# Add local repository in Home Assistant
# Rebuild and test

# Commit changes
git commit -m "fix: update Dockerfile"

# Push triggers CI/CD
git push
```

### CI/CD Pipeline

```
Commit → GitHub
  ↓
GitHub Actions (release.yml)
  ↓
Semantic Release
  ├── Analyze commits
  ├── Determine version
  ├── Update CHANGELOG.md
  ├── Create GitHub release
  └── Tag repository
  ↓
Renovate Bot
  ├── Monitor PyPI for MCPO updates
  ├── Create PR for updates
  └── Auto-merge (if configured)
```

### Update Flow

```
New MCPO version on PyPI
  ↓
Renovate detects update
  ↓
Creates PR with version bump
  ↓
GitHub Actions validate
  ↓
Auto-merge (if enabled)
  ↓
Semantic Release creates add-on version
  ↓
Users see update in Home Assistant
  ↓
Users click "Update"
  ↓
Home Assistant rebuilds from new version
```

## Comparison with Direct Docker Image Approach

### Our Approach (Custom Build)
✅ Track stable PyPI versions  
✅ Reproducible builds  
✅ Full control over dependencies  
✅ Automatic updates via Renovate  
❌ Longer initial build time  

### Direct Docker Image (Not Used)
✅ Faster build (just pull image)  
❌ No version tags available  
❌ Can't track stable releases  
❌ Tied to MCPO's Docker publishing schedule  
❌ Less control over dependencies  

## Future Considerations

### When MCPO Adds Version Tags

If MCPO starts publishing version-tagged Docker images (e.g., `ghcr.io/open-webui/mcpo:v0.0.17`), we could:

1. Switch back to using their images directly
2. Update `build.yaml` to reference their images
3. Keep current approach for better control

**Recommendation**: Stay with current approach unless MCPO images offer significant advantages.

### Alternative Approaches

**Option 1: Multi-stage build**
```dockerfile
FROM ghcr.io/open-webui/mcpo:main AS mcpo
FROM ghcr.io/home-assistant/base
COPY --from=mcpo /usr/local/bin/mcpo /usr/local/bin/
```
- More complex
- Still relies on unpredictable tags

**Option 2: Build from source**
```dockerfile
RUN git clone --depth 1 --branch v0.0.17 https://github.com/open-webui/mcpo.git
RUN cd mcpo && pip install .
```
- More control
- Slower builds
- Requires build tools

**Current approach (pip install) is optimal.**

## Troubleshooting Build Issues

### Image Not Found
**Error**: `ghcr.io/home-assistant/amd64-base-python:3.12-alpine3.20: not found`  
**Fix**: Update base image tag in `build.yaml`

### Pip Install Fails
**Error**: `Could not find a version that satisfies the requirement mcpo==X.X.X`  
**Fix**: Verify version exists on [PyPI](https://pypi.org/project/mcpo/)

### Build Timeout
**Error**: Build exceeds time limit  
**Fix**: Optimize Dockerfile, use BuildKit caching

### Architecture Mismatch
**Error**: `exec format error`  
**Fix**: Verify correct architecture in `build.yaml`

## References

- [Home Assistant Add-on Development](https://developers.home-assistant.io/docs/add-ons)
- [MCPO on PyPI](https://pypi.org/project/mcpo/)
- [MCPO GitHub](https://github.com/open-webui/mcpo)
- [Docker BuildKit](https://docs.docker.com/build/buildkit/)

