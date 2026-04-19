# Dockerfile: Best Developer Container (Ubuntu 22.04)

FROM ubuntu:22.04

ARG TARGETARCH

# ----------------------------------------------------------------------
# Environment
# ----------------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:99 \
    PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/root/.bun/bin:/root/.grok/bin:/root/.local/bin:${PATH}

# ----------------------------------------------------------------------
# System dependencies + Node.js 20 via NodeSource
# Keep apt focused on runtime dependencies. Developer userland is managed by Brew.
# ----------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        gnupg \
        git \
        python3 \
        python3-pip \
        python3-venv \
        xvfb \
        fluxbox \
        x11vnc \
        novnc \
        websockify \
        nginx \
        supervisor \
        openssl \
        lsb-release \
        xterm \
        idesk \
        imagemagick \
        feh \
        xdg-utils \
        fonts-dejavu-core \
        bzip2 \
        unzip \
        file \
        procps \
        build-essential \
        python3-dev \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------
# Create user, workspace, and shell startup before installing dev tools
# ----------------------------------------------------------------------
RUN mkdir -p /workspace && \
    useradd -m -s /bin/bash devuser && \
    mkdir -p /home/linuxbrew/.linuxbrew && \
    chown -R devuser:devuser /workspace /home/linuxbrew

# ----------------------------------------------------------------------
# Homebrew (primary developer userland)
# ----------------------------------------------------------------------
RUN NONINTERACTIVE=1 su - devuser -c '/bin/bash -lc "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
RUN printf '%s\n' \
    'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' \
    > /etc/profile.d/homebrew.sh && \
    chmod 0644 /etc/profile.d/homebrew.sh && \
    printf '\n%s\n' 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/devuser/.bashrc && \
    printf '\n%s\n' 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/devuser/.profile
RUN su - devuser -c '/bin/bash -lc "brew install gh tmux"'

# ----------------------------------------------------------------------
# code-server (VS Code Web)
# ----------------------------------------------------------------------
RUN curl -fsSL https://code-server.dev/install.sh | sh

# ----------------------------------------------------------------------
# opencode
# ----------------------------------------------------------------------
RUN curl -fsSL https://opencode.ai/install | bash

# ----------------------------------------------------------------------
# T3 Code
# ----------------------------------------------------------------------
RUN npm install -g t3

# ----------------------------------------------------------------------
# Kilo CLI
# ----------------------------------------------------------------------
RUN npm install -g @kilocode/cli

# ----------------------------------------------------------------------
# Bun
# ----------------------------------------------------------------------
RUN curl -fsSL https://bun.sh/install | bash

# ----------------------------------------------------------------------
# Claude Code (npm)
# ----------------------------------------------------------------------
RUN npm install -g @anthropic-ai/claude-code

# ----------------------------------------------------------------------
# Gemini CLI
# ----------------------------------------------------------------------
RUN npm install -g @google/gemini-cli

# ----------------------------------------------------------------------
# Qwen CLI (qwen-code)
# ----------------------------------------------------------------------
RUN npm install -g @qwen-code/qwen-code

# ----------------------------------------------------------------------
# Codex CLI
# ----------------------------------------------------------------------
RUN npm install -g @openai/codex

# ----------------------------------------------------------------------
# Crush CLI (charmbracelet)
# ----------------------------------------------------------------------
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" > /etc/apt/sources.list.d/charm.list && \
    apt-get update && apt-get install -y --no-install-recommends crush && \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------
# OpenClaw
# ----------------------------------------------------------------------
RUN npm install -g openclaw@latest

# ----------------------------------------------------------------------
# Cline CLI
# ----------------------------------------------------------------------
RUN npm install -g @yaegaki/cline-cli

# ----------------------------------------------------------------------
# File Browser (binary)
# ----------------------------------------------------------------------
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# ----------------------------------------------------------------------
# GoTTY (browser terminal for CLI tools)
# ----------------------------------------------------------------------
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) GOTTY_ARCH="linux_amd64" ;; \
      arm64) GOTTY_ARCH="linux_arm64" ;; \
      *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    mkdir -p /tmp/gotty; \
    curl -fsSL "https://github.com/sorenisanerd/gotty/releases/download/v1.6.0/gotty_v1.6.0_${GOTTY_ARCH}.tar.gz" -o /tmp/gotty.tar.gz; \
    tar -xzf /tmp/gotty.tar.gz -C /tmp/gotty; \
    install -m 0755 /tmp/gotty/gotty /usr/local/bin/gotty; \
    rm -rf /tmp/gotty /tmp/gotty.tar.gz

# ==============================================================================
# NEW TOOLS — Tier 1 (tbench top performers + high adoption)
# ==============================================================================

# ----------------------------------------------------------------------
# ForgeCode (#1 on tbench v2.0 — 81.8%)
# ----------------------------------------------------------------------
RUN curl -fsSL https://forgecode.dev/cli | sh

# ----------------------------------------------------------------------
# Goose (Block/Square — 41K stars, MCP-native, Stripe forked this)
# ----------------------------------------------------------------------
RUN mkdir -p /root/.local/bin && \
    curl -fsSL https://github.com/block/goose/releases/download/stable/goose-aarch64-unknown-linux-gnu.tar.bz2 -o /tmp/goose.tar.bz2 && \
    tar -xjf /tmp/goose.tar.bz2 -C /root/.local/bin && \
    chmod +x /root/.local/bin/goose && \
    rm /tmp/goose.tar.bz2

# ----------------------------------------------------------------------
# Aider (30K+ stars — most popular OSS AI pair programmer)
# ----------------------------------------------------------------------
RUN pip3 install --no-cache-dir aider-chat

# ----------------------------------------------------------------------
# GitHub Copilot CLI (GA agentic terminal agent)
# ----------------------------------------------------------------------
RUN npm install -g @github/copilot

# ----------------------------------------------------------------------
# Droid / Factory AI (#6 on tbench v2.0 — 77.3%)
# ----------------------------------------------------------------------
RUN curl -fsSL https://app.factory.ai/cli | sh

# ==============================================================================
# NEW TOOLS — Tier 2 (minions research + proven frameworks)
# ==============================================================================

# ----------------------------------------------------------------------
# Amp (Sourcegraph, formerly Cody — multi-repo aware)
# ----------------------------------------------------------------------
RUN npm install -g @sourcegraph/amp

# ----------------------------------------------------------------------
# Amazon Q Developer CLI
# ----------------------------------------------------------------------
RUN wget -q https://desktop-release.q.us-east-1.amazonaws.com/latest/amazon-q.deb -O /tmp/amazon-q.deb && \
    dpkg -i /tmp/amazon-q.deb || apt-get install -f -y && \
    rm /tmp/amazon-q.deb

# ----------------------------------------------------------------------
# Plandex (multi-step task planner, closest to Stripe blueprints)
# ----------------------------------------------------------------------
RUN curl -sL https://plandex.ai/install.sh | bash

# ----------------------------------------------------------------------
# SWE-agent + OpenHands: skipped — require Docker-in-Docker at runtime
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Continue CLI (source-controlled AI checks, 32K+ stars)
# ----------------------------------------------------------------------
RUN npm install -g @continuedev/cli

# ----------------------------------------------------------------------
# Kiro CLI (AWS — spec-driven agentic coding)
# ----------------------------------------------------------------------
RUN curl -fsSL https://cli.kiro.dev/install | bash

# ----------------------------------------------------------------------
# Junie CLI (JetBrains' AI coding agent)
# ----------------------------------------------------------------------
RUN for attempt in 1 2 3; do \
      curl -fsSL https://junie.jetbrains.com/install.sh | bash && exit 0; \
      echo "Junie install failed on attempt ${attempt}, retrying..." >&2; \
      sleep 5; \
    done; \
    exit 1

# ----------------------------------------------------------------------
# Letta Code (memory-first coding agent)
# ----------------------------------------------------------------------
RUN npm install -g @letta-ai/letta-code

# ----------------------------------------------------------------------
# iFlow CLI (multi-model AI coding agent)
# ----------------------------------------------------------------------
RUN npm install -g @iflow-ai/iflow-cli

# ----------------------------------------------------------------------
# Qoder CLI (AI coding assistant)
# ----------------------------------------------------------------------
RUN npm install -g @qoder-ai/qodercli

# ----------------------------------------------------------------------
# Grok CLI
# ----------------------------------------------------------------------
RUN curl -fsSL https://raw.githubusercontent.com/superagent-ai/grok-cli/main/install.sh | bash

# ----------------------------------------------------------------------
# CodeRabbit CLI
# ----------------------------------------------------------------------
RUN curl -fsSL https://cli.coderabbit.ai/install.sh | sh

# ----------------------------------------------------------------------
# Chaterm (AI terminal for infrastructure — Electron, .deb)
# ----------------------------------------------------------------------
RUN wget -q "https://github.com/chaterm/Chaterm/releases/latest/download/chaterm-0.10.1-linux-amd64.deb" -O /tmp/chaterm.deb && \
    dpkg -i /tmp/chaterm.deb 2>/dev/null || apt-get install -f -y && \
    rm -f /tmp/chaterm.deb || true

# ----------------------------------------------------------------------
# Apex2 (Terminal-Bench #1 v1.0 — research agent)
# ----------------------------------------------------------------------
RUN pip3 install --no-cache-dir apex2-agent 2>/dev/null || \
    (git clone --depth 1 https://github.com/heartyguy/Apex2-Terminal-Bench-Agent.git /opt/apex2 && \
     cd /opt/apex2 && pip3 install --no-cache-dir -r requirements.txt 2>/dev/null || true)

# ==============================================================================
# Symlink tools to /usr/local/bin for PATH accessibility
# ==============================================================================
RUN install -m 0755 /root/.opencode/bin/opencode /usr/local/bin/opencode && \
    (which bun >/dev/null 2>&1 || install -m 0755 /root/.bun/bin/bun /usr/local/bin/bun 2>/dev/null || true) && \
    (which bunx >/dev/null 2>&1 || install -m 0755 /root/.bun/bin/bunx /usr/local/bin/bunx 2>/dev/null || true) && \
    (which gh >/dev/null 2>&1 || install -m 0755 /home/linuxbrew/.linuxbrew/bin/gh /usr/local/bin/gh 2>/dev/null || true) && \
    (which tmux >/dev/null 2>&1 || install -m 0755 /home/linuxbrew/.linuxbrew/bin/tmux /usr/local/bin/tmux 2>/dev/null || true) && \
    (which forge >/dev/null 2>&1 || install -m 0755 /root/.local/bin/forge /usr/local/bin/forge 2>/dev/null || true) && \
    (which goose >/dev/null 2>&1 || install -m 0755 /root/.local/bin/goose /usr/local/bin/goose 2>/dev/null || true) && \
    (which droid >/dev/null 2>&1 || install -m 0755 /root/.local/bin/droid /usr/local/bin/droid 2>/dev/null || true) && \
    (which junie >/dev/null 2>&1 || install -m 0755 /root/.local/bin/junie /usr/local/bin/junie 2>/dev/null || true) && \
    (which kiro-cli >/dev/null 2>&1 || install -m 0755 /root/.local/bin/kiro-cli /usr/local/bin/kiro-cli 2>/dev/null || true) && \
    (which grok >/dev/null 2>&1 || install -m 0755 /root/.grok/bin/grok /usr/local/bin/grok 2>/dev/null || true) && \
    (which coderabbit >/dev/null 2>&1 || install -m 0755 /root/.local/bin/coderabbit /usr/local/bin/coderabbit 2>/dev/null || true) && \
    (which cr >/dev/null 2>&1 || install -m 0755 /root/.local/bin/cr /usr/local/bin/cr 2>/dev/null || true)

# ----------------------------------------------------------------------
# 90s Macintosh theme: Fluxbox config
# ----------------------------------------------------------------------
COPY ./theme/fluxbox/ /home/devuser/.fluxbox/
RUN chmod +x /home/devuser/.fluxbox/startup

# ----------------------------------------------------------------------
# 90s Macintosh theme: Desktop icons (idesk)
# ----------------------------------------------------------------------
COPY ./theme/idesk/ideskrc /home/devuser/.ideskrc
COPY ./theme/idesk/icons/ /home/devuser/.idesktop/

# ----------------------------------------------------------------------
# Generate wallpaper and icons with ImageMagick
# ----------------------------------------------------------------------
COPY ./scripts/generate-theme.sh /tmp/generate-theme.sh
RUN chmod +x /tmp/generate-theme.sh && \
    mkdir -p /home/devuser/.idesktop/icons && \
    /tmp/generate-theme.sh && \
    rm /tmp/generate-theme.sh

# ----------------------------------------------------------------------
# Fix ownership of all devuser home files
# ----------------------------------------------------------------------
RUN chown -R devuser:devuser /home/devuser

# ----------------------------------------------------------------------
# Web dashboard
# ----------------------------------------------------------------------
COPY ./dashboard/ /opt/dashboard/

# ----------------------------------------------------------------------
# SafeMode frontend-only alternative UI
# ----------------------------------------------------------------------
COPY ./safemode/ /opt/safemode/

# ----------------------------------------------------------------------
# Supervisor configuration
# ----------------------------------------------------------------------
COPY ./scripts/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ----------------------------------------------------------------------
# Entrypoint script
# ----------------------------------------------------------------------
COPY ./scripts/start-dev.sh /usr/local/bin/start-dev.sh
RUN chmod +x /usr/local/bin/start-dev.sh

# ----------------------------------------------------------------------
# CLI launcher for GoTTY
# ----------------------------------------------------------------------
COPY ./scripts/launch-cli.sh /usr/local/bin/launch-cli.sh
RUN chmod +x /usr/local/bin/launch-cli.sh

# ----------------------------------------------------------------------
# Default working directory (supervisor runs app processes as devuser)
# ----------------------------------------------------------------------
WORKDIR /workspace

# ----------------------------------------------------------------------
# Expose ports
#   6080 - noVNC (desktop)
#   8080 - code-server
#   5900 - VNC
#   8443 - file browser
# ----------------------------------------------------------------------
EXPOSE 6080 8080 5900 8443

# ----------------------------------------------------------------------
# Entrypoint
# ----------------------------------------------------------------------
CMD ["/usr/local/bin/start-dev.sh"]
