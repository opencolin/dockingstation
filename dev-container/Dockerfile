# Dockerfile: Best Developer Container (Ubuntu 22.04)

FROM ubuntu:22.04

# ----------------------------------------------------------------------
# Environment
# ----------------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:99

# ----------------------------------------------------------------------
# System dependencies + Node.js 20 via NodeSource
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
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------
# code-server (VS Code Web)
# ----------------------------------------------------------------------
RUN curl -fsSL https://code-server.dev/install.sh | sh

# ----------------------------------------------------------------------
# opencode
# ----------------------------------------------------------------------
RUN curl -fsSL https://opencode.ai/install | bash

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
# Symlink tools to /usr/local/bin for PATH accessibility
# ----------------------------------------------------------------------
RUN ln -sf /root/.opencode/bin/opencode /usr/local/bin/opencode

# ----------------------------------------------------------------------
# Create user, workspace, and directory structure
# ----------------------------------------------------------------------
RUN mkdir -p /workspace && \
    useradd -m -s /bin/bash devuser && \
    chown -R devuser:devuser /workspace

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
# Supervisor configuration
# ----------------------------------------------------------------------
COPY ./scripts/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ----------------------------------------------------------------------
# Entrypoint script
# ----------------------------------------------------------------------
COPY ./scripts/start-dev.sh /usr/local/bin/start-dev.sh
RUN chmod +x /usr/local/bin/start-dev.sh

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
