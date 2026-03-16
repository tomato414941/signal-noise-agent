#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$SCRIPT_DIR/logs" "$SCRIPT_DIR/workspace"

while true; do
  source "$SCRIPT_DIR/config.sh"
  bash "$SCRIPT_DIR/session.sh"
  sleep "${SLEEP_INTERVAL:-14400}"
done
