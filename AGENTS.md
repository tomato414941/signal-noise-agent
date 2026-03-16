# signal-noise-gardener

Autonomous maintenance agent for the signal-noise data collection service.

## Overview

- Runs on the signal-noise VPS (co-located with the service)
- Uses Codex CLI as the AI engine
- 4-hour session interval, 30-minute timeout per session
- One task per session (atomic commits)

## Architecture

Shell loop pattern: `run.sh` → `session.sh` → `codex exec AGENT_PROMPT.md`

Agent pushes to signal-noise repo on GitHub. Deployment is separate (human or automation).

## Files

| File | Purpose |
|------|---------|
| `run.sh` | Infinite loop runner |
| `session.sh` | Per-session: snapshot → codex → log |
| `config.sh` | Hot-reloadable parameters |
| `AGENT_PROMPT.md` | Agent system prompt |
| `workspace/STATUS.md` | Working memory (overwrite) |
| `workspace/memory/learnings.md` | Semantic memory (prepend) |
| `workspace/human/requests.md` | Agent → human |
| `workspace/human/messages.md` | Human → agent |

## Operations

```bash
# Manual single session
bash session.sh

# Start loop
nohup bash run.sh &

# Check status
cat workspace/STATUS.md

# Send instruction to agent
echo "Fix the gdelt_tone_* collectors" >> workspace/human/messages.md

# Check agent requests
cat workspace/human/requests.md
```
