# Changelog

# [1.3.0](https://github.com/lindehoff/addon-mcpo/compare/v1.2.0...v1.3.0) (2025-10-23)


### Features

* **deps:** update dependency mcpo to v0.0.19 ([7ec661c](https://github.com/lindehoff/addon-mcpo/commit/7ec661ca4f14ad6cc257370cc155dd0ff5a31e9d))

  Updates MCPO to version 0.0.19

# [1.2.0](https://github.com/lindehoff/addon-mcpo/compare/v1.1.3...v1.2.0) (2025-10-12)


### Features

* **mcpo:** move config to /config/mcpo, add env var substitution, defaults ([c635458](https://github.com/lindehoff/addon-mcpo/commit/c63545837d9940d89c38ef2181f93c9c7647bacc))

## [1.1.3](https://github.com/lindehoff/addon-mcpo/compare/v1.1.2...v1.1.3) (2025-10-04)


### Bug Fixes

* bind MCPO to all interfaces for container access ([64c0cc0](https://github.com/lindehoff/addon-mcpo/commit/64c0cc08fe7edee245cb1ee3f62af5ba58f210d2))

## [1.1.2](https://github.com/lindehoff/addon-mcpo/compare/v1.1.1...v1.1.2) (2025-10-04)


### Bug Fixes

* use addon_config for user-accessible config files ([71fe3c3](https://github.com/lindehoff/addon-mcpo/commit/71fe3c33b130e341346da67063beac55db480dd8))

  Changes:

  - Replaced config_file_content with config_file (filename only)

  - Users now place config files in /addon_configs/{REPO}_mcpo/

  - Config files are user-accessible and editable

  - Cleaner separation: simple mode uses mcp_command/args, config_file mode uses external file

  - Added helpful error messages when config file is missing or invalid

  This follows Home Assistant best practices per:

  https://developers.home-assistant.io/docs/add-ons/configuration#add-on-advanced-options

## [1.1.1](https://github.com/lindehoff/addon-mcpo/compare/v1.1.0...v1.1.1) (2025-10-04)


### Bug Fixes

* use /data directory for config file storage per Home Assistant best practices ([4f29087](https://github.com/lindehoff/addon-mcpo/commit/4f29087acd4256cdb2adae703c3648e10ec561f1))

# [1.1.0](https://github.com/lindehoff/addon-mcpo/compare/v1.0.2...v1.1.0) (2025-10-04)


### Bug Fixes

* install semantic-release extra plugins correctly ([68dd5a0](https://github.com/lindehoff/addon-mcpo/commit/68dd5a03bc84ba5f0209c7af25462e9eacae91c4))



### Features

* decouple add-on version from MCPO version ([41ee7b3](https://github.com/lindehoff/addon-mcpo/commit/41ee7b39749c1b1e55f4c65272dbc0f87170a8d4))

  Changes:

  - Add-on version now managed independently by semantic-release

  - MCPO version only tracked in Dockerfile by Renovate

  - semantic-release auto-updates config.yaml version field

  - Every commit to main triggers new add-on version

  - Home Assistant will now detect updates properly

  Add-on starts at v1.0.0, will increment based on commits:

  - fix: commits → patch (1.0.0 → 1.0.1)

  - feat: commits → minor (1.0.0 → 1.1.0)

  - BREAKING CHANGE → major (1.0.0 → 2.0.0)

  Also added comprehensive documentation:

  - VERSIONING.md - explains the versioning strategy

  - ICON_GUIDE.md - guide for creating MCPO-specific icons

  Note: Icons still use Open WebUI placeholders - should be replaced

  with MCPO-specific branding (see ICON_GUIDE.md)

## [1.0.2](https://github.com/lindehoff/addon-mcpo/compare/v1.0.1...v1.0.2) (2025-10-04)


### Bug Fixes

* install uv to provide uvx command for Python MCP servers ([ce01374](https://github.com/lindehoff/addon-mcpo/commit/ce013742368aac6397ea8f030387483f4381a0a1))

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
