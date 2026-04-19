#!/usr/bin/env bash
# launch-agents.sh — Start a tmux session with a window for every AI agent
#
# Usage:
#   launch-agents.sh          # create/attach the "agents" session
#   launch-agents.sh --list   # print agent names
#
# Inside tmux:
#   Ctrl-b w       — pick a window from the list
#   Ctrl-b n / p   — next / previous window
#   Ctrl-b 0-9     — jump to window by number
#   Ctrl-b d       — detach (session stays alive in background)

set -euo pipefail

SESSION="agents"

# Ordered by terminal-bench rank, then alphabetically
AGENTS=(
  "forge:ForgeCode"
  "claude:Claude Code"
  "gemini:Gemini CLI"
  "codex:Codex CLI"
  "copilot:Copilot CLI"
  "droid:Droid"
  "goose:Goose"
  "aider:Aider"
  "crush:Crush CLI"
  "amp:Amp"
  "junie:Junie CLI"
  "opencode:OpenCode"
  "qwen:Qwen Code"
  "grok:Grok CLI"
  "t3:T3 Code"
  "kilo:Kilo CLI"
  "plandex:Plandex"
  "kiro-cli:Kiro CLI"
  "cn:Continue"
  "letta:Letta Code"
  "iflow:iFlow CLI"
  "qodercli:Qoder CLI"
  "cline-cli:Cline CLI"
  "openclaw:OpenClaw"
  "coderabbit:CodeRabbit"
)

if [[ "${1:-}" == "--list" ]]; then
  printf "%-15s %s\n" "COMMAND" "NAME"
  printf "%-15s %s\n" "-------" "----"
  for entry in "${AGENTS[@]}"; do
    cmd="${entry%%:*}"
    name="${entry#*:}"
    printf "%-15s %s\n" "$cmd" "$name"
  done
  exit 0
fi

cd /workspace

# If session already exists, just attach
if tmux has-session -t "$SESSION" 2>/dev/null; then
  exec tmux attach-session -t "$SESSION"
fi

# Create the session with the first agent
first="${AGENTS[0]}"
first_cmd="${first%%:*}"
first_name="${first#*:}"
tmux new-session -d -s "$SESSION" -n "$first_name" -x 200 -y 50

# Give the first window a shell that launches the agent
# We use send-keys so the user can restart the agent if it exits
tmux send-keys -t "$SESSION:$first_name" "$first_cmd" Enter

# Create a window for each remaining agent
for i in $(seq 1 $(( ${#AGENTS[@]} - 1 ))); do
  entry="${AGENTS[$i]}"
  cmd="${entry%%:*}"
  name="${entry#*:}"
  tmux new-window -t "$SESSION" -n "$name"
  tmux send-keys -t "$SESSION:$name" "$cmd" Enter
done

# Add a plain shell window at the end
tmux new-window -t "$SESSION" -n "shell"
tmux send-keys -t "$SESSION:shell" "echo 'Ctrl-b w to switch agents | Ctrl-b d to detach'" Enter

# Select the first window and attach
tmux select-window -t "$SESSION:0"
exec tmux attach-session -t "$SESSION"
