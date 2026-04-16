# AGENTS.md

## OVERVIEW
This project provides a containerized development environment with a 90s Macintosh aesthetic and pre-installed AI coding tools.

## STRUCTURE
- **Dockerfile**: Configures the Ubuntu base, installs system dependencies, and sets up the AI toolchain.
- **scripts/**: Contains initialization scripts for theme generation and service management.
- **theme/**: Holds configuration files for Fluxbox and iDesk to create the retro desktop experience.

## WHERE TO LOOK
| File/Folder | Purpose |
| :--- | :--- |
| `Dockerfile` | System definition, tool installation (Node.js, code-server, AI CLIs), and user setup. |
| `scripts/` | Initialization scripts for theme generation and service management. |
| `theme/` | Retro Macintosh desktop environment (see `theme/AGENTS.md` for details). |

## AI TOOLCHAIN
The environment comes pre-configured with the following tools:
- **IDEs**: VS Code (code-server), File Browser
- **AI CLIs**: Claude Code, Cline, Codex, Gemini, OpenClaw, OpenCode, Qwen
- **Utilities**: Crush, Terminal (xterm)

## COMMANDS
- `docker build -t dev-container .`: Build the development container image.
- `docker run -p 80:80 -e DEV_PASSWORD=yourpassword dev-container`: Start the environment with password protection.
