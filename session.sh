#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGDIR="$SCRIPT_DIR/logs"
WORKSPACE="$SCRIPT_DIR/workspace"
SESSIONS_LOG="$LOGDIR/sessions.log"
MARKER_FILE="$WORKSPACE/.session_complete"

source "$SCRIPT_DIR/config.sh"
source ~/.secrets/openai 2>/dev/null || true

mkdir -p "$WORKSPACE/memory/archive" "$WORKSPACE/human" "$WORKSPACE/snapshots"
cd "$WORKSPACE"

# Seed a dedicated working copy on first run.
if [ ! -d "$WORKSPACE/signal-noise/.git" ]; then
  git clone /home/dev/projects/signal-noise "$WORKSPACE/signal-noise" >/dev/null 2>&1 || true
fi

# Pre-session: capture health snapshot
SNAPSHOT="$WORKSPACE/snapshots/health-$(date +%Y%m%d-%H%M%S).json"
curl -s "http://127.0.0.1:8000/health/signals" > "$SNAPSHOT" 2>/dev/null || true

# Sync working copy
if [ -d "$WORKSPACE/signal-noise" ]; then
  (cd "$WORKSPACE/signal-noise" && git pull -q 2>/dev/null) || true
fi

LOG="$LOGDIR/$(date +%Y%m%d_%H%M%S).log"
rm -f "$MARKER_FILE"
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) session_start" >> "$SESSIONS_LOG"

timeout "${TIMEOUT:-30}m" codex exec \
  --dangerously-bypass-approvals-and-sandbox \
  --skip-git-repo-check \
  --json \
  "$(cat "$SCRIPT_DIR/AGENT_PROMPT.md")" > "$LOG" 2>"$LOG.err" &
AGENT_PID=$!

while kill -0 $AGENT_PID 2>/dev/null; do
  if [ -f "$MARKER_FILE" ]; then
    sleep 5
    kill $AGENT_PID 2>/dev/null
    break
  fi
  sleep 10
done
wait $AGENT_PID 2>/dev/null
EXIT_STATUS=$?

# Clean old snapshots (keep last 50)
ls -t "$WORKSPACE/snapshots/"health-*.json 2>/dev/null | tail -n +51 | xargs rm -f 2>/dev/null

echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) codex_exit code=$EXIT_STATUS size=$(wc -c < "$LOG")" >> "$SESSIONS_LOG"
rm -f "$MARKER_FILE"
