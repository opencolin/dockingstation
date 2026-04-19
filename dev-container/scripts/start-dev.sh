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
    auth_basic "Docking Station";
    auth_basic_user_file /etc/nginx/.htpasswd;
'
fi

cat > /etc/nginx/sites-enabled/default <<'NGINX'
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

    # noVNC desktop
    location /desktop/ {
        proxy_pass http://127.0.0.1:6080/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }

    # code-server (VS Code Web)
    location /code-server/ {
        proxy_pass http://127.0.0.1:8080/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }

    # file browser
    location /files/ {
        proxy_pass http://127.0.0.1:8443/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }

    # browser terminal for CLI tools
    location /terminal/ {
        proxy_pass http://127.0.0.1:7681/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
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
#  Ensure workspace ownership
# ------------------------------------------------------------------
chown -R devuser:devuser /workspace

# ------------------------------------------------------------------
#  Hand off to supervisord (manages all services)
# ------------------------------------------------------------------
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
