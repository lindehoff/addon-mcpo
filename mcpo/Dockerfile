ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install system dependencies
RUN apk add --no-cache \
    bash \
    jq \
    nodejs \
    npm \
    curl \
    gettext \
    inotify-tools

# Install uv (provides uvx for Python-based MCP servers)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Install MCPO via pip
# renovate: datasource=pypi depName=mcpo
ARG MCPO_VERSION="0.0.17"
RUN pip3 install --no-cache-dir mcpo==${MCPO_VERSION}

# Copy startup script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

