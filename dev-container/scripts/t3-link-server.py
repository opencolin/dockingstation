#!/usr/bin/env python3
import http.server
import os
import re
import socket
import socketserver
import subprocess
import time
import urllib.request


T3_BASE_URL = "http://127.0.0.1:3773"
PAIR_RE = re.compile(r"https?://\S+/pair#token=\S+")


def wait_for_t3(timeout=30.0):
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            with urllib.request.urlopen(f"{T3_BASE_URL}/", timeout=2) as response:
                if response.status < 500:
                    return True
        except Exception:
            time.sleep(1)
    return False


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/launch":
            self.send_error(404)
            return

        if not wait_for_t3():
            self.send_error(503, "T3 Code is not ready")
            return

        host = self.headers.get("x-forwarded-host") or self.headers.get("host") or "localhost"
        proto = self.headers.get("x-forwarded-proto") or "http"
        base_host = host.rsplit(":", 1)[0] if ":" in host and "]" not in host else host
        base_url = f"{proto}://{base_host}:3773"

        env = os.environ.copy()
        env["HOME"] = env.get("HOME", "/home/devuser")

        result = subprocess.run(
            ["t3", "auth", "pairing", "create", "--base-url", base_url],
            cwd="/workspace",
            env=env,
            capture_output=True,
            text=True,
            timeout=20,
        )

        output = f"{result.stdout}\n{result.stderr}"
        match = PAIR_RE.search(output)
        if result.returncode != 0 or not match:
            self.send_error(502, "Failed to create T3 pairing link")
            return

        self.send_response(302)
        self.send_header("Location", match.group(0))
        self.end_headers()

    def log_message(self, format, *args):
        return


with socketserver.TCPServer(("0.0.0.0", 3774), Handler) as httpd:
    httpd.serve_forever()
