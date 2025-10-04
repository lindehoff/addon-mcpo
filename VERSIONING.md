# Versioning Strategy

## Two Independent Versions

This add-on manages two separate versions:

### 1. Add-on Version (in `config.yaml`)
**Managed by:** Semantic Release  
**Updated when:** Any commit to main branch  
**Format:** Semantic versioning (e.g., 1.0.0, 1.1.0, 1.0.1)

This is the version users see in Home Assistant. It increments based on your commits:
- `fix:` commits → Patch version (1.0.0 → 1.0.1)
- `feat:` commits → Minor version (1.0.0 → 1.1.0)
- `feat!:` or `BREAKING CHANGE:` → Major version (1.0.0 → 2.0.0)

### 2. MCPO Version (in `Dockerfile`)
**Managed by:** Renovate Bot  
**Updated when:** New MCPO release on PyPI  
**Format:** Matches MCPO version (e.g., 0.0.17)

This is the version of the MCPO package installed in the container.

## How It Works

### Scenario 1: You Fix a Bug in the Add-on
```bash
git commit -m "fix: resolve configuration parsing issue"
git push
```

**Result:**
- Add-on version: 1.0.0 → 1.0.1 (semantic-release)
- MCPO version: 0.0.17 (unchanged)
- Users see update in Home Assistant

### Scenario 2: MCPO Releases New Version
```
Renovate detects MCPO 0.0.18 on PyPI
→ Creates PR updating Dockerfile
→ Commit message: "feat(deps): Updates MCPO to version 0.0.18"
→ Auto-merges (if configured)
```

**Result:**
- Add-on version: 1.0.1 → 1.1.0 (semantic-release, due to `feat` commit)
- MCPO version: 0.0.17 → 0.0.18 (renovate)
- Users see update in Home Assistant

### Scenario 3: You Add New Feature
```bash
git commit -m "feat: add support for custom environment variables"
git push
```

**Result:**
- Add-on version: 1.0.1 → 1.1.0 (semantic-release)
- MCPO version: 0.0.18 (unchanged)
- Users see update in Home Assistant

## Automated Version Updates

### Semantic Release Process

When you push commits to main:

1. **Analyze commits** - Determines version bump based on commit messages
2. **Update CHANGELOG.md** - Generates changelog from commits
3. **Update config.yaml** - Sets new version in add-on config
4. **Commit changes** - Commits CHANGELOG and config.yaml
5. **Create GitHub release** - Tags and creates release
6. **Push changes** - Pushes version bump commit

### Files Updated Automatically

- ✅ `mcpo/CHANGELOG.md` - Release notes
- ✅ `mcpo/config.yaml` - Version field
- ✅ Git tags - v1.0.0, v1.1.0, etc.
- ✅ GitHub Releases - With notes

### Files NOT Updated Automatically

- ❌ `mcpo/Dockerfile` - Only updated by Renovate when MCPO releases

## Version Numbering Guidelines

### Major Version (X.0.0)
Breaking changes that require user action:
- Configuration format changes
- Removed features
- Changed default behavior

**Example:**
```bash
git commit -m "feat!: change config structure to support multiple servers

BREAKING CHANGE: Configuration format has changed. Users must update their config."
```

### Minor Version (1.X.0)
New features, backward compatible:
- New configuration options
- New features
- MCPO version updates

**Example:**
```bash
git commit -m "feat: add hot reload support"
```

### Patch Version (1.0.X)
Bug fixes, backward compatible:
- Bug fixes
- Documentation updates
- Minor improvements

**Example:**
```bash
git commit -m "fix: correct API key validation"
```

## Checking Versions

### Current Add-on Version
```bash
cat mcpo/config.yaml | grep version
```

### Current MCPO Version
```bash
cat mcpo/Dockerfile | grep MCPO_VERSION
```

### Latest Release
```bash
git tag -l | sort -V | tail -1
```

## Troubleshooting

### Home Assistant Not Showing Update

**Problem:** Pushed commits but Home Assistant doesn't show update

**Solutions:**
1. Check GitHub Actions - ensure release workflow succeeded
2. Check if version in `config.yaml` changed
3. Force refresh in Home Assistant: Settings → System → Reload Core
4. Check logs: Settings → System → Logs

### Version Mismatch

**Problem:** Add-on version doesn't match latest tag

**Solution:**
```bash
# Reset version to latest tag
git describe --tags --abbrev=0
# Update config.yaml manually if needed
# Commit with fix: prefix
git commit -m "fix: correct version in config.yaml"
```

### Semantic Release Failed

**Problem:** GitHub Actions shows semantic release error

**Common causes:**
1. Invalid commit message format
2. Missing GH_TOKEN secret
3. Protected branch rules preventing push

**Check:**
- Commit messages follow conventional format
- GH_TOKEN has correct permissions
- Branch protection allows semantic-release bot

## Best Practices

### 1. Use Conventional Commits
Always use proper commit message format:
```bash
✅ git commit -m "feat: add new feature"
✅ git commit -m "fix: resolve bug"
❌ git commit -m "updated stuff"
```

### 2. Let Automation Handle Versions
Never manually edit version in `config.yaml`. Let semantic-release manage it.

### 3. Check Actions Before Announcing
Wait for GitHub Actions to complete before telling users about updates.

### 4. Test Before Merging
Test changes locally before pushing to main, since every push triggers a release.

## Future Considerations

### Pre-releases
To add pre-release support (e.g., 1.0.0-beta.1):

Add to `release.config.js`:
```javascript
"branches": [
    "main",
    {
        "name": "beta",
        "prerelease": true
    }
]
```

### Manual Version Bump
If you need to manually bump version:
```bash
# Not recommended, but possible
git commit --allow-empty -m "feat: bump version for release"
git push
```

## Summary

✅ **Add-on version** - Auto-managed by semantic-release, updates on every commit  
✅ **MCPO version** - Auto-managed by Renovate, updates when MCPO releases  
✅ **Home Assistant sees updates** - When add-on version changes  
✅ **Fully automated** - No manual version management needed  

**Just focus on writing good commit messages and everything else is automatic!** 🎉

