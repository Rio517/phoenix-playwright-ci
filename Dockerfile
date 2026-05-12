FROM hexpm/elixir:1.19.5-erlang-28.4.2-debian-trixie-20260406-slim

# Keep in sync with the platform/Dockerfile in Glidedeck/proofofconcept.

# System deps for Node and Playwright + build tools needed by Elixir NIFs
# (bcrypt_elixir, etc.). git is required for safe.directory + hex resolvers.
RUN apt-get update \
    && apt-get install -y build-essential ca-certificates curl git gnupg unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
       | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
       > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

# Pre-install Playwright system dependencies (apt packages for Chromium)
# Browsers are NOT pre-installed — the project's npm ci + npx playwright install
# will install the version matching the project's package-lock.json
RUN apt-get update \
    && npx -y playwright install-deps chromium \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
