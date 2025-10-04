# Deployment Guide

This guide explains how to publish and maintain your MCPO Home Assistant Add-on.

## Before You Deploy

### Update Repository Information

1. **Update `repository.yaml`**
   ```yaml
   name: Home Assistant MCPO Addon
   url: 'https://github.com/YOUR_USERNAME/addon-mcpo'
   maintainer: Your Name <your.email@example.com>
   ```

2. **Update URLs in documentation**
   
   Replace `https://github.com/lindehoff/addon-mcpo` with your actual repository URL in:
   - `README.md`
   - `mcpo/README.md`
   - `mcpo/DOCS.md`
   - `SETUP.md`

3. **Update LICENSE**
   - Add your name and year to `LICENSE`

### Set Up GitHub Repository

1. **Create GitHub repository**
   ```shell
   # If not already initialized
   cd /Users/jaclin/dev/private/addon-mcpo
   git init
   git add .
   git commit -m "feat: initial MCPO Home Assistant add-on"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/addon-mcpo.git
   git push -u origin main
   ```

2. **Configure GitHub Secrets**
   
   Go to repository Settings → Secrets and variables → Actions:
   
   - Create secret: `GH_TOKEN`
   - Value: Personal Access Token with `repo` scope
   - This enables semantic-release to create releases

3. **Enable GitHub Actions**
   - Go to repository Settings → Actions → General
   - Enable "Read and write permissions"
   - Allow GitHub Actions to create and approve pull requests

4. **Create Environment** (for semantic release)
   - Go to Settings → Environments
   - Create environment named: `sem_ver`
   - No protection rules needed (or add as desired)

## Publishing the Add-on

### Option 1: Publish to Your Own Repository

Users will add your repository URL directly to Home Assistant.

**Advantages:**
- Full control
- Quick updates
- Custom branding

**Users install by:**
1. Add repository: `https://github.com/YOUR_USERNAME/addon-mcpo`
2. Install "MCPO" add-on
3. Configure and start

### Option 2: Submit to Home Assistant Community Add-ons

Submit to the official [Home Assistant Community Add-ons](https://github.com/hassio-addons/repository) repository.

**Advantages:**
- Wider audience
- Community support
- Official repository listing

**Requirements:**
- High-quality code
- Comprehensive documentation
- Active maintenance commitment

**Process:**
1. Ensure add-on meets quality standards
2. Fork the community add-ons repository
3. Follow their contribution guidelines
4. Submit pull request

## Updating the Add-on

### Automatic Updates via Renovate

Renovate automatically monitors for:
- MCPO upstream releases
- Dependency updates
- Pre-commit hook updates

When a new version is available:
1. Renovate creates a PR
2. Automated checks run
3. PR auto-merges (if configured)
4. Semantic-release creates new version

### Manual Version Updates

To manually update MCPO version:

1. **Update version references**
   
   `mcpo/config.yaml`:
   ```yaml
   # renovate: datasource=github-releases depName=open-webui/mcpo
   version: "0.0.XX"  # New version
   ```
   
   `mcpo/build.yaml`:
   ```yaml
   build_from:
     aarch64: ghcr.io/open-webui/mcpo:v0.0.XX
     amd64: ghcr.io/open-webui/mcpo:v0.0.XX
   ```

2. **Commit with conventional commit message**
   ```shell
   git add mcpo/config.yaml mcpo/build.yaml
   git commit -m "feat(mcpo): update to version 0.0.XX"
   git push
   ```

3. **Semantic-release will:**
   - Detect the `feat` commit
   - Bump minor version
   - Update CHANGELOG.md
   - Create GitHub release

## Versioning Strategy

This add-on uses [Semantic Versioning](https://semver.org/):

- **Major (1.0.0)**: Breaking changes
- **Minor (0.1.0)**: New features, MCPO version updates
- **Patch (0.0.1)**: Bug fixes, documentation

### When to Bump Versions

- **MCPO update**: `feat(mcpo): update to version X.X.X` → Minor bump
- **New feature**: `feat: add support for SSE servers` → Minor bump
- **Bug fix**: `fix: resolve hot reload timing issue` → Patch bump
- **Breaking change**: `feat!: change config structure` → Major bump

## Maintaining the Add-on

### Regular Tasks

**Weekly:**
- Review and merge Renovate PRs
- Check for new issues
- Test with latest Home Assistant version

**Monthly:**
- Review documentation for accuracy
- Check MCPO upstream for major changes
- Update examples if needed

**As Needed:**
- Respond to issues
- Review and merge pull requests
- Update security policies

### Monitoring

**Watch for:**
- MCPO GitHub releases
- Home Assistant breaking changes
- Security advisories
- User feedback

**Tools:**
- GitHub notifications
- Renovate PRs
- Issue tracker
- Home Assistant forums

## Customization

### Custom Branding

1. **Replace icons**
   - `mcpo/icon.png` - Add-on icon (96x96px recommended)
   - `mcpo/logo.png` - Add-on logo (wider format)

2. **Update descriptions**
   - `mcpo/config.yaml` - Short description
   - `mcpo/README.md` - User-facing docs
   - `README.md` - Repository overview

### Adding Features

Example: Add custom logging option

1. **Update config.yaml**
   ```yaml
   options:
     log_level: INFO
   schema:
     log_level: list(DEBUG|INFO|WARNING|ERROR)
   ```

2. **Update run.sh**
   ```shell
   LOG_LEVEL=$(jq -r '.log_level // "INFO"' "$INPUT_FILE")
   export LOG_LEVEL
   ```

3. **Update documentation**
   - Add to `mcpo/README.md`
   - Add to `mcpo/DOCS.md`
   - Add example to `SETUP.md`

4. **Commit with conventional commit**
   ```shell
   git commit -m "feat: add configurable log level"
   ```

### Advanced Configuration

**Custom MCP Server Support:**

If users want to add custom MCP servers:

1. Mount volumes in `config.yaml`:
   ```yaml
   map:
     - type: addon_config
       path: /config
     - type: share
       path: /share
   ```

2. Document in `DOCS.md`:
   ```markdown
   Users can place custom MCP servers in `/share/mcpo/` 
   and reference them in config
   ```

## Testing Before Release

### Pre-release Checklist

- [ ] Test on Home Assistant OS
- [ ] Test simple mode configuration
- [ ] Test config file mode
- [ ] Verify hot reload works
- [ ] Test API authentication
- [ ] Check all documentation links
- [ ] Verify icons display correctly
- [ ] Test with Open WebUI integration
- [ ] Review logs for errors
- [ ] Test on both amd64 and aarch64 (if possible)

### Testing Environments

**Minimal test:**
```yaml
port: 8000
api_key: test
config_mode: simple
mcp_command: uvx
mcp_args: mcp-server-time
```

**Comprehensive test:**
```yaml
port: 8000
api_key: test
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
        "args": ["mcp-server-time"]
      }
    }
  }
```

## Troubleshooting Deployment

### Semantic Release Not Working

**Problem:** Commits pushed but no release created

**Solutions:**
1. Verify `GH_TOKEN` secret is set
2. Check commit message follows conventional format
3. Ensure environment `sem_ver` exists
4. Review GitHub Actions logs

### Renovate Not Creating PRs

**Problem:** No dependency update PRs

**Solutions:**
1. Ensure Renovate is enabled on repository
2. Check `renovate.json5` syntax
3. Verify GitHub App permissions
4. Check Renovate logs in dependency dashboard

### Build Failures

**Problem:** Add-on won't build in Home Assistant

**Solutions:**
1. Verify `build.yaml` references valid images
2. Check Dockerfile syntax
3. Test `run.sh` script locally
4. Review Home Assistant supervisor logs

## Support and Resources

### For Maintainers

- [Home Assistant Add-on Development](https://developers.home-assistant.io/docs/add-ons)
- [Semantic Release Documentation](https://semantic-release.gitbook.io/)
- [Renovate Documentation](https://docs.renovatebot.com/)
- [MCPO GitHub Repository](https://github.com/open-webui/mcpo)

### Community

- [Home Assistant Community Forum](https://community.home-assistant.io/)
- [Home Assistant Discord](https://discord.gg/home-assistant)
- [Open WebUI Discord](https://discord.gg/open-webui)

## License

This add-on is licensed under MIT License. See [LICENSE](LICENSE) for details.

When distributing or forking, ensure:
- LICENSE file is included
- Original authors are credited
- Changes are documented

---

**Ready to deploy?** Follow the checklist above and push your first release! 🚀

