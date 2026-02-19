#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
exec python3 ./sql_web_ui_server.py
