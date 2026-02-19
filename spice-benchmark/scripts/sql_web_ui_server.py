#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError
import os

BASE_DIR = Path(__file__).resolve().parent.parent
UI_PATH = BASE_DIR / "sql-web-ui.html"
SPICE_SQL_URL = os.environ.get("SPICE_SQL_URL", "http://localhost:8090/v1/sql")
HOST = os.environ.get("HOST", "0.0.0.0")
PORT = int(os.environ.get("PORT", "8088"))


class Handler(BaseHTTPRequestHandler):
    def _send(self, status, body: bytes, content_type="text/plain; charset=utf-8"):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path in ("/", "/sql-web-ui.html"):
            if not UI_PATH.exists():
                self._send(404, b"sql-web-ui.html no encontrado")
                return
            self._send(200, UI_PATH.read_bytes(), "text/html; charset=utf-8")
            return
        self._send(404, b"Not Found")

    def do_POST(self):
        if self.path != "/sql":
            self._send(404, b"Not Found")
            return

        length = int(self.headers.get("Content-Length", "0"))
        body = self.rfile.read(length)
        req = Request(
            SPICE_SQL_URL,
            data=body,
            method="POST",
            headers={"Content-Type": "text/plain"},
        )
        try:
            with urlopen(req, timeout=30) as resp:
                payload = resp.read()
                ctype = resp.headers.get("Content-Type", "application/json")
                self._send(resp.status, payload, ctype)
        except HTTPError as e:
            payload = e.read() if hasattr(e, "read") else str(e).encode("utf-8")
            self._send(e.code, payload)
        except URLError as e:
            self._send(502, f"No se pudo contactar Spice en {SPICE_SQL_URL}: {e}".encode("utf-8"))


if __name__ == "__main__":
    server = HTTPServer((HOST, PORT), Handler)
    print(f"Abre en tu navegador: http://localhost:{PORT}/sql-web-ui.html")
    print(f"Proxy SQL -> {SPICE_SQL_URL}")
    server.serve_forever()
