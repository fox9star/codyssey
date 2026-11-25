#!/usr/bin/env python3
"""
Codyssey Mission 1 - Bonus Task Companion API Service
Provides a lightweight JSON status/counter API for multi-container Docker Compose verification.
"""
import json
import os
import socket
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(os.environ.get("API_PORT", "5000"))
APP_ENV = os.environ.get("APP_ENV", "compose-production")
DATA_FILE = os.environ.get("DATA_FILE", "/data/requests.log")


class StatusHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        os.makedirs(os.path.dirname(DATA_FILE), exist_ok=True)
        now = datetime.now(timezone.utc).isoformat()
        with open(DATA_FILE, "a", encoding="utf-8") as f:
            f.write(f"{now} GET {self.path} from {self.client_address[0]}\n")
        with open(DATA_FILE, "r", encoding="utf-8") as f:
            count = sum(1 for _ in f)

        payload = {
            "service": "codyssey-companion-api",
            "status": "healthy",
            "hostname": socket.gethostname(),
            "env": APP_ENV,
            "port": PORT,
            "persisted_request_count": count,
            "timestamp_utc": now,
        }
        body = (json.dumps(payload, ensure_ascii=False) + "\n").encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        print(f"[API] {self.address_string()} - {fmt % args}", flush=True)


if __name__ == "__main__":
    print(f"Starting Codyssey Companion API on 0.0.0.0:{PORT} (env={APP_ENV})", flush=True)
    server = HTTPServer(("0.0.0.0", PORT), StatusHandler)
    server.serve_forever()
