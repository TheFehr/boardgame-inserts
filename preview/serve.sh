#!/usr/bin/env bash
# Serves the live preview on the LAN (0.0.0.0:8000).
cd "$(dirname "$0")/site" && exec python3 -m http.server 8000 --bind 0.0.0.0
