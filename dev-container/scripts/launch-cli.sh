#!/usr/bin/env bash
set -euo pipefail

TOOL="${1:-shell}"

cd /workspace

case "$TOOL" in
  shell) exec /bin/bash -il ;;
  agents) exec /usr/local/bin/launch-agents.sh ;;
  opencode) exec opencode ;;
  grok) exec grok ;;
  t3) exec t3 ;;
  kilo) exec kilo ;;
  claude) exec claude ;;
  gemini) exec gemini ;;
  qwen) exec qwen ;;
  codex) exec codex ;;
  crush) exec crush ;;
  openclaw) exec openclaw ;;
  cline-cli) exec cline-cli ;;
  forge) exec forge ;;
  goose) exec goose ;;
  aider) exec aider ;;
  github-copilot-cli) exec copilot ;;
  droid) exec droid ;;
  amp) exec amp ;;
  plandex) exec plandex ;;
  cn) exec cn ;;
  kiro) exec kiro-cli ;;
  junie) exec junie ;;
  letta) exec letta ;;
  iflow) exec iflow ;;
  qoder) exec qodercli ;;
  coderabbit) exec coderabbit ;;
  *)
    printf 'Unsupported CLI tool: %s\n\n' "$TOOL" >&2
    printf 'Supported tools: shell agents opencode grok t3 kilo claude gemini qwen codex crush openclaw cline-cli forge goose aider github-copilot-cli droid amp plandex cn kiro junie letta iflow qoder coderabbit\n' >&2
    exit 64
    ;;
esac
