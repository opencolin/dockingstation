# Work Plan: Best Developer Docker Container

## Goal
Create a Docker image that bundles the latest developer tools (Opencode, VS Code Web, Claude Code, Gemini CLI, Qwen CLI, File Browser, Codex CLI, Crush CLI, OpenClaw, Cline CLI) with a nostalgic 1990s Macintosh‑style web GUI, password‑protected, persistent storage, and automated nightly rebuilds.

## High‑Level Steps
1. **Choose base image & system dependencies**
   - Ubuntu 22.04 LTS
   - Install Xvfb, fluxbox (or similar lightweight WM), novnc, websockify, supervisord
   - Install required runtime dependencies for each tool (nodejs, python, etc.)

2. **Install each developer tool**
   - Opencode (via npm or official installer)
   - VS Code Web (code-server)
   - Claude Code (pip install anthropic-cli or download binary)
   - Gemini CLI (npm install -g @google/gemini-cli)
   - Qwen CLI (npm install -g qwen-cli)
   - File Browser (official binary)
   - Codex CLI (npm install -g @openai/codex)
   - Crush CLI (npm install -g crush-cli)
   - OpenClaw (npm install -g openclaw)
   - Cline CLI (npm install -g cline-cli)
   - Ensure latest versions via package managers; pin to `latest` at build time.

3. **Configure GUI desktop**
   - Use Xvfb to provide a virtual display.
   - Run a lightweight window manager (e.g., Openbox or fluxbox) with a custom 90s Macintosh theme (icons, wallpaper, cursor).
   - Use noVNC + websockify to expose the desktop via HTTP on a port (e.g., 6080).
   - Create desktop shortcuts (`.desktop` files) that launch each tool in its own window (or embed web‑based tools in iframes).

4. **Add authentication**
   - Use a simple HTTP basic auth via nginx or a lightweight auth proxy in front of the noVNC endpoint.
   - Password supplied via environment variable `DEV_CONTAINER_PASSWORD` at container start.

5. **Persistent storage**
   - Define a volume `/workspace` for user files and tool configuration.
   - Symlink each tool's config directory to `/workspace/<tool>-config`.

6. **Startup script**
   - `/usr/local/bin/start-dev.sh`:
     - Set up Xvfb display.
     - Launch window manager.
     - Start noVNC websockify.
     - Start nginx auth proxy.
     - Keep container running via supervisord or a simple tail.

7. **Dockerfile**
   - Multi‑stage if needed (builder for source‑based tools).
   - Copy startup script, config files, theme assets.
   - Expose ports: 6080 (noVNC), optionally individual ports for web‑based tools if required (code-server on 8080, etc.).
   - Set default command to `/usr/local/bin/start-dev.sh`.

8. **Testing**
   - Unit: `hadolint` for Dockerfile linting.
   - Integration: Build image, run container, use `curl` to verify nginx auth, use `novnc` client to connect, verify each tool launches (via checking process or HTTP endpoint).
   - End‑to‑end: Use Playwright to open the noVNC page, log in, click each desktop icon, verify the tool window appears.

9. **CI/CD for nightly rebuild**
   - GitHub Actions workflow:
     - Schedule: `0 2 * * *` (daily at 02:00 UTC).
     - Steps: checkout, set up Docker Buildx, login to Docker Hub (or registry), build with `docker build -t <repo>/dev-container:latest .`, push.
     - Optionally tag with date.

10. **Documentation**
    - README.md with usage instructions, environment variables, how to persist data, how to update password, how to access tools.

## Deliverables
- Dockerfile
- start-dev.sh
- nginx auth config
- noVNC configuration
- Theme assets (wallpaper, icons, cursor)
- GitHub Actions workflow (`.github/workflows/nightly-build.yml`)
- README.md
- Test scripts (optional)

## Success Criteria
- Image builds successfully on Ubuntu 22.04 base.
- Container starts and presents a password‑protected noVNC desktop resembling 1990s Mac.
- Clicking each desktop icon launches the corresponding developer tool.
- Persistent `/workspace` survives container restarts.
- Nightly automated rebuild pushes latest image to registry.
- All linting and tests pass.
