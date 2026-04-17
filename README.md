# Docking Station

**One container. Every AI coding tool. Ready in 30 seconds.**

Docking Station is a self-hosted developer environment that bundles 8 leading AI coding agents, a full browser-based IDE, and a file manager into a single Docker container. Deploy it once and your entire team gets instant, password-protected access to every major AI coding tool from any browser — no local installs, no conflicting dependencies, no seat management across vendors.

---

## The Problem

Your engineering team wants to evaluate AI coding tools. Today that means:

- Installing 8+ CLI tools on every developer machine, each with different runtimes and dependencies
- Managing API keys and auth across Anthropic, Google, OpenAI, Alibaba, and more
- No way to standardize or compare tools — every developer has a different setup
- Security and compliance headaches with API keys scattered across personal laptops
- New hires wait hours to set up their environment before writing their first line of code

## The Solution

```bash
docker run -d -p 8888:80 -e DEV_PASSWORD=securepwd \
  -v workspace:/workspace dockingstation
```

Open `http://your-server:8888`. Log in. Start coding with any AI tool.

That's it.

---

## What's Inside

### AI Coding Agents

| Tool | Provider | What It Does |
|------|----------|-------------|
| **Claude Code** | Anthropic | Agentic coding — reads your codebase, writes code, runs commands |
| **Gemini CLI** | Google | AI assistant with deep Workspace and Google Cloud integration |
| **Codex CLI** | OpenAI | Autonomous coding agent from OpenAI |
| **Crush CLI** | Charmbracelet | Beautiful TUI-based AI coding agent |
| **OpenCode** | OpenCode | Multi-model AI coding assistant |
| **Qwen Code** | Alibaba | AI coding assistant from the Qwen team |
| **Cline CLI** | Cline | Autonomous terminal agent (CLI version of the VS Code extension) |
| **OpenClaw** | OpenClaw | Multi-channel AI gateway for orchestrating multiple models |

### Development Environment

| Tool | What It Does |
|------|-------------|
| **VS Code Web** | Full Visual Studio Code in the browser via code-server |
| **File Browser** | Web-based file manager with upload, download, and editing |
| **Linux Desktop** | Full GUI desktop accessible via browser (noVNC) |

---

## Two Interfaces

### Web Dashboard (for humans)

The landing page is a modern, dark-themed dashboard with:

- Card-based launcher for every tool
- Live health status indicators
- Category filters (Editors / AI Assistants / Utilities)
- One-click access to VS Code, File Browser, and the Linux desktop

### JSON API (for agents and automation)

```bash
curl -u devuser:$PASSWORD http://your-server:8888/api/tools.json
```

Returns a structured manifest of every tool with its name, command, port, category, URL, and documentation link. Built for CI/CD pipelines, orchestration scripts, and AI agent workflows that need to discover and invoke tools programmatically.

---

## Architecture

```
Browser
  |
  v
nginx (port 80) ── basic auth ── password set at runtime
  |
  |── /                 Web Dashboard (static HTML/CSS/JS)
  |── /api/tools.json   Machine-readable tool manifest
  |── /code-server/     VS Code Web (port 8080)
  |── /files/           File Browser (port 8443)
  |── /desktop/         noVNC Linux Desktop (port 6080)
  |
  v
supervisord ── manages all processes
  |── Xvfb          (virtual display)
  |── Fluxbox       (window manager)
  |── x11vnc        (VNC server)
  |── websockify    (VNC-to-WebSocket bridge)
  |── code-server   (VS Code Web)
  |── filebrowser   (File Browser)
  |── nginx         (reverse proxy + auth)
  |── idesk         (desktop icons)
```

**Base image:** Ubuntu 22.04 LTS  
**Node.js:** 22 LTS (via NodeSource)  
**Process manager:** supervisord  
**Auth:** HTTP basic auth via nginx (username: `devuser`)

---

## Quick Start

### Run Locally

```bash
# Pull and run
docker run -d \
  --name dockingstation \
  -p 8888:80 \
  -p 6080:6080 \
  -p 8080:8080 \
  -v dockingstation-workspace:/workspace \
  -e DEV_PASSWORD=changeme \
  dockingstation

# Open the dashboard
open http://localhost:8888
# Login: devuser / changeme
```

### Build from Source

```bash
git clone https://github.com/colygon/dockingstation.git
cd dockingstation/dev-container
docker build -t dockingstation .
```

### Deploy to a Cloud VM

```bash
# On any VM with Docker installed:
docker run -d --restart unless-stopped \
  -p 443:80 \
  -v dockingstation-workspace:/workspace \
  -e DEV_PASSWORD=your-secure-password \
  dockingstation
```

---

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Single container** | Zero orchestration complexity. One `docker run` and you're live. |
| **All tools at latest versions** | Nightly builds pull the newest version of every tool automatically. |
| **Password auth at the nginx layer** | Tools run without their own auth — one login protects everything. |
| **Persistent `/workspace` volume** | Code, configs, and shell history survive container restarts and upgrades. |
| **supervisord for process management** | Battle-tested, zero-dependency process supervisor. Each service is independently monitored and auto-restarted. |
| **Static dashboard + JSON API** | No runtime framework. The dashboard is 3 files (HTML, CSS, JS). The API is a static JSON file. Nothing to crash. |

---

## Nightly Builds

A GitHub Actions workflow rebuilds the image every night at 02:00 UTC, pulling the latest version of every tool. Images are pushed to GitHub Container Registry with three tags:

- `latest` — always the newest build
- `2026-04-16` — date-stamped for reproducibility
- `abc1234` — git SHA for traceability

Builds target both `linux/amd64` and `linux/arm64`.

---

## Ports

| Port | Service | Access |
|------|---------|--------|
| 80 | nginx (auth proxy + dashboard) | Primary entry point |
| 6080 | noVNC (Linux desktop) | Direct, no auth |
| 8080 | code-server (VS Code Web) | Direct, no auth |
| 8443 | File Browser | Direct, no auth |
| 5900 | VNC | Direct, no auth |

In production, expose only port 80 behind your firewall. All other ports are proxied through nginx with authentication.

---

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DEV_PASSWORD` | Yes | Password for HTTP basic auth (username is always `devuser`) |

API keys for individual AI tools (e.g., `ANTHROPIC_API_KEY`, `GOOGLE_API_KEY`) should be passed as additional environment variables when running the container.

---

## License

MIT
