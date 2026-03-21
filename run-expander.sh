#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
source ~/.secrets/openai 2>/dev/null || true

LOGDIR="$SCRIPT_DIR/logs"
WORKSPACE="$SCRIPT_DIR/workspace"
MARKER_FILE="$WORKSPACE/.session_complete"
mkdir -p "$LOGDIR" "$WORKSPACE/human" "$WORKSPACE/memory"
cd "$WORKSPACE"

LOG="$LOGDIR/$(date +%Y%m%d_%H%M%S)_expander.log"
rm -f "$MARKER_FILE"
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) expander_start" >> "$LOGDIR/sessions.log"

timeout "${EXPANDER_TIMEOUT:-${TIMEOUT:-30}}m" codex exec \
  -m "${MODEL:-gpt-5.4}" \
  -c model_reasoning_effort="${REASONING_EFFORT:-high}" \
  --dangerously-bypass-approvals-and-sandbox \
  --skip-git-repo-check \
  --json \
  "$(cat "$SCRIPT_DIR/EXPANDER_PROMPT.md")" > "$LOG" 2>"$LOG.err" &
PID=$!

while kill -0 $PID 2>/dev/null; do
  [ -f "$MARKER_FILE" ] && { sleep 5; kill $PID 2>/dev/null; break; }
  sleep 10
done
wait $PID 2>/dev/null
EXIT=$?

echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) expander_exit code=$EXIT" >> "$LOGDIR/sessions.log"
rm -f "$MARKER_FILE"
exit $EXIT
