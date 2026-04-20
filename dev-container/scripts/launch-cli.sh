#!/usr/bin/env bash
set -euo pipefail

TOOL="${1:-shell}"

cd /workspace

note() {
  printf '\n%s\n\n' "$1"
}

forge_needs_setup() {
  local provider model
  provider="$(forge config get provider 2>/dev/null || true)"
  model="$(forge config get model 2>/dev/null || true)"
  [[ "$provider" == *"Not set"* || "$model" == *"Not set"* ]]
}

coderabbit_needs_login() {
  coderabbit auth status 2>&1 | grep -q "Not logged in"
}

case "$TOOL" in
  shell) exec /bin/bash -il ;;
  tmux) exec tmux new-session -A -s workspace ;;
  cue) exec cue ;;
  agents) exec /usr/local/bin/launch-agents.sh ;;
  opencode) exec opencode ;;
  grok) exec grok ;;
  t3)
    printf 'T3 Code runs as a web app in SafeMode.\n'
    printf 'Open /t3-launch to get a fresh pairing link, or visit port 3773 directly once paired.\n'
    exec /bin/bash -il
    ;;
  kilo) exec kilo ;;
  claude) exec claude ;;
  gemini) exec gemini ;;
  qwen) exec qwen ;;
  codex) exec codex ;;
  crush) exec crush ;;
  openclaw)
    if [[ ! -f "${HOME}/.openclaw/openclaw.json" ]]; then
      note 'OpenClaw needs first-run onboarding. Starting `openclaw onboard` now.'
      exec openclaw onboard
    fi
    if ! openclaw health >/dev/null 2>&1; then
      note 'OpenClaw is configured but the local gateway is not healthy yet. Reopening onboarding so you can finish the local setup.'
      exec openclaw onboard
    fi
    exec openclaw agent --local
    ;;
  cline-cli)
    if [[ ! -f "${HOME}/.cline_cli/cline_cli_settings.json" ]]; then
      note 'Cline CLI needs first-run setup. Starting `cline-cli init` now.'
      exec cline-cli init
    fi
    exec cline-cli task
    ;;
  forge)
    if forge_needs_setup; then
      note 'Forge needs a provider and model. Inside Forge, run `:login` and then `:model`.'
    fi
    exec forge
    ;;
  goose)
    if [[ ! -x "$(command -v goose 2>/dev/null || true)" ]]; then
      note 'Goose is not installed correctly in this image.'
      exec /bin/bash -il
    fi
    if [[ ! -f "${HOME}/.config/goose/config.yaml" ]]; then
      note 'Goose needs first-run provider setup. Starting `goose configure` now.'
      exec goose configure
    fi
    exec goose
    ;;
  aider) exec aider ;;
  github-copilot-cli) exec copilot ;;
  droid) exec droid ;;
  amp) exec amp ;;
  plandex) exec plandex ;;
  cn) exec cn ;;
  kiro) exec kiro-cli ;;
  junie)
    if ! junie --version >/dev/null 2>&1; then
      note 'Junie is installed in the image, but its upstream bootstrap is still failing on this Linux container. SafeMode is leaving you in a shell instead of opening a broken session.'
      exec /bin/bash -il
    fi
    if [[ ! -d "${HOME}/.junie" ]]; then
      note 'Junie first-run auth lives under `/account`. You can sign in with your JetBrains account, use `JUNIE_API_KEY`, or bring your own model keys.'
    fi
    exec junie
    ;;
  letta) exec letta ;;
  iflow) exec iflow ;;
  qoder) exec qodercli ;;
  coderabbit)
    if coderabbit_needs_login; then
      note 'CodeRabbit needs first-run login. Starting `coderabbit auth login` now.'
      exec coderabbit auth login
    fi
    exec coderabbit review --interactive
    ;;
  *)
    printf 'Unsupported CLI tool: %s\n\n' "$TOOL" >&2
    printf 'Supported tools: shell tmux cue agents opencode grok t3 kilo claude gemini qwen codex crush openclaw cline-cli forge goose aider github-copilot-cli droid amp plandex cn kiro junie letta iflow qoder coderabbit\n' >&2
    exit 64
    ;;
esac
