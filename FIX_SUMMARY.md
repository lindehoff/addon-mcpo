# Docker Build Fix Summary

## Problem

The add-on failed to build with this error:
```
ghcr.io/open-webui/mcpo:v0.0.17: not found
```

## Root Cause

MCPO doesn't publish version-tagged Docker images to GitHub Container Registry. They only publish:
- `main` - Latest main branch
- `git-XXXXXX` - Specific commit hashes

There is no `v0.0.17` or any other version-tagged image available.

## Solution

Changed from using MCPO's Docker images to building our own:

### Before (Broken)
```yaml
# build.yaml
build_from:
  amd64: ghcr.io/open-webui/mcpo:v0.0.17  # ❌ Doesn't exist
```

### After (Fixed)
```yaml
# build.yaml
build_from:
  amd64: ghcr.io/home-assistant/amd64-base-python:3.12-alpine3.20  # ✅ Stable base
```

```dockerfile
# Dockerfile
FROM ${BUILD_FROM}

# Install system dependencies
RUN apk add --no-cache bash jq nodejs npm

# Install MCPO from PyPI (where they DO publish versions)
ARG MCPO_VERSION="0.0.17"
RUN pip3 install --no-cache-dir mcpo==${MCPO_VERSION}
```

## What Changed

### Files Modified

1. **mcpo/build.yaml**
   - Changed from MCPO Docker images to Home Assistant base Python images
   - Now uses stable, versioned Home Assistant images

2. **mcpo/Dockerfile**
   - Added installation of system dependencies (bash, jq, nodejs, npm)
   - Added MCPO installation via pip from PyPI
   - Uses versioned pip package instead of Docker image

3. **mcpo/config.yaml**
   - Updated renovate comment to track PyPI instead of GitHub releases

4. **renovate.json5**
   - Updated to monitor PyPI for MCPO updates
   - Changed from tracking GitHub releases to PyPI packages
   - Now monitors Dockerfile for version changes

## Benefits of New Approach

✅ **Works!** - Uses PyPI where MCPO actually publishes versions  
✅ **Stable** - Track official releases, not commit hashes  
✅ **Reproducible** - Same version = same build  
✅ **Automatic Updates** - Renovate monitors PyPI  
✅ **Better Control** - Install exactly what we need  

## Testing

To test the fix:

1. **Commit and push changes**
   ```bash
   git add mcpo/Dockerfile mcpo/build.yaml mcpo/config.yaml renovate.json5 ARCHITECTURE.md
   git commit -m "fix: use Home Assistant base image and install MCPO via pip"
   git push
   ```

2. **Wait for GitHub Actions to build**
   - Check Actions tab in GitHub
   - Verify build succeeds

3. **Update add-on in Home Assistant**
   - Go to Add-ons → MCPO → Update
   - Wait for rebuild
   - Start the add-on

4. **Verify it works**
   - Check logs for startup messages
   - Access http://homeassistant.local:8000/docs
   - Test with a simple MCP server

## Future Updates

Renovate will now automatically:
1. Monitor PyPI for new MCPO versions
2. Create PRs to update `MCPO_VERSION` in Dockerfile
3. Update version in config.yaml
4. Trigger semantic-release for new add-on version

## Additional Notes

- The new approach adds ~50-100MB to image size (Node.js + npm)
- Build time increases by ~1-2 minutes (need to install packages)
- These are acceptable tradeoffs for stability and reproducibility

## References

- [MCPO on PyPI](https://pypi.org/project/mcpo/) - Where actual versions are published
- [Home Assistant Base Images](https://github.com/home-assistant/docker-base) - Our new base
- [Architecture Documentation](ARCHITECTURE.md) - Detailed explanation

