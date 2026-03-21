#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$SCRIPT_DIR/workspace"

source "$SCRIPT_DIR/config.sh"

# Pre-session: capture health snapshot
mkdir -p "$WORKSPACE/snapshots"
curl -s "http://127.0.0.1:8000/health/signals" > "$WORKSPACE/snapshots/health-$(date +%Y%m%d-%H%M%S).json" 2>/dev/null || true

# Expander first, then Operator
bash "$SCRIPT_DIR/run-expander.sh"
bash "$SCRIPT_DIR/run-operator.sh"

# Clean old snapshots (keep last 50)
ls -t "$WORKSPACE/snapshots/"health-*.json 2>/dev/null | tail -n +51 | xargs rm -f 2>/dev/null
