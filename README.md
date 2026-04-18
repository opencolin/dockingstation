# Docking Station

**One container. 25 AI coding tools. Ready in 30 seconds.**

Docking Station is a self-hosted developer environment that bundles every major AI coding agent into a single Docker container with a web dashboard and JSON API. Deploy it once and your entire team gets instant, password-protected access to 22 AI coding agents from any browser — no local installs, no conflicting dependencies, no seat management across vendors.

---

## The Problem

Your engineering team wants to evaluate AI coding tools. Today that means:

- Installing 20+ CLI tools on every developer machine, each with different runtimes and dependencies
- Managing API keys and auth across Anthropic, Google, OpenAI, JetBrains, AWS, Alibaba, and more
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

### AI Coding Agents (22 tools)

| Tool | Provider | Command | What It Does |
|------|----------|---------|-------------|
| **ForgeCode** | TailCall | `forge` | #1 on terminal-bench v2.0 (81.8%) — multi-model TUI agent |
| **Claude Code** | Anthropic | `claude` | Agentic coding — reads your codebase, writes code, runs commands |
| **Gemini CLI** | Google | `gemini` | AI assistant with Google Cloud integration |
| **Codex CLI** | OpenAI | `codex` | Autonomous coding agent from OpenAI |
| **GitHub Copilot CLI** | GitHub | `copilot` | GitHub's agentic coding agent for the terminal |
| **Droid** | Factory AI | `droid` | #6 on terminal-bench v2.0 (77.3%) |
| **Goose** | Block | `goose` | MCP-native agent with 70+ extensions (Stripe forked this) |
| **Aider** | Aider | `aider` | Most popular OSS AI pair programmer — git-native file editing |
| **Crush CLI** | Charmbracelet | `crush` | Beautiful TUI-based AI coding agent |
| **Amp** | Sourcegraph | `amp` | Multi-repo aware agentic coding (formerly Cody) |
| **Junie CLI** | JetBrains | `junie` | JetBrains' AI coding agent for the terminal |
| **OpenCode** | OpenCode | `opencode` | Multi-model AI coding assistant |
| **Qwen Code** | Alibaba | `qwen` | AI coding assistant from the Qwen team |
| **Amazon Q CLI** | AWS | `q` | AWS-integrated AI coding and cloud agent |
| **Plandex** | Plandex | `plandex` | Multi-step task planner with diff management |
| **Kiro CLI** | AWS | `kiro-cli` | Spec-driven agentic coding |
| **Continue** | Continue | `cn` | Source-controlled AI checks, enforceable in CI |
| **Letta Code** | Letta AI | `letta` | Memory-first AI coding agent |
| **iFlow CLI** | iFlow | `iflow` | Multi-model agent (free Kimi, Qwen, DeepSeek access) |
| **Qoder CLI** | Qoder | `qoder` | AI coding assistant — build in your terminal |
| **Cline CLI** | Cline | `cline-cli` | Autonomous terminal agent |
| **OpenClaw** | OpenClaw | `openclaw` | Multi-channel AI gateway |
| **Chaterm** | Chaterm | `chaterm` | AI terminal for cloud infrastructure management |
| **Apex2** | heartyguy | — | Terminal-Bench #1 (v1.0, 64.5%) — research agent |

### Development Environment (3 tools)

| Tool | Command | What It Does |
|------|---------|-------------|
| **VS Code Web** | `code-server` | Full Visual Studio Code in the browser |
| **File Browser** | `filebrowser` | Web-based file manager with upload/download |
| **Linux Desktop** | noVNC | Full GUI desktop accessible via browser with 90s Mac theme |

---

## Two Interfaces

### Web Dashboard (for humans)

The landing page at `/` is a dark-themed dashboard with:

- Card-based launcher for every tool with unique icons
- Live health status indicators (green/red dots)
- Category filters (All / Editors / AI Assistants / Utilities)
- One-click access to VS Code, File Browser, and the Linux desktop
- Staggered card animations

### JSON API (for agents and automation)

```bash
curl -u devuser:$PASSWORD http://your-server:8888/api/tools.json
```

Returns a structured manifest of every tool:

```json
{
  "tools": [
    {
      "id": "claude-code",
      "name": "Claude Code",
      "command": "claude",
      "category": "ai",
      "type": "cli",
      "docs": "https://docs.anthropic.com/en/docs/claude-code"
    }
  ]
}
```

Built for CI/CD pipelines, orchestration scripts, and AI agent workflows that need to discover and invoke tools programmatically. Includes CORS headers for cross-origin access.

---

## Architecture

```
Browser
  |
  v
nginx (port 80) ── basic auth ── password set at runtime
  |
  |── /                 Web Dashboard (static HTML/CSS/JS)
  |── /api/tools.json   Machine-readable tool manifest (25 tools)
  |── /code-server/     VS Code Web (port 8080)
  |── /files/           File Browser (port 8443)
  |── /desktop/         noVNC Linux Desktop (port 6080)
  |
  v
supervisord ── manages all processes
  |── Xvfb          (virtual display)
  |── Fluxbox       (window manager, 90s Mac theme)
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

## Terminal-Bench Rankings

Several tools in Docking Station are top performers on [terminal-bench](https://www.tbench.ai/), the Stanford x Laude benchmark for AI terminal agents:

| Rank (v2.0) | Tool | Score |
|-------------|------|-------|
| #1 | ForgeCode | 81.8% |
| #6 | Droid | 77.3% |
| — | Codex CLI | Listed |
| — | Claude Code | Listed |
| — | Goose | Listed |
| — | Gemini CLI | Listed |
| — | OpenCode | Listed |

| Rank (v1.0) | Tool | Score |
|-------------|------|-------|
| #1 | Apex2 | 64.5% |
| #2 | Chaterm | 63.7% |
| #5 | Droid | 58.8% |
| #20 | Claude Code | 43.2% |
| #21 | Codex CLI | 42.8% |

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
| **Node 22 LTS** | Required by OpenClaw; compatible with all npm-based tools. |

---

## Nightly Builds

A GitHub Actions workflow rebuilds the image every night at 02:00 UTC, pulling the latest version of every tool. Images are pushed to GitHub Container Registry with three tags:

- `latest` — always the newest build
- `2026-04-17` — date-stamped for reproducibility
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

API keys for individual AI tools should be passed as additional environment variables:

```bash
docker run -d \
  -e DEV_PASSWORD=changeme \
  -e ANTHROPIC_API_KEY=sk-ant-... \
  -e OPENAI_API_KEY=sk-... \
  -e GOOGLE_API_KEY=... \
  -e AWS_ACCESS_KEY_ID=... \
  dockingstation
```

---

## License

MIT
