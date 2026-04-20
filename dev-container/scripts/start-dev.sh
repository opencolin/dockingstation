#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
#  Optional nginx basic auth
# ------------------------------------------------------------------
AUTH_CONFIG=""
if [[ "${NO_AUTH:-}" != "1" ]]; then
  if [[ -z "${DEV_PASSWORD:-}" ]]; then
    echo "Error: DEV_PASSWORD environment variable not set"
    echo "Usage: docker run -e DEV_PASSWORD=yourpassword ..."
    echo "Or disable auth with: docker run -e NO_AUTH=1 ..."
    exit 1
  fi

  HTPASSWD_FILE=/etc/nginx/.htpasswd
  mkdir -p "$(dirname "$HTPASSWD_FILE")"
  printf 'devuser:%s\n' "$(openssl passwd -apr1 "$DEV_PASSWORD")" > "$HTPASSWD_FILE"
  AUTH_CONFIG='
    auth_basic "SafeMode";
    auth_basic_user_file /etc/nginx/.htpasswd;
'
fi

cat > /etc/nginx/sites-enabled/default <<'NGINX'
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen 80;
    server_name _;

__AUTH_CONFIG__

    # Dashboard (landing page)
    location / {
        root /opt/dashboard;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # API – tools manifest (JSON)
    location /api/ {
        root /opt/dashboard;
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
        add_header Cache-Control "no-cache";
    }

    # code-server (VS Code Web)
    location /code-server/ {
        proxy_pass http://127.0.0.1:8080/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
    }

    # file browser
    location /files/ {
        proxy_pass http://127.0.0.1:8443/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
    }

    # browser terminal for CLI tools
    location /terminal/ {
        proxy_pass http://127.0.0.1:7681/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
        proxy_buffering off;
    }

    # T3 pairing-link launcher
    location /t3-launch {
        proxy_pass http://127.0.0.1:3774/launch;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # SafeMode alternate frontend
    location /safemode/ {
        root /opt;
        try_files $uri $uri/ /safemode/index.html;
    }
}
NGINX

python3 - "$AUTH_CONFIG" <<'PY'
from pathlib import Path
import sys

config = Path("/etc/nginx/sites-enabled/default")
config.write_text(config.read_text().replace("__AUTH_CONFIG__", sys.argv[1]))
PY

# ------------------------------------------------------------------
#  Optional persistent workspace/home storage
# ------------------------------------------------------------------
PERSIST_ROOT="${PERSIST_ROOT:-/persist}"
if [[ -d "$PERSIST_ROOT" ]]; then
  PERSIST_WORKSPACE="$PERSIST_ROOT/workspace"
  PERSIST_HOME_SLICE_ROOT="$PERSIST_ROOT/home"
  chmod a+rx "$PERSIST_ROOT"
  mkdir -p "$PERSIST_WORKSPACE"
  chown -R devuser:devuser "$PERSIST_WORKSPACE"
  chmod -R a+rwX "$PERSIST_WORKSPACE"

  cd /
  rm -rf /workspace
  ln -s "$PERSIST_WORKSPACE" /workspace

  persist_home_path() {
    local rel_path="$1"
    local path_kind="$2"
    local live_path="/home/devuser/${rel_path}"
    local persist_path="${PERSIST_HOME_SLICE_ROOT}/${rel_path}"

    mkdir -p "$(dirname "$persist_path")"

    if [[ -e "$live_path" && ! -e "$persist_path" ]]; then
      cp -a "$live_path" "$persist_path"
    fi

    rm -rf "$live_path"

    if [[ "$path_kind" == "dir" ]]; then
      mkdir -p "$persist_path"
    fi

    ln -s "$persist_path" "$live_path"
  }

  mkdir -p "$PERSIST_HOME_SLICE_ROOT"
  chmod a+rx "$PERSIST_HOME_SLICE_ROOT"

  persist_home_path ".ssh" dir
  persist_home_path ".gitconfig" file
  persist_home_path ".npmrc" file
  persist_home_path ".config/gh" dir
  persist_home_path ".config/goose" dir
  persist_home_path ".config/opencode" dir
  persist_home_path ".claude" dir
  persist_home_path ".codex" dir
  persist_home_path ".gemini" dir

  chown -R devuser:devuser "$PERSIST_HOME_SLICE_ROOT"
  chmod -R a+rwX "$PERSIST_HOME_SLICE_ROOT"
fi

# ------------------------------------------------------------------
#  Ensure workspace ownership
# ------------------------------------------------------------------
chown -h devuser:devuser /workspace
if [[ -d /workspace && ! -L /workspace ]]; then
  chown -R devuser:devuser /workspace
fi

# ------------------------------------------------------------------
#  Hand off to supervisord (manages all services)
# ------------------------------------------------------------------
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
