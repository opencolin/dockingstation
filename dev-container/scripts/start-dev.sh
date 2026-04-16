#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
#  DEV_PASSWORD – password for HTTP basic auth (username: devuser)
# ------------------------------------------------------------------
if [[ -z "${DEV_PASSWORD:-}" ]]; then
  echo "Error: DEV_PASSWORD environment variable not set"
  echo "Usage: docker run -e DEV_PASSWORD=yourpassword ..."
  exit 1
fi

# ------------------------------------------------------------------
#  Configure nginx basic auth
# ------------------------------------------------------------------
HTPASSWD_FILE=/etc/nginx/.htpasswd
mkdir -p "$(dirname "$HTPASSWD_FILE")"
printf 'devuser:%s\n' "$(openssl passwd -apr1 "$DEV_PASSWORD")" > "$HTPASSWD_FILE"

cat > /etc/nginx/sites-enabled/default <<'NGINX'
server {
    listen 80;
    server_name _;

    auth_basic "Docking Station";
    auth_basic_user_file /etc/nginx/.htpasswd;

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
}
NGINX

# ------------------------------------------------------------------
#  Ensure workspace ownership
# ------------------------------------------------------------------
chown -R devuser:devuser /workspace

# ------------------------------------------------------------------
#  Hand off to supervisord (manages all services)
# ------------------------------------------------------------------
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
