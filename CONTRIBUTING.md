# Contributing to MCPO Home Assistant Add-on

Thank you for your interest in contributing to the MCPO Home Assistant Add-on! This document provides guidelines and instructions for contributing.

## Code of Conduct

Be respectful, constructive, and professional. We're all here to make this add-on better.

## How to Contribute

### Reporting Bugs

Before creating a bug report:
1. Check if the issue already exists in [Issues](https://github.com/yourusername/addon-mcpo/issues)
2. Verify you're using the latest version
3. Test with a minimal configuration

When creating a bug report, include:
- Add-on version
- Home Assistant version
- Configuration (sanitized - remove API keys!)
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs

### Suggesting Features

We welcome feature suggestions! Please:
1. Check existing feature requests first
2. Explain the use case clearly
3. Describe how it would work
4. Consider implementation complexity

### Pull Requests

#### Getting Started

1. **Fork the repository**
   ```shell
   git clone https://github.com/yourusername/addon-mcpo.git
   cd addon-mcpo
   ```

2. **Create a feature branch**
   ```shell
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the existing code style
   - Test thoroughly
   - Update documentation

4. **Commit your changes**
   
   We use [Conventional Commits](https://www.conventionalcommits.org/):
   
   ```shell
   git commit -m "feat: add support for SSE MCP servers"
   git commit -m "fix: resolve hot reload timing issue"
   git commit -m "docs: improve configuration examples"
   ```

   Valid types:
   - `feat`: New feature
   - `fix`: Bug fix
   - `docs`: Documentation changes
   - `chore`: Maintenance tasks
   - `refactor`: Code refactoring
   - `test`: Test additions/modifications
   - `style`: Code style changes
   - `perf`: Performance improvements
   - `ci`: CI/CD changes
   - `build`: Build system changes

5. **Push to your fork**
   ```shell
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Describe what you changed and why
   - Reference any related issues
   - Ensure CI checks pass

#### Code Style

- **YAML**: 2 spaces indentation, no tabs
- **Bash**: Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- **Markdown**: Use markdownlint defaults
- **JSON**: 2 spaces indentation, trailing commas where allowed

#### Testing Your Changes

1. **Build the add-on locally**
   ```shell
   # In Home Assistant, add your local repository
   # Or use the Home Assistant Add-on Development workflow
   ```

2. **Test with minimal config**
   ```yaml
   port: 8000
   api_key: test-key
   config_mode: simple
   mcp_command: uvx
   mcp_args: mcp-server-time
   ```

3. **Test with complex config**
   ```yaml
   port: 8000
   api_key: test-key
   config_mode: config_file
   hot_reload: true
   config_file_content: |
     {
       "mcpServers": {
         "memory": { ... },
         "time": { ... },
         "filesystem": { ... }
       }
     }
   ```

4. **Verify:**
   - Add-on starts without errors
   - Endpoints are accessible
   - OpenAPI docs load correctly
   - Hot reload works (if applicable)
   - Logs are clean

#### Documentation

When making changes, update:
- `mcpo/README.md` - User-facing documentation
- `mcpo/DOCS.md` - Detailed documentation
- `SETUP.md` - Setup and configuration guide
- `CHANGELOG.md` - Add entry (via semantic-release)

## Development Workflow

### Local Testing

1. **Set up Home Assistant development environment**
   - Use Home Assistant OS in a VM
   - Or Home Assistant Container
   - Or Home Assistant Supervised

2. **Add local repository**
   ```shell
   # In Home Assistant, add repository
   # Point to your local git repository
   ```

3. **Make changes and rebuild**
   - Changes to files in `mcpo/` require add-on rebuild
   - Configuration changes apply immediately

### Pre-commit Hooks

We use pre-commit hooks to ensure code quality:

```shell
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

Hooks include:
- End-of-file fixer
- Trailing whitespace removal
- Markdown linting
- Renovate config validation
- Commit message format checking

### Continuous Integration

Our CI workflow:
1. **Pre-commit checks** - Code style and formatting
2. **Semantic Release** - Automated versioning
3. **Renovate** - Dependency updates

All checks must pass before merging.

## Project Structure

```
addon-mcpo/
├── .github/
│   ├── workflows/
│   │   └── release.yml          # Semantic release workflow
│   └── changelog-template.hbs   # Changelog template
├── mcpo/                         # Add-on files
│   ├── config.yaml              # Add-on configuration
│   ├── build.yaml               # Build configuration
│   ├── Dockerfile               # Docker image
│   ├── run.sh                   # Startup script
│   ├── README.md                # User documentation
│   ├── DOCS.md                  # Detailed documentation
│   ├── CHANGELOG.md             # Version history
│   ├── icon.png                 # Add-on icon
│   └── logo.png                 # Add-on logo
├── .gitignore                   # Git ignore rules
├── .pre-commit-config.yaml      # Pre-commit configuration
├── LICENSE                      # MIT License
├── README.md                    # Repository README
├── SETUP.md                     # Setup guide
├── CONTRIBUTING.md              # This file
├── release.config.js            # Semantic release config
├── renovate.json5               # Renovate config
└── repository.yaml              # Repository metadata
```

## Common Tasks

### Updating MCPO Version

The add-on tracks MCPO releases automatically via Renovate:

1. Renovate detects new MCPO release
2. Creates PR with version updates
3. Updates `config.yaml` and `build.yaml`
4. PR is auto-merged (if tests pass)
5. Semantic release creates new add-on version

Manual update:
```yaml
# In mcpo/config.yaml
version: "0.0.XX"  # Update version

# In mcpo/build.yaml
build_from:
  aarch64: ghcr.io/open-webui/mcpo:v0.0.XX
  amd64: ghcr.io/open-webui/mcpo:v0.0.XX
```

### Adding New Configuration Options

1. **Update `mcpo/config.yaml`**
   ```yaml
   options:
     new_option: default_value
   
   schema:
     new_option: str  # or int, bool, etc.
   ```

2. **Update `mcpo/run.sh`**
   ```shell
   # Add logic to handle new option
   NEW_OPTION=$(jq -r '.new_option // "default"' "$INPUT_FILE")
   ```

3. **Update documentation**
   - `mcpo/README.md`
   - `mcpo/DOCS.md`
   - `SETUP.md`

4. **Test thoroughly**

### Improving Documentation

Documentation improvements are always welcome!

- Fix typos
- Add examples
- Clarify confusing sections
- Add troubleshooting tips
- Improve AI-friendly prompts

Just open a PR with your changes.

## Release Process

We use [Semantic Release](https://semantic-release.gitbook.io/) for automated versioning and releases.

### How It Works

1. **Commit with conventional format**
   ```shell
   git commit -m "feat: add hot reload support"
   ```

2. **Push to main branch**
   ```shell
   git push origin main
   ```

3. **Semantic Release automatically:**
   - Analyzes commit messages
   - Determines version bump (major/minor/patch)
   - Updates CHANGELOG.md
   - Creates GitHub release
   - Pushes changes back to repo

### Version Bumps

- `feat:` → Minor version bump (0.1.0 → 0.2.0)
- `fix:` → Patch version bump (0.1.0 → 0.1.1)
- `feat!:` or `BREAKING CHANGE:` → Major version bump (0.1.0 → 1.0.0)

## Questions?

If you have questions about contributing:

1. Check existing issues and discussions
2. Review this document again
3. Open a new issue with the `question` label
4. Join the Home Assistant community

## Recognition

Contributors are recognized in:
- GitHub contributors page
- Release notes (when applicable)
- Special thanks section (for major contributions)

Thank you for contributing to make MCPO Home Assistant Add-on better! 🚀

