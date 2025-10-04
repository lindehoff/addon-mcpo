# Changelog

## [1.0.1](https://github.com/lindehoff/addon-mcpo/compare/v1.0.0...v1.0.1) (2025-10-04)


### Bug Fixes

* use Home Assistant base image and install MCPO via pip ([971f4e9](https://github.com/lindehoff/addon-mcpo/commit/971f4e9b49733a5d952fe19be0b2b2be0afce406)), closes [#1](https://github.com/lindehoff/addon-mcpo/issues/)

  MCPO doesn't publish version-tagged Docker images to GHCR.

  Changed approach to:

  - Use Home Assistant's official Python base image

  - Install MCPO from PyPI where versions are published

  - Install Node.js/npm for MCP servers that need them

  - Track MCPO versions via Renovate from PyPI

  This fixes the 'ghcr.io/open-webui/mcpo:v0.0.17: not found' error.

# 1.0.0 (2025-10-04)


### Features

* initial MCPO Home Assistant add-on ([f77b213](https://github.com/lindehoff/addon-mcpo/commit/f77b213f3f02e911c63399ea9d90a0454c6cf267))

All notable changes to this project will be documented in this file.
