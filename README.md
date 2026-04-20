# SafeMode

**One container. 30 tools. Every AI coding agent. Ready in 30 seconds.**

SafeMode is a self-hosted developer environment that bundles every major AI coding agent into a single Docker container. It ships with a web dashboard, a browser-based terminal, a JSON API for automation, and a full Linux desktop — all behind optional password-protected access.

Deploy it once and your entire team gets instant access to 25 AI coding agents and 5 development tools from any browser.

```bash
docker run -d -p 8888:80 -e DEV_PASSWORD=securepwd \
  -v workspace:/workspace safemode
```

Open `http://your-server:8888`. Log in. Start coding.

---

## What's Inside

### AI Coding Agents (25)

| Tool | Provider | Command | Description |
|------|----------|---------|-------------|
| **ForgeCode** | TailCall | `forge` | #1 on terminal-bench v2.0 (81.8%) — multi-model TUI agent |
| **Claude Code** | Anthropic | `claude` | Agentic coding — reads your codebase, writes code, runs commands |
| **Gemini CLI** | Google | `gemini` | AI assistant with Google Cloud integration |
| **Codex CLI** | OpenAI | `codex` | Autonomous coding agent |
| **GitHub Copilot CLI** | GitHub | `copilot` | GitHub's agentic terminal agent |
| **Droid** | Factory AI | `droid` | #6 on terminal-bench v2.0 (77.3%) |
| **Goose** | Block | `goose` | MCP-native agent with 70+ extensions (Stripe forked this) |
| **Aider** | Aider | `aider` | Most popular OSS pair programmer — git-native file editing |
| **Crush CLI** | Charmbracelet | `crush` | Beautiful TUI-based AI coding agent |
| **Amp** | Sourcegraph | `amp` | Multi-repo agentic coding (formerly Cody) |
| **Junie CLI** | JetBrains | `junie` | JetBrains' AI coding agent |
| **OpenCode** | OpenCode | `opencode` | Multi-model AI coding assistant (142K stars) |
| **Qwen Code** | Alibaba | `qwen` | AI coding assistant from the Qwen team |
| **Amazon Q CLI** | AWS | `q` | AWS-integrated AI coding and cloud agent |
| **Grok CLI** | Community | `grok` | Open-source terminal assistant powered by Grok |
| **T3 Code** | Ping.gg | `t3` | Theo's coding-agent workspace launcher |
| **Kilo CLI** | Kilo | `kilo` | Keyboard-first coding agent with multi-provider support |
| **Plandex** | Plandex | `plandex` | Multi-step task planner with diff management |
| **Kiro CLI** | AWS | `kiro-cli` | Spec-driven agentic coding |
| **Continue** | Continue | `cn` | Source-controlled AI checks, enforceable in CI (32K+ stars) |
| **Letta Code** | Letta AI | `letta` | Memory-first AI coding agent |
| **iFlow CLI** | iFlow | `iflow` | Multi-model agent (free Kimi, Qwen, DeepSeek access) |
| **Qoder CLI** | Qoder | `qodercli` | AI coding assistant for the terminal |
| **Cline CLI** | Cline | `cline-cli` | Autonomous terminal agent |
| **CodeRabbit CLI** | CodeRabbit | `coderabbit` | AI code reviews for staged and unstaged changes |

### Development Environment (5)

| Tool | URL | Description |
|------|-----|-------------|
| **VS Code Web** | `/code-server/` | Full Visual Studio Code in the browser |
| **File Browser** | `/files/` | Web-based file manager for `/workspace` |
| **Browser Terminal** | `/terminal/` | GoTTY-powered shell — launch any CLI tool in a browser tab |
| **Linux Desktop** | `/desktop/` | Full GUI desktop via noVNC with 90s Mac theme |
| **Retro Frontend** | `/safemode/` | Alternate retro web frontend |

### Base Layer

| Tool | Description |
|------|-------------|
| **Homebrew** | Package manager for additional tools (`brew install ...`) |
| **Bun** | Fast JavaScript runtime and package manager |
| **gh** | GitHub CLI |
| **tmux** | Terminal multiplexer |

---

## Three Interfaces

### Web Dashboard

The landing page at `/` is a dark-themed dashboard with card-based tool launchers, live health indicators, and category filters. Click any CLI tool card to open it directly in the browser terminal.

### Browser Terminal

Every CLI tool can be launched in a browser tab via GoTTY at `/terminal/`. The dashboard's "Launch" buttons open tools directly — no SSH or VNC required.

### JSON API

```bash
curl -u devuser:$PASSWORD http://your-server:8888/api/tools.json
```

Returns a structured manifest of all 30 tools with id, command, category, port, URL, and docs link. Built for agent orchestration and CI/CD pipelines.

---

## Architecture

```
Browser
  |
  v
nginx (port 80) ── optional basic auth
  |
  |── /                 Web Dashboard
  |── /api/tools.json   Machine-readable tool manifest (30 tools)
  |── /code-server/     VS Code Web (port 8080)
  |── /files/           File Browser (port 8443)
  |── /terminal/        GoTTY browser terminal (port 7681)
  |── /desktop/         noVNC Linux Desktop (port 6080)
  |── /safemode/        Alternate retro frontend
  |
  v
supervisord ── manages all processes
```

**Base:** Ubuntu 22.04 LTS | Node.js 22 | Python 3.10 | Homebrew | Bun

---

## Quick Start

### Run Locally

```bash
docker run -d \
  --name safemode \
  -p 8888:80 \
  -p 6080:6080 \
  -p 8080:8080 \
  -v safemode-workspace:/workspace \
  -e DEV_PASSWORD=changeme \
  safemode
```

### Without Auth

```bash
docker run -d -p 8888:80 -e NO_AUTH=1 \
  -v safemode-workspace:/workspace safemode
```

### Build from Source

```bash
git clone https://github.com/colygon/dockingstation.git
cd dockingstation/dev-container
docker build -t safemode .
```

### Deploy to a Cloud VM

```bash
docker run -d --restart unless-stopped \
  -p 443:80 \
  -v safemode-workspace:/workspace \
  -e DEV_PASSWORD=your-secure-password \
  safemode
```

---

## Terminal-Bench Rankings

Several tools in SafeMode are top performers on [terminal-bench](https://www.tbench.ai):

| Rank (v2.0) | Tool | Score |
|-------------|------|-------|
| **#1** | ForgeCode | 81.8% |
| **#6** | Droid | 77.3% |
| — | Codex CLI, Claude Code, Goose, Gemini CLI, OpenCode | Listed |

| Rank (v1.0) | Tool | Score |
|-------------|------|-------|
| **#5** | Droid | 58.8% |
| **#20** | Claude Code | 43.2% |
| **#21** | Codex CLI | 42.8% |

---

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DEV_PASSWORD` | Yes* | Password for HTTP basic auth (username: `devuser`) |
| `NO_AUTH` | No | Set to `1` to disable authentication |

*Not required when `NO_AUTH=1`.

Pass API keys for individual tools as additional env vars:

```bash
-e ANTHROPIC_API_KEY=sk-ant-... \
-e OPENAI_API_KEY=sk-... \
-e GOOGLE_API_KEY=... \
-e AWS_ACCESS_KEY_ID=...
```

---

## Ports

| Port | Service |
|------|---------|
| 80 | nginx (dashboard + auth proxy) |
| 6080 | noVNC desktop |
| 7681 | GoTTY browser terminal |
| 8080 | VS Code Web |
| 8443 | File Browser |
| 5900 | VNC |

---

## Nightly Builds

GitHub Actions rebuilds the image daily at 02:00 UTC with the latest tool versions. Images are pushed to GHCR with `latest`, date, and SHA tags. Targets `linux/amd64` and `linux/arm64`.

---

## Docs

Full documentation lives in [docs/](./docs/).

## License

MIT
